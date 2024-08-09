public with sharing class AdditionAccountAddressValidationClass{

    @auraEnabled
    public static LWCResponseWrapperClass validateAdditionalAccountAddress(String userEnteredAddress){
        LWCRequestWrapperClass requestWrapper = (LWCRequestWrapperClass)JSON.deserialize(userEnteredAddress,LWCRequestWrapperClass.class);
        String originalAddress = requestWrapper.line1+'\n'+requestWrapper.region+','+requestWrapper.city+','+requestWrapper.country+'\n'+requestWrapper.postalCode;
        originalAddress = beautifyAddress(originalAddress);


        String validatedAddress = '';
        LWCRequestWrapperClass validatedRequestWrapper = null; 
        Boolean isAddressExist = true;
        
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint('callout:Address_Validation_Basic_Auth');
        request.setBody(userEnteredAddress);
        
        Http httpObject = new Http();
        HttpResponse response = httpObject.send(request);
        if(response.getBody()!=null){
            AddressAPIResponseWrapperClass addressAPIResponseWrapperClassObject = (AddressAPIResponseWrapperClass)JSON.deserialize(response.getBody(),AddressAPIResponseWrapperClass.class);
            if(addressAPIResponseWrapperClassObject!=null && addressAPIResponseWrapperClassObject.error!=null && addressAPIResponseWrapperClassObject.error.details!=null){
                //error
                isAddressExist= false;
                validatedAddress = addressAPIResponseWrapperClassObject.error.details[0].description;
            }else if(addressAPIResponseWrapperClassObject!=null && addressAPIResponseWrapperClassObject.messages!=null){
                //error
                isAddressExist= false;
                validatedAddress = addressAPIResponseWrapperClassObject.messages[0].details;
            }else if(addressAPIResponseWrapperClassObject!=null && addressAPIResponseWrapperClassObject.validatedAddresses!=null){
                //success
                addressAPIResponseWrapperClassObject.validatedAddresses[0].name = requestWrapper.name;
                addressAPIResponseWrapperClassObject.validatedAddresses[0].accountId = requestWrapper.accountId;
                validatedRequestWrapper = addressAPIResponseWrapperClassObject.validatedAddresses[0];
                validatedAddress = addressAPIResponseWrapperClassObject.validatedAddresses[0].line1+','+addressAPIResponseWrapperClassObject.validatedAddresses[0].line2+','+addressAPIResponseWrapperClassObject.validatedAddresses[0].line3+'\n'+addressAPIResponseWrapperClassObject.validatedAddresses[0].region+','+addressAPIResponseWrapperClassObject.validatedAddresses[0].city+','+addressAPIResponseWrapperClassObject.validatedAddresses[0].country+'\n'+addressAPIResponseWrapperClassObject.validatedAddresses[0].postalCode;
                validatedAddress = beautifyAddress(validatedAddress);
            }
        }
        return (new LWCResponseWrapperClass(requestWrapper,validatedRequestWrapper,originalAddress,validatedAddress,isAddressExist));
    }

    private static string beautifyAddress(String beautifyAddress){
        beautifyAddress = beautifyAddress.startsWith(',')?beautifyAddress.substringafter(','):beautifyAddress;
        beautifyAddress = beautifyAddress.startsWith('\n')?beautifyAddress.substringafter('\n'):beautifyAddress;
        beautifyAddress = beautifyAddress.endsWith(',')?beautifyAddress.substringbeforelast(','):beautifyAddress;
        beautifyAddress = beautifyAddress.endsWith('\n')?beautifyAddress.substringbeforelast('\n'):beautifyAddress;
        beautifyAddress = beautifyAddress.contains(',,')?beautifyAddress.replace(',,',','):beautifyAddress;
        beautifyAddress = beautifyAddress.contains('\n,')?beautifyAddress.replace('\n,','\n'):beautifyAddress;
        beautifyAddress = beautifyAddress.contains('\n\n')?beautifyAddress.replace('\n\n','\n'):beautifyAddress;
        
        if(beautifyAddress.startsWith(',') || beautifyAddress.startsWith('\n') || beautifyAddress.endsWith(',') || beautifyAddress.endsWith('\n')){
            beautifyAddress = beautifyAddress(beautifyAddress);
        }
        return beautifyAddress;
    }

    @AuraEnabled
    public static AddressRecordResponseWrapperClass createAdditionAccountAddressRecord(String additionalAddressResponse,String buttonName){
        String recordId = '';
        String message = '';

        Map<String,Object> mapOfAddressAttributeAndValue = (Map<String,Object>)JSON.deserializeUntyped(additionalAddressResponse);
        if(mapOfAddressAttributeAndValue.containsKey(buttonName) && mapOfAddressAttributeAndValue.containsKey(buttonName+'Wrapper') && mapOfAddressAttributeAndValue.get(buttonName+'Wrapper')!=null){
            LWCRequestWrapperClass requestWrapperObject = (LWCRequestWrapperClass)JSON.deserialize(JSON.serialize(mapOfAddressAttributeAndValue.get(buttonName+'Wrapper')),LWCRequestWrapperClass.class);
            if(requestWrapperObject!=null){
                Account_Adddress__c accountAddressObject = new Account_Adddress__c();
                accountAddressObject.Shipping_City__c = requestWrapperObject.city;
                accountAddressObject.Shipping_Country__c = requestWrapperObject.country;
                accountAddressObject.Shipping_State_Province__c = requestWrapperObject.region;
                accountAddressObject.Shipping_Street__c  = requestWrapperObject.line1;
                accountAddressObject.Shipping_Zip_Postal_Code__c = requestWrapperObject.postalCode;
                accountAddressObject.Name = requestWrapperObject.name;
                accountAddressObject.Account__c = requestWrapperObject.accountId;
                accountAddressObject.Billing_Address_same_as_Shipping_Address__c = true;
                accountAddressObject.IsAddressFromCustomUI__c = true;
                try{insert accountAddressObject;recordId=accountAddressObject.id;}catch(DMLException exceptionObject){message=exceptionObject.getMessage();}
            }  
        }

        return (new AddressRecordResponseWrapperClass(recordId,message));
    }
    

    public class AddressAPIResponseWrapperClass{
        public List<LWCRequestWrapperClass> validatedAddresses;
        public ErrorWrapper error;
        public List<MessageWrapper> messages;
    }

    public class MessageWrapper{
        public String details;
    }

    public class errorWrapper{
        public List<errorDetailWrapper> details;
    }

    public class errorDetailWrapper{
        public string message;
        public string description;
    }

    public class AddressRecordResponseWrapperClass{
        @auraEnabled
        public String recordId{get;set;}
        @auraEnabled
        public String message{get;set;}

        public AddressRecordResponseWrapperClass(String recordId, String message){
            this.recordId = recordId;
            this.message = message;
        }
    }

    public class LWCRequestWrapperClass{
        @auraEnabled
        public String line1{get;set;}
        @auraEnabled
        public string line2{get;set;}
        @auraEnabled
        public string line3{get;set;}
        @auraEnabled
        public String city{get;set;}
        @auraEnabled
        public String region{get;set;}
        @auraEnabled
        public String country{get;set;}
        @auraEnabled
        public String postalCode{get;set;}
        @auraEnabled
        public String name{get;set;}
        @auraEnabled
        public String accountId{get;set;}
    }

    public class LWCResponseWrapperClass{
        @auraEnabled
        public LWCRequestWrapperClass originalAddressWrapper{get;set;}
        @auraEnabled
        public LWCRequestWrapperClass validatedAddressWrapper{get;set;}
        @auraEnabled
        public String originalAddress{get;set;}
        @auraEnabled
        public String validatedAddress{get;set;}
        @auraEnabled
        public Boolean isAddressExist{get;set;}
        
        public LWCResponseWrapperClass(LWCRequestWrapperClass originalAddressWrapper,LWCRequestWrapperClass validatedAddressWrapper,String originalAddress,String validatedAddress,Boolean isAddressExist){
            this.originalAddressWrapper = originalAddressWrapper;
            this.validatedAddressWrapper = validatedAddressWrapper;
            this.originalAddress = originalAddress;
            this.validatedAddress = validatedAddress;
            this.isAddressExist = isAddressExist;
        }
         
    }
}