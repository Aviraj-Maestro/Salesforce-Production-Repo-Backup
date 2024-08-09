@RestResource(urlMapping='/api/Order/')
global  class PlaceOrderFromWoocomerce {
    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Account acct;
        Contact cont;
        Set<Id> ToGetParentProductId= new Set<Id>();
        Map<String, Object> responseMap =   (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
        System.debug('responseMap >>>'+ req.requestBody.toString());
        Id AccountId;
        String ShippingState;
        String ShippingAddress;
        String ShippingCity;
        String ShippingCountry;
        String ShippingPostcode;
        AcctSeedERP__Warehouse__c wareHouse=new AcctSeedERP__Warehouse__c();
        Map<String,Object> MapVal= (Map<String, Object>)responseMap.get('customer_info');     
            for(String MapValues :  MapVal.keyset()){             
                if(MapValues == 'mwb_salesforce_Account_id'){
                    AccountId=(Id)MapVal.get(MapValues);           
                }       
            }
        //}
        Set<Id> setWareHouse= new Set<Id>();
       
        Map<String,Object> MapWareHouseInformation= (Map<String, Object>)responseMap.get('warehouse_info'); 
        List<Object> ShippingLines= (List<Object>)responseMap.get('shipping_lines');
        Map<String,Object> MapShippingInformation= (Map<String, Object>)responseMap.get('shipping'); 

        Map<String,Object> MapShippingLinesInformation= (Map<String, Object>)ShippingLines[0];      
        if (MapWareHouseInformation == null || MapWareHouseInformation.isEmpty()) {
            for(String MapShippingValues :  MapShippingInformation.keyset()){          
                switch on MapShippingValues {
                    when 'state' {		
                        ShippingState=(String)MapShippingInformation.get(MapShippingValues); 
                    }
                    when 'address_1' {		
                        ShippingAddress=(String)MapShippingInformation.get(MapShippingValues); 
                    }	
                    when 'city' {		
                        ShippingCity=(String)MapShippingInformation.get(MapShippingValues); 
                    }
                    when 'country' {	
                        ShippingCountry=(String)MapShippingInformation.get(MapShippingValues); 
                    }
                    when 'postcode' {		  
                        ShippingPostcode=(String)MapShippingInformation.get(MapShippingValues); 
                    }
                }
            }
        }
        else
        {
           
            setWareHouse.add((Id)MapWareHouseInformation.get('warehouse_sf_id'));
            wareHouse=[select State__c,Country__c,City__c,Street__c,Zip_Code__c from AcctSeedERP__Warehouse__c where Id=:(Id)MapWareHouseInformation.get('warehouse_sf_id') Limit 1];
            ShippingState=wareHouse.State__c;
        }
     
       
        if(AccountId == null){
            Map<String,Object> MapBillingInformation= (Map<String, Object>)responseMap.get('billing'); 
            String FirstName;
            String LastName;
            String UserEmail;
            String Phone;
            String CompanyName='';
            String RecordType;
             acct= new Account();
             cont= new Contact();
             Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Customer').getRecordTypeId();
             acct.RecordTypeId=recordTypeId;
            for(String MapValues :  MapVal.keyset()){          
                switch on MapValues {
                    when 'user_email' {		
                        acct.Email__c=(String)MapVal.get(MapValues); 
                        UserEmail=(String)MapVal.get(MapValues);
                    }
                    when 'company_name' {		
                        CompanyName=(String)MapVal.get(MapValues); 
                    }	
                    when 'phone_number' {		
                        Phone=(String)MapVal.get(MapValues); 
                    }		
                    when 'first_name' {		
                        FirstName=(String)MapVal.get(MapValues);      
                    }
                    when 'last_name' {		
                        LastName=(String)MapVal.get(MapValues); 
                    }
                    when 'record_type' {
                        recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get((String)MapVal.get(MapValues)).getRecordTypeId();		
                        acct.RecordTypeId=recordTypeId; 
                    }
                   
                }   
               
            }
            System.debug('UserEmail >>>>'+UserEmail);

            List<Account> lstAccount= [Select id from Account where Email__c =:UserEmail] ;

            if(lstAccount.Size() <= 0){ 

                System.debug('came here >>>>');
                System.debug('Phone >>>>'+Phone);
                lstAccount= [Select id from Account where Phone =:Phone] ;
            }

            if(lstAccount.Size() > 0){
                acct = lstAccount[0];
            }else{
                        for(String MapShippingValues :  MapShippingInformation.keyset()){          
                            switch on MapShippingValues {
                                when 'address_1' {		
                                    acct.ShippingStreet=(String)MapShippingInformation.get(MapShippingValues); 
                                }	
                                when 'city' {		
                                    acct.ShippingCity=(String)MapShippingInformation.get(MapShippingValues); 
                                }
                                when 'state' {		
                                    acct.ShippingState=(String)MapShippingInformation.get(MapShippingValues); 
                                }
                                when 'country' {	
                                    acct.ShippingCountry=(String)MapShippingInformation.get(MapShippingValues); 
                                }
                                when 'postcode' {		  
                                    acct.ShippingPostalCode=(String)MapShippingInformation.get(MapShippingValues); 
                                }
                            
                            }   
                        
                        }
                        for(String MapBillingValues :  MapBillingInformation.keyset()){          
                            switch on MapBillingValues {
                                when 'address_1' {		
                                    acct.BillingStreet=(String)MapBillingInformation.get(MapBillingValues); 
                                }	
                                when 'city' {		
                                    acct.BillingCity=(String)MapBillingInformation.get(MapBillingValues); 
                                }
                                when 'state' {		
                                    acct.BillingState=(String)MapBillingInformation.get(MapBillingValues); 
                                }
                                when 'country' {
                                    acct.BillingCountry=(String)MapBillingInformation.get(MapBillingValues); 
                                }
                                when 'postcode' {		  
                                    acct.BillingPostalCode=(String)MapBillingInformation.get(MapBillingValues); 
                                }
                            
                            }   
                        
                        }
                        if(CompanyName == ''){
                            acct.Name= FirstName +' '+ LastName;
                        }else{
                            acct.Name=CompanyName;
                        }
                        acct.Alternate_Phone__c=Phone;
                        acct.Phone=Phone;
                      
                    
                    
                    try {
                    
                            insert acct;
                            cont.Phone=Phone;
                            cont.AccountId=acct.Id;
                            cont.LastName=LastName;
                            cont.FirstName=FirstName;
                            cont.Email=UserEmail; 
                            cont.Personal_Email__c=UserEmail; 
                            insert cont;
                    } catch (Exception Ex) {
                            res.responseBody = Blob.valueOf(JSON.serialize('{ "Status" : "Error", "Message" : "'+Ex.getMessage()+'" }'));
                            res.statusCode = 200;
                        return;
                       
                    }
                }
            
            AccountId = acct.id;
            
        }
        
      
        if(AccountId !=null){
            acct =[Select ShippingState,ShippingStateCode from Account where id=:AccountId];
            AcctSeed__Ledger__c acctLedger=[Select Id from AcctSeed__Ledger__c where AcctSeed__Type__c ='Transactional' limit 1];
            AcctSeedERP__Sales_Order__c createSalesOrder= new AcctSeedERP__Sales_Order__c();
            if (MapWareHouseInformation == null || MapWareHouseInformation.isEmpty()) {
                createSalesOrder.AcctSeedERP__Shipping_State__c=ShippingState;
                createSalesOrder.AcctSeedERP__Shipping_Country__c=ShippingCountry;
                createSalesOrder.AcctSeedERP__Shipping_City__c=ShippingCity;
                createSalesOrder.AcctSeedERP__Shipping_Street__c=ShippingAddress;
                createSalesOrder.AcctSeedERP__Shipping_PostalCode__c=ShippingPostcode;
            }else{
                createSalesOrder.AcctSeedERP__Shipping_State__c=wareHouse.State__c;
                createSalesOrder.AcctSeedERP__Shipping_Country__c=wareHouse.Country__c;
                createSalesOrder.AcctSeedERP__Shipping_City__c=wareHouse.City__c;
                createSalesOrder.AcctSeedERP__Shipping_Street__c=wareHouse.Street__c;
                createSalesOrder.AcctSeedERP__Shipping_PostalCode__c=wareHouse.Zip_Code__c;
         
            }
            createSalesOrder.AcctSeedERP__Customer__c=AccountId;
            createSalesOrder.AcctSeedERP__Ledger__c =acctLedger.Id;
            createSalesOrder.Delivery_Type__c = String.valueOf(MapShippingLinesInformation.get('method_title'));
            if(MapShippingLinesInformation.get('method_title') == 'Store Pick up'){
                 createSalesOrder.Warehouse_Location__c = (Id)MapWareHouseInformation.get('warehouse_sf_id');

            }
            Savepoint sp = Database.setSavepoint();
        try{
            insert createSalesOrder;

            Map<String,BundleProductWrapper> MapBundleProduct= new Map<String,BundleProductWrapper>();
            Map<String,BundleProductWrapper> MapParentProduct= new Map<String,BundleProductWrapper>();
            Map<String,Decimal> MapSkuAndQuantity= new Map<String,Decimal>();
           
         
            LineItem[] lineItems = (LineItem[])JSON.deserialize(JSON.Serialize(responseMap.get('line_items')),LineItem[].class);
            Map<Integer,LineItem> lineItemsById = new Map<Integer,LineItem>();    
            for (LineItem l : lineItems){
                lineItemsById.put(l.id,l);
            }  
            Integer Quantity;   
            for (LineItem l : lineItems){
            //for (Integer id : l.composite_children){
                if( !String.IsEmpty(l.composite_parent)){            
                    LineItem childLineItem=lineItemsById.get(Integer.valueOf(l.id));
                    LineItem ParentLineItem; 
                    if( l.bundled_items.size() > 0){  
                        ParentLineItem = lineItemsById.get(Integer.valueOf(l.bundled_items[0]));
                        if(childLineItem !=null){  
                            if(childLineItem.name.contains('Set of 2')){
                                Quantity=childLineItem.quantity*2;
                            }
                            else if(childLineItem.name.contains('Set of 4')){
                                    Quantity=childLineItem.quantity*4;
                            }
                            else if(childLineItem.name.contains('Set of 6')){
                                    Quantity=childLineItem.quantity*6;
                            }
                            else if(childLineItem.name.contains('Set of 8')){
                                Quantity=childLineItem.quantity*8;
                            }
                            else{
                                Quantity=childLineItem.quantity;
                            } 
                            MapSkuAndQuantity.put(ParentLineItem.sku, Quantity);
                            MapParentProduct.put(ParentLineItem.sku, new BundleProductWrapper(Quantity,childLineItem.total));

                        }
                    }
                    else{
                        if(childLineItem !=null){ 
                            MapSkuAndQuantity.put(childLineItem.sku, childLineItem.quantity);
                            MapParentProduct.put(childLineItem.sku, new BundleProductWrapper(childLineItem.quantity,childLineItem.total));
                        }
                        } 
                    }    
            // }
            }
            Map<Id,String> MapFETSkuToCreateSalesORderLine = new Map<Id,String>();
            Map<String,Id> MapParentProductAndFET= new Map<String,Id>();

            Map<String,Id> MapProductsBySKU= new Map<String,Id>();
               
                for(Product2 produ:[Select StockKeepingUnit ,Id,FET_Product__c from Product2 where StockKeepingUnit in :MapParentProduct.keyset()]){
                    MapProductsBySKU.put(produ.StockKeepingUnit,produ.Id);  
                    MapParentProductAndFET.put(produ.StockKeepingUnit,produ.FET_Product__c);
                    MapFETSkuToCreateSalesORderLine.put(produ.FET_Product__c,produ.StockKeepingUnit);         
                }
                List<AcctSeedERP__Sales_Order_Line__c> lstSalesOrderLine=  new List<AcctSeedERP__Sales_Order_Line__c>();

                 Map<Id,PricebookEntry> mapFETandUnitPrice=new Map<Id,PricebookEntry>();
                 List<PricebookEntry> LstFETStandardPriceBook= new List<PricebookEntry>();
                 if(!Test.IsrunningTest()){
                    LstFETStandardPriceBook =[select Product2Id,  UnitPrice from PricebookEntry where Product2Id in :MapFETSkuToCreateSalesORderLine.keySet() and Pricebook2.IsStandard =true];
                 }
                 else{
                    LstFETStandardPriceBook =[select Product2Id,  UnitPrice from PricebookEntry where Product2Id in :MapFETSkuToCreateSalesORderLine.keySet() ];

                 }
                 for(PricebookEntry pEntry :LstFETStandardPriceBook){
                    mapFETandUnitPrice.put(pEntry.Product2Id,pEntry);
                 }
             
                 Set<Id> setToRetriveInventoryQuantityAvailable = new Set<Id>();
                 
                 List<AcctSeedERP__Sales_Order_Line__c> lstFETSalesOrderLineProducts= new List<AcctSeedERP__Sales_Order_Line__c>();
                 List<AcctSeedERP__Sales_Order_Line__c> lstInventorySalesOrderLineProducts= new List<AcctSeedERP__Sales_Order_Line__c>();
                 List<AcctSeedERP__Sales_Order_Line__c> lstStateFeeSalesOrderLineProducts= new List<AcctSeedERP__Sales_Order_Line__c>();
            
                 for(Id FETSku:MapFETSkuToCreateSalesORderLine.keySet()){
                    lstFETSalesOrderLineProducts.add(new AcctSeedERP__Sales_Order_Line__c(
                                            AcctSeedERP__Sales_Order__c=createSalesOrder.Id,
                                            AcctSeedERP__Product__c=FETSku,
                                            AcctSeedERP__Unit_Price__c=mapFETandUnitPrice.get(FETSku).UnitPrice,
                                            AcctSeedERP__Quantity_Ordered__c=MapSkuAndQuantity.get(MapFETSkuToCreateSalesORderLine.get(FETSku))
                    ));
                }
              
               
                if(!MapParentProduct.IsEmpty()){
                    for(String strSku:MapParentProduct.keySet()){
                        setToRetriveInventoryQuantityAvailable.add(MapProductsBySKU.get(strSku));
                        lstInventorySalesOrderLineProducts.add(new AcctSeedERP__Sales_Order_Line__c(
                                                AcctSeedERP__Sales_Order__c=createSalesOrder.Id,
                                                AcctSeedERP__Product__c=MapProductsBySKU.get(strSku),
                                                AcctSeedERP__Quantity_Ordered__c=MapParentProduct.get(strSku).Quantity,
                                                AcctSeedERP__Unit_Price__c=MapParentProduct.get(strSku).UnitPrice-mapFETandUnitPrice.get(MapParentProductAndFET.get(strSku)).UnitPrice
                        ));

                     

                    }
                }
                Decimal StateFee;
                List<State_Tire_Fee_Calculator__c> lstStateFeeRecords=[select Id,Delivery_State__c,Section_Width__c,State_Fees__c,Tire_Rim__c from State_Tire_Fee_Calculator__c];
                 Map<String, List<State_Tire_Fee_Calculator__c>> mapStateFee = new Map<String, List<State_Tire_Fee_Calculator__c>>();
                List<PricebookEntry> procebookentryRec = new List<PricebookEntry>();
                if(!Test.IsrunningTest()){
                    procebookentryRec=[SELECT Id,product2Id, UnitPrice,Pricebook2Id  from pricebookentry where Product2Id IN (select Id  from Product2 where name ='State Fee') and Pricebook2Id in(select id from Pricebook2 where isStandard = true)];
                }
                else
                {
                    procebookentryRec=[SELECT Id,product2Id, UnitPrice,Pricebook2Id  from pricebookentry where Product2Id IN (select Id  from Product2 where name ='State Fee')];

                }
                 for ( State_Tire_Fee_Calculator__c record : lstStateFeeRecords )
                 {        
                     String key = (String)record.Delivery_State__c;        
                     if (!mapStateFee.containsKey( key ))
                         mapStateFee.put( key, new List<State_Tire_Fee_Calculator__c> ());
                     mapStateFee.get( key ).add( record );
                 }
                 System.debug('ShippingState >>>'+ShippingState);
                 System.debug('mapStateFee.get(ShippingState) >>>'+mapStateFee.get(ShippingState));
                 Map<String, List<State_Tire_Fee_Calculator__c>> duplcateMap = new Map<String, List<State_Tire_Fee_Calculator__c>>();
                Map<Id,Product2> MapProductGetStateFeeDetails=new Map<Id,Product2>([Select Id,RIM__c from Product2 where Id in :setToRetriveInventoryQuantityAvailable]);
                if(!MapParentProduct.IsEmpty()){
                    for(String strSku:MapParentProduct.keySet()){
                        for(State_Tire_Fee_Calculator__c state: mapStateFee.get(ShippingState)){
                            if(state.Tire_Rim__c != 'Any'){
                                if(state.Tire_Rim__c.contains('<=')){
                                    string Value = state.Tire_Rim__c.substring(state.Tire_Rim__c.lastIndexOf('=')+1);
                                    if( Decimal.valueOf(MapProductGetStateFeeDetails.get(MapProductsBySKU.get(strSku)).RIM__c) <= Decimal.valueOf(Value)){
                                    String key = (String)State.Delivery_State__c;        
                                    if (!duplcateMap.containsKey( key ))
                                        duplcateMap.put( key, new List<State_Tire_Fee_Calculator__c> ());
                                    duplcateMap.get( key ).add( state );
                                    }
                                    else {
                                    }
                                }
                                else if(state.Tire_Rim__c.contains('>')){
                                    string Value = state.Tire_Rim__c.substring(state.Tire_Rim__c.lastIndexOf('>')+1);
                                    if( Decimal.valueOf(MapProductGetStateFeeDetails.get(MapProductsBySKU.get(strSku)).RIM__c) > Decimal.valueOf(Value)){
                                        String key = (String)State.Delivery_State__c;        
                                        if (!duplcateMap.containsKey( key ))
                                        duplcateMap.put( key, new List<State_Tire_Fee_Calculator__c> ());
                                        duplcateMap.get( key ).add( state );
                                    }
                                    else {
                                    }
                                } 
                                else if(state.Tire_Rim__c.contains('<')){
                                    string Value = state.Tire_Rim__c.substring(state.Tire_Rim__c.lastIndexOf('<')+1);
                                    if( Decimal.valueOf(MapProductGetStateFeeDetails.get(MapProductsBySKU.get(strSku)).RIM__c) < Decimal.valueOf(Value)){
                                        String key = (String)State.Delivery_State__c;        
                                        if (!duplcateMap.containsKey( key ))
                                        duplcateMap.put( key, new List<State_Tire_Fee_Calculator__c> ());
                                        duplcateMap.get( key ).add( state );
                                    }
                                    else {
                                    }
                                } 
                                else if(state.Tire_Rim__c.contains('-')){
                                    string firstValue =state.Tire_Rim__c.SubString(0,state.Tire_Rim__c.lastIndexOf('-')).replace('\'','');
                                    string secondValue = state.Tire_Rim__c.SubString(state.Tire_Rim__c.lastIndexOf('-')+1).replace('\'','');
                                if( Decimal.valueOf(MapProductGetStateFeeDetails.get(MapProductsBySKU.get(strSku)).RIM__c) >= Decimal.valueOf(firstValue) && Decimal.valueOf(MapProductGetStateFeeDetails.get(MapProductsBySKU.get(strSku)).RIM__c) <= Decimal.valueOf(secondValue)){
                                        String key = (String)State.Delivery_State__c;        
                                        if (!duplcateMap.containsKey( key ))
                                        duplcateMap.put( key, new List<State_Tire_Fee_Calculator__c> ());
                                        duplcateMap.get( key ).add( state );
                                    }
                                    else {
                                    }
                                }                   
                            }
                            else{
                                String key = (String)State.Delivery_State__c;  
                                if (!duplcateMap.containsKey( key ))
                                    duplcateMap.put( key, new List<State_Tire_Fee_Calculator__c> ());
                                 duplcateMap.get( key ).add( state );
                            }            
                        }
                        if( duplcateMap.size() > 1 ){
                                
                        }
                        else
                        {
                            List<State_Tire_Fee_Calculator__c> lstState=(List<State_Tire_Fee_Calculator__c>)duplcateMap.values()[0];
                            if(lstState[0].Delivery_State__c== 'North Carolina'){
                                StateFee= (lstState[0].State_Fees__c/100) * MapParentProduct.get(strSku).UnitPrice.setScale(2);
                            }
                            else{
                                StateFee=lstState[0].State_Fees__c;
                            }
                            
                        }
                        for(AcctSeedERP__Sales_Order_Line__c salesOrderLine: lstSalesOrderLine){
                            if(salesOrderLine.AcctSeedERP__Product__c == MapProductsBySKU.get(strSku)){
                                salesOrderLine.AcctSeedERP__Unit_Price__c = salesOrderLine.AcctSeedERP__Unit_Price__c - StateFee;
                            }
                        }
                        lstStateFeeSalesOrderLineProducts.add(new AcctSeedERP__Sales_Order_Line__c(
                                                AcctSeedERP__Sales_Order__c=createSalesOrder.Id,
                                                AcctSeedERP__Product__c=procebookentryRec[0].product2Id,
                                                AcctSeedERP__Quantity_Ordered__c=MapParentProduct.get(strSku).Quantity,
                                                AcctSeedERP__Unit_Price__c=StateFee
                        ));
                    }
                }

                

                lstSalesOrderLine.addAll(lstInventorySalesOrderLineProducts);
                lstSalesOrderLine.addAll(lstFETSalesOrderLineProducts);
                lstSalesOrderLine.addAll(lstStateFeeSalesOrderLineProducts);
                if(!lstSalesOrderLine.IsEmpty()){
                    insert lstSalesOrderLine;


                    if (MapWareHouseInformation == null || MapWareHouseInformation.isEmpty()) {
                    }
                    else{

                    AcctSeed__Ledger__c AcctLedgerActual=[SELECT Id  FROM AcctSeed__Ledger__c where Name='Actual' limit 1];
                 
                    Set<Id> setlocation= new Set<Id>();
                   
                   
                    // for (AcctSeedERP__Warehouse__c warehouse : [select Id from AcctSeedERP__Warehouse__c where name =:WareHouseName]){
                    //     setWareHouse.add(warehouse.Id);
                    // }
                
                    for (AcctSeedERP__Location__c location : [select Id from AcctSeedERP__Location__c where AcctSeedERP__Warehouse__c =:setWareHouse]){
                        setlocation.add(location.Id);
                     
                     }
                   
                     Map<Id,AcctSeedERP__Inventory_Balance__c> MapSalesOrderInventory= new  Map<Id,AcctSeedERP__Inventory_Balance__c>();
                     
                  
                    List<AcctSeedERP__Inventory_Balance__c> lstInvetQuantityBalance= [select id,AcctSeedERP__Product__c,AcctSeedERP__Available_Quantity__c from AcctSeedERP__Inventory_Balance__c where AcctSeedERP__Product__c in :setToRetriveInventoryQuantityAvailable and AcctSeedERP__Warehouse__c in:setWareHouse and AcctSeedERP__Location__c in:setlocation and AcctSeedERP__Available_Quantity__c > 0 order by AcctSeedERP__Location__r.Allocation_Priority__c asc];
                   
                   for(AcctSeedERP__Inventory_Balance__c inventoryQuantityBalance: lstInvetQuantityBalance){
                         MapSalesOrderInventory.put(inventoryQuantityBalance.AcctSeedERP__Product__c,inventoryQuantityBalance);
                   }
                    List<AcctSeedERP__Sales_Order_Inventory_Movement__c> lstInventoryMovement= new List<AcctSeedERP__Sales_Order_Inventory_Movement__c>();
                    Map<Id,AcctSeedERP__Sales_Order_Line__c> mapSaleOrderLine= new Map<Id,AcctSeedERP__Sales_Order_Line__c>();
                   Decimal RemainingQuantity;
                   Map<Id, List<AcctSeedERP__Inventory_Balance__c>> MapInventoryBalance = new Map<Id, List<AcctSeedERP__Inventory_Balance__c>>();
                    for(AcctSeedERP__Inventory_Balance__c record: lstInvetQuantityBalance) {
                        if(MapInventoryBalance.containsKey(record.AcctSeedERP__Product__c)) {
                            MapInventoryBalance.get(record.AcctSeedERP__Product__c).add(record);
                        } else {
                            MapInventoryBalance.put(record.AcctSeedERP__Product__c, new List<AcctSeedERP__Inventory_Balance__c> { record });
                        }
                    }
                    lstInvetQuantityBalance.clear();
                    for(Id productId: MapInventoryBalance.keySet()){
                        for(AcctSeedERP__Inventory_Balance__c balance : MapInventoryBalance.get(productId)){
                            lstInvetQuantityBalance.add(balance);
                        }
                    }
                    for(AcctSeedERP__Sales_Order_Line__c salesorderLine : [select Id,AcctSeedERP__Quantity_Ordered__c,AcctSeedERP__Unit_Price__c,AcctSeedERP__Product__c,AcctSeedERP__Product__r.Name from AcctSeedERP__Sales_Order_Line__c where AcctSeedERP__Sales_Order__c =:createSalesOrder.Id]){
                        for (Integer i = 0; i < lstInvetQuantityBalance.size(); i++) {
                            if(lstInvetQuantityBalance[i].AcctSeedERP__Product__c == salesorderLine.AcctSeedERP__Product__c){
                                if(lstInvetQuantityBalance[i].AcctSeedERP__Available_Quantity__c >= salesorderLine.AcctSeedERP__Quantity_Ordered__c){
                                  
                                    lstInventoryMovement.add(new AcctSeedERP__Sales_Order_Inventory_Movement__c(                        
                                           AcctSeedERP__Sales_Order_Line__c = salesorderLine.Id,
                                            AcctSeedERP__Inventory_Balance__c = lstInvetQuantityBalance[i].Id,
                                            AcctSeedERP__Movement_Date__c = System.today(),
                                            AcctSeedERP__Quantity__c =  salesorderLine.AcctSeedERP__Quantity_Ordered__c,
                                            AcctSeedERP__Unit_Cost__c = salesorderLine.AcctSeedERP__Unit_Price__c,
                                            AcctSeedERP__Ledger__c=AcctLedgerActual.Id,
                                            AcctSeedERP__Status__c='Approved'
                                    ));
                                    break;
                                }
                                else{
                                    RemainingQuantity = salesorderLine.AcctSeedERP__Quantity_Ordered__c - lstInvetQuantityBalance[i].AcctSeedERP__Available_Quantity__c ;
                                
                                    lstInventoryMovement.add(new AcctSeedERP__Sales_Order_Inventory_Movement__c(                        
                                            AcctSeedERP__Sales_Order_Line__c = salesorderLine.Id,
                                            AcctSeedERP__Inventory_Balance__c = lstInvetQuantityBalance[i].Id,
                                            AcctSeedERP__Movement_Date__c = System.today(),
                                            AcctSeedERP__Quantity__c =  lstInvetQuantityBalance[i].AcctSeedERP__Available_Quantity__c,
                                            AcctSeedERP__Unit_Cost__c = salesorderLine.AcctSeedERP__Unit_Price__c,
                                            AcctSeedERP__Ledger__c=AcctLedgerActual.Id,
                                            AcctSeedERP__Status__c='Approved'
                                    ));
                                 lstInventoryMovement.add(new AcctSeedERP__Sales_Order_Inventory_Movement__c(                        
                                        AcctSeedERP__Sales_Order_Line__c = salesorderLine.Id,
                                        AcctSeedERP__Inventory_Balance__c = lstInvetQuantityBalance[i+1].Id,
                                        AcctSeedERP__Movement_Date__c = System.today(),
                                        AcctSeedERP__Quantity__c =  RemainingQuantity,
                                        AcctSeedERP__Unit_Cost__c = salesorderLine.AcctSeedERP__Unit_Price__c,
                                        AcctSeedERP__Ledger__c=AcctLedgerActual.Id,
                                        AcctSeedERP__Status__c='Approved'
                                    ));
                                }
                                break;
                            }
                           
                        }
                    }

              
                   insert lstInventoryMovement;
                }

                }
                    res.responseBody = Blob.valueOf(JSON.serialize('{ "Status" : "Success", "OrderId" : '+createSalesOrder.Id +' }'));
                    res.statusCode = 200;
            }
                catch(exception ex){
                    System.debug('ex Main'+  ex.getMessage());
                    Database.rollback(sp);
                    res.responseBody = Blob.valueOf(ex.getMessage());
                    res.statusCode = 500;
                }
        
        }
        else{
            res.responseBody = Blob.valueOf(JSON.serialize('{ "Status" : "Error", "Message" : "Account not found" }'));
            res.statusCode = 202;
        }

       
    //    return requestBody;
    }
    class BundleProductWrapper{
        Integer Quantity{get;set;}
        Decimal Price{get;set;}
        Decimal UnitPrice{get;set;}
      
        public BundleProductWrapper(Integer Quantity,Decimal Price){
            this.Quantity=Quantity;
            this.price=price;
            this.UnitPrice=price/Quantity;
           
        }
    }
        class LineItem{
        Integer id;
        //add other attributes as you need
        String sku;
        Decimal total;
        Integer[] composite_children;
        Integer[] bundled_items;
        Integer quantity;
        Decimal price;
        String bundled_by;
        String composite_parent;
        String warehouse;
        String location;
        String name;
    }
}