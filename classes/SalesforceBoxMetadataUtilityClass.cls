public class SalesforceBoxMetadataUtilityClass {

    public static void prepareBoxMetadata(String fileId,sobject objectRecord,String objectAPIName){
        List<Salesforce_Box_Metadata_Configuration__mdt> listOfMetadataRecord = [Select id,label,Record_Type_Check_Fields__c,Box_Account_Type__c,Box_Metadata_Name__c,Metadata_Name_and_Record_Field__c from Salesforce_Box_Metadata_Configuration__mdt where label=:objectAPIName limit 1];

        if(listOfMetadataRecord!=null && listOfMetadataRecord.size()>0){
            List<String> listSemiColonSeparated = listOfMetadataRecord[0].Metadata_Name_and_Record_Field__c.split(';');
            List<Box.KeyValuePair> listOfBoxKeyValuePair = new List<Box.KeyValuePair>();
            Map<String,String> mapOfFieldNameAndCastType = new Map<String,String>();
            Map<String,String> mapOfFieldNameAndRecordTypeCheck = new Map<String,String>();

            if(String.isNotBlank(listOfMetadataRecord[0].Record_Type_Check_Fields__c)){
                for(String eachString:listOfMetadataRecord[0].Record_Type_Check_Fields__c.split(';')){
                    mapOfFieldNameAndRecordTypeCheck.put(eachString.substringbeforelast('=>'),eachString.substringAfterlast('=>'));
                }
            }

            String requestBody = '';
            for(String metadataField:listSemiColonSeparated){
                if(String.isNotBlank(metadataField.substringAfterlast('=>'))){
                    Box.KeyValuePair keyValueObject = new Box.KeyValuePair();
                    Box.FolderMetadataUpdate updateObject = new Box.FolderMetadataUpdate();
                    
                    String fieldValue='';
                    if(metadataField.substringAfterlast('=>').endsWith('_Text')){
                        fieldValue = metadataField.substringAfterlast('=>').subStringBeforeLast('_Text');
                    }else{
                        String recordTypeComparision = (!mapOfFieldNameAndRecordTypeCheck.isEmpty() && mapOfFieldNameAndRecordTypeCheck.containsKey(metadataField.substringAfterlast('=>')))?mapOfFieldNameAndRecordTypeCheck.get(metadataField.substringAfterlast('=>')):'';
                        fieldValue = fetchFieldValue(metadataField.substringAfterlast('=>'),objectRecord,recordTypeComparision);
                    }
                    requestBody +='"'+metadataField.substringbeforelast('=>')+'":"'+fieldValue+'",';
                }
            }

            if(String.isNotBlank(requestBody)){
                Box.Toolkit toolkitObj = new Box.Toolkit();
                requestBody = '{'+requestBody.subStringBeforeLast(',')+'}';
                String endpoint = 'https://api.box.com/2.0/files/'+fileId+'/metadata/'+listOfMetadataRecord[0].Box_Account_Type__c+'/'+listOfMetadataRecord[0].Box_Metadata_Name__c;
                HttpRequest request = new HttpRequest();
                request.setMethod('POST');
                request.setHeader('content-type','application/json');
                request.setBody(requestBody);
                request.setEndpoint(endpoint);
                HttpResponse response = Test.isRunningTest()?null:toolkitObj.sendRequest(request);
            }
        }
    }

    private static String fetchFieldValue(String fieldName,sobject objectRecord,String recordTypeComparision){
        String fieldValue = '';
        if(fieldName.contains('.')){
            fieldValue = fetchFieldValue(fieldName.substringAfter('.'),objectRecord.getSobject(fieldName.substringbefore('.')),recordTypeComparision);
        }else{
            if(objectRecord.getSObjectType().getDescribe().fields.getMap().get(fieldName)!=null && String.valueOf(objectRecord.getSObjectType().getDescribe().fields.getMap().get(fieldName).getDescribe().getType()).equalsIgnoreCase('Date') && objectRecord.get(fieldName)!=null){
                fieldValue = Date.valueOf(objectRecord.get(fieldName)).year()+'-'+Date.valueOf(objectRecord.get(fieldName)).month()+'-'+Date.valueOf(objectRecord.get(fieldName)).day();
            }else if(String.isNotBlank(recordTypeComparision)){
                fieldValue = String.valueOf(objectRecord.get(fieldName)).equalsIgnoreCase(recordTypeComparision)?'Y':'N';
            }else{
                fieldValue = string.valueOf(objectRecord.get(fieldName));
            }
        }
        return fieldValue;
    }
}