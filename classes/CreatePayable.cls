public with sharing class CreatePayable {
    
    @AuraEnabled(cacheable=true)
    public static AcctSeedERP__Purchase_Order__c getRecordInfo(Id recordId){
        try {
            return [Select Id, RecordType.Name From AcctSeedERP__Purchase_Order__c where Id =: recordId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String createPayableAndPayableLines(String types,string values,string purchaseOrderId,String issueDate,String dueDate,string payeeReference){
        // try {
     
        
        List<String> lstTypes = types.replaceAll('"','').split(',');
        Map<String,Object> finalVal= new Map<String, Object>();  
        List< Object> responseMap =   (List<Object>) JSON.deserializeUntyped(values);
        for(Object everyTypes:responseMap){
            Map<String,Object> mapTypes= (Map<String, Object>)everyTypes;  
            finalVal.putAll(mapTypes);
        }
        AcctSeedERP__Purchase_Order__c purchaseOrder=[select id, RecordTypeId, RecordType.Name,                                     
                                                      AcctSeedERP__Ledger__c,                                        
                                                      AcctSeedERP__Vendor__c,                                       
                                                      AcctSeedERP__Total__c, 
                                                      Vendor_Custom_Clearing_Agent__c, 
                                                      Vendor_Freight__c,
                                                      Custom_Duty_Vendor__c,
                                                      Local_Trucking__c,
                                                      Other_Vendor_1__c,
                                                      Other_Vendor_2__c, 
                                                      Total_PO_Value__c,
                                                      Other_Charges_1__c ,
                                                      Other_Charges_2__c,
                                                      Total_Ocean_Freight__c, 
                                                      Total_Custom_Duty__c,
                                                      Total_Port_Charges_without_custom_duty__c,   
                                                      Local_Transportation__c,    
                                                      Purchase_Order__c, (select Id,  
                                                                          AcctSeedERP__GL_Account_Variable_1__c, 
                                                                          AcctSeedERP__GL_Account_Variable_2__c, 
                                                                          AcctSeedERP__GL_Account_Variable_3__c, 
                                                                          AcctSeedERP__GL_Account_Variable_4__c, 
                                                                          AcctSeedERP__Product__c,   
                                                                          AcctSeedERP__Product__r.Family,
                                                                          AcctSeedERP__Product__r.AcctSeed__Expense_GL_Account__c,                                             
                                                                          AcctSeedERP__Quantity__c, 
                                                                          AcctSeedERP__Total__c, 
                                                                          AcctSeedERP__Unit_Price__c ,
                                                                          Purchase_Price__c,
                                                                          Clearing_Cost_Including_Custom_Duty__c,
                                                                          Total_Freight_1__c,
                                                                          Custom_Duty_Charges__c,
                                                                          Local_Transportation__c,
                                                                          Other_Charges_1__c,
                                                                          Other_Charges_2__c,
                                                                          Total_Purchase_Price_1__c,
                                                                          Custom_Clearing_Agent__c
                                                                          
                                                                          from AcctSeedERP__Purchase_Order_Lines__r) from AcctSeedERP__Purchase_Order__c where id=:purchaseOrderId];
        AcctSeed__GL_Account__c ExpenseGLAccount= [ select id from AcctSeed__GL_Account__c where Name='2010-Vouchers Payable'];
        if(lstTypes.contains('productvendor')){
            Map<String,Object> mapproductvendor= (Map<String, Object>)finalVal.get('ProductVendor'); 
            createPayableAndPayableLine(purchaseOrder,Date.valueOf((String)mapproductvendor.get('issueDate')),Date.valueOf((String)mapproductvendor.get('dueDate')),mapproductvendor.get('payeeReference') + ' - Vendor -'+ DateTime.now(),purchaseOrder.AcctSeedERP__Vendor__c,ExpenseGLAccount,'productvendor');
               
        }
        if(lstTypes.contains('shippingcompany')){
            Map<String,Object> mapShippingCompany= (Map<String, Object>)finalVal.get('ShippingVendor'); 
            if(!'Purchase Order Domestic'.equalsIgnoreCase(purchaseOrder.RecordType.Name)){
                createPayableAndPayableLine(purchaseOrder,Date.valueOf((String)mapShippingCompany.get('issueDate')),Date.valueOf((String)mapShippingCompany.get('dueDate')),mapShippingCompany.get('payeeReference') + ' - Shipping Agent-'+ DateTime.now(),purchaseOrder.Vendor_Freight__c,ExpenseGLAccount,'shippingcompany');
            }else{
                createPayableAndPayableLineForDomesticPO(purchaseOrder,Date.valueOf((String)mapShippingCompany.get('issueDate')),Date.valueOf((String)mapShippingCompany.get('dueDate')),mapShippingCompany.get('payeeReference') + ' - Shipping Agent-'+ DateTime.now(),purchaseOrder.Vendor_Freight__c,ExpenseGLAccount,'shippingcompany');
            }
        }
        if(lstTypes.contains('customclearingagent')){
            Map<String,Object> mapcustomclearingagent= (Map<String, Object>)finalVal.get('CustomclearingAgent'); 
            createPayableAndPayableLine(purchaseOrder,Date.valueOf((String)mapcustomclearingagent.get('issueDate')),Date.valueOf((String)mapcustomclearingagent.get('dueDate')),mapcustomclearingagent.get('payeeReference') + ' - Custom Clearing Agent -'+ DateTime.now(),purchaseOrder.Vendor_Custom_Clearing_Agent__c,ExpenseGLAccount,'customclearingagent');
        }
        if(lstTypes.contains('customDutyVendor')){
            Map<String,Object> mapCustomDutyVendor= (Map<String, Object>)finalVal.get('CustomDutyVendor');  
            createPayableAndPayableLine(purchaseOrder,Date.valueOf((String)mapCustomDutyVendor.get('issueDate')),Date.valueOf((String)mapCustomDutyVendor.get('dueDate')),mapCustomDutyVendor.get('payeeReference') + ' - Custom Duty Vendor -'+ DateTime.now(),purchaseOrder.Custom_Duty_Vendor__c,ExpenseGLAccount,'customDutyVendor');
        }
        if(lstTypes.contains('localtrucking')){
            Map<String,Object> mapLocalTrucking= (Map<String, Object>)finalVal.get('LocalTrucking'); 
            createPayableAndPayableLine(purchaseOrder,Date.valueOf((String)mapLocalTrucking.get('issueDate')),Date.valueOf((String)mapLocalTrucking.get('dueDate')),mapLocalTrucking.get('payeeReference') + ' - Local Trucking -'+ DateTime.now(),purchaseOrder.Local_Trucking__c,ExpenseGLAccount,'localtrucking');
            
        }
        if(lstTypes.contains('otherVendor_1')){
            Map<String,Object> maoOtherVendor1= (Map<String, Object>)finalVal.get('OtherVendor_1'); 
            if(!'Purchase Order Domestic'.equalsIgnoreCase(purchaseOrder.RecordType.Name)){
                createPayableAndPayableLine(purchaseOrder,Date.valueOf((String)maoOtherVendor1.get('issueDate')),Date.valueOf((String)maoOtherVendor1.get('dueDate')),maoOtherVendor1.get('payeeReference') + ' - Other Vendor 1 -'+ DateTime.now(),purchaseOrder.Other_Vendor_1__c,ExpenseGLAccount,'otherVendor_1');
            }else{
                createPayableAndPayableLineForDomesticPO(purchaseOrder,Date.valueOf((String)maoOtherVendor1.get('issueDate')),Date.valueOf((String)maoOtherVendor1.get('dueDate')),maoOtherVendor1.get('payeeReference') + ' - Other Vendor 1 -'+ DateTime.now(),purchaseOrder.Other_Vendor_1__c,ExpenseGLAccount,'otherVendor_1');
            }
        }
        if(lstTypes.contains('otherVendor_2')){
            Map<String,Object> mapOtherVendor2= (Map<String, Object>)finalVal.get('OtherVendor_2'); 
            if(!'Purchase Order Domestic'.equalsIgnoreCase(purchaseOrder.RecordType.Name)){
                createPayableAndPayableLine(purchaseOrder,Date.valueOf((String)mapOtherVendor2.get('issueDate')),Date.valueOf((String)mapOtherVendor2.get('dueDate')),mapOtherVendor2.get('payeeReference') + ' - Other Vendor 2 -'+ DateTime.now(),purchaseOrder.Other_Vendor_2__c,ExpenseGLAccount,'otherVendor_2');
            }else{
                createPayableAndPayableLineForDomesticPO(purchaseOrder,Date.valueOf((String)mapOtherVendor2.get('issueDate')),Date.valueOf((String)mapOtherVendor2.get('dueDate')),mapOtherVendor2.get('payeeReference') + ' - Other Vendor 2 -'+ DateTime.now(),purchaseOrder.Other_Vendor_2__c,ExpenseGLAccount,'otherVendor_2');
            }
        }
        
        return 'Success';  
        
      
        
    }
    
    
    private static Id getAccountingPeriod(Date accountingPeriodDate){
        Date selectedDate =  accountingPeriodDate; //Give your date
        Date firstDate = selectedDate.toStartOfMonth();
        Date lastDate = firstDate.addDays(date.daysInMonth(selectedDate.year() , selectedDate.month())  - 1);
        String sMonth = String.valueof(selectedDate.month());
        if(sMonth.length()==1){
            sMonth = '0' + sMonth;
        }
        string AccountingPeriodName=String.valueOf(selectedDate.year())+'-'+sMonth;
        List<AcctSeed__Accounting_Period__c> lstPeriod= [Select Id,Name from AcctSeed__Accounting_Period__c where Name=:AccountingPeriodName and AcctSeed__Status__c  ='Open'];
        if(!lstPeriod.IsEmpty()){
            return lstPeriod[0].Id;
        }else{
            throw new AuraHandledException('Accounting period does not exist for this period '+ AccountingPeriodName);
        }
        
    }
    
    private static void createPayableAndPayableLine(AcctSeedERP__Purchase_Order__c purchaseOrder,Date issueDate,Date dueDate,String payeeReference, Id Vendor,AcctSeed__GL_Account__c ExpenseGLAccount,string Type){
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        List<AcctSeed__Account_Payable_Line__c> lstPurchaseOrderProductvendorLineToCreate= new List<AcctSeed__Account_Payable_Line__c>();
        Integer Counter=0;
        Decimal productVendorCharges,customDutyCharges,ShippingCost,customClearingAgenCost , localTruckingProductCost,otherVendor1Cost,otherVendor2Cost;
        productVendorCharges=customDutyCharges=ShippingCost=customClearingAgenCost=localTruckingProductCost=otherVendor1Cost=otherVendor2Cost=0;
        for(AcctSeedERP__Purchase_Order_Line__c purchOrderline: purchaseOrder.AcctSeedERP__Purchase_Order_Lines__r){
            Counter=Counter+1;
            if(((Type == 'shippingcompany' || Type == 'customclearingagent') && purchOrderline.AcctSeedERP__Product__r.Family != 'FET') ||  Type == 'productvendor' || 'customDutyVendor'.equalsIgnoreCase(Type) || 'localtrucking'.equalsIgnoreCase(Type) || 'otherVendor_1'.equalsIgnoreCase(Type) || 'otherVendor_2'.equalsIgnoreCase(Type)){
                AcctSeed__Account_Payable__c  PayableRef= new AcctSeed__Account_Payable__c();       
                PayableRef.Ext_ID_for_Single_Insert__c=guid;
                
                AcctSeed__Account_Payable_Line__c payableLineTocreate= new AcctSeed__Account_Payable_Line__c();
                
                if(purchOrderline.AcctSeedERP__Product__r.Family == 'FET'){
                    payableLineTocreate.AcctSeed__Expense_GL_Account__c = purchOrderline.AcctSeedERP__Product__r.AcctSeed__Expense_GL_Account__c;
                }else {
                    payableLineTocreate.AcctSeed__Expense_GL_Account__c = ExpenseGLAccount.Id;
                }
                
                payableLineTocreate.AcctSeed__GL_Account_Variable_1__c=purchOrderline.AcctSeedERP__GL_Account_Variable_1__c;
                payableLineTocreate.AcctSeed__GL_Account_Variable_2__c=purchOrderline.AcctSeedERP__GL_Account_Variable_2__c;
                payableLineTocreate.AcctSeed__GL_Account_Variable_3__c=purchOrderline.AcctSeedERP__GL_Account_Variable_3__c;
                payableLineTocreate.AcctSeed__GL_Account_Variable_4__c=purchOrderline.AcctSeedERP__GL_Account_Variable_4__c;
                payableLineTocreate.AcctSeed__Quantity__c=purchOrderline.AcctSeedERP__Quantity__c;
                payableLineTocreate.AcctSeed__Product__c=purchOrderline.AcctSeedERP__Product__c;
                if(purchOrderline.AcctSeedERP__Product__r.Family == 'FET'){
                                payableLineTocreate.AcctSeed__Amount__c =  purchOrderline.Total_Purchase_Price_1__c.setScale(2) ;
                     
                }else{
                    if(Type == 'productvendor'){
                        if(purchOrderline.Total_Purchase_Price_1__c != null){
                            productVendorCharges = productVendorCharges + purchOrderline.Total_Purchase_Price_1__c.setScale(2);
                            if(Counter == purchaseOrder.AcctSeedERP__Purchase_Order_Lines__r.Size()){
                                Decimal Difference =  productVendorCharges - purchaseOrder.Total_PO_Value__c;
                                payableLineTocreate.AcctSeed__Amount__c =  purchOrderline.Total_Purchase_Price_1__c.setScale(2) - Difference;
                            }else{
                                payableLineTocreate.AcctSeed__Amount__c =  purchOrderline.Total_Purchase_Price_1__c.setScale(2) ;
                            }
                        }else{
                            if(Counter == purchaseOrder.AcctSeedERP__Purchase_Order_Lines__r.Size()){
                                Decimal Difference = 0;
                                if(purchaseOrder.Total_PO_Value__c != null){
                                    Difference =  productVendorCharges - purchaseOrder.Total_PO_Value__c;
                                }else{
                                    Difference =  productVendorCharges;
                                }
                                payableLineTocreate.AcctSeed__Amount__c =  0 - Difference;
                            }else{
                                payableLineTocreate.AcctSeed__Amount__c =  0;
                            }
                        }
                        
                    }else if(Type == 'shippingcompany' ){
                        
                        ShippingCost = ShippingCost + purchOrderline.Total_Freight_1__c.setScale(2);
                        if(Counter== purchaseOrder.AcctSeedERP__Purchase_Order_Lines__r.Size()){
                            Decimal Difference =  ShippingCost - purchaseOrder.Total_Ocean_Freight__c;
                            payableLineTocreate.AcctSeed__Amount__c =  purchOrderline.Total_Freight_1__c.setScale(2) - Difference;
                        }else{
                            payableLineTocreate.AcctSeed__Amount__c =  purchOrderline.Total_Freight_1__c.setScale(2) ;
                        }
                        
                    }else if(Type == 'customclearingagent'){
                        customClearingAgenCost = customClearingAgenCost + purchOrderline.Clearing_Cost_Including_Custom_Duty__c.setScale(2);
                        if(Counter == purchaseOrder.AcctSeedERP__Purchase_Order_Lines__r.Size()){
                            Decimal Difference =  customClearingAgenCost - purchaseOrder.Total_Port_Charges_without_custom_duty__c;
                            payableLineTocreate.AcctSeed__Amount__c =  purchOrderline.Clearing_Cost_Including_Custom_Duty__c.setScale(2) - Difference;
                        }else{
                            payableLineTocreate.AcctSeed__Amount__c =  purchOrderline.Clearing_Cost_Including_Custom_Duty__c.setScale(2) ;
                        }
                        
                    }else if('customDutyVendor'.equalsIgnoreCase(Type)){
                        customDutyCharges = customDutyCharges + purchOrderline.Custom_Duty_Charges__c.setScale(2);
                        if(Counter== purchaseOrder.AcctSeedERP__Purchase_Order_Lines__r.Size()){
                            Decimal Difference =  customDutyCharges - purchaseOrder.Total_Custom_Duty__c;
                            payableLineTocreate.AcctSeed__Amount__c =  purchOrderline.Custom_Duty_Charges__c.setScale(2) - Difference;
                        }else{
                            payableLineTocreate.AcctSeed__Amount__c =  purchOrderline.Custom_Duty_Charges__c.setScale(2) ;
                        }
                        
                    }else if('localtrucking'.equalsIgnoreCase(Type)){
                        localTruckingProductCost = localTruckingProductCost + purchOrderline.Local_Transportation__c.setScale(2);
                        if(Counter == purchaseOrder.AcctSeedERP__Purchase_Order_Lines__r.Size()){
                            Decimal Difference =  localTruckingProductCost - purchaseOrder.Local_Transportation__c;
                            payableLineTocreate.AcctSeed__Amount__c =  purchOrderline.Local_Transportation__c.setScale(2) - Difference;
                        }else{
                            payableLineTocreate.AcctSeed__Amount__c =  purchOrderline.Local_Transportation__c.setScale(2) ;
                        }
                    }else if('otherVendor_1'.equalsIgnoreCase(Type)){
                        
                        otherVendor1Cost = otherVendor1Cost + purchOrderline.Other_Charges_1__c.setScale(2);
                        if(Counter== purchaseOrder.AcctSeedERP__Purchase_Order_Lines__r.Size()){
                            Decimal Difference =  otherVendor1Cost - purchaseOrder.Other_Charges_1__c;
                            payableLineTocreate.AcctSeed__Amount__c =  purchOrderline.Other_Charges_1__c.setScale(2) - Difference;
                        }else{
                            payableLineTocreate.AcctSeed__Amount__c =  purchOrderline.Other_Charges_1__c.setScale(2) ;
                        }
                    }else if('otherVendor_2'.equalsIgnoreCase(Type)){
                        
                        otherVendor2Cost = otherVendor2Cost + purchOrderline.Other_Charges_2__c.setScale(2);
                        if(Counter== purchaseOrder.AcctSeedERP__Purchase_Order_Lines__r.Size()){
                            Decimal Difference =  otherVendor2Cost - purchaseOrder.Other_Charges_2__c;
                            payableLineTocreate.AcctSeed__Amount__c =  purchOrderline.Other_Charges_2__c.setScale(2) - Difference;
                        }else{
                            payableLineTocreate.AcctSeed__Amount__c =  purchOrderline.Other_Charges_2__c.setScale(2) ;
                        }
                    }
                }
                //payableLineTocreate.AcctSeed__Account_Payable__r=PayableRef;
                lstPurchaseOrderProductvendorLineToCreate.add(payableLineTocreate);
            }
            
        }
        
        AcctSeed__Account_Payable__c payable = new AcctSeed__Account_Payable__c();
        payable.AcctSeed__Status__c = 'Approved';
        payable.AcctSeedERP__Purchase_Order__c = purchaseOrder.Id;
        payable.AcctSeed__Payment_Status__c='Unpaid';
        payable.AcctSeed__Accounting_Period__c = getAccountingPeriod(issueDate);      
        payable.AcctSeed__Date__c=issueDate;
        payable.AcctSeed__Due_Date__c=dueDate;
        payable.AcctSeed__Payee_Reference__c=payeeReference ;
        payable.AcctSeed__Ledger__c = purchaseOrder.AcctSeedERP__Ledger__c;
        payable.AcctSeed__Vendor__c = Vendor;  
        //payable.Ext_ID_for_Single_Insert__c=guid; 
        /*if(!lstPurchaseOrderProductvendorLineToCreate.IsEmpty()){
            SObject[] sobjList = new List<SObject>();
            sobjList.add(payable);
            sobjList.addAll(lstPurchaseOrderProductvendorLineToCreate);   
            Database.SaveResult[] results = Database.insert(sobjList);
        }*/
        insert payable;
        for(AcctSeed__Account_Payable_Line__c payableLine: lstPurchaseOrderProductvendorLineToCreate){
            payableLine.AcctSeed__Account_Payable__c = payable.Id;
        }
        insert lstPurchaseOrderProductvendorLineToCreate;
        
    }


    private static void createPayableAndPayableLineForDomesticPO(AcctSeedERP__Purchase_Order__c purchaseOrder,Date issueDate,Date dueDate,String payeeReference, Id Vendor,AcctSeed__GL_Account__c ExpenseGLAccount,string Type){
           
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        List<AcctSeed__Account_Payable_Line__c> lstPurchaseOrderProductvendorLineToCreate= new List<AcctSeed__Account_Payable_Line__c>();
        Integer Counter=0;
        Decimal productVendorCharges,customDutyCharges,ShippingCost,customClearingAgenCost , localTruckingProductCost,otherVendor1Cost,otherVendor2Cost;
        productVendorCharges=customDutyCharges=ShippingCost=customClearingAgenCost=localTruckingProductCost=otherVendor1Cost=otherVendor2Cost=0;
        for(AcctSeedERP__Purchase_Order_Line__c purchOrderline: purchaseOrder.AcctSeedERP__Purchase_Order_Lines__r){
            if(purchOrderline.AcctSeedERP__Product__r.Family != 'FET'){
                Counter=Counter+1;
                if(Type == 'shippingcompany' ||  Type == 'productvendor' || 'localtrucking'.equalsIgnoreCase(Type) || 'otherVendor_1'.equalsIgnoreCase(Type) || 'otherVendor_2'.equalsIgnoreCase(Type)){
                    AcctSeed__Account_Payable__c  PayableRef= new AcctSeed__Account_Payable__c();       
                    PayableRef.Ext_ID_for_Single_Insert__c=guid;
                    
                    AcctSeed__Account_Payable_Line__c payableLineTocreate= new AcctSeed__Account_Payable_Line__c();
                 
                    if(purchOrderline.AcctSeedERP__Product__r.Family == 'FET'){
                        payableLineTocreate.AcctSeed__Expense_GL_Account__c=purchOrderline.AcctSeedERP__Product__r.AcctSeed__Expense_GL_Account__c;
                    }else {
                        payableLineTocreate.AcctSeed__Expense_GL_Account__c=ExpenseGLAccount.Id;
                    }
                    
                    payableLineTocreate.AcctSeed__GL_Account_Variable_1__c=purchOrderline.AcctSeedERP__GL_Account_Variable_1__c;
                    payableLineTocreate.AcctSeed__GL_Account_Variable_2__c=purchOrderline.AcctSeedERP__GL_Account_Variable_2__c;
                    payableLineTocreate.AcctSeed__GL_Account_Variable_3__c=purchOrderline.AcctSeedERP__GL_Account_Variable_3__c;
                    payableLineTocreate.AcctSeed__GL_Account_Variable_4__c=purchOrderline.AcctSeedERP__GL_Account_Variable_4__c;
                    payableLineTocreate.AcctSeed__Quantity__c=purchOrderline.AcctSeedERP__Quantity__c;
                    payableLineTocreate.AcctSeed__Product__c=purchOrderline.AcctSeedERP__Product__c;
                    System.debug('purchOrderline.AcctSeedERP__Product__r.Family >>>>>'+purchOrderline.AcctSeedERP__Product__r.Family); 
                    if(purchOrderline.AcctSeedERP__Product__r.Family.equalsIgnoreCase('FET'))
                    {
                        System.debug('Came here FET >>>>>'); 
                        payableLineTocreate.AcctSeed__Amount__c =  purchOrderline.Total_Purchase_Price_1__c.setScale(2) ;
                    }else{
                        System.debug('Came here Base Product >>>>>'); 
                        if('productvendor'.equalsIgnoreCase(Type)){
                            productVendorCharges = productVendorCharges + purchOrderline.Total_Purchase_Price_1__c.setScale(2);
                            if(Counter == purchaseOrder.AcctSeedERP__Purchase_Order_Lines__r.Size()){
                                Decimal Difference =  productVendorCharges - purchaseOrder.Total_PO_Value__c;
                                payableLineTocreate.AcctSeed__Amount__c =  purchOrderline.Total_Purchase_Price_1__c.setScale(2) - Difference;
                            }else{
                                payableLineTocreate.AcctSeed__Amount__c =  purchOrderline.Total_Purchase_Price_1__c.setScale(2) ;
                            }
                        }else if('shippingcompany'.equalsIgnoreCase(Type)){
                          
                            if(purchOrderline.Total_Freight_1__c != null){
                                ShippingCost = ShippingCost + purchOrderline.Total_Freight_1__c.setScale(2);
                            }
                            if(Counter== purchaseOrder.AcctSeedERP__Purchase_Order_Lines__r.Size()){
                                Decimal Difference =  ShippingCost - purchaseOrder.Total_Ocean_Freight__c;
                                payableLineTocreate.AcctSeed__Amount__c =  purchOrderline.Total_Freight_1__c.setScale(2) - Difference;
                            }else{
                                payableLineTocreate.AcctSeed__Amount__c =  purchOrderline.Total_Freight_1__c.setScale(2) ;
                            }
                        }else if('otherVendor_1'.equalsIgnoreCase(Type)){
                            
                            otherVendor1Cost = otherVendor1Cost + purchOrderline.Other_Charges_1__c.setScale(2);
                            if(Counter== purchaseOrder.AcctSeedERP__Purchase_Order_Lines__r.Size()){
                                Decimal Difference =  otherVendor1Cost - purchaseOrder.Other_Charges_1__c;
                                payableLineTocreate.AcctSeed__Amount__c =  purchOrderline.Other_Charges_1__c.setScale(2) - Difference;
                            }else{
                                payableLineTocreate.AcctSeed__Amount__c =  purchOrderline.Other_Charges_1__c.setScale(2) ;
                            }
                        }else if('otherVendor_2'.equalsIgnoreCase(Type)){
                            
                            otherVendor2Cost = otherVendor2Cost + purchOrderline.Other_Charges_2__c.setScale(2);
                            if(Counter== purchaseOrder.AcctSeedERP__Purchase_Order_Lines__r.Size()){
                                Decimal Difference =  otherVendor2Cost - purchaseOrder.Other_Charges_2__c;
                                payableLineTocreate.AcctSeed__Amount__c =  purchOrderline.Other_Charges_2__c.setScale(2) - Difference;
                            }else{
                                payableLineTocreate.AcctSeed__Amount__c =  purchOrderline.Other_Charges_2__c.setScale(2) ;
                            }
                        }
                    }
                  
                    //payableLineTocreate.AcctSeed__Account_Payable__r=PayableRef;
                    lstPurchaseOrderProductvendorLineToCreate.add(payableLineTocreate);
                }
            }
            
        }
        
        AcctSeed__Account_Payable__c payable = new AcctSeed__Account_Payable__c();
        payable.AcctSeed__Status__c = 'Approved';
        payable.AcctSeedERP__Purchase_Order__c = purchaseOrder.Id;
        payable.AcctSeed__Payment_Status__c='Unpaid';
        payable.AcctSeed__Accounting_Period__c = getAccountingPeriod(issueDate);      
        payable.AcctSeed__Date__c=issueDate;
        payable.AcctSeed__Due_Date__c=dueDate;
        payable.AcctSeed__Payee_Reference__c=payeeReference ;
        payable.AcctSeed__Ledger__c = purchaseOrder.AcctSeedERP__Ledger__c;
        if(Vendor != null){
            payable.AcctSeed__Vendor__c = Vendor;  
        }
        //payable.Ext_ID_for_Single_Insert__c=guid; 
        /*if(!lstPurchaseOrderProductvendorLineToCreate.IsEmpty()){
            SObject[] sobjList = new List<SObject>();
            sobjList.add(payable);
            sobjList.addAll(lstPurchaseOrderProductvendorLineToCreate);   
            Database.SaveResult[] results = Database.insert(sobjList);
        }*/
        insert payable;
        for(AcctSeed__Account_Payable_Line__c payableLine: lstPurchaseOrderProductvendorLineToCreate){
            payableLine.AcctSeed__Account_Payable__c = payable.Id;
        }
        insert lstPurchaseOrderProductvendorLineToCreate;
        
    }
    
}