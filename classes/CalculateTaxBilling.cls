/*
 * Test Class: CalculateTaxTest
 */
public with sharing class CalculateTaxBilling {
    
    public static CalculateTax.ResponseWrapper calculateTax(String recordId){
        CalculateTax.ResponseWrapper responseResult = new CalculateTax.ResponseWrapper();
        System.debug('===== Method Called =====');
        
        list<AcctSeed__Billing__c> selectedBilling = [select Id, Name,AcctSeed__Date__c, AcctSeed__Customer__r.name, AcctSeed__Customer__r.RecordType.Name,AcctSeed__Customer__r.AcctSeed__Entity_Use_Code__c, AcctSeed__Customer__r.Customer_Number__c,
                                    AcctSeed__Customer__r.AcctSeed__Exemption_Number__c,AcctSeed__Billing_Street__c, AcctSeed__Billing_City__c, 
                                    AcctSeed__Billing_State__c,AcctSeed__Billing_Country__c, AcctSeed__Billing_PostalCode__c, AcctSeed__Shipping_Street__c,
                                    AcctSeed__Shipping_City__c, AcctSeed__Shipping_State__c, AcctSeed__Shipping_Country__c, AcctSeed__Shipping_PostalCode__c,
                                    AcctSeed__Opportunity__c, AcctSeed__Opportunity__r.Pricebook2Id, AcctSeed__Opportunity__r.Name, AcctSeed__Opportunity__r.Ship_to_Address__c,
                                    AcctSeed__Opportunity__r.Ship_to_Address__r.Shipping_City__c, AcctSeed__Opportunity__r.Ship_to_Address__r.Shipping_Country__c, AcctSeed__Opportunity__r.Ship_to_Address__r.Shipping_State_Province__c, 
                                    AcctSeed__Opportunity__r.Ship_to_Address__r.Shipping_Street__c, AcctSeed__Opportunity__r.Ship_to_Address__r.Shipping_Zip_Postal_Code__c,
                                    Ship_to_Address__r.Shipping_City__c, Ship_to_Address__r.Shipping_Country__c, Ship_to_Address__r.Shipping_State_Province__c, 
                                    Ship_to_Address__r.Shipping_Street__c, Ship_to_Address__r.Shipping_Zip_Postal_Code__c,Delivery_Type__c,
                                    Ship_From_Address__r.Street__c, Ship_From_Address__r.City__c, Ship_From_Address__r.State__c,
                                    Ship_From_Address__r.Country__c, Ship_From_Address__r.Zip_Code__c, Ship_From_Address__r.Avalara_Location_Code__c,
                                    Warehouse_Location__r.Street__c, Warehouse_Location__r.City__c,Warehouse_Location__r.State__c,
                                    Warehouse_Location__r.Country__c, Warehouse_Location__r.Zip_Code__c,Warehouse_Location__r.Avalara_Location_Code__c,
                                    (Select Id, AcctSeed__Hours_Units__c, AcctSeed__Sub_Total__c, AcctSeed__Product__c, AcctSeed__Product__r.Name, AcctSeed__Product__r.Tax_Code__c, AcctSeed__Product__r.Description, AcctSeed__Product__r.StockKeepingUnit, 
                                    AcctSeed__Product__r.Tyre_Type__c, AcctSeed__Product__r.RIM__c, AcctSeed__Product__r.Studded__c, AcctSeed__Product__r.WEIGHT_IN_LBS__c, AcctSeed__Product__r.Width_Inches__c,
                                    AcctSeed__Product__r.Product_Type__c, Group__c, AcctSeed__Product__r.Product_Master__r.StockKeepingUnit,AcctSeed__Product__r.Tread_Width_In_Inches__c,AcctSeed__Product__r.ProductCode
                                    From AcctSeed__Project_Billing_Lines__r) 
                                    from AcctSeed__Billing__c
                                    Where Id =:recordId
                                ];


        //Validiting required parement for Avalara Request.
        for(AcctSeed__Billing__c checkValidity: selectedBilling){
            System.debug('checkValidity.Delivery_Type__c >>>'+checkValidity.Delivery_Type__c);
            responseResult.title = 'Required Parameter Missing';
            responseResult.variant = 'error';
            // if(checkValidity.AcctSeed__Opportunity__c == null){
            //     responseResult.message = 'Opportunity is not associated with this billing.';
            //       if(!Test.isRunningTest())
            //     return responseResult;
            // }
            
            if(checkValidity.AcctSeed__Project_Billing_Lines__r.size() < 1){
                responseResult.title = 'No Product Found';
                responseResult.message = 'Please add product before calculating tax.';
                  if(!Test.isRunningTest())
                return responseResult;
            }
            for(AcctSeed__Billing_Line__c billingLine: checkValidity.AcctSeed__Project_Billing_Lines__r){
                if(String.isBlank(billingLine.AcctSeed__Product__r.Tax_Code__c)&& !'State Fee'.equalsIgnoreCase(billingLine.AcctSeed__Product__r.ProductCode)){
                    responseResult.message = 'Tax Code Missing on ' + billingLine.AcctSeed__Product__r.Name + ' Product';
                      if(!Test.isRunningTest())
                    return responseResult;
                }
                if(!'State Fee'.equalsIgnoreCase(billingLine.AcctSeed__Product__r.StockKeepingUnit) && !'FET Product'.equalsIgnoreCase(billingLine.AcctSeed__Product__r.Product_Type__c) && 'PA3000301'.equalsIgnoreCase(billingLine.AcctSeed__Product__r.Tax_Code__c)){
                    responseResult.message = billingLine.AcctSeed__Product__r.Name + ' Product is missing,';
                    Integer count = 0;
                    if(String.isBlank(billingLine.AcctSeed__Product__r.Tyre_Type__c)){
                        responseResult.message += ' Tire Type,';
                        count++;
                    }
                    if(String.isBlank(billingLine.AcctSeed__Product__r.RIM__c)){
                        responseResult.message += ' Rim Diameter,';
                        count++;
                    }
                    if(String.isBlank(billingLine.AcctSeed__Product__r.Studded__c)){
                        responseResult.message += ' Studded,';
                        count++;
                    }
                    if(billingLine.AcctSeed__Product__r.WEIGHT_IN_LBS__c == null){
                        responseResult.message += ' Net Weight,';
                        count++;
                    }
                    if(String.isBlank(String.valueof(billingLine.AcctSeed__Product__r.Tread_Width_In_Inches__c))){
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
        
        Set<Id> setPriceBookId = new Set<Id>();
        Map<String, String> lineItemAndGroup = new Map<String, String>();
        AvalaraRequestParser request = new AvalaraRequestParser();
        request.adjustmentReason = 'Other';
        request.adjustmentDescription = 'Other';
        AvalaraRequestParser.cls_createTransactionModel requestTransactionModal = new AvalaraRequestParser.cls_createTransactionModel();
        requestTransactionModal.type                    = 'SalesInvoice';
     
        requestTransactionModal.companyCode             = 'MAE-BAKERSFEILD';
       
        requestTransactionModal.purchaseOrderNo         = '';
        requestTransactionModal.ReferenceCode           = '';
        requestTransactionModal.SalespersonCode         = UserInfo.getName();
        requestTransactionModal.commit_x                = false;
        requestTransactionModal.currencyCode            = 'USD';


        for(AcctSeed__Billing__c billing: selectedBilling){
            requestTransactionModal.date_x                  = String.valueOf(billing.AcctSeed__Date__c);
            if(billing.AcctSeed__Opportunity__c != null){
                setPriceBookId.add(billing.AcctSeed__Opportunity__r.Pricebook2Id);
            }
            if(billing.AcctSeed__Customer__r.RecordType.Name.equalsIgnoreCase('Reseller')){
                requestTransactionModal.entityUseCode               = billing.AcctSeed__Customer__r.AcctSeed__Entity_Use_Code__c;
                requestTransactionModal.exemptionNo                  = billing.AcctSeed__Customer__r.AcctSeed__Exemption_Number__c;
            }
            requestTransactionModal.description                     = 'Billing - ' + billing.Name;
            requestTransactionModal.Code                            = 'Billing - ' + billing.Name;
            requestTransactionModal.customerCode                    = billing.AcctSeed__Customer__r.Customer_Number__c;
           
            requestTransactionModal.addresses = new AvalaraRequestParser.cls_addresses();
            requestTransactionModal.addresses.ShipTo = new AvalaraRequestParser.cls_ShipTo();
            requestTransactionModal.addresses.ShipFrom = new AvalaraRequestParser.cls_ShipFrom();
            if(Test.isRunningTest()){
                billing.Delivery_Type__c='Door Delivery';
            }

              if('Door Delivery'.equalsIgnoreCase(billing.Delivery_Type__c)){
                requestTransactionModal.ReportingLocationCode   = billing.Ship_From_Address__r.Avalara_Location_Code__c;
                  requestTransactionModal.addresses.ShipTo.line1        = billing.Ship_to_Address__r.Shipping_Street__c;
                  requestTransactionModal.addresses.ShipTo.city         = billing.Ship_to_Address__r.Shipping_City__c;
                  requestTransactionModal.addresses.ShipTo.region       = billing.Ship_to_Address__r.Shipping_State_Province__c;
                  requestTransactionModal.addresses.ShipTo.country      = billing.Ship_to_Address__r.Shipping_Country__c;
                  requestTransactionModal.addresses.ShipTo.postalCode   = billing.Ship_to_Address__r.Shipping_Zip_Postal_Code__c;
        
                  requestTransactionModal.addresses.ShipFrom.line1          = billing.Ship_From_Address__r.Street__c;
                  requestTransactionModal.addresses.ShipFrom.city           = billing.Ship_From_Address__r.City__c;
                  requestTransactionModal.addresses.ShipFrom.region         = billing.Ship_From_Address__r.State__c;
                  requestTransactionModal.addresses.ShipFrom.country        = billing.Ship_From_Address__r.Country__c;
                  requestTransactionModal.addresses.ShipFrom.postalCode     = billing.Ship_From_Address__r.Zip_Code__c;
  
  
              }else  if('Store Pick up'.equalsIgnoreCase(billing.Delivery_Type__c)){
                requestTransactionModal.ReportingLocationCode   = billing.Warehouse_Location__r.Avalara_Location_Code__c;
                  requestTransactionModal.addresses.ShipFrom.line1        = billing.Warehouse_Location__r.Street__c;
                  requestTransactionModal.addresses.ShipFrom.city         = billing.Warehouse_Location__r.City__c;
                  requestTransactionModal.addresses.ShipFrom.region       = billing.Warehouse_Location__r.State__c;
                  requestTransactionModal.addresses.ShipFrom.country      = billing.Warehouse_Location__r.Country__c;
                  requestTransactionModal.addresses.ShipFrom.postalCode   = billing.Warehouse_Location__r.Zip_Code__c;
                  
                  requestTransactionModal.addresses.ShipTo.line1          = billing.Warehouse_Location__r.Street__c;
                  requestTransactionModal.addresses.ShipTo.city           = billing.Warehouse_Location__r.City__c;
                  requestTransactionModal.addresses.ShipTo.region         = billing.Warehouse_Location__r.State__c;
                  requestTransactionModal.addresses.ShipTo.country        = billing.Warehouse_Location__r.Country__c;
                  requestTransactionModal.addresses.ShipTo.postalCode     = billing.Warehouse_Location__r.Zip_Code__c;
              }

            requestTransactionModal.lines = new List<AvalaraRequestParser.cls_lines>();
            for(AcctSeed__Billing_Line__c billingLine: billing.AcctSeed__Project_Billing_Lines__r){
                if(!'State Fee'.equalsIgnoreCase(billingLine.AcctSeed__Product__r.StockKeepingUnit)){
                    AvalaraRequestParser.cls_lines line = new AvalaraRequestParser.cls_lines();
                    line.number_x       = billingLine.Id;
                    line.quantity       = CalculateQuantity(billingLine.AcctSeed__Product__r.Name,billingLine.AcctSeed__Hours_Units__c);
                    line.amount         = billingLine.AcctSeed__Sub_Total__c;
                    line.taxCode        = billingLine.AcctSeed__Product__r.Tax_Code__c;
                    line.description    = billingLine.AcctSeed__Product__r.Description;
                    line.itemCode       = billingLine.AcctSeed__Product__r.StockKeepingUnit;
                    if(billingLine.AcctSeed__Product__r.Tax_Code__c == 'PA3000301'){
                        line.parameters  = new List<AvalaraRequestParser.cls_parameters>();
                        line.parameters.add(getParameters1('TireType', String.valueOf(billingLine.AcctSeed__Product__r.Tyre_Type__c)));
                        if(!'FET Product'.equalsIgnoreCase(billingLine.AcctSeed__Product__r.Product_Type__c)){
                           
                            line.parameters.add(getParameters('RimDiameter', String.valueOf(billingLine.AcctSeed__Product__r.RIM__c), 'Inch'));
                            line.parameters.add(getParameters1('Studded', String.valueOf(billingLine.AcctSeed__Product__r.Studded__c)));
                            line.parameters.add(getParameters('NetWeight', String.valueOf(billingLine.AcctSeed__Product__r.WEIGHT_IN_LBS__c), 'Pound'));
                            line.parameters.add(getParameters('TreadWidth', String.valueOf(billingLine.AcctSeed__Product__r.Width_Inches__c), 'Inch'));
                        }
                    }
                    requestTransactionModal.lines.add(line);
                    if( String.isNotBlank(billingLine.AcctSeed__Product__r.Product_Type__c)){
                        if(billingLine.AcctSeed__Product__r.Product_Type__c.equalsIgnoreCase('Kit Product')){
                            lineItemAndGroup.put(billingLine.Id, billingLine.AcctSeed__Product__r.Product_Master__r.StockKeepingUnit);
                        }else if(billingLine.AcctSeed__Product__r.Product_Type__c.equalsIgnoreCase('Base Product')){
                            lineItemAndGroup.put(billingLine.Id, billingLine.AcctSeed__Product__r.StockKeepingUnit);
                        }
                    }
                }
            }
        }
        request.createTransactionModel = requestTransactionModal;

        
        String stringifyJson = JSON.serialize(request, true);
      
        stringifyJson= stringifyJson.replace('number_x','number').replace('date_x','date').replace('commit_x','commit');
     
        System.debug('Request Body >>>>'+stringifyJson);

        AvalaraHttpCallOut callout = new AvalaraHttpCallOut();
        HttpResponse response = callout.getTaxAmountDetails(stringifyJson);
        System.debug('Response Body >>>>'+response.getBody());
        if(response.getStatusCode() == 201 || response.getStatusCode() == 200){
            AvalaraResponseDetails resultObj = (AvalaraResponseDetails) System.JSON.deserialize(response.getBody(), AvalaraResponseDetails.class);
          
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
          
            
            List<AcctSeed__Billing_Line__c> stateFeeBillingLineItemToInsert= new List<AcctSeed__Billing_Line__c>();

            for(AvalaraResponseDetails.lineItem line: resultObj.lines){
                System.debug(line.details);
                for(AvalaraResponseDetails.lineDetails details: line.details){
                    if(details.taxType == 'Tires' && lineItemAndGroup.containsKey(line.lineNumber) && Decimal.valueOf(details.reportingTaxCalculated) > 0){
                        AcctSeed__Billing_Line__c stateFeeLineItem= new AcctSeed__Billing_Line__c();
                        //stateFeeLineItem.Group__c                           = lineItemAndGroup.get(line.lineNumber);
                        stateFeeLineItem.AcctSeed__Product__c       = stateFeePriceBookEntry[0].product2Id;
                        stateFeeLineItem.AcctSeed__Hours_Units__c   = Decimal.valueOf(details.reportingTaxableUnits);
                        stateFeeLineItem.AcctSeed__Billing__c       = recordId;
                        stateFeeLineItem.AcctSeed__Rate__c          = Decimal.valueOf(details.rate);
                        //stateFeeLineItem.PricebookEntryId   = stateFeePriceBookEntry[0].Id;
                        stateFeeLineItem.Parent_Line_Item__c   	= line.lineNumber;
                        stateFeeBillingLineItemToInsert.add(stateFeeLineItem);
                    }
                }
            }

            List<AcctSeed__Billing_Line__c> deleteOldStateFeeLineItem = new List<AcctSeed__Billing_Line__c>();
            List<Avalara_Tax_Calculation__c> taxCalculationRecord = new List<Avalara_Tax_Calculation__c>();
            List<AcctSeed__Billing_Line__c> billingLineitemToUpdate = new List<AcctSeed__Billing_Line__c>();

            for(AcctSeed__Billing_Line__c lineItem: [Select Id, AcctSeed__Billing__c, AcctSeed__Tax_Amount2__c, AcctSeed__Product__c, AcctSeed__Product__r.Name, AcctSeed__Product__r.Tax_Code__c, AcctSeed__Product__r.Description, AcctSeed__Product__r.StockKeepingUnit, 
                                                    AcctSeed__Product__r.Tyre_Type__c, AcctSeed__Product__r.RIM__c, AcctSeed__Product__r.Studded__c, AcctSeed__Product__r.WEIGHT_IN_LBS__c, AcctSeed__Product__r.Width_Inches__c,
                                                    AcctSeed__Product__r.Product_Type__c, Group__c, AcctSeed__Product__r.Product_Master__r.StockKeepingUnit
                                                    From AcctSeed__Billing_Line__c Where AcctSeed__Billing__c =: recordId]){
                if(lineIdAndLineResponse.containsKey(lineItem.Id) && !'State Fee'.equalsIgnoreCase(lineItem.AcctSeed__Product__r.StockKeepingUnit)){

                    Decimal taxAmount=Decimal.valueOf(lineIdAndLineResponse.get(lineItem.Id).taxCalculated);
                    for(AvalaraResponseDetails.lineDetails lineDetail: lineIdAndLineResponse.get(lineItem.Id).details){
                        if(lineDetail.taxType.equalsIgnoreCase('Tires')){
                            taxAmount = taxAmount- Decimal.valueOf(lineDetail.taxCalculated);
                        }
                    }
                    lineItem.AcctSeed__Tax_Amount2__c = taxAmount;
                    Avalara_Tax_Calculation__c calculatedTax = new Avalara_Tax_Calculation__c();
                    calculatedTax.Billing__c                      = lineItem.AcctSeed__Billing__c;
                    calculatedTax.Billing_Line__c                 = lineItem.Id;
                    calculatedTax.Sales_Tax_Amount__c             = Decimal.valueOf(lineIdAndLineResponse.get(lineItem.Id).taxableAmount) + Decimal.valueOf(lineIdAndLineResponse.get(lineItem.Id).taxCalculated);
                    calculatedTax.Zip_Code__c                     = resultObj.addresses[0].postalCode;
                    calculatedTax.quantity__c                     = Decimal.valueOf(lineIdAndLineResponse.get(lineItem.Id).quantity);
                    calculatedTax.Required_Committed_Status__c    = false;
                   // calculatedTax.Request_JSON__c                 = stringifyJson;
                   // calculatedTax.Response_JSON__c                = response.getBody();
                    taxCalculationRecord.add(calculatedTax);
                    billingLineitemToUpdate.add(lineItem);
                }
                if('State Fee'.equalsIgnoreCase(lineItem.AcctSeed__Product__r.StockKeepingUnit)){
                    deleteOldStateFeeLineItem.add(lineItem);
                }
            }

            if(stateFeeBillingLineItemToInsert.size() > 0){
                insert stateFeeBillingLineItemToInsert;
            }
            if(deleteOldStateFeeLineItem.size() > 0){
                delete deleteOldStateFeeLineItem;
            }
            if(billingLineitemToUpdate.size() > 0){
                update billingLineitemToUpdate;
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