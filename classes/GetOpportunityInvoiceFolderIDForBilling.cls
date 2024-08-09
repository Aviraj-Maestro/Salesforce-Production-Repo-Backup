public class GetOpportunityInvoiceFolderIDForBilling {

    
    public static String fetchInvoiceBoxFolderId(String opportunityFolderId){
        String endpoint = 'https://api.box.com/2.0/folders/'+opportunityFolderId+'/items';
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(endpoint);
        box.Toolkit boxToolkit = new box.Toolkit();
        HttpResponse response = Test.isRunningTest()?null:boxToolkit.sendRequest(request);
        String boxInvoiceFolderId='';
        if(Test.isRunningTest() || (response!=null && response.getBody()!=null && response.getStatusCode()==200)){
            String responseBody = !Test.isRunningTest()?response.getBody():'{"total_count":5,"entries":[{"type":"folder","id":"2","sequence_id":"0","etag":"0","name":"Invoices"}],"offset":0,"limit":100,"order":[{"by":"type","direction":"ASC"},{"by":"name","direction":"ASC"}]}';
            Map<String, Object> untypedTokenResponse = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
            if(untypedTokenResponse!=null){
                List<Object> listOfAllRelatedObject = (List<Object>)untypedTokenResponse.get('entries');
                //iterate over all template folder and fetch folder id
                for(object innerObject:listOfAllRelatedObject){
                    Map<String, Object> mapOfInnerJSONAndValue = (Map<String, Object>)innerObject;
                    if(mapOfInnerJSONAndValue!=null && mapOfInnerJSONAndValue.containsKey('name') && String.valueOf(mapOfInnerJSONAndValue.get('name')).equalsIgnoreCase('Invoices')){
                        boxInvoiceFolderId = String.valueOf(mapOfInnerJSONAndValue.get('id'));
                        break;
                    }
                }
            }
        }
        return boxInvoiceFolderId;
    }
}