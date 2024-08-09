@isTest
public with sharing class AdditionAccountAddressValidationTest{

    @testSetup static void createSampleData(){

        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Reseller').getRecordTypeId();
        
        Account acc1 = new Account();
        acc1.AcctSeed__Exemption_Number__c='12000-3456';
        acc1.Name='Test';
        Acc1.Phone='8700203559';
        acc1.RecordTypeId= recordTypeIdAccount;
        acc1.AcctSeed__Entity_Use_Code__c='G';
        acc1.BillingCity='allbama city';
        acc1.BillingCountry='USA';
        acc1.BillingState='Alaska';
        acc1.BillingPostalCode='36117';
        acc1.ShippingCity='test city';
        acc1.ShippingCountry='USA';
        acc1.ShippingState='Alaska';
        acc1.ShippingStreet='Test1';
        acc1.ShippingPostalCode='36119';
        insert acc1;
    }

    @isTest static void additionalAccountAddressSuccessTest(){
        Account accObj = [Select id from Account limit 1];
        String userEnteredAddress = '{"name":"test","accountId":"'+accObj.id+'","line1":"","textCase":"Upper","city":"","region":"","country":"US","postalCode":"92614"}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ServiceRequestMockClass(''));
        AdditionAccountAddressValidationClass.LWCResponseWrapperClass wrapperObj = AdditionAccountAddressValidationClass.validateAdditionalAccountAddress(userEnteredAddress);
        AdditionAccountAddressValidationClass.createAdditionAccountAddressRecord(JSON.serialize(wrapperObj),'originalAddress');
        Test.stopTest();
    }
    
    @isTest static void additionalAccountAddressErrorTest(){
        Account accObj = [Select id from Account limit 1];
        String userEnteredAddress = '{"name":"test","accountId":"'+accObj.id+'","line1":"","textCase":"Upper","city":"","region":"","country":"US","postalCode":"92614"}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ServiceRequestMockClass('error'));
        AdditionAccountAddressValidationClass.LWCResponseWrapperClass wrapperObj1 = AdditionAccountAddressValidationClass.validateAdditionalAccountAddress(userEnteredAddress);
        Test.stopTest();
    }
    
    @isTest static void additionalAccountAddressMessageTest(){
        Account accObj = [Select id from Account limit 1];
        String userEnteredAddress = '{"name":"test","accountId":"'+accObj.id+'","line1":"","textCase":"Upper","city":"","region":"","country":"US","postalCode":"92614"}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ServiceRequestMockClass('message'));
        AdditionAccountAddressValidationClass.LWCResponseWrapperClass wrapperObj2 = AdditionAccountAddressValidationClass.validateAdditionalAccountAddress(userEnteredAddress);
        Test.stopTest();
    }

    public class ServiceRequestMockClass implements HttpCalloutMock {
        Public String serviceType;
        public ServiceRequestMockClass(String serviceType){
            this.serviceType=serviceType;
        }
        public HttpResponse respond(HTTPRequest req) {
            req.setBody('{"mockRequest":"mock"}');
            req.setEndpoint('test.com');
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"validatedAddresses": [{"addressType": "StreetOrResidentialAddress","line1": "2000 MAIN ST","line2": "","line3": "","city": "IRVINE","region": "CA","country": "US","postalCode": "92614-7202","latitude": 33.684731,"longitude": -117.851466}]}');
            if(serviceType=='error'){
            	res.setBody('{"error": {"code": "InvalidAddress","message": "The address value was incomplete.","target": "IncorrectData","details": [{"code": "InvalidAddress","number": 309,"message": "The address value was incomplete.","description": "The address value NULL was incomplete. You must provide either a valid postal code, line1 + city + region, or line1 + postal code.","faultCode": "Client","helpLink": "https://developer.avalara.com/avatax/errors/InvalidAddress","severity": "Error"}]}}');
            }else if(serviceType=='message'){
            	res.setBody('{"messages": [{    "summary": "An exact street name match could not be found",    "details": "An exact street name match could not be found and phonetically matching the street name resulted in either no matches or matches to more than one street name.",    "refersTo": "Address.Line0",    "severity": "Error",    "source": "Avalara.AvaTax.Common"}    ]}');
            }
            res.setStatusCode(200);
            return res;
        }
	}
}