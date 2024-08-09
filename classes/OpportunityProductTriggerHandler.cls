public with sharing class OpportunityProductTriggerHandler implements ITriggerHandler {
    public Boolean IsDisabled(){		
        //  Trigger_Handler__mdt lstMetaData = [SELECT Disable__c FROM Trigger_Handler__mdt where MasterLabel='OpportunityProduct'];	
        return false;
        
    }
    public void BeforeInsert(List<Sobject> newItems){
        
        
        
    }
    //  public void BeforeUpdate(Map<id, sObject> newItems, Map<id, sObject> oldItems){   
    //  }
    
    public void BeforeDelete(Map<id, sObject> oldItems){
        
        Map<String,OpportunityLineItem> mapOppLineItemAndSKU= new Map<String,OpportunityLineItem>();
        Set<Id> SetoppId= new Set<Id>();
        
        for(OpportunityLineItem OppLineitem :  [Select Name,id,Quantity,Product2.StockKeepingUnit,OpportunityId from OpportunityLineItem where Id= :((Map<Id,OpportunityLineItem>)oldItems).keyset()]){
            SetoppId.add(OppLineitem.OpportunityId);
            if(OppLineitem.Product2.StockKeepingUnit !=null){
                if(OppLineitem.Product2.StockKeepingUnit.contains('-') ){
                    mapOppLineItemAndSKU.put(OppLineitem.Product2.StockKeepingUnit.SubString(0,OppLineitem.Product2.StockKeepingUnit.lastIndexOf('-')).trim(),OppLineitem);
                }
                else{
                    mapOppLineItemAndSKU.put(OppLineitem.Product2.StockKeepingUnit,OppLineitem);
                }
            }
        }
        
        if(!mapOppLineItemAndSKU.IsEmpty()){
            List<OpportunityLineItem> lstOppLineItem= [Select id,Quantity,Name,Product2.StockKeepingUnit,OpportunityId,Group__c from OpportunityLineItem where Group__c= :mapOppLineItemAndSKU.keyset() and OpportunityId=:SetoppId];
            
            List<OpportunityLineItem> lstOppLineItemToDelete = new  List<OpportunityLineItem>();
            
            for(Id triggerOppLineItem :  ((Map<Id,OpportunityLineItem>)oldItems).Keyset()){
				OpportunityLineItem oppLI = ((Map<Id,OpportunityLineItem>)oldItems).get(triggerOppLineItem);
                Decimal Quantity;
                if(oppLI.Name.contains('Set of 2')){
                    Quantity = 2 * oppLI.Quantity;
                }else if(oppLI.Name.contains('Set of 4')){
                    Quantity = 4 * oppLI.Quantity;
                }else if(oppLI.Name.contains('Set of 6')){
                    Quantity = 6 * oppLI.Quantity;
                }else if(oppLI.Name.contains('Set of 8')){
                    Quantity = 8 * oppLI.Quantity;
                }else{
                    Quantity = oppLI.Quantity;
                }
                Set<String> fetSet = new Set<String>();
                for( OpportunityLineItem opplineItem : lstOppLineItem ){
                    if(!fetSet.contains(opplineItem.Name)){
                        if(opplineItem.Id != triggerOppLineItem && opplineItem.Quantity == Quantity){
                            lstOppLineItemToDelete.add(opplineItem);
                            fetSet.add(opplineItem.Name);
                        }
                    }
                }
                
                
            } 
            
            if(lstOppLineItemToDelete.size() >0 ){
                try { delete lstOppLineItemToDelete; } catch (Exception Ex) {}
            }
        }
    }
    
    
    public void AfterInsert(List<Sobject> newMap){
        
        Set<Id> oppLineItemIds= new Set<Id>();
        List<Opportunity> lstOpportunityToUpdate= new List<Opportunity>();
        Map<Id,OpportunityLineItem>  MapToThrowError= new Map<Id,OpportunityLineItem>();
        for(OpportunityLineItem oppLine : ((List<OpportunityLineItem>)newMap)){   
            oppLineItemIds.add(oppLine.Id);
            MapToThrowError.put(oppLine.Id,oppLine);
            
        }
        
        List<OpportunityLineItem> lstOppLineitem=[Select Id,Name,TotalPrice,UnitPrice,Product2.Family,Product2.RecordType.Name, Product2.StockKeepingUnit,Product2.FET_Product__c,OpportunityId,Opportunity.Delivery_Type__c,Opportunity.Account.ShippingState,Opportunity.Account.RecordType.Name,Quantity,Product2.Section_Width__c,Product2.Aspect_Ratio__c,Product2.RIM__c,Opportunity.Pricebook2Id,Opportunity.Has_Line_Item__c,Opportunity.Opportunity_Type__c,Opportunity.RecordType.Name from OpportunityLineItem where id in :oppLineItemIds and Product2.Family='Sales Product'];
        
        Set<Id> setProceBookId= new Set<Id>();
        Set<Id> setFETProductId= new Set<Id>();
        List<OpportunityLineItem> letNewOppLineItemToInsert= new List<OpportunityLineItem>();
        Map<Id,OpportunityLineItem> MapOppLineItem= new Map<Id,OpportunityLineItem>();
        String strDeliveryType;
        for(OpportunityLineItem oppLineItem:lstOppLineitem){
            if(oppLineItem.Opportunity.Has_Line_Item__c == false){
                
                MapOppLineItem.put(oppLineItem.Id,oppLineItem);
                setProceBookId.add(oppLineItem.Opportunity.Pricebook2Id);
                setFETProductId.add(oppLineItem.Product2.FET_Product__c);
                lstOpportunityToUpdate.add(new Opportunity(Id=oppLineItem.OpportunityId,Has_Line_Item__c=true));
                strDeliveryType=oppLineItem.Opportunity.Delivery_Type__c;
                
            }
            // letNewOppLineItemToInsert.add(new OpportunityLineItem)
        }
        
        
        if(MapOppLineItem.size()>0){
            
            Map<Id,PricebookEntry> mapPriceBookEntryFET= new Map<Id,PricebookEntry>();
            
            List<PricebookEntry> proceBookEntryofFET = [SELECT Id,product2Id, UnitPrice,Pricebook2Id  from pricebookentry where Product2Id =:setFETProductId and Pricebook2Id =:setProceBookId];
            
            
            for(PricebookEntry Pe: proceBookEntryofFET){
                mapPriceBookEntryFET.put(Pe.Product2Id,pe);
                
            }
            for(Id OppLineItemId : MapOppLineItem.KeySet()){
                
                Decimal Quantity;
                if(MapOppLineItem.get(OppLineItemId).Name.contains('Set of 2')){
                    Quantity=MapOppLineItem.get(OppLineItemId).Quantity*2;
                }
                else if(MapOppLineItem.get(OppLineItemId).Name.contains('Set of 4')){
                    Quantity=MapOppLineItem.get(OppLineItemId).Quantity*4;
                }
                else if(MapOppLineItem.get(OppLineItemId).Name.contains('Set of 6')){
                    Quantity=MapOppLineItem.get(OppLineItemId).Quantity*6;
                }
                else if(MapOppLineItem.get(OppLineItemId).Name.contains('Set of 8')){
                    Quantity=MapOppLineItem.get(OppLineItemId).Quantity*8;
                }
                else{
                    Quantity=MapOppLineItem.get(OppLineItemId).Quantity;
                }
                string MasterProductSku=null;
                if(MapOppLineItem.get(OppLineItemId).Product2.StockKeepingUnit != null){
                    if(MapOppLineItem.get(OppLineItemId).Product2.StockKeepingUnit.contains('-')){
                        MasterProductSku=MapOppLineItem.get(OppLineItemId).Product2.StockKeepingUnit.SubString(0,MapOppLineItem.get(OppLineItemId).Product2.StockKeepingUnit.lastIndexOf('-'));
                    }
                    else{
                        MasterProductSku=MapOppLineItem.get(OppLineItemId).Product2.StockKeepingUnit;
                    }
                }
                if(MapOppLineItem.get(OppLineItemId).Product2.RecordType.Name !='Add on Services'){
                    if(MapOppLineItem.get(OppLineItemId).Opportunity.RecordType.Name !='B2B Container'){

                        //If(!Test.IsRunningTest()){
                            letNewOppLineItemToInsert.add(new OpportunityLineItem( Product2Id=MapOppLineItem.get(OppLineItemId).Product2.FET_Product__c,Quantity=Quantity,OpportunityId=MapOppLineItem.get(OppLineItemId).OpportunityId,UnitPrice=mapPriceBookEntryFET.get(MapOppLineItem.get(OppLineItemId).Product2.FET_Product__c).UnitPrice,PricebookEntryId=mapPriceBookEntryFET.get(MapOppLineItem.get(OppLineItemId).Product2.FET_Product__c).Id,Group__c=MasterProductSku, Parent_Line_Item__c=OppLineItemId));
                        //}
                    }
                    else{
                        
                        if(MapOppLineItem.get(OppLineItemId).Opportunity.Opportunity_Type__C != 'Factory to Customer' && MapOppLineItem.get(OppLineItemId).Opportunity.Opportunity_Type__C != 'Maestro'){
                            if(MapOppLineItem.get(OppLineItemId).Opportunity.Opportunity_Type__C != 'Dropship' || MapOppLineItem.get(OppLineItemId).Opportunity.Account.RecordType.Name !='Reseller'){
                                letNewOppLineItemToInsert.add(new OpportunityLineItem( Product2Id=MapOppLineItem.get(OppLineItemId).Product2.FET_Product__c,Quantity=Quantity,OpportunityId=MapOppLineItem.get(OppLineItemId).OpportunityId,UnitPrice=mapPriceBookEntryFET.get(MapOppLineItem.get(OppLineItemId).Product2.FET_Product__c).UnitPrice,PricebookEntryId=mapPriceBookEntryFET.get(MapOppLineItem.get(OppLineItemId).Product2.FET_Product__c).Id,Group__c=MasterProductSku, Parent_Line_Item__c=OppLineItemId));
                                
                            }else {
                                letNewOppLineItemToInsert.add(new OpportunityLineItem( Product2Id=MapOppLineItem.get(OppLineItemId).Product2.FET_Product__c,Quantity=Quantity,OpportunityId=MapOppLineItem.get(OppLineItemId).OpportunityId,UnitPrice=mapPriceBookEntryFET.get(MapOppLineItem.get(OppLineItemId).Product2.FET_Product__c).UnitPrice,PricebookEntryId=mapPriceBookEntryFET.get(MapOppLineItem.get(OppLineItemId).Product2.FET_Product__c).Id,Group__c=MasterProductSku, Parent_Line_Item__c=OppLineItemId));
                                
                            }
                        }
                        
                    }
                }
                
                
                
                
                
            }
            
            if(!letNewOppLineItemToInsert.IsEmpty()){
                insert letNewOppLineItemToInsert;
            }
            if(!lstOpportunityToUpdate.IsEmpty()){
                
                Map<Id,Opportunity> mapOpp=new Map<Id,Opportunity>();
                for( Opportunity opp:lstOpportunityToUpdate){
                    mapOpp.put(opp.id,opp);
                }
                update (List<Opportunity>)mapOpp.values();
            }
            
            
            
            
        }
        
        
    } 
    
    //  public void AfterUndelete(List<Sobject> newMap){
    public void AfterUpdate(Map<Id, sObject> newMap, Map<Id, sObject> oldMap){
        Map<Id,OpportunityLineItem> oppLineItemMap= (Map<Id,OpportunityLineItem>)newMap;
        Map<Id,OpportunityLineItem> oldOppLineItems= (Map<Id,OpportunityLineItem>)oldMap;
        System.debug('Update Method Called ==========>');
        Map<Id, OpportunityLineItem> changedLineItems = new Map<Id, OpportunityLineItem>();
        for(OpportunityLineItem oppLineItem: oppLineItemMap.values()){
            if(oppLineItem.Quantity != oldOppLineItems.get(oppLineItem.Id).Quantity){
                changedLineItems.put(oppLineItem.Id, oppLineItem);
            }
        }
        System.debug(changedLineItems);
        
        Map<Id, OpportunityLineItem> allFETProducts = new Map<Id, OpportunityLineItem>();
        Map<String, String> lineItemIdAndFetIdMap = new Map<String, String>();
        for(OpportunityLineItem oppLineItem: [Select Name, Quantity, (Select Id, Quantity, Parent_Line_Item__c From Opportunity_Product__r) from OpportunityLineItem where Id= : changedLineItems.keyset()]){
            if(oppLineItem.Opportunity_Product__r.size() > 0){
                for(OpportunityLineItem childLineItem: oppLineItem.Opportunity_Product__r){
                    allFETProducts.put(childLineItem.Id, childLineItem);
                    lineItemIdAndFetIdMap.put(childLineItem.Id, oppLineItem.Id);
                }
                //allFETProducts.put(oppLineItem.Opportunity_Product__r[0].Id, oppLineItem.Opportunity_Product__r[0]);
                //lineItemIdAndFetIdMap.put(oppLineItem.Opportunity_Product__r[0].Id, oppLineItem.Id);
            }
        }
        
        System.debug(allFETProducts);
        System.debug(lineItemIdAndFetIdMap);
        
        for(OpportunityLineItem fetLineItem: allFETProducts.values()){
            fetLineItem.Quantity = changedLineItems.get(lineItemIdAndFetIdMap.get(fetLineItem.Id)).Quantity;
            if(changedLineItems.get(lineItemIdAndFetIdMap.get(fetLineItem.Id)).Name.containsIgnoreCase('Set of 2')){
                fetLineItem.Quantity = changedLineItems.get(lineItemIdAndFetIdMap.get(fetLineItem.Id)).Quantity*2;
            }
            else if(changedLineItems.get(lineItemIdAndFetIdMap.get(fetLineItem.Id)).Name.containsIgnoreCase('Set of 4')){
                fetLineItem.Quantity = changedLineItems.get(lineItemIdAndFetIdMap.get(fetLineItem.Id)).Quantity*4;
            }
            else if(changedLineItems.get(lineItemIdAndFetIdMap.get(fetLineItem.Id)).Name.containsIgnoreCase('Set of 6')){
                fetLineItem.Quantity = changedLineItems.get(lineItemIdAndFetIdMap.get(fetLineItem.Id)).Quantity*6;
            }
            else if(changedLineItems.get(lineItemIdAndFetIdMap.get(fetLineItem.Id)).Name.containsIgnoreCase('Set of 8')){
                fetLineItem.Quantity = changedLineItems.get(lineItemIdAndFetIdMap.get(fetLineItem.Id)).Quantity*8;
            }
            else{
                fetLineItem.Quantity = changedLineItems.get(lineItemIdAndFetIdMap.get(fetLineItem.Id)).Quantity;
            }
        }
        System.debug(allFETProducts.values());
        if(allFETProducts.size() > 0){
            update allFETProducts.values();
        }
        
        
        
        
        /*Map<Id,OpportunityLineItem> oppLineItemMap= (Map<Id,OpportunityLineItem>)newMap;
        Map<String,OpportunityLineItem> mapOppLineItemAndSKU= new Map<String,OpportunityLineItem>();
        
        List<OpportunityLineItem> oppLineItemToUpdate= new List<OpportunityLineItem>();
        Set<Id> SetoppId= new Set<Id>();
        
        Map<Id,Decimal> mapOpplineAndUnitPrice= new Map<Id,Decimal>();
        
        for(OpportunityLineItem oppLineItem :  ((Map<Id,OpportunityLineItem>)newMap).values()){
            
            OpportunityLineItem oldOppItem = (OpportunityLineItem) oldMap.get(oppLineItem.ID);
            OpportunityLineItem newOpItem  = (OpportunityLineItem) newMap.get(oppLineItem.ID);  
            if(oldOppItem.UnitPrice  != newOpItem.UnitPrice)
            {
                
                mapOpplineAndUnitPrice.put(newOpItem.Id,newOpItem.UnitPrice);     
            }
            
        }  
        
        
        for(OpportunityLineItem OppLineitem :  [Select Name,id,Quantity,Product2.StockKeepingUnit,OpportunityId,Product2.Name from OpportunityLineItem where Id= :((Map<Id,OpportunityLineItem>)newMap).keyset()]){
            SetoppId.add(OppLineitem.OpportunityId);
            if(OppLineitem.Product2.StockKeepingUnit !=null){
                
                if(!OppLineitem.Product2.StockKeepingUnit.contains('- FET')){
                    if(OppLineitem.Product2.StockKeepingUnit.contains('-') ){
                        mapOppLineItemAndSKU.put(OppLineitem.Product2.StockKeepingUnit.SubString(0,OppLineitem.Product2.StockKeepingUnit.lastIndexOf('-')).trim(),OppLineitem);
                    }
                    else{
                        mapOppLineItemAndSKU.put(OppLineitem.Product2.StockKeepingUnit,OppLineitem);
                    }
                }
                
            }
        }
        
        if(!mapOppLineItemAndSKU.IsEmpty()){
            for(OpportunityLineItem OppLineitem : [Select id,Quantity,Name,Product2.StockKeepingUnit,OpportunityId,Group__c,UnitPrice,Product2.Name from OpportunityLineItem where Group__c= :mapOppLineItemAndSKU.keyset() and OpportunityId=:SetoppId]){
                Decimal Quantity = 0;
                Decimal UnitPrice = 0;
                if(mapOppLineItemAndSKU.get(OppLineitem.Group__c).Name.containsIgnoreCase('Set of 2')){
                    Quantity=mapOppLineItemAndSKU.get(OppLineitem.Group__c).Quantity*2;
                }
                else if(mapOppLineItemAndSKU.get(OppLineitem.Group__c).Name.containsIgnoreCase('Set of 4')){
                    Quantity=mapOppLineItemAndSKU.get(OppLineitem.Group__c).Quantity*4;
                }
                else if(mapOppLineItemAndSKU.get(OppLineitem.Group__c).Name.containsIgnoreCase('Set of 6')){
                    Quantity=mapOppLineItemAndSKU.get(OppLineitem.Group__c).Quantity*6;
                }
                else if(mapOppLineItemAndSKU.get(OppLineitem.Group__c).Name.containsIgnoreCase('Set of 8')){
                    Quantity=mapOppLineItemAndSKU.get(OppLineitem.Group__c).Quantity*8;
                }
                else{
                    Quantity=mapOppLineItemAndSKU.get(OppLineitem.Group__c).Quantity;
                }
                if(mapOpplineAndUnitPrice.containsKey(OppLineitem.Id)){
                    UnitPrice=mapOpplineAndUnitPrice.get(OppLineitem.Id);
                }else{
                    UnitPrice=OppLineitem.UnitPrice;
                }
                
                // if(OppLineitem.Product2.Name != 'State Fee'){
                oppLineItemToUpdate.add(new OpportunityLineItem(Id=OppLineitem.Id,Quantity=Quantity,UnitPrice=UnitPrice));
                // }
                // else{
                //     oppLineItemToUpdate.add(new OpportunityLineItem(Id=OppLineitem.Id,Quantity=Quantity));
                // }
                
            }
            
        }
        if(!oppLineItemToUpdate.IsEmpty()){
            update oppLineItemToUpdate;
        }*/
        
    }
}