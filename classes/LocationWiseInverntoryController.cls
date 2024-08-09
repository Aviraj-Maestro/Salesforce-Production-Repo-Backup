public with sharing class LocationWiseInverntoryController {
    @AuraEnabled
    public static List<Warehouse> getRelevantWarehouses(Id opportunityId){
        List<Warehouse> warehouses = new List<Warehouse>();
        System.debug('========== Method Called ==========');
        System.debug('Opportunity Id : ' + opportunityId);
        
        String sObjName = opportunityId.getSObjectType().getDescribe().getName();
        
        String warehouseId = null;
        String warehouseState = null;
        if(String.isNotBlank(opportunityId)){
            Map<String, String> allProducts = new Map<String, String>();
            //Set<String> allLocationIds = new Set<String>();
            Set<String> allWarehouseIds = new Set<String>();
            if(sObjName == 'Opportunity'){
                for(Opportunity opp : [Select Id, Warehouse_Location__c, Warehouse_Location__r.Name, Delivery_Type__c, Account.ShippingState, (Select id, Name, product2Id, Product2.Name,Product2.Product_Master__r.Name,Product2.Product_Master__c,Product2.Product_Type__c from opportunityLineItems where product2.Family = 'Sales Product') from Opportunity where Id =: opportunityId]){
                    if(opp.Delivery_Type__c == 'Door Delivery'){
                        warehouseState = opp.Account.ShippingState;
                    }else{
                        warehouseId = opp.Warehouse_Location__c;
                    }
                    
                    if(opp.opportunityLineItems.size() > 0){
                        for(opportunityLineItem lineItem : opp.opportunityLineItems){
                            if(lineItem.Product2.Product_Type__c == 'Base Product'){
                                allProducts.put(lineItem.product2Id, lineItem.Product2.Name);
                            }else if(lineItem.Product2.Product_Type__c == 'kit Product'){
                                allProducts.put(lineItem.Product2.Product_Master__c, lineItem.Product2.Name);
                            }
                        }
                    }
                } 
            }
            else if(sObjName == 'Quote'){
                for(Quote qte : [Select Id, Opportunity.Warehouse_Location__c, Opportunity.Warehouse_Location__r.Name,Opportunity.Delivery_Type__c, Opportunity.Account.ShippingState, (Select id, product2Id, Product2.Name,Product2.Product_Master__r.Name,Product2.Product_Master__c,Product2.Product_Type__c from QuoteLineItems where product2.Family = 'Sales Product') from quote where Id =: opportunityId]){
                    if(qte.Opportunity.Delivery_Type__c == 'Door Delivery'){
                        warehouseState = qte.Opportunity.Account.ShippingState;
                    }else{
                        warehouseId = qte.Opportunity.Warehouse_Location__c;
                    }
                    
                    if(qte.QuoteLineItems.size() > 0){
                        for(QuoteLineItem lineItem : qte.QuoteLineItems){
                            if(lineItem.Product2.Product_Type__c == 'Base Product'){
                                allProducts.put(lineItem.product2Id, lineItem.Product2.Name);
                            }else if(lineItem.Product2.Product_Type__c == 'kit Product'){
                                allProducts.put(lineItem.Product2.Product_Master__c, lineItem.Product2.Name);
                            }
                        }
                    }
                    
                }
            }
            System.debug('Checkpoint - 1');
            System.debug(warehouseId);
            System.debug(warehouseState);
            System.debug(allProducts);

            List<AcctSeedERP__Warehouse__c> relevantWarehouseRecords = new List<AcctSeedERP__Warehouse__c>();
            if(String.isNotBlank(warehouseId)){
                for(AcctSeedERP__Warehouse__c warehouseRecord : [Select id, Name, (Select id, Name from AcctSeedERP__Locations__r) from AcctSeedERP__Warehouse__c where Id =: warehouseId]){
                    /*if(warehouseRecord.AcctSeedERP__Locations__r.size() > 0){
                        for(AcctSeedERP__Location__c location : warehouseRecord.AcctSeedERP__Locations__r){
                        	allLocationIds.add(location.Id);
                        }
                    }*/
                    allWarehouseIds.add(warehouseRecord.Id);
                    relevantWarehouseRecords.add(warehouseRecord);
                }
            //}else if(String.isNotBlank(warehouseState)){ // Commented this condition as warehouseState is not used further in any condition.
            }else{
                for(AcctSeedERP__Warehouse__c warehouseRecord : [Select id, Name, (Select id, Name from AcctSeedERP__Locations__r) from AcctSeedERP__Warehouse__c]){
                    /*if(warehouseRecord.AcctSeedERP__Locations__r.size() > 0){
                        for(AcctSeedERP__Location__c location : warehouseRecord.AcctSeedERP__Locations__r){
                        	allLocationIds.add(location.Id);
                        }
                    }*/
                    allWarehouseIds.add(warehouseRecord.Id);
                    relevantWarehouseRecords.add(warehouseRecord);
                }
            }
            System.debug('Checkpoint - 2');
            System.debug(allWarehouseIds);
            System.debug(relevantWarehouseRecords);
            Map<String, AcctSeedERP__Inventory_Balance__c> prodBalceMap = new Map<String, AcctSeedERP__Inventory_Balance__c>();
            Map<String, Map<String, Decimal>> warehouseProductQtyMap = new Map<String, Map<String, Decimal>>();
            //Map<String, List<AcctSeedERP__Inventory_Balance__c>> locationToBalanceMap = new Map<String, List<AcctSeedERP__Inventory_Balance__c>>();
            for(AcctSeedERP__Inventory_Balance__c InventoryBalance : [Select id, Qty_Available__c, AcctSeedERP__Available_Quantity__c, AcctSeedERP__Sales_Order_Quantity__c,AcctSeedERP__Warehouse__c, AcctSeedERP__Product__c, AcctSeedERP__Product__r.AXLE_POSITION__c,AcctSeedERP__Product__r.Name, AcctSeedERP__Location__c from AcctSeedERP__Inventory_Balance__c where AcctSeedERP__Warehouse__c IN: allWarehouseIds]){//AcctSeedERP__Product__c IN: allProducts.keySet() AND
                /*if(!locationToBalanceMap.containsKey(InventoryBalance.AcctSeedERP__Location__c)){
                    locationToBalanceMap.put(InventoryBalance.AcctSeedERP__Location__c, new List<AcctSeedERP__Inventory_Balance__c>());
                }
                locationToBalanceMap.get(InventoryBalance.AcctSeedERP__Location__c).add(InventoryBalance);*/
                if(!warehouseProductQtyMap.containsKey(InventoryBalance.AcctSeedERP__Warehouse__c)){
                    warehouseProductQtyMap.put(InventoryBalance.AcctSeedERP__Warehouse__c, new Map<String, Decimal>());
                    warehouseProductQtyMap.get(InventoryBalance.AcctSeedERP__Warehouse__c).put(InventoryBalance.AcctSeedERP__Product__c, InventoryBalance.AcctSeedERP__Available_Quantity__c);
                }else if(!warehouseProductQtyMap.get(InventoryBalance.AcctSeedERP__Warehouse__c).containsKey(InventoryBalance.AcctSeedERP__Product__c)){
                    warehouseProductQtyMap.get(InventoryBalance.AcctSeedERP__Warehouse__c).put(InventoryBalance.AcctSeedERP__Product__c, InventoryBalance.AcctSeedERP__Available_Quantity__c);
                }else {
                    Decimal qtyToIncrement = warehouseProductQtyMap.get(InventoryBalance.AcctSeedERP__Warehouse__c).get(InventoryBalance.AcctSeedERP__Product__c)+InventoryBalance.AcctSeedERP__Available_Quantity__c;
                    warehouseProductQtyMap.get(InventoryBalance.AcctSeedERP__Warehouse__c).put(InventoryBalance.AcctSeedERP__Product__c, qtyToIncrement);
                }
                prodBalceMap.put(InventoryBalance.AcctSeedERP__Product__c, InventoryBalance);
            }
            System.debug('Checkpoint - 3');
            System.debug(prodBalceMap);
            System.debug(warehouseProductQtyMap);
            Map<String, Decimal> prodOrderedQtyMap = new Map<String, Decimal>();
            for(AcctSeedERP__Sales_Order_Line__c salesOrderLine :[Select Id, AcctSeedERP__Quantity_Ordered__c, AcctSeedERP__Product__c from AcctSeedERP__Sales_Order_Line__c where AcctSeedERP__Product__c IN: prodBalceMap.keySet()]){
                if(!prodOrderedQtyMap.containsKey(salesOrderLine.AcctSeedERP__Product__c)){
                    prodOrderedQtyMap.put(salesOrderLine.AcctSeedERP__Product__c, salesOrderLine.AcctSeedERP__Quantity_Ordered__c);
                }else{
                    Decimal ordQty = prodOrderedQtyMap.get(salesOrderLine.AcctSeedERP__Product__c) + salesOrderLine.AcctSeedERP__Quantity_Ordered__c;
                    prodOrderedQtyMap.put(salesOrderLine.AcctSeedERP__Product__c, ordQty);
                }
            }
            System.debug('Checkpoint - 4');
            System.debug(prodOrderedQtyMap);
            if(relevantWarehouseRecords.size() > 0){
                for(AcctSeedERP__Warehouse__c warehouseRecord : relevantWarehouseRecords){
                    if(warehouseProductQtyMap.containsKey(warehouseRecord.Id)){
                        Map<String, Inventory> inventories = new Map<String, Inventory>();
                        for(String productId : warehouseProductQtyMap.get(warehouseRecord.Id).keyset()){
                            Inventory inventoryVar = new Inventory();
                            inventoryVar.productId = productId;
                            inventoryVar.productName = prodBalceMap.get(productId).AcctSeedERP__Product__r.Name;
                            inventoryVar.availableQuantity = warehouseProductQtyMap.get(warehouseRecord.Id).get(productId);
                            inventoryVar.axlePosition = prodBalceMap.get(productId).AcctSeedERP__Product__r.AXLE_POSITION__c;
                            inventoryVar.allocationWaitingQuantity = prodOrderedQtyMap.get(productId);
                            if(allProducts.containsKey(productId)){
                                inventoryVar.selected = true;
                            }
                            inventories.put(productId, inventoryVar);
                        }
                        /*if(inventories.size() != allProducts.size()){
                            for(String productId : allProducts.keySet()){
                                if(!inventories.containsKey(productId)){
                                    Inventory inventoryVar = new Inventory();
                                    inventoryVar.productId = productId;
                                    inventoryVar.productName = allProducts.get(productId);
                                    inventoryVar.availableQuantity = 0;
                                    inventoryVar.allocationWaitingQuantity = 0;
                                    inventories.put(productId, inventoryVar);
                                }
                            }
                        }*/
                        Warehouse warehouseVar = new Warehouse();
                        warehouseVar.warehouseId = warehouseRecord.Id;
                        warehouseVar.warehouseName = warehouseRecord.Name;
                        warehouseVar.productLevelInventory = inventories.values();
                        warehouses.add(warehouseVar);
                    }
					System.debug('Checkpoint - 5');
            		System.debug(warehouses);
                    /*List<Location> locations = new List<Location>();
                    //if(warehouseRecord.AcctSeedERP__Locations__r.size() > 0){
                        //for(AcctSeedERP__Location__c locationRecord : warehouseRecord.AcctSeedERP__Locations__r){
                            if(warehouseToBalanceMap.containsKey(warehouseRecord.Id)){
                                Map<String, Inventory> inventories = new Map<String, Inventory>();
                                for(AcctSeedERP__Inventory_Balance__c balance : warehouseToBalanceMap.get(warehouseRecord.Id)){
                                    Inventory inventoryVar = new Inventory();
                                    inventoryVar.productId = balance.AcctSeedERP__Product__c;
                                    inventoryVar.productName = balance.AcctSeedERP__Product__r.Name;
                                    inventoryVar.availableQuantity = balance.AcctSeedERP__Available_Quantity__c;
                                    inventories.put(balance.AcctSeedERP__Product__c, inventoryVar);
                                }

                                if(inventories.size() != allProducts.size()){
                                    for(String productId : allProducts.keySet()){
                                        if(!inventories.containsKey(productId)){
                                            Inventory inventoryVar = new Inventory();
                                            inventoryVar.productId = productId;
                                            inventoryVar.productName = allProducts.get(productId);
                                            inventoryVar.availableQuantity = 0;
                                            inventories.put(productId, inventoryVar);
                                        }
                                    }
                                }


                                
                                Location locationVar = new Location();
                                locationVar.locationId = locationRecord.Id;
                                locationVar.locationName = locationRecord.Name;
                                locationVar.productLevelInventory = inventories.values();
                                locations.add(locationVar);
                            }else{
                                Map<String, Inventory> inventories = new Map<String, Inventory>();

                                for(String productId : allProducts.keySet()){
                                    Inventory inventoryVar = new Inventory();
                                    inventoryVar.productId = productId;
                                    inventoryVar.productName = allProducts.get(productId);
                                    inventoryVar.availableQuantity = 0;
                                    inventories.put(productId, inventoryVar);
                                }

                                Location locationVar = new Location();
                                locationVar.locationId = locationRecord.Id;
                                locationVar.locationName = locationRecord.Name;
                                locationVar.productLevelInventory = inventories.values();
                                locations.add(locationVar);
                            }
                        }
                    }

                    Warehouse warehouseVar = new Warehouse();
                    warehouseVar.warehouseId = warehouseRecord.Id;
                    warehouseVar.warehouseName = warehouseRecord.Name;
                    warehouseVar.locations = locations;
                    warehouses.add(warehouseVar);*/
                }
            }
        }
        
        return warehouses;
    }


    Public Class Warehouse{
        @AuraEnabled Public String warehouseId{get;set;}
        @AuraEnabled Public String warehouseName{get;set;}
        @AuraEnabled Public Boolean isDrawerOpen{get;set;}
        @AuraEnabled Public List<Inventory> productLevelInventory{get;set;}
        //@AuraEnabled Public List<Location> locations{get;set;}

        Public Warehouse(){
            this.isDrawerOpen = false;
        }
    }

    /*Public Class Location{
        @AuraEnabled Public String locationId{get;set;}
        @AuraEnabled Public String locationName{get;set;}
        @AuraEnabled Public Boolean isDrawerOpen{get;set;}
        @AuraEnabled Public List<Inventory> productLevelInventory{get;set;}

        Public Location(){
            this.isDrawerOpen = false;
        }
    }*/

    Public Class Inventory{
        @AuraEnabled Public String productId{get;set;}
        @AuraEnabled Public String productName{get;set;}
        @AuraEnabled Public Decimal availableQuantity{get;set;}
        @AuraEnabled Public Decimal allocationWaitingQuantity{get;set;}
        @AuraEnabled Public String axlePosition{get;set;}
        @AuraEnabled Public Boolean selected{get;set;}
        //@AuraEnabled Public AcctSeedERP__Inventory_Balance__c inventoryRecord{get;set;}
        public Inventory (){
            this.selected = false;
        }
    }

    Public Class Product{

    }
}