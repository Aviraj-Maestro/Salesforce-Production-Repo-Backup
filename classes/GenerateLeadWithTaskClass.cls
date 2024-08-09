@RestResource(urlMapping='/LeadGeneration/*')
global with sharing class GenerateLeadWithTaskClass{
    
    @httpPost
    global static void createAndUpdateLeadWithTask(){
        
        RestContext.response.addHeader('Content-Type','application/json');
        String jsonRequestBody = (RestContext.request.requestBody!=null)?(RestContext.request.requestBody.toString()):'';
        String responsebody = JSON.serialize(new responseJSONWrapper('Error','404','Request cannot be blank',false));
        Integer statusCode = 404;
        if(String.isNotBlank(jsonRequestBody)){
            RequestJSONWrapper requestJSONWrapperObject = (RequestJSONWrapper)JSON.deserialize(jsonRequestBody,RequestJSONWrapper.class);
            responsebody = JSON.serialize(new responseJSONWrapper('Error','404','Email/Phone cannot be blank',false));
            if(requestJSONWrapperObject!=null && String.isNotBlank(requestJSONWrapperObject.phone) && String.isNotBlank(requestJSONWrapperObject.email)){
                List<Lead> listOfLeadRecord = [Select id,firstname,lastname,company,status,leadSource,type_of_customer__c,email,phone,isconverted from Lead where (email=:requestJSONWrapperObject.email OR phone=:requestJSONWrapperObject.phone) AND isconverted=false];
                //new lead record
                Lead leadRecord = (listOfLeadRecord.size()>0)?listOfLeadRecord[0]:new Lead();
                Boolean isLeadCreateAndUpdateRequired = false;
                if(listOfLeadRecord.size()==0){
                    leadRecord.firstname = requestJSONWrapperObject.firstName;
                    leadRecord.lastname = requestJSONWrapperObject.lastName;
                    leadRecord.company = requestJSONWrapperObject.company;
                    leadRecord.Status = 'New_Lead';
                    leadRecord.LeadSource = 'Other';
                    leadRecord.phone = requestJSONWrapperObject.phone;
                    leadRecord.email =  requestJSONWrapperObject.email;
                    isLeadCreateAndUpdateRequired = true;
                }else if(listOfLeadRecord.size()>0 && listOfLeadRecord[0].Status!='New_Lead'){
                    leadRecord.Status='New_Lead';
                    leadRecord.Id=listOfLeadRecord[0].Id;
                    isLeadCreateAndUpdateRequired = true;
                }
                Boolean isLeadSuccess = false;
                if(isLeadCreateAndUpdateRequired){
                    try{
                        upsert leadRecord;
                        isLeadSuccess = true;
                    }Catch(DMLException exceptionObj){
                        responsebody = JSON.serialize(new responseJSONWrapper('Error','404',exceptionObj.getMessage(),false));
                    }
                }                    
                
                if((isLeadCreateAndUpdateRequired && isLeadSuccess) || (!isLeadCreateAndUpdateRequired && !isLeadSuccess)){
                    Task taskRecord = new Task();
                    taskRecord.OwnerId = [select id,developername from group where developername='LeadTaskOwnerQueue'].id;
                    taskRecord.Description = requestJSONWrapperObject.description;
                    taskRecord.ActivityDate = system.now().dateGMT();
                    taskRecord.WhoId = leadRecord.Id;
                    taskRecord.Status = 'Open';
                    taskRecord.subject = requestJSONWrapperObject.firstName+' '+requestJSONWrapperObject.lastName;
                    try{
                        insert taskRecord;
                        statusCode = 200;
                        responsebody = JSON.serialize(new responseJSONWrapper('Success','200','Lead and Task is successfully created!!',true));
                    }Catch(DMLException exceptionObj){
                        responsebody = JSON.serialize(new responseJSONWrapper('Error','404',exceptionObj.getMessage(),false));
                    }
                }
                
            }
        } 
        RestContext.response.statuscode = statusCode;
        RestContext.response.responsebody = blob.valueOf(responseBody);
        
    }
    
    public class ResponseJSONWrapper{
        public String status{get;set;}
        public String statusCode{get;set;}
        public String message{get;set;}
        public Boolean success{get;set;}

        public ResponseJSONWrapper(String status, String statusCode,String message,Boolean success){
            this.status = status;
            this.statusCode = statusCode;
            this.message = message;
            this.success = success;
        }
    }

    public class RequestJSONWrapper{
        public String firstName;
        public String lastName;
        public String company;
        public String email;
        public String phone;
        public String description;
    }
}