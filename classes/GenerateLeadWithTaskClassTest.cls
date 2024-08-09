@isTest
public with sharing class GenerateLeadWithTaskClassTest{

    @testSetup static void createSampleData(){
        Lead leadObj = new Lead(firstName='test',lastname='test1',company='test',email='test@test.com',phone='9897969594',status='unqualified');
        insert leadObj;
    }

    @isTest static void generateLeadWithTask(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String jsonRequest = '{"firstName":"hell99","lastName":"tesg","company":"test","phone":"9991119987","email":"test i1ng@125.com.vi.vii","description":"asdsad"}';
        req.requestURI = '/services/apexrest/LeadGeneration/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonRequest);
        
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        GenerateLeadWithTaskClass.createAndUpdateLeadWithTask();
        Test.stopTest();
    
    }
    
    @isTest static void generateExistingLeadWithTask(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String jsonRequest = '{"firstName":"test","test1":"tesg","company":"test","phone":"9897969594","email":"test@test.com","description":"asdsad"}';
        req.requestURI = '/services/apexrest/LeadGeneration/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonRequest);
        
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        GenerateLeadWithTaskClass.createAndUpdateLeadWithTask();
        Test.stopTest();
    
    }
}