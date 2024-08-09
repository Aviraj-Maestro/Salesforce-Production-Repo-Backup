public with sharing class PurchaseOrderLineTriggerHandler implements ITriggerHandler {
    public Boolean IsDisabled(){	
        //Trigger_Handler__mdt lstMetaData = [SELECT Disable__c FROM Trigger_Handler__mdt where MasterLabel='PurchaseOrder'];		
        //return lstMetaData.Disable__c;	
        return false;
     }
     public void BeforeInsert(List<Sobject> newItems){
        Map<Id,AcctSeedERP__Purchase_Order_Line__c> purchaseOrderAndPurchaseOrderLineMap= new Map<Id,AcctSeedERP__Purchase_Order_Line__c>();
        Set<Id> productIdSet= new Set<Id>();
       
        for(AcctSeedERP__Purchase_Order_Line__c purchaseOrderLine : ((List<AcctSeedERP__Purchase_Order_Line__c>)newItems)){ 
            //if(Purchase_Order_Domestic)
            productIdSet.add(purchaseOrderLine.AcctSeedERP__Product__c);
        }
  

        Map<Id,Product2>  purshaseOrderLineFamilyMap= new Map<Id,Product2>([Select Id,Name,Family from Product2 where Id=:productIdSet]);

        for(AcctSeedERP__Purchase_Order_Line__c purchaseOrderLine : ((List<AcctSeedERP__Purchase_Order_Line__c>)newItems)){ 
           System.debug(' purshaseOrderLineFamilyMap.get(purchaseOrderLine.AcctSeedERP__Product__c).Name  >>'+ purshaseOrderLineFamilyMap.get(purchaseOrderLine.AcctSeedERP__Product__c).Name  );
           System.debug(' purshaseOrderLineFamilyMap.get(purchaseOrderLine.AcctSeedERP__Product__c).Family  >>'+ purshaseOrderLineFamilyMap.get(purchaseOrderLine.AcctSeedERP__Product__c).Family  );
           if( purshaseOrderLineFamilyMap.get(purchaseOrderLine.AcctSeedERP__Product__c).Family != 'FET'){ 
        
                 purchaseOrderAndPurchaseOrderLineMap.put(purchaseOrderLine.AcctSeedERP__Purchase_Order__c,purchaseOrderLine);
            }
       }
      
       if(!purchaseOrderAndPurchaseOrderLineMap.IsEmpty()){
          calculateFreightinPurchaseOrderLine(purchaseOrderAndPurchaseOrderLineMap,false);
       }
    }
    
    public void BeforeDelete(Map<id, sObject> oldItems){
    }
    public void AfterInsert(List<Sobject> newPurchaseOrderLine){
     	addFETProduct((List<AcctSeedERP__Purchase_Order_Line__c>)newPurchaseOrderLine);
    }
    public void AfterUpdate(Map<Id, sObject> newMap, Map<Id, sObject> oldMap){
    
        Map<Id,AcctSeedERP__Purchase_Order_Line__c> purchaseOrderAndPurchaseOrderLineMap= new Map<Id,AcctSeedERP__Purchase_Order_Line__c>();
        Map<Id,AcctSeedERP__Purchase_Order_Line__c>  purshaseOrderLineFamilyMap= new Map<Id,AcctSeedERP__Purchase_Order_Line__c>([Select Id,AcctSeedERP__Product__r.Family from AcctSeedERP__Purchase_Order_Line__c where Id=:((Map<Id,AcctSeedERP__Purchase_Order_Line__c>)oldMap).keyset()]);
   
        for(AcctSeedERP__Purchase_Order_Line__c purchaseOrderLineItem :  ((Map<Id,AcctSeedERP__Purchase_Order_Line__c>)newMap).values()){
          
            AcctSeedERP__Purchase_Order_Line__c oldpurchaseOrderLineItemItem = (AcctSeedERP__Purchase_Order_Line__c) oldMap.get(purchaseOrderLineItem.ID);
            AcctSeedERP__Purchase_Order_Line__c newpurchaseOrderLineItemItem  = (AcctSeedERP__Purchase_Order_Line__c) newMap.get(purchaseOrderLineItem.ID);  
            if(oldpurchaseOrderLineItemItem.AcctSeedERP__Quantity__c  != newpurchaseOrderLineItemItem.AcctSeedERP__Quantity__c)
            {  
                if( purshaseOrderLineFamilyMap.get(purchaseOrderLineItem.Id).AcctSeedERP__Product__r.Family != 'FET'){
                     purchaseOrderAndPurchaseOrderLineMap.put(purchaseOrderLineItem.AcctSeedERP__Purchase_Order__c,purchaseOrderLineItem);
                }
            }
            
        }  
        if(!purchaseOrderAndPurchaseOrderLineMap.IsEmpty()){
           calculateFreightinPurchaseOrderLine(purchaseOrderAndPurchaseOrderLineMap,true);
        }
    }

    private void calculateFreightinPurchaseOrderLine( Map<Id,AcctSeedERP__Purchase_Order_Line__c> purchaseOrderAndPurchaseOrderLineMap,Boolean toUpdate){
      
        Map<Id,AggregateResult> aggregateResultofPurchaseOrderLine= new  Map<Id,AggregateResult>();
        List<AcctSeedERP__Purchase_Order_Line__c> purchaseOrderLineToUpdate= new List<AcctSeedERP__Purchase_Order_Line__c>();
      
        List<AggregateResult> lstAggregateResult=[select AcctSeedERP__Purchase_Order__c,
                                                            SUM(AcctSeedERP__Quantity__c),
                                                            SUM(Total_Freight_1__c),
                                                            SUM(Clearing_Cost_Including_Custom_Duty__c),
                                                            SUM(Total_Purchase_Price_1__c),
                                                            Sum(Total_Landed_Cost__c),
                                                            SUM(Local_Transportation__c),
                                                            Sum(Other_Charges_1__c),
                                                            Sum(Other_Charges_2__c),
                                                            Sum(Custom_Clearing_Agent__c),
                                                            Sum(Custom_Duty_Charges__c) from AcctSeedERP__Purchase_Order_Line__c where AcctSeedERP__Purchase_Order__c =:purchaseOrderAndPurchaseOrderLineMap.Keyset() and AcctSeedERP__Product__r.Family !='FET' group by AcctSeedERP__Purchase_Order__c];

        for(AggregateResult agg : lstAggregateResult){
             aggregateResultofPurchaseOrderLine.put((Id)agg.get('AcctSeedERP__Purchase_Order__c'),agg);
        }
 
       

        

        Map<Id, AcctSeedERP__Purchase_Order__c> purchaseOrderMap = new Map<Id, AcctSeedERP__Purchase_Order__c>([Select id, Total_Ocean_Freight__c,Total_Quantity__c,Total_Custom_Duty__c,Total_PO_Value__c,Total_Port_Charges_without_custom_duty__c,AcctSeedERP__Total__c,RecordTypeId,Local_Transportation__c,Other_Charges_1__c,Other_Charges_2__c From AcctSeedERP__Purchase_Order__c where Id=:purchaseOrderAndPurchaseOrderLineMap.Keyset()]);
        Id DomesticRecordTypeId = Schema.SObjectType.AcctSeedERP__Purchase_Order__c.getRecordTypeInfosByName().get('Purchase Order Domestic').getRecordTypeId();
       
        for(Id purchaseOrder:purchaseOrderAndPurchaseOrderLineMap.keyset()){
                if(purchaseOrderMap.get(purchaseOrder).RecordTypeId != DomesticRecordTypeId){

                    System.debug('1 >>'+purchaseOrderMap.get(purchaseOrder).Total_Quantity__c );
                    System.debug('2 >>'+purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).AcctSeedERP__Quantity__c );
                    System.debug('3 >>'+(aggregateResultofPurchaseOrderLine.get(purchaseOrder)!=null? (Decimal) aggregateResultofPurchaseOrderLine.get(purchaseOrder).get('expr0') :0) );
                
                    if(purchaseOrderMap.get(purchaseOrder).Total_Quantity__c == purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).AcctSeedERP__Quantity__c + (aggregateResultofPurchaseOrderLine.get(purchaseOrder)!=null? (Decimal) aggregateResultofPurchaseOrderLine.get(purchaseOrder).get('expr0') :0)){
                            if(toUpdate){
                                    purchaseOrderLineToUpdate.add(new AcctSeedERP__Purchase_Order_Line__c(Id=purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Id,
                                                                                                        Total_Freight_1__c= (purchaseOrderMap.get(purchaseOrder).Total_Ocean_Freight__c - (Decimal)aggregateResultofPurchaseOrderLine.get(purchaseOrder).get('expr1')).setScale(6),
                                                                                                        Clearing_Cost_Including_Custom_Duty__c= (purchaseOrderMap.get(purchaseOrder).Total_Custom_Duty__c / purchaseOrderMap.get(purchaseOrder).Total_PO_Value__c * ((purchaseOrderMap.get(purchaseOrder).Total_PO_Value__c - (Decimal)aggregateResultofPurchaseOrderLine.get(purchaseOrder).get('expr3')).setScale(6)))+(purchaseOrderMap.get(purchaseOrder).Total_Port_Charges_without_custom_duty__c / purchaseOrderMap.get(purchaseOrder).Total_Quantity__c * purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).AcctSeedERP__Quantity__c),
                                                                                                        Custom_Duty_Charges__c=(purchaseOrderMap.get(purchaseOrder).Total_Custom_Duty__c / purchaseOrderMap.get(purchaseOrder).Total_PO_Value__c * ((purchaseOrderMap.get(purchaseOrder).Total_PO_Value__c - (Decimal)aggregateResultofPurchaseOrderLine.get(purchaseOrder).get('expr9')).setScale(6))),
                                                                                                        Custom_Clearing_Agent__c=(purchaseOrderMap.get(purchaseOrder).Total_Port_Charges_without_custom_duty__c / purchaseOrderMap.get(purchaseOrder).Total_Quantity__c * purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).AcctSeedERP__Quantity__c).setScale(6),
                                                                                                        Total_Purchase_Price_1__c=(purchaseOrderMap.get(purchaseOrder).Total_PO_Value__c - (Decimal)aggregateResultofPurchaseOrderLine.get(purchaseOrder).get('expr3')).setScale(6),
                                                                                                        Local_Transportation__c=(purchaseOrderMap.get(purchaseOrder).Local_Transportation__c - (Decimal)aggregateResultofPurchaseOrderLine.get(purchaseOrder).get('expr5')).setScale(6),
                                                                                                        Other_Charges_1__c=(purchaseOrderMap.get(purchaseOrder).Other_Charges_1__c - (Decimal)aggregateResultofPurchaseOrderLine.get(purchaseOrder).get('expr6')).setScale(6),
                                                                                                        Other_Charges_2__c=(purchaseOrderMap.get(purchaseOrder).Other_Charges_2__c - (Decimal)aggregateResultofPurchaseOrderLine.get(purchaseOrder).get('expr7')).setScale(6)

                                                                ));
                                }else{
                                    purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Total_Freight_1__c = (purchaseOrderMap.get(purchaseOrder).Total_Ocean_Freight__c - (aggregateResultofPurchaseOrderLine.get(purchaseOrder) != null ? (Decimal)aggregateResultofPurchaseOrderLine.get(purchaseOrder).get('expr1') : 0) ).setScale(6);
                                    purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Clearing_Cost_Including_Custom_Duty__c = (purchaseOrderMap.get(purchaseOrder).Total_Custom_Duty__c + purchaseOrderMap.get(purchaseOrder).Total_Port_Charges_without_custom_duty__c - (aggregateResultofPurchaseOrderLine.get(purchaseOrder) != null ?(Decimal)aggregateResultofPurchaseOrderLine.get(purchaseOrder).get('expr2'):0)).setScale(6);
                                    purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Custom_Duty_Charges__c = (purchaseOrderMap.get(purchaseOrder).Total_Custom_Duty__c  - (aggregateResultofPurchaseOrderLine.get(purchaseOrder) != null ?(Decimal)aggregateResultofPurchaseOrderLine.get(purchaseOrder).get('expr9'):0)).setScale(6);
                                    purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Custom_Clearing_Agent__c = ( purchaseOrderMap.get(purchaseOrder).Total_Port_Charges_without_custom_duty__c - (aggregateResultofPurchaseOrderLine.get(purchaseOrder) != null ?(Decimal)aggregateResultofPurchaseOrderLine.get(purchaseOrder).get('expr8'):0)).setScale(6);
                                    purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Total_Purchase_Price_1__c = (purchaseOrderMap.get(purchaseOrder).Total_PO_Value__c- (aggregateResultofPurchaseOrderLine.get(purchaseOrder) != null ? (Decimal)aggregateResultofPurchaseOrderLine.get(purchaseOrder).get('expr3') : 0)).setScale(6);
                                    purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Local_Transportation__c = (purchaseOrderMap.get(purchaseOrder).Local_Transportation__c- (aggregateResultofPurchaseOrderLine.get(purchaseOrder) != null ? (Decimal)aggregateResultofPurchaseOrderLine.get(purchaseOrder).get('expr5') : 0)).setScale(6);
                                    purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Other_Charges_1__c = (purchaseOrderMap.get(purchaseOrder).Other_Charges_1__c- (aggregateResultofPurchaseOrderLine.get(purchaseOrder) != null ? (Decimal)aggregateResultofPurchaseOrderLine.get(purchaseOrder).get('expr6') : 0)).setScale(6);
                                    purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Other_Charges_2__c = (purchaseOrderMap.get(purchaseOrder).Other_Charges_2__c- (aggregateResultofPurchaseOrderLine.get(purchaseOrder) != null ? (Decimal)aggregateResultofPurchaseOrderLine.get(purchaseOrder).get('expr7') : 0)).setScale(6);

                                }
                    }else{
                        if(toUpdate){
                            purchaseOrderLineToUpdate.add(new AcctSeedERP__Purchase_Order_Line__c(Id=purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Id,Total_Freight_1__c= purchaseOrderMap.get(purchaseOrder).Total_Ocean_Freight__c / purchaseOrderMap.get(purchaseOrder).Total_Quantity__c * purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).AcctSeedERP__Quantity__c,
                                                                                Clearing_Cost_Including_Custom_Duty__c= (
                                                                                purchaseOrderMap.get(purchaseOrder).Total_Custom_Duty__c / purchaseOrderMap.get(purchaseOrder).Total_PO_Value__c * (purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).AcctSeedERP__Quantity__c * purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Purchase_Price__c))+
                                                                                (purchaseOrderMap.get(purchaseOrder).Total_Port_Charges_without_custom_duty__c / purchaseOrderMap.get(purchaseOrder).Total_Quantity__c * purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).AcctSeedERP__Quantity__c),
                                                                                Custom_Duty_Charges__c=purchaseOrderMap.get(purchaseOrder).Total_Custom_Duty__c / purchaseOrderMap.get(purchaseOrder).Total_PO_Value__c * (purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).AcctSeedERP__Quantity__c * purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Purchase_Price__c),
                                                                                Custom_Clearing_Agent__c=purchaseOrderMap.get(purchaseOrder).Total_Port_Charges_without_custom_duty__c / purchaseOrderMap.get(purchaseOrder).Total_Quantity__c * purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).AcctSeedERP__Quantity__c,
                                                                                Total_Purchase_Price_1__c= purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).AcctSeedERP__Quantity__c * purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Purchase_Price__c,
                                                                                Local_Transportation__c=(purchaseOrderMap.get(purchaseOrder).Local_Transportation__c - (Decimal)aggregateResultofPurchaseOrderLine.get(purchaseOrder).get('expr5')).setScale(6),
                                                                                Other_Charges_1__c=(purchaseOrderMap.get(purchaseOrder).Other_Charges_1__c - (Decimal)aggregateResultofPurchaseOrderLine.get(purchaseOrder).get('expr6')).setScale(6),
                                                                                Other_Charges_2__c=(purchaseOrderMap.get(purchaseOrder).Other_Charges_2__c - (Decimal)aggregateResultofPurchaseOrderLine.get(purchaseOrder).get('expr7')).setScale(6)
                                                                                ));
                                                                            
                        }else{

                            purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Total_Freight_1__c=purchaseOrderMap.get(purchaseOrder).Total_Ocean_Freight__c / purchaseOrderMap.get(purchaseOrder).Total_Quantity__c * purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).AcctSeedERP__Quantity__c;
                            purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Clearing_Cost_Including_Custom_Duty__c = (
                                purchaseOrderMap.get(purchaseOrder).Total_Custom_Duty__c / purchaseOrderMap.get(purchaseOrder).Total_PO_Value__c * (purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).AcctSeedERP__Quantity__c * purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Purchase_Price__c))+
                                (purchaseOrderMap.get(purchaseOrder).Total_Port_Charges_without_custom_duty__c / purchaseOrderMap.get(purchaseOrder).Total_Quantity__c * purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).AcctSeedERP__Quantity__c);
                            purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Custom_Duty_Charges__c= (
                                purchaseOrderMap.get(purchaseOrder).Total_Custom_Duty__c / purchaseOrderMap.get(purchaseOrder).Total_PO_Value__c * (purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).AcctSeedERP__Quantity__c * purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Purchase_Price__c));
                            purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Custom_Clearing_Agent__c  = 
                                (purchaseOrderMap.get(purchaseOrder).Total_Port_Charges_without_custom_duty__c / purchaseOrderMap.get(purchaseOrder).Total_Quantity__c * purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).AcctSeedERP__Quantity__c);
                            purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Total_Purchase_Price_1__c = purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).AcctSeedERP__Quantity__c * purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Purchase_Price__c;
                            purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Local_Transportation__c = purchaseOrderMap.get(purchaseOrder).Local_Transportation__c / purchaseOrderMap.get(purchaseOrder).Total_Quantity__c * purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).AcctSeedERP__Quantity__c;
                            purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Other_Charges_1__c = purchaseOrderMap.get(purchaseOrder).Other_Charges_1__c / purchaseOrderMap.get(purchaseOrder).Total_Quantity__c * purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).AcctSeedERP__Quantity__c;
                            purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Other_Charges_2__c = purchaseOrderMap.get(purchaseOrder).Other_Charges_2__c / purchaseOrderMap.get(purchaseOrder).Total_Quantity__c * purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).AcctSeedERP__Quantity__c;

                        //  purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).AcctSeedERP__Unit_Price__c= (purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Total_Freight_1__c+purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Clearing_Cost_Including_Custom_Duty__c+purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Total_Purchase_Price_1__c) / purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).AcctSeedERP__Quantity__c ;
                
                        }          
                    }
                }else{
                    System.debug('purchaseOrderMap.get(purchaseOrder).Total_Quantity__c >>'+purchaseOrderMap.get(purchaseOrder).Total_Quantity__c );
                    System.debug('purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).AcctSeedERP__Quantity__c >>'+purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).AcctSeedERP__Quantity__c );
                    System.debug('aggregateResultofPurchaseOrderLine.get(purchaseOrder).get() >>'+(aggregateResultofPurchaseOrderLine.get(purchaseOrder)!=null? (Decimal) aggregateResultofPurchaseOrderLine.get(purchaseOrder).get('expr0') :0) );

                    if(purchaseOrderMap.get(purchaseOrder).Total_Quantity__c == purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).AcctSeedERP__Quantity__c + (aggregateResultofPurchaseOrderLine.get(purchaseOrder)!=null? (Decimal) aggregateResultofPurchaseOrderLine.get(purchaseOrder).get('expr0') :0)){
                            if(toUpdate){
                                purchaseOrderLineToUpdate.add(new AcctSeedERP__Purchase_Order_Line__c(Id=purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Id,
                                                                Total_Freight_1__c= (purchaseOrderMap.get(purchaseOrder).Total_Ocean_Freight__c - (Decimal)aggregateResultofPurchaseOrderLine.get(purchaseOrder).get('expr1')).setScale(6),
                                                                Total_Purchase_Price_1__c=(purchaseOrderMap.get(purchaseOrder).Total_PO_Value__c - (Decimal)aggregateResultofPurchaseOrderLine.get(purchaseOrder).get('expr3')).setScale(6),
                                                                Other_Charges_1__c=(purchaseOrderMap.get(purchaseOrder).Other_Charges_1__c - (Decimal)aggregateResultofPurchaseOrderLine.get(purchaseOrder).get('expr6')).setScale(6),
                                                                Other_Charges_2__c=(purchaseOrderMap.get(purchaseOrder).Other_Charges_2__c - (Decimal)aggregateResultofPurchaseOrderLine.get(purchaseOrder).get('expr7')).setScale(6)

                                                            ));
                                    }else{
                                        purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Total_Freight_1__c = (purchaseOrderMap.get(purchaseOrder).Total_Ocean_Freight__c - (aggregateResultofPurchaseOrderLine.get(purchaseOrder) != null ? (Decimal)aggregateResultofPurchaseOrderLine.get(purchaseOrder).get('expr1') : 0) ).setScale(6);
                                        purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Total_Purchase_Price_1__c = (purchaseOrderMap.get(purchaseOrder).Total_PO_Value__c- (aggregateResultofPurchaseOrderLine.get(purchaseOrder) != null ? (Decimal)aggregateResultofPurchaseOrderLine.get(purchaseOrder).get('expr3') : 0)).setScale(6);
                                        purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Other_Charges_1__c = (purchaseOrderMap.get(purchaseOrder).Other_Charges_1__c- (aggregateResultofPurchaseOrderLine.get(purchaseOrder) != null ? (Decimal)aggregateResultofPurchaseOrderLine.get(purchaseOrder).get('expr6') : 0)).setScale(6);
                                        purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Other_Charges_2__c = (purchaseOrderMap.get(purchaseOrder).Other_Charges_2__c- (aggregateResultofPurchaseOrderLine.get(purchaseOrder) != null ? (Decimal)aggregateResultofPurchaseOrderLine.get(purchaseOrder).get('expr7') : 0)).setScale(6);
    
                                    }
                    }else{
                            if(toUpdate){
                                    purchaseOrderLineToUpdate.add(new AcctSeedERP__Purchase_Order_Line__c(Id=purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Id,
                                                                    Total_Freight_1__c= purchaseOrderMap.get(purchaseOrder).Total_Ocean_Freight__c / purchaseOrderMap.get(purchaseOrder).Total_Quantity__c * purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).AcctSeedERP__Quantity__c,
                                                                    Total_Purchase_Price_1__c= purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).AcctSeedERP__Quantity__c * purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Purchase_Price__c,
                                                                    Other_Charges_1__c=(purchaseOrderMap.get(purchaseOrder).Other_Charges_1__c - (Decimal)aggregateResultofPurchaseOrderLine.get(purchaseOrder).get('expr6')).setScale(6),
                                                                    Other_Charges_2__c=(purchaseOrderMap.get(purchaseOrder).Other_Charges_2__c - (Decimal)aggregateResultofPurchaseOrderLine.get(purchaseOrder).get('expr7')).setScale(6)
                                                            ));
                                                                                
                            }
                            else{
                                purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Total_Purchase_Price_1__c = purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).AcctSeedERP__Quantity__c * purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Purchase_Price__c;
                                purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Other_Charges_1__c = purchaseOrderMap.get(purchaseOrder).Other_Charges_1__c / purchaseOrderMap.get(purchaseOrder).Total_Quantity__c * purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).AcctSeedERP__Quantity__c;
                                purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Other_Charges_2__c = purchaseOrderMap.get(purchaseOrder).Other_Charges_2__c / purchaseOrderMap.get(purchaseOrder).Total_Quantity__c * purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).AcctSeedERP__Quantity__c;
                                purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).Total_Freight_1__c=purchaseOrderMap.get(purchaseOrder).Total_Ocean_Freight__c / purchaseOrderMap.get(purchaseOrder).Total_Quantity__c * purchaseOrderAndPurchaseOrderLineMap.get(purchaseOrder).AcctSeedERP__Quantity__c;
    
                            }          
                    }
                }
        
        }
            if(toUpdate){
                if(!purchaseOrderLineToUpdate.IsEmpty()){
                    update purchaseOrderLineToUpdate;
                }
            }
        
    }
    
    private void addFETProduct( List<AcctSeedERP__Purchase_Order_Line__c> newPurchaseOrderLine){
        System.debug('FET Product Item Create Start');
        Id domesticRecordTypeId = Schema.SObjectType.AcctSeedERP__Purchase_Order__c.getRecordTypeInfosByName().get('Purchase Order Domestic').getRecordTypeId();
        Set<Id> purchaseOrderId = new Set<Id>();
        for(AcctSeedERP__Purchase_Order_Line__c lineItem: newPurchaseOrderLine){
            purchaseOrderId.add(lineItem.AcctSeedERP__Purchase_Order__c);
        }
        Map<Id, Boolean> purchaseOrderAndDomesticRecordTypeMap = new Map<Id, Boolean>();
        for(AcctSeedERP__Purchase_Order__c po: [Select Id, RecordTypeId From AcctSeedERP__Purchase_Order__c Where Id In: purchaseOrderId]){
            if(domesticRecordTypeId.equals(po.RecordTypeId)){
                purchaseOrderAndDomesticRecordTypeMap.put(po.Id, true);
            }else{
                purchaseOrderAndDomesticRecordTypeMap.put(po.Id, false);
            }
        }
        
        Map<String, String> lineItemIdAndProductIdMap = new Map<String, String>();
        
        for(AcctSeedERP__Purchase_Order_Line__c lineItem: newPurchaseOrderLine){
            if(purchaseOrderAndDomesticRecordTypeMap.get(lineItem.AcctSeedERP__Purchase_Order__c)){
                lineItemIdAndProductIdMap.put(lineItem.Id, lineItem.AcctSeedERP__Product__c);
            }
        }

        Map<Id, Product2> allProducts = new Map<Id, Product2>([Select Id, FET_Product__c From Product2 Where Id In: lineItemIdAndProductIdMap.values()]);

        Set<Id> fetProductId = new Set<Id>();
        for(Product2 prod: allProducts.values()){
            if(prod.FET_Product__c != null){
                fetProductId.add(prod.FET_Product__c);
            }
        }
        System.debug('All Product ============>');
        System.debug(allProducts);
        System.debug(fetProductId);
        if(fetProductId.size() > 0){
            Map<Id, PricebookEntry> productIdAndPriceBookEntryMap = new Map<Id, PricebookEntry>();
            for(PricebookEntry entry: [Select Id, UnitPrice, Product2Id, Pricebook2Id From PricebookEntry Where Product2Id In: fetProductId AND Pricebook2.Name = 'Standard Price Book']){
                productIdAndPriceBookEntryMap.put(entry.Product2Id, entry);
            }
            System.debug('Price Book Entry ============>');
            System.debug(productIdAndPriceBookEntryMap);
            List<AcctSeedERP__Purchase_Order_Line__c> allFETProductLineItem = new List<AcctSeedERP__Purchase_Order_Line__c>();
            for(AcctSeedERP__Purchase_Order_Line__c lineItem: newPurchaseOrderLine){
                if(allProducts.get(lineItem.AcctSeedERP__Product__c).FET_Product__c != null){
                    AcctSeedERP__Purchase_Order_Line__c fetProductLineItem = new AcctSeedERP__Purchase_Order_Line__c();
                    fetProductLineItem.AcctSeedERP__Purchase_Order__c = lineItem.AcctSeedERP__Purchase_Order__c;
                    fetProductLineItem.AcctSeedERP__Product__c = allProducts.get(lineItem.AcctSeedERP__Product__c).FET_Product__c;
                    fetProductLineItem.AcctSeedERP__Quantity__c = lineItem.AcctSeedERP__Quantity__c;
                    fetProductLineItem.Purchase_Price__c = productIdAndPriceBookEntryMap.get(allProducts.get(lineItem.AcctSeedERP__Product__c).FET_Product__c).UnitPrice;
                    fetProductLineItem.Total_Purchase_Price_1__c = lineItem.AcctSeedERP__Quantity__c * productIdAndPriceBookEntryMap.get(allProducts.get(lineItem.AcctSeedERP__Product__c).FET_Product__c).UnitPrice;
                    allFETProductLineItem.add(fetProductLineItem);
                }
            }

            System.debug('Final Debug =========>');
            System.debug(allFETProductLineItem);

            if(allFETProductLineItem.size() > 0){
                insert allFETProductLineItem;
            }
        }
    }
}