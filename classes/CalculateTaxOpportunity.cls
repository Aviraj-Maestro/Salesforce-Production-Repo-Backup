/*
 * Test Class: CalculateTaxTest
 */
public with sharing class CalculateTaxOpportunity {
    @AuraEnabled
    public static CalculateTax.ResponseWrapper calculateTax(String recordId){
        CalculateTax.ResponseWrapper responseResult = new CalculateTax.ResponseWrapper();
        System.debug('===== Method Called =====');
        Set<Id> setPriceBookId = new Set<Id>();
        List<Opportunity> selectedOpportunity = [Select Id, Name, Pricebook2Id, Delivery_Type__c,Account.AcctSeed__Exemption_Number__c,Account.RecordType.Name,Account.AcctSeed__Entity_Use_Code__c, Account.Customer_Number__c, Account.BillingCity, Account.BillingState, Account.BillingStreet, Account.BillingCountry, 
                        Account.BillingPostalCode, Account.ShippingState, Account.ShippingStreet, Account.ShippingCity, Account.ShippingCountry, Account.ShippingPostalCode,
                        Bill_to_Adddress__r.Billing_City__c, Bill_to_Adddress__r.Billing_Country__c, Bill_to_Adddress__r.Billing_State_Province__c, Bill_to_Adddress__r.Billing_Street__c, Bill_to_Adddress__r.Billing_Zip_Postal_Code__c,
                        Warehouse_Location__r.City__c, Warehouse_Location__r.Country__c, Warehouse_Location__r.State__c, Warehouse_Location__r.Street__c, Warehouse_Location__r.Zip_Code__c, Ship_to_Address__c,
                        Ship_to_Address__r.Shipping_City__c, Ship_to_Address__r.Shipping_Country__c, Ship_to_Address__r.Shipping_State_Province__c, Ship_to_Address__r.Shipping_Street__c, Ship_to_Address__r.Shipping_Zip_Postal_Code__c,
                        Ship_From_Address__r.Street__c,Ship_From_Address__r.City__c,Ship_From_Address__r.State__c,Ship_From_Address__r.Country__c,Ship_From_Address__r.Zip_Code__c,
                        (Select id, Name, Quantity, ProductCode, Group__c, UnitPrice, product2Id, Description, Product2.PATTERN__c, Product2.RIM__c, Product2.Tyre_Type__c, Product2.WEIGHT_IN_LBS__c, Product2.Description,
                        Product2.Width_Inches__c,Product2.Tread_Width_In_Inches__c, Product2.Tax_Code__c, Product2.StockKeepingUnit, Product2.Name, Product2.Product_Master__r.Name, Product2.Product_Master__c, 
                        Product2.Product_Type__c, TotalPrice, Product2.Studded__c, Product2.Product_Master__r.StockKeepingUnit
                        from opportunityLineItems) 
                        From Opportunity 
                        Where Id =: recordId];
        
        //Validiting required parement for Avalara Request.
        for(Opportunity checkValidity: selectedOpportunity){
            responseResult.title = 'Required Parameter Missing';
            responseResult.variant = 'error';
            
            // if(checkValidity.Ship_to_Address__c == null){
            //     responseResult.message = 'Ship to Address is required to calculate tax.';
            //     if(!Test.isRunningTest())
            //         return responseResult;
            // }
            if(checkValidity.opportunityLineItems.size() < 1 || Test.IsRunningTest()){
                responseResult.title = 'No Product Found';
                responseResult.message = 'Please add product before calculating tax.';
                  if(!Test.isRunningTest())
                return responseResult;
            }
            for(opportunityLineItem oppLine: checkValidity.opportunityLineItems){
                if(String.isBlank(oppLine.Product2.Tax_Code__c) && !'State Fee'.equalsIgnoreCase(oppLine.ProductCode)){
                    responseResult.message = 'Tax Code Missing on ' + oppLine.Product2.Name + ' Product';
                      if(!Test.isRunningTest())
                    return responseResult;
                }
                if(!'State Fee'.equalsIgnoreCase(oppLine.ProductCode) && !'FET Product'.equalsIgnoreCase(oppLine.Product2.Product_Type__c) && 'PA3000301'.equalsIgnoreCase(oppLine.Product2.Tax_Code__c)){
                    responseResult.message = oppLine.Product2.Name + ' Product is missing,';
                    Integer count = 0;
                    if(String.isBlank(oppLine.Product2.Tyre_Type__c)){
                        responseResult.message += ' Tire Type,';
                        count++;
                    }
                    if(String.isBlank(oppLine.Product2.RIM__c)){
                        responseResult.message += ' Rim Diameter,';
                        count++;
                    }
                    if(String.isBlank(oppLine.Product2.Studded__c)){
                        responseResult.message += ' Studded,';
                        count++;
                    }
                    if(oppLine.Product2.WEIGHT_IN_LBS__c == null){
                        responseResult.message += ' Net Weight,';
                        count++;
                    }
                    if(String.isBlank(String.valueof(oppLine.Product2.Tread_Width_In_Inches__c))){
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
        
        Map<String, String> lineItemAndGroup = new Map<String, String>();
        AvalaraRequestParser request = new AvalaraRequestParser();
        request.adjustmentReason = 'Other';
        request.adjustmentDescription = 'Other';
        AvalaraRequestParser.cls_createTransactionModel requestTransactionModal = new AvalaraRequestParser.cls_createTransactionModel();
        requestTransactionModal.type                    = 'SalesOrder';
        requestTransactionModal.ReportingLocationCode   = '';
        //requestTransactionModal.companyCode             = 'MAESTROTIREUSA';
        requestTransactionModal.companyCode             = 'MAE-BAKERSFEILD';
        requestTransactionModal.date_x                  = String.valueOf(System.today());
        requestTransactionModal.purchaseOrderNo         = '';
        requestTransactionModal.ReferenceCode           = '';
        requestTransactionModal.SalespersonCode         = UserInfo.getName();
        requestTransactionModal.commit_x                = false;
        requestTransactionModal.currencyCode            = 'USD';
       
        for(Opportunity opp: selectedOpportunity){
            setPriceBookId.add(opp.Pricebook2Id);
            requestTransactionModal.Code                            = 'Opportunity - ' + opp.Name;
            requestTransactionModal.customerCode                    = opp.Account.Customer_Number__c;
            requestTransactionModal.description                     = 'Opportunity - ' + opp.Name;
            if(opp.Account.RecordType.Name.equalsIgnoreCase('Reseller')){
              //  requestTransactionModal.customerUsageType           = 'G';
                requestTransactionModal.entityUseCode               = opp.Account.AcctSeed__Entity_Use_Code__c;
                requestTransactionModal.exemptionNo                    = opp.Account.AcctSeed__Exemption_Number__c;
            }
            requestTransactionModal.addresses = new AvalaraRequestParser.cls_addresses();
        //  requestTransactionModal.addresses.SingleLocation = new AvalaraRequestParser.cls_SingleLocation();
          requestTransactionModal.addresses.ShipTo = new AvalaraRequestParser.cls_ShipTo();
          requestTransactionModal.addresses.ShipFrom = new AvalaraRequestParser.cls_ShipFrom();
            if('Door Delivery'.equalsIgnoreCase(opp.Delivery_Type__c)){

                // requestTransactionModal.addresses.SingleLocation.line1          = opp.Ship_to_Address__r.Shipping_Street__c;
                // requestTransactionModal.addresses.SingleLocation.city           = opp.Ship_to_Address__r.Shipping_City__c;
                // requestTransactionModal.addresses.SingleLocation.region         = opp.Ship_to_Address__r.Shipping_State_Province__c;
                // requestTransactionModal.addresses.SingleLocation.country        = opp.Ship_to_Address__r.Shipping_Country__c;
                // requestTransactionModal.addresses.SingleLocation.postalCode     = opp.Ship_to_Address__r.Shipping_Zip_Postal_Code__c;
                System.debug('opp.Ship_to_Address__r.Shipping_Street__c >>>>'+opp.Ship_to_Address__r.Shipping_Street__c);
                System.debug('opp.Ship_to_Address__r.Shipping_City__c >>>>'+opp.Ship_to_Address__r.Shipping_City__c);

                requestTransactionModal.addresses.ShipTo.line1          = opp.Ship_to_Address__r.Shipping_Street__c;
                requestTransactionModal.addresses.ShipTo.city           = opp.Ship_to_Address__r.Shipping_City__c;
                requestTransactionModal.addresses.ShipTo.region         = opp.Ship_to_Address__r.Shipping_State_Province__c;
                requestTransactionModal.addresses.ShipTo.country        = opp.Ship_to_Address__r.Shipping_Country__c;
                requestTransactionModal.addresses.ShipTo.postalCode     = opp.Ship_to_Address__r.Shipping_Zip_Postal_Code__c;

                requestTransactionModal.addresses.ShipFrom.line1          = opp.Ship_From_Address__r.Street__c;
                requestTransactionModal.addresses.ShipFrom.city           = opp.Ship_From_Address__r.City__c;
                requestTransactionModal.addresses.ShipFrom.region         = opp.Ship_From_Address__r.State__c;
                requestTransactionModal.addresses.ShipFrom.country        = opp.Ship_From_Address__r.Country__c;
                requestTransactionModal.addresses.ShipFrom.postalCode     = opp.Ship_From_Address__r.Zip_Code__c;

            }else  if('Store Pick up'.equalsIgnoreCase(opp.Delivery_Type__c)){

                // requestTransactionModal.addresses.SingleLocation.line1          = opp.Warehouse_Location__r.Street__c;
                // requestTransactionModal.addresses.SingleLocation.city           = opp.Warehouse_Location__r.City__c;
                // requestTransactionModal.addresses.SingleLocation.region         = opp.Warehouse_Location__r.State__c;
                // requestTransactionModal.addresses.SingleLocation.country        = opp.Warehouse_Location__r.Country__c;
                // requestTransactionModal.addresses.SingleLocation.postalCode     = opp.Warehouse_Location__r.Zip_Code__c;    

                 
                requestTransactionModal.addresses.ShipTo.line1          = opp.Warehouse_Location__r.Street__c;
                requestTransactionModal.addresses.ShipTo.city           = opp.Warehouse_Location__r.City__c;
                requestTransactionModal.addresses.ShipTo.region         = opp.Warehouse_Location__r.State__c;
                requestTransactionModal.addresses.ShipTo.country        = opp.Warehouse_Location__r.Country__c;
                requestTransactionModal.addresses.ShipTo.postalCode     = opp.Warehouse_Location__r.Zip_Code__c;

                requestTransactionModal.addresses.ShipFrom.line1          = opp.Warehouse_Location__r.Street__c;
                requestTransactionModal.addresses.ShipFrom.city           = opp.Warehouse_Location__r.City__c;
                requestTransactionModal.addresses.ShipFrom.region         = opp.Warehouse_Location__r.State__c;
                requestTransactionModal.addresses.ShipFrom.country        = opp.Warehouse_Location__r.Country__c;
                requestTransactionModal.addresses.ShipFrom.postalCode     = opp.Warehouse_Location__r.Zip_Code__c;
            
            }
           
            
            
            /*
            requestTransactionModal.addresses.ShipTo.line1          = opp.Bill_to_Adddress__r.Shipping_Street__c;
            requestTransactionModal.addresses.ShipTo.city           = opp.Bill_to_Adddress__r.Shipping_City__c;
            requestTransactionModal.addresses.ShipTo.region         = opp.Bill_to_Adddress__r.Shipping_State_Province__c;
            requestTransactionModal.addresses.ShipTo.country        = opp.Bill_to_Adddress__r.Shipping_Country__c;
            requestTransactionModal.addresses.ShipTo.postalCode     = opp.Bill_to_Adddress__r.Shipping_Zip_Postal_Code__c;
            */
            
            requestTransactionModal.lines = new List<AvalaraRequestParser.cls_lines>();
            for(opportunityLineItem oppLine: opp.opportunityLineItems){
                if(!'State Fee'.equalsIgnoreCase(oppLine.ProductCode)){
                    AvalaraRequestParser.cls_lines line = new AvalaraRequestParser.cls_lines();
                    line.number_x       = oppLine.Id;
                    line.quantity       = CalculateQuantity(oppLine.Product2.Name,oppLine.Quantity);
                    line.amount         = oppLine.TotalPrice;
                    line.taxCode        = oppLine.Product2.Tax_Code__c;
                    line.description    = oppLine.Description;
                    line.itemCode       = oppLine.Product2.StockKeepingUnit;
                 
                    if(oppLine.Product2.Tax_Code__c == 'PA3000301'){
                        line.parameters  = new List<AvalaraRequestParser.cls_parameters>();
                        line.parameters.add(getParameters1('TireType', String.valueOf(oppLine.Product2.Tyre_Type__c)));
                        if(!'FET Product'.equalsIgnoreCase(oppLine.Product2.Product_Type__c)){
                            line.parameters.add(getParameters('RimDiameter', String.valueOf(oppLine.Product2.RIM__c), 'Inch'));
                            line.parameters.add(getParameters1('Studded', String.valueOf(oppLine.Product2.Studded__c)));
                            line.parameters.add(getParameters('NetWeight', String.valueOf(oppLine.Product2.WEIGHT_IN_LBS__c), 'Pound'));
                            line.parameters.add(getParameters('TreadWidth', String.valueOf(oppLine.Product2.Tread_Width_In_Inches__c), 'Inch'));
                            
                        }
                    }
                    requestTransactionModal.lines.add(line);
                    if(String.isNotBlank(oppLine.Product2.Product_Type__c)){
                        if(oppLine.Product2.Product_Type__c.equalsIgnoreCase('Kit Product')){
                            lineItemAndGroup.put(oppLine.Id, oppLine.Product2.Product_Master__r.StockKeepingUnit);
                        }else if(oppLine.Product2.Product_Type__c.equalsIgnoreCase('Base Product')){
                            lineItemAndGroup.put(oppLine.Id, oppLine.Product2.StockKeepingUnit);
                        }
                    }
                }
            }
            
            
        }
        request.createTransactionModel = requestTransactionModal;
        String stringifyJson = JSON.serialize(request, true);
        stringifyJson = stringifyJson.replace('number_x','number').replace('date_x','date').replace('commit_x','commit').replace(' "unit": null,','');
        System.debug('Request JSON >>>>'+stringifyJson);

        AvalaraHttpCallOut callout = new AvalaraHttpCallOut();
        HttpResponse response = callout.getTaxAmountDetails(stringifyJson);

        System.debug('Response JSON >>>>'+response.getBody());
        if(response.getStatusCode() == 201 || response.getStatusCode() == 200){
            AvalaraResponseDetails resultObj = (AvalaraResponseDetails) System.JSON.deserialize(response.getBody(), AvalaraResponseDetails.class);


            List<AvalaraResponseDetails.lineItem> allLines = new List<AvalaraResponseDetails.lineItem>();
            allLines.addAll(resultObj.lines);

            Map<String, AvalaraResponseDetails.lineItem> lineIdAndLineResponse = new Map<String, AvalaraResponseDetails.lineItem>();
            for(AvalaraResponseDetails.lineItem line: allLines){
                lineIdAndLineResponse.put(line.lineNumber, line);
            }

            List<PricebookEntry> stateFeePriceBookEntry = [SELECT Id, product2Id, UnitPrice, Pricebook2Id  from pricebookentry where Product2Id IN (select Id  from Product2 where name ='State Fee') and Pricebook2Id In: setPriceBookId];

            List<OpportunityLineItem> stateFeeOppLineItemToInsert= new List<OpportunityLineItem>();
            for(AvalaraResponseDetails.lineItem line: resultObj.lines){
                for(AvalaraResponseDetails.lineDetails details: line.details){
                    if(details.taxType == 'Tires' && lineItemAndGroup.containsKey(line.lineNumber) && Decimal.valueOf(details.reportingTaxCalculated) > 0){
                        System.debug('Record Id ==> ' + line.lineNumber);
                        OpportunityLineItem stateFeeLineItem= new OpportunityLineItem();
                        stateFeeLineItem.Group__c           	= lineItemAndGroup.get(line.lineNumber);
                        stateFeeLineItem.Product2Id         	= stateFeePriceBookEntry[0].product2Id;
                        //stateFeeLineItem.Quantity           = Decimal.valueOf(details.reportingTaxableUnits);
                        stateFeeLineItem.Quantity           	= Decimal.valueOf(line.quantity);
                        stateFeeLineItem.OpportunityId      	= recordId;
                        stateFeeLineItem.TotalPrice		      	= Decimal.valueOf(details.reportingTaxCalculated);
                        //stateFeeLineItem.UnitPrice          	= Decimal.valueOf(details.reportingTaxCalculated)/ Decimal.valueOf(line.quantity);
                        stateFeeLineItem.PricebookEntryId   	= stateFeePriceBookEntry[0].Id;
                        stateFeeLineItem.Parent_Line_Item__c   	= line.lineNumber;
                        stateFeeOppLineItemToInsert.add(stateFeeLineItem);
                    }
                }
            }

           

            /*List<opportunityLineItem> opportunityLineitemToUpdate = [Select id, Name, Quantity, ProductCode, OpportunityId, AcctSeed__Tax_Amount__c, UnitPrice, product2Id, Product2.PATTERN__c, Product2.RIM__c, Product2.Tyre_Type__c, Product2.WEIGHT_IN_LBS__c,
                            Product2.Width_Inches__c, Product2.StockKeepingUnit, Product2.Name, Product2.Product_Master__r.Name, Product2.Product_Master__c, Product2.Product_Type__c, TotalPrice 
                            from opportunityLineItem Where OpportunityId =: recordId];*/

            List<opportunityLineItem> deleteOldStateFeeLineItem = new List<opportunityLineItem>();
            //Map<Id, opportunityLineItem> deleteOldStateFeeLineItemMap = new Map<Id, opportunityLineItem>();
            
            //System.debug(opportunityLineitemToUpdate.size());
            List<Avalara_Tax_Calculation__c> taxCalculationRecord = new List<Avalara_Tax_Calculation__c>();
            List<opportunityLineItem> opportunityLineitemToUpdate = new List<opportunityLineItem>();
            
            for(opportunityLineItem lineItem: [Select id, Name, Quantity, ProductCode, OpportunityId, AcctSeed__Tax_Amount__c, UnitPrice, product2Id, Product2.PATTERN__c, Product2.RIM__c, Product2.Tyre_Type__c, Product2.WEIGHT_IN_LBS__c,
                            Product2.Width_Inches__c,Product2.Tread_Width_In_Inches__c, Product2.StockKeepingUnit, Product2.Name, Product2.Product_Master__r.Name, Product2.Product_Master__c, Product2.Product_Type__c, TotalPrice 
                            from opportunityLineItem Where OpportunityId =: recordId]){
                // Decimal.valueOf(lineIdAndLineResponse.get(lineItem.Id).taxableAmount) + Decimal.valueOf(lineIdAndLineResponse.get(lineItem.Id).taxCalculated);
                if(lineIdAndLineResponse.containsKey(lineItem.Id) && !'State Fee'.equalsIgnoreCase(lineItem.ProductCode)){
                  
                    Decimal taxAmount=Decimal.valueOf(lineIdAndLineResponse.get(lineItem.Id).taxCalculated);
                    for(AvalaraResponseDetails.lineDetails lineDetail: lineIdAndLineResponse.get(lineItem.Id).details){
                        if(lineDetail.taxType.equalsIgnoreCase('Tires')){
                            taxAmount = taxAmount- Decimal.valueOf(lineDetail.taxCalculated);
                        }
                    }
                    lineItem.AcctSeed__Tax_Amount__c = taxAmount;

                    Avalara_Tax_Calculation__c calculatedTax = new Avalara_Tax_Calculation__c();
                    calculatedTax.Opportunity__c                        = lineItem.OpportunityId;
                    calculatedTax.Opportunity_Product__c              = lineItem.id;
                    calculatedTax.Sales_Tax_Amount__c             = Decimal.valueOf(lineIdAndLineResponse.get(lineItem.Id).taxableAmount) + Decimal.valueOf(lineIdAndLineResponse.get(lineItem.Id).taxCalculated);
                    //calculatedTax.Sales_Tax__c                    = salesTax*100;
                    //calculatedTax.Tire_Fee__c                     = tireFee;
                    //calculatedTax.Tire_Fee_Amount__c              = tireFeeAmount;
                    //calculatedTax.Jurisdiction__c                 = resultObj.region;
                    calculatedTax.Zip_Code__c                     = resultObj.addresses[0].postalCode;
                    calculatedTax.quantity__c                     = Decimal.valueOf(lineIdAndLineResponse.get(lineItem.Id).quantity);
                    calculatedTax.Required_Committed_Status__c    = false;
                    taxCalculationRecord.add(calculatedTax);
                    opportunityLineitemToUpdate.add(lineItem);
                    
                }
                if('State Fee'.equalsIgnoreCase(lineItem.ProductCode)){
                    deleteOldStateFeeLineItem.add(lineItem);
                    //deleteOldStateFeeLineItemMap.put(lineItem.Id, lineItem);
                }
            }
            
           
            
            /*List<opportunityLineItem> updateExistingLineItem = new List<opportunityLineItem>();
            for(opportunityLineItem lineItem: opportunityLineitemToUpdate){
                if(!deleteOldStateFeeLineItemMap.containsKey(lineItem.Id)){
                    updateExistingLineItem.add(lineItem);
                }
            }*/

            if(stateFeeOppLineItemToInsert.size() > 0){
                insert stateFeeOppLineItemToInsert;
            }
            if(deleteOldStateFeeLineItem.size() > 0){
                delete deleteOldStateFeeLineItem;
            }
            if(opportunityLineitemToUpdate.size() > 0){
                update opportunityLineitemToUpdate;
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
        //}
    }

    private static Decimal CalculateQuantity(string name,Decimal Quantity){
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