public with sharing class InventoryBalanceCallout {
    @Future(callout=true)
    public static void post( set<Id> inventoryBalanceId) {
        Set<String> setProductSKU= new Set<String>();
        Set<String> setWareHouseName= new Set<String>();
        for(AcctSeedERP__Inventory_Balance__c inventoryBalance: [SELECT AcctSeedERP__Location__r.Name,AcctSeedERP__Available_Quantity__c,AcctSeedERP__Warehouse__r.Name,AcctSeedERP__Product__c,AcctSeedERP__Product__r.StockKeepingUnit   from AcctSeedERP__Inventory_Balance__c where id in :inventoryBalanceId]){
            setProductSKU.add(inventoryBalance.AcctSeedERP__Product__r.StockKeepingUnit);
            setWareHouseName.add(inventoryBalance.AcctSeedERP__Warehouse__r.Name);
        }

        Woocommerce_IQA_API__c creds = Woocommerce_IQA_API__c.getOrgDefaults();

        for(AggregateResult ar: [select sum(AcctSeedERP__Available_Quantity__c), AcctSeedERP__Warehouse__c, AcctSeedERP__Product__r.StockKeepingUnit,AcctSeedERP__Warehouse__r.Name  from AcctSeedERP__Inventory_Balance__c where AcctSeedERP__Product__r.StockKeepingUnit in :setProductSKU and AcctSeedERP__Warehouse__r.Name in :setWareHouseName  group by AcctSeedERP__Warehouse__c,AcctSeedERP__Product__r.StockKeepingUnit,AcctSeedERP__Warehouse__r.Name]){
            
            ProductData objPRod= new ProductData();       
            List<cls_ProductData> lstclsPrd= new List<cls_ProductData>();
             cls_ProductData clsPrd= new cls_ProductData();
            clsPrd.product_sku=String.Valueof(ar.get('StockKeepingUnit'));
            clsPrd.warehouse_id=String.Valueof(ar.get('AcctSeedERP__Warehouse__c'));
            clsPrd.stock_available=String.Valueof( ar.get('expr0'));
            lstclsPrd.add(clsPrd);       
            objPRod.ProductData=lstclsPrd;
            try {
                Http http = new Http();
                HttpRequest request = new HttpRequest();               
                Blob headerValue = Blob.valueOf(creds.header__c);
                request.setEndpoint(creds.Sync_URL__c);
                request.setMethod('POST');
                request.setHeader('Content-Type','application/json');
                request.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(headerValue));
                request.setBody(JSON.serialize(objPRod));
                HttpResponse response = http.send(request);
                
                
                
            } catch (Exception Ex) {
                System.debug('Ex   >>>>'+Ex.getMessage());
            }
        }
    }


    class ProductData {
        public cls_ProductData[] ProductData;        
    }
    class cls_ProductData {
            public String product_sku;	
            public String warehouse_id;	
            public String stock_available;	
        }
}