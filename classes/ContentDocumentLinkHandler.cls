public class ContentDocumentLinkHandler{
    
    public static void contentDocumentLinkHandlerAfterInsert(List<ContentDocumentLink> listOfContentDocumentLink){
        
        if(!listOfContentDocumentLink.isEmpty()){
            ContentDocumentLink billingContentDocumentLinkObj = null;
            for(ContentDocumentLink contentDocumentLinkObj:listOfContentDocumentLink){
                if((contentDocumentLinkObj.LinkedEntityId.getSObjectType().getDescribe().getName()).equalsIgnoreCase('AcctSeed__Billing__c')){
                    billingContentDocumentLinkObj = new ContentDocumentLink();
                    billingContentDocumentLinkObj = contentDocumentLinkObj;
                    break;
                }
            }

            if(billingContentDocumentLinkObj!=null){
                List<ContentVersion> listOfContentVersion = [Select id,versiondata,title,filetype,contentDocumentId from contentVersion where contentDocumentId=:billingContentDocumentLinkObj.ContentDocumentId limit 1];
                List<AcctSeed__Billing__c> listOfBilling = [Select id,Name,AcctSeed__Opportunity__c,AcctSeed__Opportunity__r.AccountId,AcctSeed__Opportunity__r.Account.Name,AcctSeed__Opportunity__r.Name,AcctSeed__Opportunity__r.Delivery_Type__c,AcctSeed__Date__c,AcctSeed__Opportunity__r.Account.Customer_Number__c,AcctSeed__Opportunity__r.Account.RecordType.DeveloperName from AcctSeed__Billing__c where Id=:billingContentDocumentLinkObj.LinkedEntityId limit 1];
                
                if(listOfContentVersion!=null && listOfContentVersion.size()>0 && listOfBilling!=null && listOfBilling.size()>0){
                    moveFileToBoxFolder(JSON.serialize(listOfBilling[0]),listOfContentVersion[0].versiondata,(listOfBilling[0].Name+'_'+listOfBilling[0].AcctSeed__Opportunity__r.Account.Name+'.'+listOfContentVersion[0].filetype),listOfContentVersion[0].id,listOfBilling[0].Id,listOfBilling[0].AcctSeed__Opportunity__r.AccountId,listOfBilling[0].AcctSeed__Opportunity__c);
                }
            }
        }
    }

    @future(callout=true)
    private static void moveFileToBoxFolder(String billingRecordString,Blob versiondata,String fileName,Id parentRecordId,Id billingRecordId,Id accountId,Id opportunityId){
        Attachment attachmentRecord = new Attachment(Body=versiondata,Name=fileName,isPrivate=false,parentId=parentRecordId);
        box.Toolkit boxToolkit = new box.Toolkit();
        String billingFolderId = boxToolkit.getFolderIdByRecordId(billingRecordId);
        String accountFolderId = !Test.isRunningTest()?boxToolkit.getFolderIdByRecordId(accountId):'678901';
        AcctSeed__Billing__c billingUpdate = null;
        box__FRUP__c frupInsert = null;
        box__folder_meta__c  folderMetadata = null;
        system.debug('billingFolderId: '+billingFolderId);
        if(String.isBlank(billingFolderId)){
            billingFolderId = !Test.isRunningTest()?boxToolkit.createFolderForRecordId(billingRecordId, fileName.subStringBefore('_'), true):'1111';
            String opportunityFolderId = boxToolkit.getFolderIdByRecordId(opportunityId);
            String boxInvoiceFolderId = GetOpportunityInvoiceFolderIDForBilling.fetchInvoiceBoxFolderId(opportunityFolderId);
            system.debug('billingFolderId: '+billingFolderId+'---boxInvoiceFolderId:'+boxInvoiceFolderId);
            Boolean moved = boxToolkit.moveFolder(billingFolderId,boxInvoiceFolderId,null);
            system.debug('moved: '+moved);
            if(moved){
                frupInsert = new box__FRUP__c(box__Folder_ID__c=billingFolderId,box__Object_Name__c ='AcctSeed__Billing__c',box__Permission__c='Read/Write',box__Record_ID__c=billingRecordId); 
                folderMetadata = new box__folder_meta__c(box__Folder_Id__c=billingFolderId,box__Folder_Name__c=fileName.subStringBefore('_'),box__Folder_Share_Link__c=('https://maestrotradexpvtltd.app.box.com/embed/folder/'+billingFolderId));
            }
        }

        if(String.isNotBlank(billingFolderId) && String.isNotBlank(accountFolderId)){
            set<String> setOfString = new set<String>{billingFolderId,accountFolderId};
            String isOpportunityInoviceGenerated = '';
            for(String boxFolderId:setOfString){
                
                String updatedBoxInvoiceFolderId = (billingFolderId!=boxFolderId)?'':billingFolderId;
                system.debug('boxInvoiceFolderId: '+updatedBoxInvoiceFolderId);
                if(String.isBlank(updatedBoxInvoiceFolderId)){
                    String endpoint = 'https://api.box.com/2.0/folders/'+boxFolderId+'/items';
                    HttpRequest request = new HttpRequest();
                    request.setMethod('GET');
                    request.setEndpoint(endpoint);
                    HttpResponse response = Test.isRunningTest()?null:boxToolkit.sendRequest(request);

                    if(Test.isRunningTest() || (response!=null && response.getBody()!=null && response.getStatusCode()==200)){
                        String responseBody = !Test.isRunningTest()?response.getBody():'{"total_count":5,"entries":[{"type":"folder","id":"2","sequence_id":"0","etag":"0","name":"Invoices"}],"offset":0,"limit":100,"order":[{"by":"type","direction":"ASC"},{"by":"name","direction":"ASC"}]}';
                        Map<String, Object> untypedTokenResponse = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
                        if(untypedTokenResponse!=null){
                            //get all entries from template folder
                            List<Object> listOfAllRelatedObject = (List<Object>)untypedTokenResponse.get('entries');
                            //iterate over all template folder and fetch folder id
                            for(object innerObject:listOfAllRelatedObject){
                                Map<String, Object> mapOfInnerJSONAndValue = (Map<String, Object>)innerObject;
                                if(mapOfInnerJSONAndValue!=null && mapOfInnerJSONAndValue.containsKey('name') && String.valueOf(mapOfInnerJSONAndValue.get('name')).equalsIgnoreCase('Invoices')){
                                    updatedBoxInvoiceFolderId = String.valueOf(mapOfInnerJSONAndValue.get('id'));
                                    break;
                                }
                            }
                        }
                    }
                }

                if(String.isNotBlank(updatedBoxInvoiceFolderId)){
                    String fileId = !Test.isRunningTest()?boxToolkit.createFileFromAttachment(attachmentRecord,fileName ,updatedBoxInvoiceFolderId, null):'22222';
                    if(Test.isRunningTest() || (String.isBlank(fileId) && boxToolkit.mostRecentError!=null && boxToolkit.mostRecentError.equalsIgnoreCase('Unable to create a file on Box.'))){
                        String endpoint = 'https://api.box.com/2.0/folders/'+updatedBoxInvoiceFolderId+'/items';
                        HttpRequest request = new HttpRequest();
                        request.setMethod('GET');
                        request.setEndpoint(endpoint);
                        HttpResponse response = Test.isRunningTest()?null:boxToolkit.sendRequest(request);
                        
                        if(Test.isRunningTest() || (response.getBody()!=null && response.getStatusCode()==200)){
                            String responseBody = Test.isRunningTest()?'{"total_count":5,"entries":[{"type":"folder","id":"1","sequence_id":"1","etag":"0","name":"'+fileName+'"}],"offset":0,"limit":100,"order":[{"by":"type","direction":"ASC"},{"by":"name","direction":"ASC"}]}':response.getBody();
                            Map<String, Object> untypedTokenResponse = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
                            if(untypedTokenResponse!=null){
                                List<object> listOfAllRelatedObject = (List<Object>)untypedTokenResponse.get('entries');
                                String existingFileId = '';
                                for(object innerObject:listOfAllRelatedObject){
                                    Map<String, Object> mapOfInnerJSONAndValue = (Map<String, Object>)innerObject;
                                    if(mapOfInnerJSONAndValue!=null && mapOfInnerJSONAndValue.containsKey('name') && String.valueOf(mapOfInnerJSONAndValue.get('name')).equalsIgnoreCase(fileName)){
                                        existingFileId = String.valueOf(mapOfInnerJSONAndValue.get('id'));
                                        break;
                                    }
                                }

                                if(String.isNotBlank(existingFileId)){
                                    endpoint = 'https://api.box.com/2.0/files/'+existingFileId;
                                    HttpRequest updateFileRequest = new HttpRequest();
                                    updateFileRequest.setMethod('DELETE');
                                    updateFileRequest.setEndpoint(endpoint);
                                    HttpResponse updateFileResponse = Test.isRunningTest()?null:boxToolkit.sendRequest(updateFileRequest);
                                    if(Test.isRunningTest() || (updateFileResponse.getBody()!=null && updateFileResponse.getStatusCode()==204)){
                                        fileId = Test.isRunningTest()?'234565':boxToolkit.createFileFromAttachment(attachmentRecord,fileName ,updatedBoxInvoiceFolderId, null);
                                    }
                                }
                            }
                        }
                        
                    }
                    if(String.isNotBlank(fileId)){
                        sobject objectRecord = (sobject)JSON.deserialize(billingRecordString,sobject.class);
                        SalesforceBoxMetadataUtilityClass.prepareBoxMetadata(fileId,objectRecord,'AcctSeed__Billing__c');
                        if(billingFolderId==boxFolderId){
                            billingUpdate = new AcctSeed__Billing__c();
                            billingUpdate.Id = String.valueOf(objectRecord.get('Id'));
                            billingUpdate.Opportunity_Invoice_Link__c = 'https://maestrotradexpvtltd.app.box.com/file/'+fileId;
                        }
                    }
                }
            }

            if(frupInsert!=null && folderMetadata!=null){
                insert frupInsert;
                insert folderMetadata;
            }
            
            if(billingUpdate!=null){
                update billingUpdate;
            }
            
        }
    }

}