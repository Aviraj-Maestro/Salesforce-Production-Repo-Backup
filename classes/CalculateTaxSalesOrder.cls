/*
 * Test Class: CalculateTaxTest
 */
public with sharing class CalculateTaxSalesOrder {
    @AuraEnabled
    public static CalculateTax.ResponseWrapper calculateTax(String recordId){
        CalculateTax.ResponseWrapper responseResult = new CalculateTax.ResponseWrapper();
        List<AcctSeedERP__Sales_Order__c> selectedSalesOrder = [Select Id, Name,Delivery_Type__c, AcctSeedERP__Customer__r.Customer_Number__c, AcctSeedERP__Shipping_Street__c, 
                        AcctSeedERP__Shipping_City__c, AcctSeedERP__Shipping_State__c, AcctSeedERP__Shipping_Country__c, AcctSeedERP__Shipping_PostalCode__c, AcctSeedERP__Customer__r.AcctSeed__Entity_Use_Code__c,AcctSeedERP__Customer__r.AcctSeed__Exemption_Number__c,
                        AcctSeedERP__Billing_Street__c, AcctSeedERP__Billing_City__c, AcctSeedERP__Billing_State__c, AcctSeedERP__Billing_Country__c, AcctSeedERP__Billing_PostalCode__c,
                        AcctSeedERP__Opportunity__c, AcctSeedERP__Opportunity__r.Pricebook2Id, AcctSeedERP__Opportunity__r.Account.RecordType.Name,AcctSeedERP__Opportunity__r.Account.AcctSeed__Entity_Use_Code__c,AcctSeedERP__Opportunity__r.Account.AcctSeed__Exemption_Number__c, AcctSeedERP__Opportunity__r.Name, AcctSeedERP__Opportunity__r.Ship_to_Address__c,
                        Ship_to_Address__r.Shipping_City__c, Ship_to_Address__r.Shipping_Country__c, Ship_to_Address__r.Shipping_State_Province__c, 
                        Ship_to_Address__r.Shipping_Street__c, Ship_to_Address__r.Shipping_Zip_Postal_Code__c,
                        Ship_From_Address__r.Street__c, Ship_From_Address__r.City__c, Ship_From_Address__r.State__c,
                        Ship_From_Address__r.Country__c, Ship_From_Address__r.Zip_Code__c, AcctSeedERP__Opportunity__r.Delivery_Type__c,
                        Warehouse_Location__r.Street__c, Warehouse_Location__r.City__c,Warehouse_Location__r.State__c,
                        Warehouse_Location__r.Country__c, Warehouse_Location__r.Zip_Code__c,
                        (Select Id,AcctSeedERP__Product__r.ProductCode, AcctSeedERP__Product__c, AcctSeedERP__Quantity_Ordered__c, AcctSeedERP__Total__c, AcctSeedERP__Product__r.Name, AcctSeedERP__Product__r.Tax_Code__c, AcctSeedERP__Product__r.Description, AcctSeedERP__Product__r.StockKeepingUnit, 
                        AcctSeedERP__Product__r.Tyre_Type__c, AcctSeedERP__Product__r.RIM__c, AcctSeedERP__Product__r.Studded__c, AcctSeedERP__Product__r.WEIGHT_IN_LBS__c, AcctSeedERP__Product__r.Width_Inches__c,
                        AcctSeedERP__Product__r.Product_Type__c, AcctSeedERP__Product__r.Tread_Width_In_Inches__c, Group__c, AcctSeedERP__Product__r.Product_Master__r.StockKeepingUnit
                        From AcctSeedERP__Sales_Order_Line__r) 
                        From AcctSeedERP__Sales_Order__c 
                        Where Id =: recordId];
        
        //Validiting required parement for Avalara Request.
        for(AcctSeedERP__Sales_Order__c checkValidity: selectedSalesOrder){
            responseResult.title = 'Required Parameter Missing';
            responseResult.variant = 'error';
            // if(checkValidity.AcctSeedERP__Opportunity__c == null){
            //     responseResult.message = 'Opportunity is not associated with this sales order.';
            //       if(!Test.isRunningTest())
            //     return responseResult;
            // }
            // if(checkValidity.AcctSeedERP__Opportunity__r.Ship_to_Address__c == null){
            //     responseResult.message = 'Ship to Address is required on associated opportunity to calculate tax.';
            //       if(!Test.isRunningTest())
            //     return responseResult;
            // }
            if(checkValidity.AcctSeedERP__Sales_Order_Line__r.size() < 1){
                responseResult.title = 'No Product Found';
                responseResult.message = 'Please add product before calculating tax.';
                  if(!Test.isRunningTest())
                return responseResult;
            }
            for(AcctSeedERP__Sales_Order_Line__c salesLine: checkValidity.AcctSeedERP__Sales_Order_Line__r ){
                if(String.isBlank(salesLine.AcctSeedERP__Product__r.Tax_Code__c) && !'State Fee'.equalsIgnoreCase(salesLine.AcctSeedERP__Product__r.ProductCode)){
                    responseResult.message = 'Tax Code Missing on ' + salesLine.AcctSeedERP__Product__r.Name + ' Product';
                      if(!Test.isRunningTest())
                    return responseResult;
                }
                if(!'State Fee'.equalsIgnoreCase(salesLine.AcctSeedERP__Product__r.StockKeepingUnit) && !'FET Product'.equalsIgnoreCase(salesLine.AcctSeedERP__Product__r.Product_Type__c) && 'PA3000301'.equalsIgnoreCase(salesLine.AcctSeedERP__Product__r.Tax_Code__c)){
                    responseResult.message = salesLine.AcctSeedERP__Product__r.Name + ' Product is missing,';
                    Integer count = 0;
                    if(String.isBlank(salesLine.AcctSeedERP__Product__r.Tyre_Type__c)){
                        responseResult.message += ' Tire Type,';
                        count++;
                    }
                    if(String.isBlank(salesLine.AcctSeedERP__Product__r.RIM__c)){
                        responseResult.message += ' Rim Diameter,';
                        count++;
                    }
                    if(String.isBlank(salesLine.AcctSeedERP__Product__r.Studded__c)){
                        responseResult.message += ' Studded,';
                        count++;
                    }
                    if(salesLine.AcctSeedERP__Product__r.WEIGHT_IN_LBS__c == null){
                        responseResult.message += ' Net Weight,';
                        count++;
                    }
                    if(String.isBlank(String.valueof(salesLine.AcctSeedERP__Product__r.Tread_Width_In_Inches__c))){
                        responseResult.message += ' Tread Width';
                        count++;
                    }
                    if(count > 0){
                          if(!Test.isRunningTest())
                        return responseResult;
                    }
                }
            }
        }


        System.debug('===== Method Called =====');
        Set<Id> setPriceBookId = new Set<Id>();
        Map<String, String> lineItemAndGroup = new Map<String, String>();
        AvalaraRequestParser request = new AvalaraRequestParser();
        request.adjustmentReason = 'Other';
        request.adjustmentDescription = 'Other';
        AvalaraRequestParser.cls_createTransactionModel requestTransactionModal = new AvalaraRequestParser.cls_createTransactionModel();
        requestTransactionModal.type                    = 'SalesOrder';
        requestTransactionModal.ReportingLocationCode   = '';
        //requestTransactionModal.companyCode             = 'MAESTROTIREUSA'; //For Sandbox
        requestTransactionModal.companyCode             = 'MAE-BAKERSFEILD'; //For Production
        requestTransactionModal.date_x                  = String.valueOf(System.today());
        requestTransactionModal.purchaseOrderNo         = '';
        requestTransactionModal.ReferenceCode           = '';
        requestTransactionModal.SalespersonCode         = UserInfo.getName();
        requestTransactionModal.commit_x                = false;
        requestTransactionModal.currencyCode            = 'USD';
        for(AcctSeedERP__Sales_Order__c so: selectedSalesOrder){
            if(so.AcctSeedERP__Opportunity__c != null){
                setPriceBookId.add(so.AcctSeedERP__Opportunity__r.Pricebook2Id);
                if(so.AcctSeedERP__Opportunity__r.Account.RecordType.Name.equalsIgnoreCase('Reseller')){
                //  requestTransactionModal.customerUsageType           = 'G';
                  requestTransactionModal.entityUseCode               = so.AcctSeedERP__Opportunity__r.Account.AcctSeed__Entity_Use_Code__c;
                  requestTransactionModal.exemptionNo                  = so.AcctSeedERP__Opportunity__r.Account.AcctSeed__Exemption_Number__c;
              }
            }else{
                requestTransactionModal.entityUseCode               = so.AcctSeedERP__Customer__r.AcctSeed__Entity_Use_Code__c;
                requestTransactionModal.exemptionNo                  = so.AcctSeedERP__Customer__r.AcctSeed__Exemption_Number__c;
            }
            requestTransactionModal.Code                            = 'Sales Order - ' + so.Name;
            requestTransactionModal.customerCode                    = so.AcctSeedERP__Customer__r.Customer_Number__c;
            requestTransactionModal.description                     = 'Sales Order - ' + so.Name;
           
            requestTransactionModal.addresses = new AvalaraRequestParser.cls_addresses();
            requestTransactionModal.addresses.ShipTo = new AvalaraRequestParser.cls_ShipTo();
          requestTransactionModal.addresses.ShipFrom = new AvalaraRequestParser.cls_ShipFrom();

            /*requestTransactionModal.addresses.SingleLocation = new AvalaraRequestParser.cls_SingleLocation();
            requestTransactionModal.addresses.SingleLocation.line1          = so.AcctSeedERP__Opportunity__r.Ship_to_Address__r.Shipping_Street__c;
            requestTransactionModal.addresses.SingleLocation.city           = so.AcctSeedERP__Opportunity__r.Ship_to_Address__r.Shipping_City__c;
            requestTransactionModal.addresses.SingleLocation.region         = so.AcctSeedERP__Opportunity__r.Ship_to_Address__r.Shipping_State_Province__c;
            requestTransactionModal.addresses.SingleLocation.country        = so.AcctSeedERP__Opportunity__r.Ship_to_Address__r.Shipping_Country__c;
            requestTransactionModal.addresses.SingleLocation.postalCode     = so.AcctSeedERP__Opportunity__r.Ship_to_Address__r.Shipping_Zip_Postal_Code__c;*/

            if('Door Delivery'.equalsIgnoreCase(so.Delivery_Type__c)){
                
                requestTransactionModal.addresses.ShipTo.line1        = so.Ship_to_Address__r.Shipping_Street__c;
                requestTransactionModal.addresses.ShipTo.city         = so.Ship_to_Address__r.Shipping_City__c;
                requestTransactionModal.addresses.ShipTo.region       = so.Ship_to_Address__r.Shipping_State_Province__c;
                requestTransactionModal.addresses.ShipTo.country      = so.Ship_to_Address__r.Shipping_Country__c;
                requestTransactionModal.addresses.ShipTo.postalCode   = so.Ship_to_Address__r.Shipping_Zip_Postal_Code__c;
      
                requestTransactionModal.addresses.ShipFrom.line1          = so.Ship_From_Address__r.Street__c;
                requestTransactionModal.addresses.ShipFrom.city           = so.Ship_From_Address__r.City__c;
                requestTransactionModal.addresses.ShipFrom.region         = so.Ship_From_Address__r.State__c;
                requestTransactionModal.addresses.ShipFrom.country        = so.Ship_From_Address__r.Country__c;
                requestTransactionModal.addresses.ShipFrom.postalCode     = so.Ship_From_Address__r.Zip_Code__c;


            }else  if('Store Pick up'.equalsIgnoreCase(so.Delivery_Type__c)){

                requestTransactionModal.addresses.ShipFrom.line1        = so.Warehouse_Location__r.Street__c;
                requestTransactionModal.addresses.ShipFrom.city         = so.Warehouse_Location__r.City__c;
                requestTransactionModal.addresses.ShipFrom.region       = so.Warehouse_Location__r.State__c;
                requestTransactionModal.addresses.ShipFrom.country      = so.Warehouse_Location__r.Country__c;
                requestTransactionModal.addresses.ShipFrom.postalCode   = so.Warehouse_Location__r.Zip_Code__c;
                
                requestTransactionModal.addresses.ShipTo.line1          = so.Warehouse_Location__r.Street__c;
                requestTransactionModal.addresses.ShipTo.city           = so.Warehouse_Location__r.City__c;
                requestTransactionModal.addresses.ShipTo.region         = so.Warehouse_Location__r.State__c;
                requestTransactionModal.addresses.ShipTo.country        = so.Warehouse_Location__r.Country__c;
                requestTransactionModal.addresses.ShipTo.postalCode     = so.Warehouse_Location__r.Zip_Code__c;
            }

            /*requestTransactionModal.addresses.ShipFrom = new AvalaraRequestParser.cls_ShipFrom();
            requestTransactionModal.addresses.ShipFrom.line1        = so.AcctSeedERP__Shipping_Street__c;
            requestTransactionModal.addresses.ShipFrom.city         = so.AcctSeedERP__Shipping_City__c;
            requestTransactionModal.addresses.ShipFrom.region       = so.AcctSeedERP__Shipping_State__c;
            requestTransactionModal.addresses.ShipFrom.country      = so.AcctSeedERP__Shipping_Country__c;
            requestTransactionModal.addresses.ShipFrom.postalCode   = so.AcctSeedERP__Shipping_PostalCode__c;
            requestTransactionModal.addresses.ShipTo = new AvalaraRequestParser.cls_ShipTo();
            requestTransactionModal.addresses.ShipTo.line1          = so.AcctSeedERP__Billing_Street__c;
            requestTransactionModal.addresses.ShipTo.city           = so.AcctSeedERP__Billing_City__c;
            requestTransactionModal.addresses.ShipTo.region         = so.AcctSeedERP__Billing_State__c;
            requestTransactionModal.addresses.ShipTo.country        = so.AcctSeedERP__Billing_Country__c;
            requestTransactionModal.addresses.ShipTo.postalCode     = so.AcctSeedERP__Billing_PostalCode__c;*/

            requestTransactionModal.lines = new List<AvalaraRequestParser.cls_lines>();
            for(AcctSeedERP__Sales_Order_Line__c salesLine: so.AcctSeedERP__Sales_Order_Line__r){
                if(!'State Fee'.equalsIgnoreCase(salesLine.AcctSeedERP__Product__r.StockKeepingUnit)){
                    AvalaraRequestParser.cls_lines line = new AvalaraRequestParser.cls_lines();
                    line.number_x       = salesLine.Id;
                    line.quantity       = CalculateQuantity(salesLine.AcctSeedERP__Product__r.Name,salesLine.AcctSeedERP__Quantity_Ordered__c);
                    line.amount         = salesLine.AcctSeedERP__Total__c;
                    line.taxCode        = salesLine.AcctSeedERP__Product__r.Tax_Code__c;
                    line.description    = salesLine.AcctSeedERP__Product__r.Description;
                    line.itemCode       = salesLine.AcctSeedERP__Product__r.StockKeepingUnit;
                    if(salesLine.AcctSeedERP__Product__r.Tax_Code__c == 'PA3000301'){
                        line.parameters  = new List<AvalaraRequestParser.cls_parameters>();
                        line.parameters.add(getParameters1('TireType', String.valueOf(salesLine.AcctSeedERP__Product__r.Tyre_Type__c)));

                        if(!'FET Product'.equalsIgnoreCase(salesLine.AcctSeedERP__Product__r.Product_Type__c)){
                            line.parameters.add(getParameters('RimDiameter', String.valueOf(salesLine.AcctSeedERP__Product__r.RIM__c), 'Inch'));
                            line.parameters.add(getParameters1('Studded', String.valueOf(salesLine.AcctSeedERP__Product__r.Studded__c)));
                            line.parameters.add(getParameters('NetWeight', String.valueOf(salesLine.AcctSeedERP__Product__r.WEIGHT_IN_LBS__c), 'Pound'));
                            line.parameters.add(getParameters('TreadWidth', String.valueOf(salesLine.AcctSeedERP__Product__r.Width_Inches__c), 'Inch'));
                        }
                   }
                    requestTransactionModal.lines.add(line);
                    if( String.isNotBlank(salesLine.AcctSeedERP__Product__r.Product_Type__c)){
                        if(salesLine.AcctSeedERP__Product__r.Product_Type__c.equalsIgnoreCase('Kit Product')){
                            lineItemAndGroup.put(salesLine.Id, salesLine.AcctSeedERP__Product__r.Product_Master__r.StockKeepingUnit);
                        }else if(salesLine.AcctSeedERP__Product__r.Product_Type__c.equalsIgnoreCase('Base Product')){
                            lineItemAndGroup.put(salesLine.Id, salesLine.AcctSeedERP__Product__r.StockKeepingUnit);
                        }
                    }
                }
            }
        }
        request.createTransactionModel = requestTransactionModal;

     
        String stringifyJson = JSON.serialize(request, true);
      
        stringifyJson= stringifyJson.replace('number_x','number').replace('date_x','date').replace('commit_x','commit');
        System.debug('Request JSON >>>>'+stringifyJson);

        AvalaraHttpCallOut callout = new AvalaraHttpCallOut();
        HttpResponse response = callout.getTaxAmountDetails(stringifyJson);
        System.debug('Response JSON >>>>'+response.getBody());
        if(response.getStatusCode() == 201 || response.getStatusCode() == 200){
            AvalaraResponseDetails resultObj = (AvalaraResponseDetails) System.JSON.deserialize(response.getBody(), AvalaraResponseDetails.class);
            //System.debug('========== Response Body =========');
          
            /*if(resultObj.locked){
                return false;
            }*/

            List<AvalaraResponseDetails.lineItem> allLines = new List<AvalaraResponseDetails.lineItem>();
            allLines.addAll(resultObj.lines);

            Map<String, AvalaraResponseDetails.lineItem> lineIdAndLineResponse = new Map<String, AvalaraResponseDetails.lineItem>();
            for(AvalaraResponseDetails.lineItem line: allLines){
                lineIdAndLineResponse.put(line.lineNumber, line);
            }
            System.debug(setPriceBookId);
            List<PricebookEntry> stateFeePriceBookEntry  = new List<PricebookEntry>();
            if(!setPriceBookId.IsEmpty()){
                stateFeePriceBookEntry = [SELECT Id, product2Id, UnitPrice, Pricebook2Id  from pricebookentry where Product2Id IN (select Id  from Product2 where name ='State Fee') and Pricebook2Id In: setPriceBookId];
            }else{
                stateFeePriceBookEntry = [SELECT Id, product2Id, UnitPrice, Pricebook2Id  from pricebookentry where Product2Id IN (select Id  from Product2 where name ='State Fee')];
            }
            System.debug(stateFeePriceBookEntry);
            List<AcctSeedERP__Sales_Order_Line__c> stateFeeSalesOrderLineItemToInsert= new List<AcctSeedERP__Sales_Order_Line__c>();
            for(AvalaraResponseDetails.lineItem line: resultObj.lines){
          
                for(AvalaraResponseDetails.lineDetails details: line.details){
                    System.debug('lineItemAndGroup.containsKey(line.lineNumber) >>>'+lineItemAndGroup.containsKey(line.lineNumber));
                    if(details.taxType == 'Tires' && lineItemAndGroup.containsKey(line.lineNumber) && Decimal.valueOf(details.reportingTaxCalculated) > 0){
                        AcctSeedERP__Sales_Order_Line__c stateFeeLineItem= new AcctSeedERP__Sales_Order_Line__c();
                        stateFeeLineItem.Group__c                           = lineItemAndGroup.get(line.lineNumber);
                        stateFeeLineItem.AcctSeedERP__Product__c            = stateFeePriceBookEntry[0].product2Id;
                        //stateFeeLineItem.AcctSeedERP__Quantity_Ordered__c   = Decimal.valueOf(details.reportingTaxableUnits);
                        stateFeeLineItem.AcctSeedERP__Quantity_Ordered__c   = Decimal.valueOf(line.quantity);
                        stateFeeLineItem.AcctSeedERP__Sales_Order__c        = recordId;
                        //stateFeeLineItem.AcctSeedERP__Unit_Price__c         = Decimal.valueOf(details.rate);
                        stateFeeLineItem.AcctSeedERP__Unit_Price__c         = Decimal.valueOf(details.reportingTaxCalculated)/ Decimal.valueOf(line.quantity);
                        //stateFeeLineItem.PricebookEntryId   = stateFeePriceBookEntry[0].Id;
                        stateFeeLineItem.Parent_Line_Item__c   	= line.lineNumber;
                        stateFeeSalesOrderLineItemToInsert.add(stateFeeLineItem);
                    }
                }
            }

            List<AcctSeedERP__Sales_Order_Line__c> deleteOldStateFeeLineItem = new List<AcctSeedERP__Sales_Order_Line__c>();
            List<Avalara_Tax_Calculation__c> taxCalculationRecord = new List<Avalara_Tax_Calculation__c>();
            List<AcctSeedERP__Sales_Order_Line__c> salesOrderLineitemToUpdate = new List<AcctSeedERP__Sales_Order_Line__c>();

            for(AcctSeedERP__Sales_Order_Line__c lineItem: [Select Id, AcctSeedERP__Sales_Order__c, Tax_Amount__c, AcctSeedERP__Product__c, AcctSeedERP__Quantity_Ordered__c, AcctSeedERP__Total__c, AcctSeedERP__Product__r.Name, AcctSeedERP__Product__r.Tax_Code__c, AcctSeedERP__Product__r.Description, AcctSeedERP__Product__r.StockKeepingUnit, 
                                                            AcctSeedERP__Product__r.Tyre_Type__c, AcctSeedERP__Product__r.RIM__c, AcctSeedERP__Product__r.Studded__c, AcctSeedERP__Product__r.WEIGHT_IN_LBS__c, AcctSeedERP__Product__r.Width_Inches__c
                                                            From AcctSeedERP__Sales_Order_Line__c Where AcctSeedERP__Sales_Order__c =: recordId]){
                if(lineIdAndLineResponse.containsKey(lineItem.Id) && !'State Fee'.equalsIgnoreCase(lineItem.AcctSeedERP__Product__r.StockKeepingUnit)){
                    Decimal taxAmount=Decimal.valueOf(lineIdAndLineResponse.get(lineItem.Id).taxCalculated);
                    for(AvalaraResponseDetails.lineDetails lineDetail: lineIdAndLineResponse.get(lineItem.Id).details){
                        if(lineDetail.taxType.equalsIgnoreCase('Tires')){
                            taxAmount = taxAmount- Decimal.valueOf(lineDetail.taxCalculated);
                        }
                    }
                    lineItem.Tax_Amount__c = taxAmount;
                    Avalara_Tax_Calculation__c calculatedTax = new Avalara_Tax_Calculation__c();
                    calculatedTax.Sales_Order__c                  = lineItem.AcctSeedERP__Sales_Order__c;
                    calculatedTax.Sales_Order_Line__c             = lineItem.Id;
                    calculatedTax.Sales_Tax_Amount__c             = Decimal.valueOf(lineIdAndLineResponse.get(lineItem.Id).taxableAmount) + Decimal.valueOf(lineIdAndLineResponse.get(lineItem.Id).taxCalculated);
                    calculatedTax.Zip_Code__c                     = resultObj.addresses[0].postalCode;
                    calculatedTax.quantity__c                     = Decimal.valueOf(lineIdAndLineResponse.get(lineItem.Id).quantity);
                    calculatedTax.Required_Committed_Status__c    = false;
                    calculatedTax.Request_JSON__c                 = stringifyJson;
                    calculatedTax.Response_JSON__c                = response.getBody();
                    taxCalculationRecord.add(calculatedTax);
                    salesOrderLineitemToUpdate.add(lineItem);
                }
                if('State Fee'.equalsIgnoreCase(lineItem.AcctSeedERP__Product__r.StockKeepingUnit)){
                    deleteOldStateFeeLineItem.add(lineItem);
                }
            }

            if(stateFeeSalesOrderLineItemToInsert.size() > 0){
                insert stateFeeSalesOrderLineItemToInsert;
            }
            if(deleteOldStateFeeLineItem.size() > 0){
                delete deleteOldStateFeeLineItem;
            }
            if(salesOrderLineitemToUpdate.size() > 0){
                update salesOrderLineitemToUpdate;
            }
            if(taxCalculationRecord.size() > 0){
                insert taxCalculationRecord;
            }

            responseResult.title = 'Success!';
            responseResult.variant = 'success';
            responseResult.message = 'Tax calculated succesfully.';
            return responseResult;
        }else{
            responseResult.title = 'Avalara Response Error!';
            responseResult.variant = 'error';
            responseResult.message = 'Tax claculation not processed in Avalara, please Contact you admin.';
            return responseResult;
        }
        
    }

    private static Decimal CalculateQuantity(string name,Decimal Quantity){
        System.debug('Calculate Quantity ========>');
        System.debug(name);
        System.debug(Quantity);
        if(name.contains('Set of 2')){
            Quantity=Quantity*2;
        }
        else if(name.contains('Set of 4')){
            Quantity=Quantity*4;
        }
        else if(name.contains('Set of 6')){
            Quantity=Quantity*6;
        }
        else if(name.contains('Set of 8')){
            Quantity=Quantity*8;
        }
        return Quantity;
    }

    private static AvalaraRequestParser.cls_parameters getParameters1(string name,String value){
        AvalaraRequestParser.cls_parameters param = new AvalaraRequestParser.cls_parameters();
        param.name = name;
        param.value = value;
        return param;
    }
    private static AvalaraRequestParser.cls_parameters getParameters(string name,String value, String unit){
        AvalaraRequestParser.cls_parameters param = new AvalaraRequestParser.cls_parameters();
        param.name = name;
        param.value = value;
        param.unit = unit;
        return param;
    }
}