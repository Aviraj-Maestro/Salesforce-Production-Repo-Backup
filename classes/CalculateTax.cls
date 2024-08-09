/*
 * Test Class: CalculateTaxTest
 */
public with sharing class CalculateTax {
    @AuraEnabled
    public static ResponseWrapper calculateTax(String recordId, String objectApiName){
        ResponseWrapper returnResult = new ResponseWrapper();
        //Boolean returnResult = false;
        System.debug('Apex Called ======>');
        System.debug(objectApiName);
        if('Quote'.equalsIgnoreCase(objectApiName)){
            returnResult = CalculateTaxQuote.calculateTax(recordId);
        }else if('Opportunity'.equalsIgnoreCase(objectApiName)){
            returnResult = CalculateTaxOpportunity.calculateTax(recordId);
        }else if('AcctSeedERP__Sales_Order__c'.equalsIgnoreCase(objectApiName)){
            returnResult = CalculateTaxSalesOrder.calculateTax(recordId);
        }else if('AcctSeed__Billing__c'.equalsIgnoreCase(objectApiName)){
           returnResult = CalculateTaxBilling.calculateTax(recordId);
        }

        return returnResult;
    }
    
    public class ResponseWrapper{
        @AuraEnabled public string title {get;set;}
        @AuraEnabled public string variant {get;set;}
        @AuraEnabled public string message {get;set;}
    }
}