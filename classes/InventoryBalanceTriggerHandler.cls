public with sharing class InventoryBalanceTriggerHandler implements ITriggerHandler {
    public Boolean IsDisabled(){	
       Trigger_Handler__mdt lstMetaData = [SELECT Disable__c FROM Trigger_Handler__mdt where MasterLabel='InventoryBalance'];		
        return lstMetaData.Disable__c;
       
     }
     public void BeforeInsert(List<Sobject> newItems){
     
     }
     public void BeforeUpdate(Map<id, sObject> newItems, Map<id, sObject> oldItems){   
     }
    
     public void BeforeDelete(Map<id, sObject> oldItems){
     
     }
    
     public void AfterInsert(List<Sobject> newMap){       
       
     }
     public void AfterDelete(Map<id, sObject> oldMap){
         
     }
    
     public void AfterUndelete(List<Sobject> newMap){
         
     }
     public void AfterUpdate(Map<Id, sObject> newMap, Map<Id, sObject> oldMap){    
      set<Id> inventoryBalanceId= new set<Id>();

      System.debug('Test >>>>');
        for(AcctSeedERP__Inventory_Balance__c inventoryBalance :  ((Map<Id,AcctSeedERP__Inventory_Balance__c>)newMap).values()){
          
            AcctSeedERP__Inventory_Balance__c oldinventoryBalance = (AcctSeedERP__Inventory_Balance__c) oldMap.get(inventoryBalance.ID);
            AcctSeedERP__Inventory_Balance__c newinventoryBalance = (AcctSeedERP__Inventory_Balance__c) newMap.get(inventoryBalance.ID);  
            System.debug('oldinventoryBalance.AcctSeedERP__Available_Quantity__c >>>>'+oldinventoryBalance.AcctSeedERP__Available_Quantity__c);
            System.debug('newinventoryBalance.AcctSeedERP__Available_Quantity__c >>>>'+newinventoryBalance.AcctSeedERP__Available_Quantity__c);
            if(oldinventoryBalance.AcctSeedERP__Available_Quantity__c  != newinventoryBalance.AcctSeedERP__Available_Quantity__c){
               inventoryBalanceId.add(newinventoryBalance.Id);  
            }
        } 
        System.debug('inventoryBalanceId >>>>'+inventoryBalanceId);
          if(!inventoryBalanceId.IsEmpty()){
          
            System.enqueueJob(new InventoryBalanceQueue(inventoryBalanceId));
        }
     }
    
     
}