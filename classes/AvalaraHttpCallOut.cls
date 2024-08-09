public with sharing class AvalaraHttpCallOut {
    public String accountId;
    public String authToken;
    public String endpoint;
    Http http;
    public AvalaraHttpCallOut() {
        Avalara_API__c avalApi = Avalara_API__c.getInstance();
        accountId = avalApi.Account_Id__c;
        authToken = avalApi.Auth_Token__c;
        endpoint = avalApi.Endpoint__c;
    }

    public HttpResponse getTaxAmountDetails(String requestBody){
        HttpResponse response = new HttpResponse();
        if(String.isNotBlank(requestBody)){
            http = new Http();
            HttpRequest req = new HttpRequest();               
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(accountId +':'+authToken));
            req.setEndpoint(endpoint);
            
            req.setMethod('POST');
            req.setHeader('Content-Type','application/json');
            req.setHeader('Authorization',authorizationHeader);
            req.setBody(requestBody);
            response = http.send(req);
            System.debug(response);
            System.debug(response.getBody());
            return response;
        }
        return response;
    }
}