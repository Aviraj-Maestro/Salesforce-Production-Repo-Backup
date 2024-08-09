public with sharing class BillingTriggerHandler  implements ITriggerHandler {
    public Boolean IsDisabled(){		
        return false;
       
     }
  
     public void BeforeInsert(List<Sobject> newItems){

       
     
    }
     public void BeforeDelete(Map<id, sObject> oldItems){
     
     }
    
     public void AfterInsert(List<Sobject> newMap){     

     }
 
     public void AfterUpdate(Map<Id, sObject> newMap, Map<Id, sObject> oldMap){    
        Map<Id,AcctSeed__Billing__c> newItems= (Map<Id,AcctSeed__Billing__c>)newMap;
        Map<Id,AcctSeed__Billing__c> oldItems= (Map<Id,AcctSeed__Billing__c>)oldMap;
       
        try {
            for(AcctSeed__Billing__c billing: newItems.values()){
                if(billing.AcctSeed__Status__c != oldItems.get(billing.Id).AcctSeed__Status__c && billing.AcctSeed__Status__c=='Posted'){
                    System.enqueuejob(new PostAvalaraAndCreateJEQueable(billing,'commit'));
                }
                if(billing.AcctSeed__Status__c != oldItems.get(billing.Id).AcctSeed__Status__c && billing.AcctSeed__Status__c=='Approved' && oldItems.get(billing.Id).AcctSeed__Status__c == 'Posted'){
                    System.enqueuejob(new PostAvalaraAndCreateJEQueable(billing,'uncommit'));
                }
            }
           
        } catch (Exception Ex) {
            
        } finally {
            
        }
      
     }
    
     
}