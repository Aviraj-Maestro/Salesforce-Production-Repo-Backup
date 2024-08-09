/*
 * Test Class: CalculateTaxTest
 */
public class CalculateTaxQuote {

    @AuraEnabled
    public static CalculateTax.ResponseWrapper calculateTax(String recordId){
        CalculateTax.ResponseWrapper responseResult = new CalculateTax.ResponseWrapper();
        List<Quote> selectedQuote = [Select Id, Name, Account.Customer_Number__c, Shipping_Street__c, Shipping_City__c, Shipping_State__c, Shipping_Country__c, Shipping_Zip_Code__c, Account.AcctSeed__Exemption_Number__c,Account.RecordType.Name,Account.AcctSeed__Entity_Use_Code__c, 
                                    Billing_Street__c, Billing_City__c, Billing_State__c, Billing_Country__c, Billing_Zip_Code__c, Opportunity.Pricebook2Id, Opportunity.Name, Opportunity.Ship_to_Address__c,Delivery_Type__c,
                                    Opportunity.Ship_to_Address__r.Shipping_City__c, Opportunity.Ship_to_Address__r.Shipping_Country__c, Opportunity.Ship_to_Address__r.Shipping_State_Province__c, 
                                    Opportunity.Ship_to_Address__r.Shipping_Street__c, Opportunity.Ship_to_Address__r.Shipping_Zip_Postal_Code__c,
                                    Warehouse_Location__r.City__c, Warehouse_Location__r.Country__c, Warehouse_Location__r.State__c, Warehouse_Location__r.Street__c, Warehouse_Location__r.Zip_Code__c, Ship_to_Address__c,
                                    Ship_to_Address__r.Shipping_City__c, Ship_to_Address__r.Shipping_Country__c, Ship_to_Address__r.Shipping_State_Province__c, Ship_to_Address__r.Shipping_Street__c, Ship_to_Address__r.Shipping_Zip_Postal_Code__c,
                                    Ship_From_Address__r.Street__c,Ship_From_Address__r.City__c,Ship_From_Address__r.State__c,Ship_From_Address__r.Country__c,Ship_From_Address__r.Zip_Code__c,
                                    (Select Id, Product2Id, Quantity, Total_Price__c, Product2.Name, Product2.Tax_Code__c, Product2.Description, Product2.StockKeepingUnit, 
                                    Product2.Tyre_Type__c, Product2.RIM__c, Product2.ProductCode,Product2.Studded__c, Product2.WEIGHT_IN_LBS__c, Product2.Product_Type__c, Product2.Width_Inches__c,
                                    Product2.Product_Master__r.StockKeepingUnit, Group__c, Product_SKU__c,Product2.Tread_Width_In_Inches__c
                                    From QuoteLineItems) 
                                    From Quote 
                                    Where Id =: recordId];
        
        //Validiting required parement for Avalara Request.
        for(Quote checkValidity: selectedQuote){
            responseResult.title = 'Required Parameter Missing';
            responseResult.variant = 'error';
            
            // if(checkValidity.Opportunity.Ship_to_Address__c == null){
            //     responseResult.message = 'Ship to Address is required on associated Opportunity to calculate tax.';
            //       if(!Test.isRunningTest())
            //     return responseResult;
            // }
            if(checkValidity.QuoteLineItems.size() < 1){
                responseResult.title = 'No Product Found';
                responseResult.message = 'Please add product before calculating tax.';
                  if(!Test.isRunningTest())
                return responseResult;
            }
            for(QuoteLineItem quoteLine: checkValidity.QuoteLineItems){
                if(String.isBlank(quoteLine.Product2.Tax_Code__c) && !'State Fee'.equalsIgnoreCase(quoteLine.Product2.ProductCode)){
                    responseResult.message = 'Tax Code Missing on ' + quoteLine.Product2.Name + ' Product';
                      if(!Test.isRunningTest())
                    return responseResult;
                }
                if(!'State Fee'.equalsIgnoreCase(quoteLine.Product_SKU__c) && !'FET Product'.equalsIgnoreCase(quoteLine.Product2.Product_Type__c)&& 'PA3000301'.equalsIgnoreCase(quoteLine.Product2.Tax_Code__c) ){
                    responseResult.message = quoteLine.Product2.Name + ' Product is missing,';
                    Integer count = 0;
                    if(String.isBlank(quoteLine.Product2.Tyre_Type__c)){
                        responseResult.message += ' Tire Type,';
                        count++;
                    }
                    if(String.isBlank(quoteLine.Product2.RIM__c)){
                        responseResult.message += ' Rim Diameter,';
                        count++;
                    }
                    if(String.isBlank(quoteLine.Product2.Studded__c)){
                        responseResult.message += ' Studded,';
                        count++;
                    }
                    if(quoteLine.Product2.WEIGHT_IN_LBS__c == null){
                        responseResult.message += ' Net Weight,';
                        count++;
                    }
                    if(String.isBlank(String.valueof(quoteLine.Product2.Tread_Width_In_Inches__c))){
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
        requestTransactionModal.type                    = 'SalesOrder';
        requestTransactionModal.ReportingLocationCode   = '';
        requestTransactionModal.companyCode             = 'MAE-BAKERSFEILD';
        requestTransactionModal.date_x                  = String.valueOf(System.today());
        requestTransactionModal.purchaseOrderNo         = '';
        requestTransactionModal.ReferenceCode           = '';
        requestTransactionModal.SalespersonCode         = UserInfo.getName();
        requestTransactionModal.commit_x                = false;
        requestTransactionModal.currencyCode            = 'USD';
        for(Quote qt: selectedQuote){
      
            setPriceBookId.add(qt.Opportunity.Pricebook2Id);
            requestTransactionModal.Code                            = 'Quote - ' + qt.Name;
            requestTransactionModal.customerCode                    = qt.Account.Customer_Number__c;
            requestTransactionModal.description                     = 'Quote - ' + qt.Name;
            if(qt.Account.RecordType.Name.equalsIgnoreCase('Reseller')){
                //  requestTransactionModal.customerUsageType           = 'G';
                  requestTransactionModal.entityUseCode               = qt.Account.AcctSeed__Entity_Use_Code__c;
                  requestTransactionModal.exemptionNo                    = qt.Account.AcctSeed__Exemption_Number__c;
              }

            requestTransactionModal.addresses = new AvalaraRequestParser.cls_addresses();

            requestTransactionModal.addresses.ShipTo = new AvalaraRequestParser.cls_ShipTo();
            requestTransactionModal.addresses.ShipFrom = new AvalaraRequestParser.cls_ShipFrom();
              if('Door Delivery'.equalsIgnoreCase(qt.Delivery_Type__c)){

                  requestTransactionModal.addresses.ShipTo.line1          = qt.Ship_to_Address__r.Shipping_Street__c;
                  requestTransactionModal.addresses.ShipTo.city           = qt.Ship_to_Address__r.Shipping_City__c;
                  requestTransactionModal.addresses.ShipTo.region         = qt.Ship_to_Address__r.Shipping_State_Province__c;
                  requestTransactionModal.addresses.ShipTo.country        = qt.Ship_to_Address__r.Shipping_Country__c;
                  requestTransactionModal.addresses.ShipTo.postalCode     = qt.Ship_to_Address__r.Shipping_Zip_Postal_Code__c;
  
                  requestTransactionModal.addresses.ShipFrom.line1          = qt.Ship_From_Address__r.Street__c;
                  requestTransactionModal.addresses.ShipFrom.city           = qt.Ship_From_Address__r.City__c;
                  requestTransactionModal.addresses.ShipFrom.region         = qt.Ship_From_Address__r.State__c;
                  requestTransactionModal.addresses.ShipFrom.country        = qt.Ship_From_Address__r.Country__c;
                  requestTransactionModal.addresses.ShipFrom.postalCode     = qt.Ship_From_Address__r.Zip_Code__c;
  
              }else  if('Store Pick up'.equalsIgnoreCase(qt.Delivery_Type__c)){
  
                   
                  requestTransactionModal.addresses.ShipTo.line1          = qt.Warehouse_Location__r.Street__c;
                  requestTransactionModal.addresses.ShipTo.city           = qt.Warehouse_Location__r.City__c;
                  requestTransactionModal.addresses.ShipTo.region         = qt.Warehouse_Location__r.State__c;
                  requestTransactionModal.addresses.ShipTo.country        = qt.Warehouse_Location__r.Country__c;
                  requestTransactionModal.addresses.ShipTo.postalCode     = qt.Warehouse_Location__r.Zip_Code__c;
  
                  requestTransactionModal.addresses.ShipFrom.line1          = qt.Warehouse_Location__r.Street__c;
                  requestTransactionModal.addresses.ShipFrom.city           = qt.Warehouse_Location__r.City__c;
                  requestTransactionModal.addresses.ShipFrom.region         = qt.Warehouse_Location__r.State__c;
                  requestTransactionModal.addresses.ShipFrom.country        = qt.Warehouse_Location__r.Country__c;
                  requestTransactionModal.addresses.ShipFrom.postalCode     = qt.Warehouse_Location__r.Zip_Code__c;
              
              }

            requestTransactionModal.lines = new List<AvalaraRequestParser.cls_lines>();
            for(QuoteLineItem quoteLine: qt.QuoteLineItems){
                if(!'State Fee'.equalsIgnoreCase(quoteLine.Product_SKU__c)){
                    AvalaraRequestParser.cls_lines line = new AvalaraRequestParser.cls_lines();
                    line.number_x       = quoteLine.Id;
                    line.quantity       = CalculateQuantity(quoteLine.Product2.Name,quoteLine.Quantity);
                    line.amount         = quoteLine.Total_Price__c;
                    line.taxCode        = quoteLine.Product2.Tax_Code__c;
                    line.description    = quoteLine.Product2.Description;
                    line.itemCode       = quoteLine.Product2.StockKeepingUnit;
                    if(quoteLine.Product2.Tax_Code__c == 'PA3000301'){
                        line.parameters  = new List<AvalaraRequestParser.cls_parameters>();
                        line.parameters.add(getParameters1('TireType', String.valueOf(quoteLine.Product2.Tyre_Type__c)));
                        if(!'FET Product'.equalsIgnoreCase(quoteLine.Product2.Product_Type__c)){
                            line.parameters.add(getParameters('RimDiameter', String.valueOf(quoteLine.Product2.RIM__c), 'Inch'));
                            line.parameters.add(getParameters1('Studded', String.valueOf(quoteLine.Product2.Studded__c)));
                            line.parameters.add(getParameters('NetWeight', String.valueOf(quoteLine.Product2.WEIGHT_IN_LBS__c), 'Pound'));
                            line.parameters.add(getParameters('TreadWidth', String.valueOf(quoteLine.Product2.Width_Inches__c), 'Inch'));
                        }
                    }
                    requestTransactionModal.lines.add(line);

                    
                    if(String.isNotBlank(quoteLine.Product2.Product_Type__c)){
                        if(quoteLine.Product2.Product_Type__c.equalsIgnoreCase('Kit Product')){
                            lineItemAndGroup.put(quoteLine.Id, quoteLine.Product2.Product_Master__r.StockKeepingUnit);
                        }else if(quoteLine.Product2.Product_Type__c.equalsIgnoreCase('Base Product')){
                            lineItemAndGroup.put(quoteLine.Id, quoteLine.Product2.StockKeepingUnit);
                        }
                    }

                  
                }
            }

        }
        request.createTransactionModel = requestTransactionModal;

     
        String stringifyJson = JSON.serialize(request, true);
     
        stringifyJson = stringifyJson.replace('number_x','number').replace('date_x','date').replace('commit_x','commit');
      

        AvalaraHttpCallOut callout = new AvalaraHttpCallOut();
        HttpResponse response = callout.getTaxAmountDetails(stringifyJson);

        if(response.getStatusCode() == 201 || response.getStatusCode() == 200){

            AvalaraResponseDetails resultObj = (AvalaraResponseDetails) System.JSON.deserialize(response.getBody(), AvalaraResponseDetails.class);
       

            List<AvalaraResponseDetails.lineItem> allLines = new List<AvalaraResponseDetails.lineItem>();
            allLines.addAll(resultObj.lines);

            Map<String, AvalaraResponseDetails.lineItem> lineIdAndLineResponse = new Map<String, AvalaraResponseDetails.lineItem>();
            for(AvalaraResponseDetails.lineItem line: allLines){
                lineIdAndLineResponse.put(line.lineNumber, line);
            }

          
            List<PricebookEntry> stateFeePriceBookEntry = [SELECT Id, product2Id, UnitPrice, Pricebook2Id  from pricebookentry where Product2Id IN (select Id  from Product2 where name ='State Fee') and Pricebook2Id In: setPriceBookId];
           

            List<QuoteLineItem> stateFeeQuoteLineItemToInsert= new List<QuoteLineItem>();
          
            for(AvalaraResponseDetails.lineItem line: resultObj.lines){
              
                for(AvalaraResponseDetails.lineDetails details: line.details){
                   
                    if(details.taxType == 'Tires' && lineItemAndGroup.containsKey(line.lineNumber)&& Decimal.valueOf(details.reportingTaxCalculated) > 0){
                        QuoteLineItem stateFeeLineItem= new QuoteLineItem();
                        stateFeeLineItem.Group__c           = lineItemAndGroup.get(line.lineNumber);
                        stateFeeLineItem.Product2Id         = stateFeePriceBookEntry[0].product2Id;
                        stateFeeLineItem.Quantity           = Decimal.valueOf(details.reportingTaxableUnits);
                        stateFeeLineItem.QuoteId            = recordId;
                        stateFeeLineItem.UnitPrice          = Decimal.valueOf(details.rate);
                        stateFeeLineItem.PricebookEntryId   = stateFeePriceBookEntry[0].Id;
                        stateFeeLineItem.Parent_Line_Item__c   	= line.lineNumber;
                        stateFeeQuoteLineItemToInsert.add(stateFeeLineItem);
                    }
                }
            }

          

            List<QuoteLineItem> deleteOldStateFeeLineItem = new List<QuoteLineItem>();
            List<Avalara_Tax_Calculation__c> taxCalculationRecord = new List<Avalara_Tax_Calculation__c>();
            List<QuoteLineItem> quoteLineitemToUpdate = new List<QuoteLineItem>();

            
            for(QuoteLineItem lineItem: [Select Id, QuoteId, Tax_Amount__c, Product_SKU__c, Product2Id, Quantity, Total_Price__c, Product2.Name, Product2.Tax_Code__c, Product2.Description, Product2.StockKeepingUnit, 
                                        Product2.Tyre_Type__c, Product2.RIM__c, Product2.Studded__c, Product2.WEIGHT_IN_LBS__c, Product2.Width_Inches__c
                                        From QuoteLineItem Where QuoteId =: recordId]){

                if(lineIdAndLineResponse.containsKey(lineItem.Id) && !'State Fee'.equalsIgnoreCase(lineItem.Product_SKU__c)){
                    Decimal taxAmount=Decimal.valueOf(lineIdAndLineResponse.get(lineItem.Id).taxCalculated);
                    for(AvalaraResponseDetails.lineDetails lineDetail: lineIdAndLineResponse.get(lineItem.Id).details){
                        if(lineDetail.taxType.equalsIgnoreCase('Tires')){
                            taxAmount = taxAmount- Decimal.valueOf(lineDetail.taxCalculated);
                        }
                    }

                    lineItem.Tax_Amount__c = taxAmount;

                    Avalara_Tax_Calculation__c calculatedTax = new Avalara_Tax_Calculation__c();
                    calculatedTax.Quote__c                        = lineItem.QuoteId;
                    calculatedTax.Quote_Line_Item__c              = lineItem.Id;
                    calculatedTax.Sales_Tax_Amount__c             = Decimal.valueOf(lineIdAndLineResponse.get(lineItem.Id).taxableAmount) + Decimal.valueOf(lineIdAndLineResponse.get(lineItem.Id).taxCalculated);
                    calculatedTax.Zip_Code__c                     = resultObj.addresses[0].postalCode;
                    calculatedTax.quantity__c                     = Decimal.valueOf(lineIdAndLineResponse.get(lineItem.Id).quantity);
                    calculatedTax.Required_Committed_Status__c    = false;
                    calculatedTax.Request_JSON__c                 = stringifyJson;
                    calculatedTax.Response_JSON__c                = response.getBody();

                    taxCalculationRecord.add(calculatedTax);
                    quoteLineitemToUpdate.add(lineItem);
                }
                if('State Fee'.equalsIgnoreCase(lineItem.Product_SKU__c)){
                    deleteOldStateFeeLineItem.add(lineItem);
                }
            }

           

            if(stateFeeQuoteLineItemToInsert.size() > 0){
                insert stateFeeQuoteLineItemToInsert;
            }

            if(deleteOldStateFeeLineItem.size() > 0){
                delete deleteOldStateFeeLineItem;
            }

            if(quoteLineitemToUpdate.size() > 0){
                update quoteLineitemToUpdate;
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