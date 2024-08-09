public with sharing class MaestroBillingController {
    public String BillingId {get; set;}
    public Map<String,List<AcctSeed__Billing_Line__c>> BillingLines{get; set;}
    public AcctSeed__Billing__c billing{get;set;}
    public Map<String,Decimal> GroupProductSummary{get; set;}
    public List<AcctSeed__Billing_Line__c> ShippingAndHandling{get; set;}
    public Decimal SalesTax{get;set;}
    public Decimal TotalTires{get;set;}
    public Decimal ProductTotal{get;set;}
    public Decimal FETTotal{get;set;}
    public Decimal StateFee{get;set;}
    public Decimal InvoiceTotal{get;set;}
    public Decimal TaxableValue{get;set;}
    public OpportunityContactRole primaryContact{get;set;}
    public OpportunityContactRole receivingContact{get;set;}


    public MaestroBillingController() {
        BillingId=ApexPages.currentPage().getParameters().get('Id'); 
        billing= [select id,
                                Name,
                                AcctSeed__Billing_Format__r.AcctSeed__Image__c,
                                AcctSeed__Billing_Format__r.AcctSeed__Company_Name__c,
                                AcctSeed__Billing_Format__r.AcctSeed__Company_Street2__c,
                                AcctSeed__Billing_Format__r.AcctSeed__Company_City__c,
                                AcctSeed__Billing_Format__r.AcctSeed__Company_Country__c,
                                AcctSeed__Billing_Format__r.AcctSeed__Company_State__c,
                                AcctSeed__Billing_Format__r.AcctSeed__Company_PostalCode__c,
                                AcctSeed__Billing_Contact__c,
                                AcctSeed__Customer__r.AcctSeed__Billing_Contact__c,
                                AcctSeed__Customer__r.Name,
                                AcctSeed__Billing_Street__c,
                                AcctSeed__Billing_State__c,
                                AcctSeed__Billing_PostalCode__c,
                                AcctSeed__Billing_Country__c,
                                AcctSeed__Shipping_Contact__c,
                                AcctSeed__Shipping_Street__c,
                                AcctSeed__Shipping_City__c,
                                AcctSeed__Shipping_PostalCode__c,
                                AcctSeed__Shipping_Country__c,
                                AcctSeed__Shipping_State__c,
                                AcctSeed__Billing_City__c,
                                AcctSeed__Customer__r.AcctSeed__Alternate_Payee_Name__c,
                                AcctSeed__Billing_Contact__r.Name,
                                AcctSeed__Customer__r.BillingStreet,
                                AcctSeed__Customer__r.BillingCity,
                                AcctSeed__Customer__r.BillingState,
                                AcctSeed__Customer__r.BillingPostalCode,
                                AcctSeed__Customer__r.BillingCountry,
                                AcctSeed__Shipping_Contact__r.Name,
                                AcctSeed__Customer__r.AcctSeed__Shipping_Contact__r.Name,
                                AcctSeed__Customer__r.ShippingStreet,
                                AcctSeed__Customer__r.ShippingCity,
                                AcctSeed__Customer__r.ShippingState,
                                AcctSeed__Customer__r.ShippingPostalCode,
                                AcctSeed__Customer__r.ShippingCountry,
                                AcctSeed__Type__c,
                                AcctSeed__Opportunity__c,
                                AcctSeed__Proprietary_Billing_Number__c,
                                AcctSeed__PO_Number__c,
                                AcctSeed__Date__c,
                                AcctSeed__Due_Date2__c,
                                AcctSeed__Billing_Terms_Name__c,
                                AcctSeed__Balance__c,
                                AcctSeed__Billing_Comment__c,
                                AcctSeedERP__Sales_Order__c,
                                AcctSeed__Sales_Tax2__c,
                                AcctSeed__Sales_Tax3__c,
                                AcctSeedERP__Sales_Order__r.Name,
                                AcctSeed__Customer__r.Customer_Number__c,
                                AcctSeed__Total__c,
                                AcctSeed__Sub_Total__c,
                                AcctSeed__Billing_Format__r.AcctSeed__Custom_Footer_Content__c,
                                AcctSeed__Billing_Format__r.Bank_Information__c,
                                Billing_Number1__c,
                                Delivery_Type__c,
                                Ship_From_Address__r.Street__c, Ship_From_Address__r.City__c, Ship_From_Address__r.State__c,
                                Ship_From_Address__r.Country__c, Ship_From_Address__r.Zip_Code__c, Ship_From_Address__r.Avalara_Location_Code__c,
                                Warehouse_Location__r.Street__c, Warehouse_Location__r.City__c,Warehouse_Location__r.State__c,
                                Warehouse_Location__r.Country__c, Warehouse_Location__r.Zip_Code__c,
                                Ship_to_Address__r.Shipping_City__c, Ship_to_Address__r.Shipping_Country__c, Ship_to_Address__r.Shipping_State_Province__c, 
                                Ship_to_Address__r.Shipping_Street__c, Ship_to_Address__r.Shipping_Zip_Postal_Code__c,

                                Bill_to_Adddress__r.Billing_Street__c, Bill_to_Adddress__r.Billing_City__c, Bill_to_Adddress__r.Billing_State_Province__c,
                                Bill_to_Adddress__r.Billing_Country__c, Bill_to_Adddress__r.Billing_Zip_Postal_Code__c
                                from AcctSeed__Billing__c where Id =:BillingId ];
                this.InvoiceTotal = billing.AcctSeed__Sales_Tax3__c + billing.AcctSeed__Sub_Total__c;
            List<AcctSeed__Billing_Line__c> billingLines= [select id, Group__c, AcctSeed__Product__r.name,AcctSeed__Product__r.StockKeepingUnit,AcctSeed__Total__c,AcctSeed__Sub_Total__c,AcctSeed__Tax_Rate__c,AcctSeed__Hours_Units__c,AcctSeed__Rate__c,AcctSeed__Product__r.Tax_Code__c,AcctSeed__Product__r.Family  from AcctSeed__Billing_Line__c where AcctSeed__Billing__c =:BillingId ];
            this.StateFee=0;
            this.TaxableValue=0;
            List<OpportunityContactRole> oppConroles= [SELECT IsPrimary,Role,Contact.Name,Contact.Phone,contact.Email FROM OpportunityContactRole where OpportunityId=:billing.AcctSeed__Opportunity__c];

             for(OpportunityContactRole opp:oppConroles){
    
                    if(opp.IsPrimary){
                        primaryContact = opp;
                    }
                    if(opp.Role != null && opp.Role.containsIgnoreCase('Receiving Contact')){
                        receivingContact=opp;
                    }
            }



            Map<String, List<AcctSeed__Billing_Line__c>> returnMap = new Map<String, List<AcctSeed__Billing_Line__c>>();
            List<AcctSeed__Billing_Line__c> extraBillingLinesToAdd= new List<AcctSeed__Billing_Line__c>();
                for ( AcctSeed__Billing_Line__c billingLine : billingLines )
                {        
                    if(billingLine.AcctSeed__Product__r.name.contains('State Fee')){
                        this.StateFee=this.StateFee+billingLine.AcctSeed__Sub_Total__c;
                       // lstOrder.add(new SortClassWrapper(new SortClass(billingLine,3)));
                    }
                    String key = (String)billingLine.Group__c; 
                    if(billingLine.AcctSeed__Product__r.name.equalsIgnoreCase('Lugs'))    {
                      extraBillingLinesToAdd.add(billingLine);
                    }       
                    if(billingLine.AcctSeed__Product__r.Tax_Code__c == 'PA3000301' || (String.IsNotBlank( billingLine.AcctSeed__Product__r.Family) && billingLine.AcctSeed__Product__r.Family.containsIgnoreCase('FET')))
                    {
                        this.TaxableValue=this.TaxableValue+billingLine.AcctSeed__Sub_Total__c;
                        if (!returnMap.containsKey( key ))
                            returnMap.put( key, new List<AcctSeed__Billing_Line__c> ());
                            returnMap.get( key ).add( billingLine );
                    }
                }


            Map<String, List<SortClassWrapper>> newMap = new Map<String, List<SortClassWrapper>>();
                this.TotalTires=0;
                this.ProductTotal=0;
                this.FETTotal=0;
              
        for(String skugroup : returnMap.keySet()){
        List<SortClassWrapper> lstOrder= new List<SortClassWrapper>();
            for(AcctSeed__Billing_Line__c billingLine : returnMap.get(skugroup)){
             
                if(billingLine.AcctSeed__Product__r.Family.containsIgnoreCase('FET')){
                    this.FETTotal=this.FETTotal+billingLine.AcctSeed__Sub_Total__c;
                    lstOrder.add(new SortClassWrapper(new SortClass(billingLine,2)));
                }
                else if(billingLine.AcctSeed__Product__r.Tax_Code__c == 'PA3000301'){
                    this.SalesTax=billingLine.AcctSeed__Tax_Rate__c;
                    this.ProductTotal=this.ProductTotal+billingLine.AcctSeed__Sub_Total__c;
                    this.TotalTires=this.TotalTires+billingLine.AcctSeed__Hours_Units__c;
                    lstOrder.add(new SortClassWrapper(new SortClass(billingLine,1)));
                }
                lstOrder.sort();
                newMap.put(skugroup,lstOrder);
            }
        }

        this.ShippingAndHandling = new List<AcctSeed__Billing_Line__c>();
       
        for(AcctSeed__Billing_Line__c billingLine : billingLines){
            if(billingLine.AcctSeed__Product__r.name.contains('Misc. Charges') || billingLine.AcctSeed__Product__r.name.contains('Freight charges') || billingLine.AcctSeed__Product__r.name.contains('Lift Gate Charges') ){
                this.ShippingAndHandling.add(billingLine);
            }
        }
      

       Decimal GroupTotal=0;
      
       this.BillingLines= new Map<String,List<AcctSeed__Billing_Line__c>> ();
       this.GroupProductSummary=new Map<String,Decimal>();
       List<AcctSeed__Billing_Line__c> lstBillingLines;
        for(String skugroup : newMap.keySet()){
            GroupTotal=0;
            lstBillingLines= new List<AcctSeed__Billing_Line__c>();
            for(SortClassWrapper billingLine : newMap.get(skugroup)){
                lstBillingLines.add(billingLine.oppy.ProductName);
                GroupTotal=billingLine.oppy.ProductName.AcctSeed__Sub_Total__c+GroupTotal;
            }
            if(skugroup != null){
            this.BillingLines.put(skugroup,lstBillingLines);
            this.GroupProductSummary.put(skugroup,GroupTotal);
            }
            
        } 
        if(!extraBillingLinesToAdd.IsEmpty()){
            this.BillingLines.put('Lugs',extraBillingLinesToAdd);
            this.GroupProductSummary.put('Lugs',extraBillingLinesToAdd[0].AcctSeed__Sub_Total__c);
        }
    }
 
    class SortClass{
         AcctSeed__Billing_Line__c ProductName{get;set;}
         Integer Position{get;set;}
        public SortClass(AcctSeed__Billing_Line__c ProductName,Integer Position){
            this.ProductName=ProductName;
            this.Position=Position;
        }
    }
 

public  class SortClassWrapper implements Comparable {

    public SortClass oppy;
    public Integer sortField;
  
    public SortClassWrapper(SortClass op) {
        oppy = op;
    }

   
    public Integer compareTo(Object compareTo) {
       
        SortClassWrapper compareToOppy = (SortClassWrapper)compareTo;
        Integer returnValue = 0;
        if (oppy.Position > compareToOppy.oppy.Position) {
            returnValue = 1;
        } else if (oppy.Position < compareToOppy.oppy.Position) {
            returnValue = -1;
        }
     return returnValue;       
    }
}

}