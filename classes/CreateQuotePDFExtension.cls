public class CreateQuotePDFExtension{
    
    public PDFWrapperClass pdfWrapperObject{get;set;}
    
    public void createPDFContent(){
        pdfWrapperObject = new PDFWrapperClass();
        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('Id'))){
            List<PDF_Configuration_Mapping__mdt> pdfConfigurationMappingObject = [Select id,Bank_Information__c,Footer_Information__c,Header_Information__c,Object_API_Name__c from PDF_Configuration_Mapping__mdt where Object_API_Name__c=:ID.valueOf(ApexPages.currentPage().getParameters().get('Id')).getSObjectType().getDescribe().getName() AND isActive__c=true limit 1];
            
            if(pdfConfigurationMappingObject!=null){
                List<Quote> listOfQuoteRecords = [SELECT AccountId,OpportunityId,Account.Name,Account.Customer_Number__c,Account.RecordType.DeveloperName,Opportunity.Name,Bill_to_Adddress__c,Opportunity.Delivery_Type__c,Quote_Number__c,Bill_to_Adddress__r.Account__r.Name,Bill_to_Adddress__r.Billing_City__c,Bill_to_Adddress__r.Billing_Country__c,Bill_to_Adddress__r.Billing_State_Province__c,Bill_to_Adddress__r.Billing_Street__c,Bill_to_Adddress__r.Billing_Zip_Postal_Code__c,Bill_to_Adddress__r.Shipping_City__c,Bill_to_Adddress__r.Shipping_Country__c,Bill_to_Adddress__r.Shipping_State_Province__c,Bill_to_Adddress__r.Shipping_Street__c,Bill_to_Adddress__r.Shipping_Zip_Postal_Code__c,Comments_for_the_Customer__c,ContactId,Contact.Name,Contact.Phone,Contact.Email,Customer_Number__c,Delivery_Type__c,Description,Discount__c,Freight_charges__c,GrandTotal,Grand_Total_wo_Settlement__c,Grand_Total__c,Id,LiftGate_Requirement__c,Lift_Gate_Charges__c,Name,ExpirationDate,Other_Charges__c,PaymentTerms__c,Pickup_Fitment_Address_New__c,Pickup_Fitment_Address_New__r.Name,Pickup_Fitment_Address_New__r.Street__c,Pickup_Fitment_Address_New__r.State__c,Pickup_Fitment_Address_New__r.Country__c,Pickup_Fitment_Address_New__r.City__c,Pickup_Fitment_Address_New__r.Avalara_Location_Code__c,Pickup_Fitment_Address_New__r.Zip_Code__c,QuoteNumber,Quote_Date__c,Quote_Type__c,Receiver_Contact_Name__c,Receiver_Contact_Number__c,RecordType.DeveloperName,Sales_Tax__c,Settlement_Discount__c,Shipping_Charges__c,Ship_From_Address__c,Ship_From_Address__r.Name,Ship_From_Address__r.Street__c,Ship_From_Address__r.State__c,Ship_From_Address__r.Country__c,Ship_From_Address__r.City__c,Ship_From_Address__r.Avalara_Location_Code__c,Ship_From_Address__r.Zip_Code__c,Ship_to_Address__r.Account__r.Name,Ship_to_Address__r.Billing_City__c,Ship_to_Address__r.Billing_Country__c,Ship_to_Address__r.Billing_State_Province__c,Ship_to_Address__c,Ship_to_Address__r.Billing_Street__c,Ship_to_Address__r.Billing_Zip_Postal_Code__c,Ship_to_Address__r.Shipping_City__c,Ship_to_Address__r.Shipping_Country__c,Ship_to_Address__r.Shipping_State_Province__c,Ship_to_Address__r.Shipping_Street__c,Ship_to_Address__r.Shipping_Zip_Postal_Code__c,State_Fees__c,Status,Subtotal,SystemModstamp,Tax,Terms_Conditions__c,TotalPrice,Total_FET_Amount__c,Total_Price__c,Total_Product_Amount__c,Total_Quantity__c,Total_State_Fee__c,Valid_Untill__c,Warehouse_Location__c,Warehouse_Location__r.Name,Warehouse_Location__r.Street__c,Warehouse_Location__r.State__c,Warehouse_Location__r.Country__c,Warehouse_Location__r.City__c,Warehouse_Location__r.Avalara_Location_Code__c,Warehouse_Location__r.Zip_Code__c,Warranty_Information__c,Weight__c,(select id,QuoteId,Product_SKU__c,Line_Item_Description__c,Quantity,UnitPrice,TotalPrice,ProductName__c,Product2Id,Product2.Product_Category__c,Group__c,Tax_Amount__c from QuoteLineItems where QuoteId=:ApexPages.currentPage().getParameters().get('Id') order by createddate asc) FROM Quote where Id=:ApexPages.currentPage().getParameters().get('Id') limit 1];
                pdfWrapperObject.isDoorDelivery = listOfQuoteRecords[0].RecordType.DeveloperName.equalsIgnoreCase('WalkIn_Door_delivery_process')?true:false;
                pdfWrapperObject.isLiftGateCharge = (String.isNotBlank(listOfQuoteRecords[0].LiftGate_Requirement__c) && listOfQuoteRecords[0].LiftGate_Requirement__c.equalsIgnoreCase('Yes'))?true:false;
                //header infromation
                HeaderWrapperClass headerWrapperClassObject = new HeaderWrapperClass();
                headerWrapperClassObject.billDate = listOfQuoteRecords[0].Quote_Date__c!=null?(listOfQuoteRecords[0].Quote_Date__c.month()+'/'+listOfQuoteRecords[0].Quote_Date__c.day()+'/'+listOfQuoteRecords[0].Quote_Date__c.year()):'';
                headerWrapperClassObject.validUntilDate = listOfQuoteRecords[0].ExpirationDate!=null?(listOfQuoteRecords[0].ExpirationDate.month()+'/'+listOfQuoteRecords[0].ExpirationDate.day()+'/'+listOfQuoteRecords[0].ExpirationDate.year()):'';
                headerWrapperClassObject.mainHeader = pdfConfigurationMappingObject[0].Header_Information__c;
                pdfWrapperObject.headerWrapper = headerWrapperClassObject;

                //body information
                BodyWrapperClass bodyWrapperClassObject = new BodyWrapperClass();
                bodyWrapperClassObject.billToAddress = listOfQuoteRecords[0].Bill_to_Adddress__c!=null?('<b style="font-family: Arial;font-size:14px;">'+listOfQuoteRecords[0].Bill_to_Adddress__r.Account__r.Name+'</b><br/>'+listOfQuoteRecords[0].Bill_to_Adddress__r.Billing_Street__c+'<br/>'+listOfQuoteRecords[0].Bill_to_Adddress__r.Billing_State_Province__c+', '+listOfQuoteRecords[0].Bill_to_Adddress__r.Billing_Country__c+' '+listOfQuoteRecords[0].Bill_to_Adddress__r.Billing_Zip_Postal_Code__c+(listOfQuoteRecords[0].ContactId!=null?('<br/><b style="font-family: Arial;font-size:14px;">'+listOfQuoteRecords[0].Contact.Name+'</b> '+listOfQuoteRecords[0].Contact.Phone):'')):'';
                bodyWrapperClassObject.shipFromAddress = listOfQuoteRecords[0].Ship_From_Address__c!=null?(listOfQuoteRecords[0].Ship_From_Address__r.Street__c+'<br/>'+listOfQuoteRecords[0].Ship_From_Address__r.State__c+','+listOfQuoteRecords[0].Ship_From_Address__r.City__c+', '+listOfQuoteRecords[0].Ship_From_Address__r.Country__c+','+listOfQuoteRecords[0].Ship_From_Address__r.Zip_Code__c):'';
                bodyWrapperClassObject.deliveryAddress = listOfQuoteRecords[0].Ship_to_Address__c!=null?(listOfQuoteRecords[0].Ship_to_Address__r.Shipping_Street__c+'<br/>'+listOfQuoteRecords[0].Ship_to_Address__r.Shipping_State_Province__c+', '+listOfQuoteRecords[0].Ship_to_Address__r.Shipping_Country__c+' '+listOfQuoteRecords[0].Ship_to_Address__r.Shipping_Zip_Postal_Code__c):'';
                bodyWrapperClassObject.pickupAddress = listOfQuoteRecords[0].Pickup_Fitment_Address_New__c!=null?(listOfQuoteRecords[0].Pickup_Fitment_Address_New__r.Street__c+'<br/>'+listOfQuoteRecords[0].Pickup_Fitment_Address_New__r.State__c+', '+listOfQuoteRecords[0].Pickup_Fitment_Address_New__r.City__c+', '+listOfQuoteRecords[0].Pickup_Fitment_Address_New__r.Country__c+' '+listOfQuoteRecords[0].Pickup_Fitment_Address_New__r.Zip_Code__c):'';                
                List<String> listOfTableHeader = new List<String>{'PRODUCT','SKU','QUANTITY','UNIT PRICE','TOTAL'};
                
                Map<String,List<QuoteLineItem>> mapOfGroupNameAndQLI = null;
                Map<String,List<QuoteLineItem>> mapOfGroupNameAndAllQLI = null;
                Map<String,Decimal> mapOfGroupNameAndTotalPrice = new Map<String,Decimal>();
                Map<String,String> mapOfStringGroupNameAndTotalPrice = new Map<String,String>();
                Map<Id,Integer> mapOfOLIIdANDQuantity = new Map<Id,Integer>();
                Map<Id,String> mapOfOLIIdANDUnitPrice = new Map<Id,String>();
                Map<Id,String> mapOfOLIIdANDTotal = new Map<Id,String>();
                Integer totalTiresCount=0;
                Decimal subTotal = 0;
                Decimal taxAmount = 0;
                set<String> setOfProductNames = new set<String>();
                if(listOfQuoteRecords[0].QuoteLineItems.size()>0){
                    mapOfGroupNameAndAllQLI = new Map<String,List<QuoteLineItem>>(); 
                    for(QuoteLineItem lineItemObject:listOfQuoteRecords[0].QuoteLineItems){
                        List<QuoteLineItem> listOfQuoteLineItem = new List<QuoteLineItem>();
                        if(!lineItemObject.ProductName__c.contains('Misc. Charges') && !lineItemObject.ProductName__c.contains('Lift Gate Charges') && !lineItemObject.ProductName__c.contains('Freight charges')){
                            if(!lineItemObject.ProductName__c.startsWith('FET') && !lineItemObject.ProductName__c.startsWith('State Fee')){
                                String productName = lineItemObject.ProductName__c.subStringBeforeLast(' (Set');
                                setOfProductNames.add(productName); 
                            }
                            listOfQuoteLineItem.add(lineItemObject);
                        
                            if(!mapOfGroupNameAndAllQLI.isEmpty() && mapOfGroupNameAndAllQLI.containsKey(lineItemObject.Group__c)){
                                listOfQuoteLineItem.addAll(mapOfGroupNameAndAllQLI.get(lineItemObject.Group__c));
                                mapOfGroupNameAndTotalPrice.put(lineItemObject.Group__c,(lineItemObject.TotalPrice+mapOfGroupNameAndTotalPrice.get(lineItemObject.Group__c)).setScale(2, RoundingMode.CEILING));
                            }else if(mapOfGroupNameAndTotalPrice.isEmpty() || (!mapOfGroupNameAndTotalPrice.isEmpty() && !mapOfGroupNameAndTotalPrice.containsKey(lineItemObject.Group__c))){
                                mapOfGroupNameAndTotalPrice.put(lineItemObject.Group__c,lineItemObject.TotalPrice.setScale(2, RoundingMode.CEILING));
                            }
                            mapOfGroupNameAndAllQLI.put(lineItemObject.Group__c,listOfQuoteLineItem);
                            mapOfStringGroupNameAndTotalPrice.put(lineItemObject.Group__c,numberFormatConversion(mapOfGroupNameAndTotalPrice.get(lineItemObject.Group__c)));
                        }
                        mapOfOLIIdANDUnitPrice.put(lineItemObject.Id,numberFormatConversion(lineItemObject.UnitPrice));
                        mapOfOLIIdANDTotal.put(lineItemObject.Id,numberFormatConversion(lineItemObject.TotalPrice));
                        
                        if(lineItemObject.Product2Id!=null && String.isNotBlank(lineItemObject.Product2.Product_Category__c) && lineItemObject.Product2.Product_Category__c.equalsIgnoreCase('Tires')){
                            Integer productSet = (String.isNotBlank(lineItemObject.Product_SKU__c) && lineItemObject.Product_SKU__c.replaceAll(' ','').contains('-') && lineItemObject.Product_SKU__c.replaceAll(' ','').substringafter('-').isNumeric())?Integer.valueOf(lineItemObject.Product_SKU__c.replaceAll(' ','').substringafter('-')):1;
                            totalTiresCount+=(Integer.valueOf(lineItemObject.Quantity)*productSet);
                            mapOfOLIIdANDQuantity.put(lineItemObject.Id,Integer.valueOf(lineItemObject.Quantity));
                            taxAmount+=(lineItemObject.Tax_Amount__c!=null?lineItemObject.Tax_Amount__c:0);
                        }else if(lineItemObject.ProductName__c.toLowerCase().startswith('fet')){
                            taxAmount+=(lineItemObject.Tax_Amount__c!=null?lineItemObject.Tax_Amount__c:0);
                        }
                    }

                    if(!mapOfGroupNameAndAllQLI.isEmpty()){
                        mapOfGroupNameAndQLI = new Map<String,List<QuoteLineItem>>();
                        for(String groupName:mapOfGroupNameAndAllQLI.keySet()){
                            List<QuoteLineItem> listOfQuoteLineItem = mapOfGroupNameAndAllQLI.get(groupName);
                            List<QuoteLineItem> listOfUpdatedQuoteLineItem = new QuoteLineItem[100];
                            for(QuoteLineItem quoteLineItemObject:listOfQuoteLineItem){
                                if(!quoteLineItemObject.ProductName__c.toLowerCase().startsWith('fet') && !quoteLineItemObject.ProductName__c.toLowerCase().startsWith('state fee')){
                                    listOfUpdatedQuoteLineItem.add(0,quoteLineItemObject);
                                }else if(quoteLineItemObject.ProductName__c.toLowerCase().startsWith('fet')){
                                    listOfUpdatedQuoteLineItem.add(1,quoteLineItemObject);
                                }else{
                                    listOfUpdatedQuoteLineItem.add(2,quoteLineItemObject);
                                }
                            }
                            mapOfGroupNameAndQLI.put(groupName,listOfUpdatedQuoteLineItem);
                        }
                    }
                }



                bodyWrapperClassObject.mapOfGroupNameAndQLI = mapOfGroupNameAndQLI;
                bodyWrapperClassObject.mapOfStringGroupNameAndTotalPrice = mapOfStringGroupNameAndTotalPrice;
                bodyWrapperClassObject.totalTiresCount = totalTiresCount;
                bodyWrapperClassObject.totalTiresPrice = numberFormatConversion((listOfQuoteRecords[0].Total_Product_Amount__c!=null?listOfQuoteRecords[0].Total_Product_Amount__c:0.0));
                bodyWrapperClassObject.totalFeeAmount = numberFormatConversion(listOfQuoteRecords[0].Total_FET_Amount__c);
                bodyWrapperClassObject.mapOfOLIIdANDQuantity = (!mapOfOLIIdANDQuantity.isEmpty())?mapOfOLIIdANDQuantity:null;
                bodyWrapperClassObject.mapOfOLIIdANDUnitPrice = mapOfOLIIdANDUnitPrice;
                bodyWrapperClassObject.mapOfOLIIdANDTotal = mapOfOLIIdANDTotal;
                bodyWrapperClassObject.subtotal = numberFormatConversion((listOfQuoteRecords[0].Total_Product_Amount__c!=null?listOfQuoteRecords[0].Total_Product_Amount__c:0.0)+(listOfQuoteRecords[0].Total_FET_Amount__c!=null?listOfQuoteRecords[0].Total_FET_Amount__c:0.0)); 
                bodyWrapperClassObject.tax = numberFormatConversion(taxAmount);
                bodyWrapperClassObject.totalStateFee = numberFormatConversion(listOfQuoteRecords[0].Total_State_Fee__c);
                bodyWrapperClassObject.liftGateCharges = numberFormatConversion(listOfQuoteRecords[0].Lift_Gate_Charges__c);
                bodyWrapperClassObject.freightCharges = numberFormatConversion(listOfQuoteRecords[0].Freight_charges__c);
                bodyWrapperClassObject.otherCharges = numberFormatConversion(listOfQuoteRecords[0].Other_Charges__c);
                bodyWrapperClassObject.grandTotal = numberFormatConversion(listOfQuoteRecords[0].Grand_Total__c);
                pdfWrapperObject.bodyWrapper = bodyWrapperClassObject;
                pdfWrapperObject.quoteRecord = listOfQuoteRecords[0];
                FooterWrapperClass footerWrapperClassObject = new FooterWrapperClass();
                footerWrapperClassObject.bankInformation = pdfConfigurationMappingObject[0].Bank_Information__c;
                footerWrapperClassObject.extraInformation = pdfConfigurationMappingObject[0].Footer_Information__c;
                pdfWrapperObject.footerWrapper = footerWrapperClassObject;
                String fileName = listOfQuoteRecords[0].QuoteNumber+'-'+listOfQuoteRecords[0].recordType.developerName+'.pdf';
                Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename='+fileName);
                //move quote pdf file into opporunity quotes folder in box
                moveQuotePDFToBoxQuoteFolder(listOfQuoteRecords[0],setOfProductNames);
            }
        }
    }

    @testVisible
    private String numberFormatConversion(Decimal inputDecimal){
        List<String> formatArguments = new String[]{'0','number','#,##,##,##,###.0'};
        return (inputDecimal!=null?('$ '+String.format(inputDecimal.format(), formatArguments)):'$ 0');
    }
    
    @testVisible
    private void moveQuotePDFToBoxQuoteFolder(Quote quoteRecord,set<String> setOfProductNames){
        if(String.isBlank(ApexPages.currentPage().getParameters().get('savePdf'))){
            String quoteRecordString = JSON.serialize(quoteRecord);
            //move quote pdf to quote folder under opporunity in box  
            PageReference pdfObject =  Page.QuoteEstimationPDF;
            pdfObject.getParameters().put('Id',quoteRecord.Id);
            pdfObject.getParameters().put('savePdf','Yes');
            pdfObject.setRedirect(true);
			Blob pdfBlob = Test.isRunningTest()?Blob.valueOf('Test'):pdfObject.getContent();
            createFileAndMoveProductFolder(quoteRecordString,pdfBlob,quoteRecord.Quote_Number__c,(quoteRecord.Quote_Number__c+'_'+quoteRecord.Account.Name+'.pdf'),String.valueOf(quoteRecord.Id),quoteRecord.OpportunityId,quoteRecord.AccountId,setOfProductNames);
        }
    }
	
    @future(callout=true)
    private static void createFileAndMoveProductFolder(String quoteRecordString,Blob fileData,String quoteNumber,String fileName,String parentRecordId,Id opportunityRecordId,Id accountId,set<String> setOfProductNames){
        if(Test.isRunningTest()){
            setOfProductNames.add('ARISUN 295/75R22.5 AT552 - 14 PR');
        }
        Attachment attachmentRecord = new Attachment(Body=fileData,Name=fileName,isPrivate=false,parentId=parentRecordId);
        box.Toolkit boxToolkit = new box.Toolkit();
        String opportunityFolderId = Test.isRunningTest()?'1234':boxToolkit.getFolderIdByRecordId(opportunityRecordId);
        if(String.isNotBlank(opportunityFolderId)){
            String endpoint = 'https://api.box.com/2.0/folders/'+opportunityFolderId+'/items';
            HttpRequest request = new HttpRequest();
            request.setMethod('GET');
            request.setEndpoint(endpoint);
            HttpResponse response = Test.isRunningTest()?null:boxToolkit.sendRequest(request);
            if(Test.isRunningTest() || (response.getBody()!=null && response.getStatusCode()==200)){
                String responseBody = Test.isRunningTest()?'{"total_count":5,"entries":[{"type":"folder","id":"2","sequence_id":"0","etag":"0","name":"Quotes"},{"type":"folder","id":"1","sequence_id":"1","etag":"0","name":"Product Specifications"}],"offset":0,"limit":100,"order":[{"by":"type","direction":"ASC"},{"by":"name","direction":"ASC"}]}':response.getBody();
                Map<String, Object> untypedTokenResponse = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
                if(untypedTokenResponse!=null){
                    //get all entries from template folder
                    List<Object> listOfAllRelatedObject = (List<Object>)untypedTokenResponse.get('entries');
                    String quoteFolderId='';
                    String opportunityProductFolderId = '';
                    //iterate over all template folder and fetch Quotes folder id
                    for(object innerObject:listOfAllRelatedObject){
                        Map<String, Object> mapOfInnerJSONAndValue = (Map<String, Object>)innerObject;
                        if(mapOfInnerJSONAndValue!=null && mapOfInnerJSONAndValue.containsKey('name') && String.valueOf(mapOfInnerJSONAndValue.get('name')).equalsIgnoreCase('Quotes')){
                            quoteFolderId = String.valueOf(mapOfInnerJSONAndValue.get('id'));
                            break;
                        }

                    }

                    if(String.isNotBlank(quoteFolderId)){
                        String quoteNumberFolderId = boxToolkit.createFolder(quoteNumber,quoteFolderId,'');
                        String fileId = boxToolkit.createFileFromAttachment(attachmentRecord,fileName ,quoteNumberFolderId, null);
                        if(String.isBlank(fileId) && boxToolkit.mostRecentError.equalsIgnoreCase('Unable to create a file on Box.')){
                            endpoint = 'https://api.box.com/2.0/folders/'+quoteNumberFolderId+'/items';
                            HttpRequest fileRequest = new HttpRequest();
                            fileRequest.setMethod('GET');
                            fileRequest.setEndpoint(endpoint);
                            HttpResponse fileResponse = Test.isRunningTest()?null:boxToolkit.sendRequest(fileRequest);
                            if(Test.isRunningTest() || (fileResponse.getBody()!=null && fileResponse.getStatusCode()==200)){
                                responseBody = Test.isRunningTest()?'{"total_count":5,"entries":[{"type":"folder","id":"1","sequence_id":"1","etag":"0","name":"'+fileName+'"}],"offset":0,"limit":100,"order":[{"by":"type","direction":"ASC"},{"by":"name","direction":"ASC"}]}':fileResponse.getBody();
                				untypedTokenResponse = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
                                if(untypedTokenResponse!=null){
                                    listOfAllRelatedObject.clear();
                                    listOfAllRelatedObject = (List<Object>)untypedTokenResponse.get('entries');
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
                                            fileId = Test.isRunningTest()?'234565':boxToolkit.createFileFromAttachment(attachmentRecord,fileName ,quoteNumberFolderId, null);
                                        }
                                    }
                                }
                            }
                        }

                        if(String.isNotBlank(fileId) && !setOfProductNames.isEmpty()){
                            sobject objectRecord = (sobject)JSON.deserialize(quoteRecordString,sobject.class);
                            SalesforceBoxMetadataUtilityClass.prepareBoxMetadata(fileId,objectRecord,'Quote');  
                            moveProductFolderIntoOpportunity(setOfProductNames,quoteNumberFolderId,parentRecordId,quoteNumberFolderId,opportunityRecordId,opportunityFolderId);
                        }
                    }
                }
            }
        }
    
    }

    private static void moveProductFolderIntoOpportunity(set<String> setOfProductNames,String quoteNumberFolderId,String parentRecordId,String quoteFolderId,String opportunityRecordId,String opportunityFolderId){
        List<Salesforce_Product_Box_Mapping__mdt> listOfSalesforceProductBoxMapping = [select id,Box_Folder_ID__c,Box_Product_Name__c,Salesforce_Product_Name__c from Salesforce_Product_Box_Mapping__mdt where Box_Folder_ID__c!=null AND Salesforce_Product_Name__c IN:setOfProductNames];
        if(listOfSalesforceProductBoxMapping!=null && listOfSalesforceProductBoxMapping.size()>0){
            String endpoint;
            box.toolkit boxToolkit = new box.toolkit();
            for(Salesforce_Product_Box_Mapping__mdt metadataObj:listOfSalesforceProductBoxMapping){
                endpoint = 'https://api.box.com/2.0/folders/'+metadataObj.Box_Folder_ID__c+'/copy';
                HttpRequest opportunityProductRequest = new HttpRequest();
                opportunityProductRequest.setMethod('POST');
                opportunityProductRequest.setBody('{"parent":{"id":"'+quoteNumberFolderId+'"}}');
                opportunityProductRequest.setEndpoint(endpoint);
                HttpResponse opportunityProductResponse = Test.isRunningTest()?null:boxToolkit.sendRequest(opportunityProductRequest);
                if(Test.isRunningTest() || (opportunityProductResponse!=null && opportunityProductResponse.getStatusCode()==409)){
                    endpoint = 'https://api.box.com/2.0/folders/'+quoteNumberFolderId+'/items';
                    HttpRequest fileRequest = new HttpRequest();
                    fileRequest.setMethod('GET');
                    fileRequest.setEndpoint(endpoint);
                    HttpResponse fileResponse = Test.isRunningTest()?null:boxToolkit.sendRequest(fileRequest);
                    if(Test.isRunningTest() || (fileResponse.getBody()!=null && fileResponse.getStatusCode()==200)){
                        String responseBody = Test.isRunningTest()?'{"total_count":5,"entries":[{"type":"folder","id":"1","sequence_id":"1","etag":"0","name":"any"}],"offset":0,"limit":100,"order":[{"by":"type","direction":"ASC"},{"by":"name","direction":"ASC"}]}':fileResponse.getBody();
                        Map<String, Object> untypedTokenResponse = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
                        if(untypedTokenResponse!=null){
                            List<Object> listOfAllRelatedObject = (List<Object>)untypedTokenResponse.get('entries');
                            String existingFileId = '';
                            set<String> setOfFolderIds = new set<String>();
                            for(object innerObject:listOfAllRelatedObject){
                                Map<String, Object> mapOfInnerJSONAndValue = (Map<String, Object>)innerObject;
                                if(String.valueOf(mapOfInnerJSONAndValue.get('type')).equalsIgnoreCase('folder')){
                                    setOfFolderIds.add(String.valueOf(mapOfInnerJSONAndValue.get('id')));
                                }
                            }
                            
                            if(!setOfFolderIds.isEmpty()){
                                for(String folderIdValue:setOfFolderIds){
                                    endpoint = 'https://api.box.com/2.0/folders/'+folderIdValue+'?recursive=true';
                                    opportunityProductRequest = new HttpRequest();
                                    opportunityProductRequest.setMethod('DELETE');
                                    opportunityProductRequest.setEndpoint(endpoint);
                                    opportunityProductResponse = Test.isRunningTest()?null:boxToolkit.sendRequest(opportunityProductRequest);
                                    if(Test.isRunningTest() || (opportunityProductResponse!=null && opportunityProductResponse.getStatusCode()==204)){
                                        setOfFolderIds.remove(folderIdValue);
                                    }
                                }
                                if(setOfFolderIds.isEmpty()){
                                    endpoint = 'https://api.box.com/2.0/folders/'+metadataObj.Box_Folder_ID__c+'/copy';
                                    opportunityProductRequest = new HttpRequest();
                                    opportunityProductRequest.setMethod('POST');
                                    opportunityProductRequest.setBody('{"parent":{"id":"'+quoteNumberFolderId+'"}}');
                                    opportunityProductRequest.setEndpoint(endpoint);
                                    opportunityProductResponse = Test.isRunningTest()?null:boxToolkit.sendRequest(opportunityProductRequest);
                                }
                            }
                        }
                    }
                }
            }

            if(String.isNotBlank(parentRecordId) && String.isNotBlank(quoteNumberFolderId) && String.isNotBlank(opportunityFolderId) && String.isNotBlank(opportunityRecordId)){
                HttpRequest shareFolderLinkRequest = new HttpRequest();
                shareFolderLinkRequest.setMethod('PUT');
                shareFolderLinkRequest.setHeader('content-type','application/json');
                shareFolderLinkRequest.setHeader('content-length','0');
                shareFolderLinkRequest.setBody('{"shared_link": {"access": "open","permissions": {"can_download": true}}}');
                shareFolderLinkRequest.setEndpoint('https://api.box.com/2.0/folders/'+quoteNumberFolderId+'?fields=shared_link');
                HttpResponse shareFolderLinkResponse = Test.isRunningTest()?null:boxToolkit.sendRequest(shareFolderLinkRequest);
                if((shareFolderLinkResponse!=null && shareFolderLinkResponse.getStatusCode()==200 && shareFolderLinkResponse.getBody()!=null) || Test.isRunningTest()){
                    Map<String,object> mapOfResponse = Test.isRunningTest()?null:(Map<String,object>)JSON.deserializeUntyped(shareFolderLinkResponse.getBody());
                    Map<String,object> mapOfSharedLinkResponse = Test.isRunningTest()?null:(Map<String,object>)mapOfResponse.get('shared_link');
                    if((mapOfSharedLinkResponse!=null && mapOfSharedLinkResponse.containsKey('url')  && mapOfSharedLinkResponse.get('url')!=null) || Test.isRunningTest()){
                        try{
                            Quote quoteObj = new Quote(Id=parentRecordId,Box_Quote_Folder_Link__c=(Test.isRunningTest()?'https://test.com':String.valueOf(mapOfSharedLinkResponse.get('url'))));
                            update quoteObj;
                            Opportunity opportunityRecord = new Opportunity(id=opportunityRecordId,Box_Opportunity_Product_Link__c='https://maestrotradexpvtltd.app.box.com/folder/'+opportunityFolderId);
                            update opportunityRecord;
                        }catch(DMLException e){
                            system.debug('----quote updation failed---');
                        }
                    }
                }
            }
                        
        }   
    }

    public class PDFWrapperClass{
        public HeaderWrapperClass headerWrapper{get;set;}
        public BodyWrapperClass bodyWrapper{get;set;}
        public FooterWrapperClass footerWrapper{get;set;}
        public Boolean isDoorDelivery{get;set;}
        public Quote quoteRecord{get;set;}
        public Boolean isLiftGateCharge{get;set;}
    }

    public class HeaderWrapperClass{
        public String mainHeader{get;set;}
        public String billDate{get;set;}
        public String validUntilDate{get;set;}
    }

    public class BodyWrapperClass{
        public String billToAddress{get;set;}
        public String shipFromAddress{get;set;}
        public String deliveryAddress{get;set;}
        public String pickupAddress{get;set;}
        public Map<String,List<QuoteLineItem>> mapOfGroupNameAndQLI{get;set;}
        public Map<String,String> mapOfStringGroupNameAndTotalPrice{get;set;}
        public Map<Id,Integer> mapOfOLIIdANDQuantity{get;set;}
        public Map<Id,String> mapOfOLIIdANDUnitPrice{get;set;}
        public Map<Id,String> mapOfOLIIdANDTotal{get;set;}
        public Integer totalTiresCount{get;set;}
        public String totalTiresPrice{get;set;}
        public String totalFeeAmount{get;set;}
        public String subtotal{get;set;}
        public String tax{get;set;}
        public String totalStateFee{get;set;}
        public String liftGateCharges{get;set;}
        public String freightCharges{get;set;}
        public String otherCharges{get;set;}
        public String grandTotal{get;set;}
        
    }

    public class FooterWrapperClass{
        public String bankInformation{get;set;}
        public String extraInformation{get;set;}
    }
}