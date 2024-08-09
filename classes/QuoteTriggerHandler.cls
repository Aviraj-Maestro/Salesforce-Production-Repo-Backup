public with sharing class QuoteTriggerHandler implements ITriggerHandler {
    public Boolean IsDisabled(){		
        return false;
       
     }
  
     public void BeforeInsert(List<Sobject> newItems){

       
     
    }
     public void BeforeDelete(Map<id, sObject> oldItems){
     
     }
    
     public void AfterInsert(List<Sobject> newMap){      
        Map<Id,Quote> mapQuote= new Map<Id,Quote>();
        Map<Id,OpportunityLineItem>  MapToThrowError= new Map<Id,OpportunityLineItem>();
        Map<String,OpportunityLineItem> mapOppLineItemAndSKU= new Map<String,OpportunityLineItem>();
        List<QuoteLineItem> lstQuoteLineItemToCreate= new List<QuoteLineItem>();
        Map<String,Id> mapSkuAndProductMap =new Map<String,Id>();
        Map<String,Id> mapSkuAndOpportunity =new Map<String,Id>();
        Set<Id> PricebookId = new Set<Id>();
        List<Id> quoteId= new List<Id>();
        Decimal Quantity;
        Boolean HideFromPDF=false;
        for(Quote qte : ((List<Quote>)newMap)){   
            mapQuote.put(qte.OpportunityId,qte);
            PricebookId.add(qte.Pricebook2Id);
            quoteId.add(qte.Id);
         
        }
        if(mapQuote.Size()>0){
       
            for(opportunity opp : [select Id,RecordTypeId, RecordType.Name,(select id,Name,Product2Id,Product2.name,Product2.StockKeepingUnit,Quantity,UnitPrice,TotalPrice,Group__c,AcctSeed__Tax_Amount__c,PricebookEntryId,Description from OpportunityLineItems) from Opportunity where id =:mapQuote.KeySet()]){
                if(opp.RecordType.Name != 'B2B Container'){
                    for(OpportunityLineItem OppLineitem : opp.OpportunityLineItems){
                        if(OppLineitem.Product2.StockKeepingUnit != null){
                        if(!OppLineitem.Product2.StockKeepingUnit.contains('- FET') &&  !OppLineitem.Product2.StockKeepingUnit.contains('State Fee')){
                            // if(OppLineitem.Product2.StockKeepingUnit.contains('-') ){
                            //    //  mapOppLineItemAndSKU.put(OppLineitem.Product2.StockKeepingUnit.SubString(0,OppLineitem.Product2.StockKeepingUnit.lastIndexOf('-')).trim(),OppLineitem);
                            //    // mapSkuAndOpportunity.put(OppLineitem.Product2.StockKeepingUnit.SubString(0,OppLineitem.Product2.StockKeepingUnit.lastIndexOf('-')).trim(),Opp.Id);
                            // }
                            // else{
                                mapOppLineItemAndSKU.put(OppLineitem.Product2.StockKeepingUnit,OppLineitem);
                                mapSkuAndOpportunity.put(OppLineitem.Product2.StockKeepingUnit,Opp.Id);
                            //}
                        }else{
                            if(mapQuote.get(Opp.Id).Quote_Type__c != 'Without FET' || !OppLineitem.Product2.StockKeepingUnit.contains('State Fee')){
                                lstQuoteLineItemToCreate.add(new QuoteLineItem(
                                    QuoteId=mapQuote.get(Opp.Id).Id,
                                    Quantity=OppLineitem.Quantity,
                                    UnitPrice=OppLineitem.UnitPrice,
                                    Description=OppLineitem.Description,
                                    Tax_Amount__c=OppLineitem.AcctSeed__Tax_Amount__c,
                                    PricebookEntryId=OppLineitem.PricebookEntryId,
                                    Group__c=OppLineitem.Group__c
                                ));
                            }
                        }
                      }
                      else{
                        if(OppLineitem.Product2.Name.contains('Misc. Charges') || OppLineitem.Product2.Name.contains('Lift Gate Charges') || OppLineitem.Product2.Name.contains('Freight charges')  || OppLineitem.Product2.Name.contains('Lug')){
    
                                lstQuoteLineItemToCreate.add(new QuoteLineItem(
                                    QuoteId=mapQuote.get(Opp.Id).Id,
                                    Quantity=OppLineitem.Quantity,
                                    UnitPrice=OppLineitem.UnitPrice,
                                    Description=OppLineitem.Description,
                                    Tax_Amount__c=OppLineitem.AcctSeed__Tax_Amount__c,
                                    PricebookEntryId=OppLineitem.PricebookEntryId,
                                    Hide_from_PDF__c=true
                                ));
                            }
                        }
                    }
                }
            }
           for(PricebookEntry priceEntry:[select Id,Product2.StockKeepingUnit from  PricebookEntry where Product2.StockKeepingUnit=:mapOppLineItemAndSKU.KeySet() and Pricebook2Id=:PricebookId]){
                mapSkuAndProductMap.put(priceEntry.Product2.StockKeepingUnit,priceEntry.Id);
           }
        System.debug('mapSkuAndProductMap >>>'+mapSkuAndProductMap);
        for(String prodSku : mapOppLineItemAndSKU.keyset()){
            if(mapOppLineItemAndSKU.get(prodSku).Name.contains('Set of 2')){
                Quantity=mapOppLineItemAndSKU.get(prodSku).Quantity*2;
            }
            else if(mapOppLineItemAndSKU.get(prodSku).Name.contains('Set of 4')){
                Quantity=mapOppLineItemAndSKU.get(prodSku).Quantity*4;
            }
            else if(mapOppLineItemAndSKU.get(prodSku).Name.contains('Set of 6')){
                Quantity=mapOppLineItemAndSKU.get(prodSku).Quantity*6;
            }
            else if(mapOppLineItemAndSKU.get(prodSku).Name.contains('Set of 8')){
                Quantity=mapOppLineItemAndSKU.get(prodSku).Quantity*8;
            }
            else{
                Quantity=mapOppLineItemAndSKU.get(prodSku).Quantity;
            }
            if(mapOppLineItemAndSKU.get(prodSku).Name.contains('Misc. Charges') || mapOppLineItemAndSKU.get(prodSku).Name.contains('Lift Gate Charges') || mapOppLineItemAndSKU.get(prodSku).Name.contains('Freight charges')){
                HideFromPDF=true;
            }else{
                HideFromPDF=false;
            }
          
            if(mapSkuAndProductMap.get(prodSku) !=null){
                    lstQuoteLineItemToCreate.add(new QuoteLineItem(
                        QuoteId= mapQuote.get(mapSkuAndOpportunity.get(prodSku)).Id ,
                        Quantity=mapOppLineItemAndSKU.get(prodSku).Quantity,
                        Hide_from_PDF__c=HideFromPDF,
                        UnitPrice=mapOppLineItemAndSKU.get(prodSku).UnitPrice,
                        Description=mapOppLineItemAndSKU.get(prodSku).Description,
                        PricebookEntryId=mapSkuAndProductMap.get(prodSku),
                        Tax_Amount__c=mapOppLineItemAndSKU.get(prodSku).AcctSeed__Tax_Amount__c,
                        Group__c= prodSku.contains('-') ? prodSku.SubString(0,prodSku.lastIndexOf('-')).trim() : prodSku
                ));
            }
              
        }
        if(lstQuoteLineItemToCreate.Size()>0){
            insert lstQuoteLineItemToCreate;
        }
    }
        Decimal StateFeeAmount=0;
        Decimal FETTotalAmount=0;
        Decimal MasterTotalAmount=0;
        Quote qteToUpdate= new Quote();
        for(QuoteLineItem qteLineItem:[select Id,TotalPrice,ProductName__c from QuoteLineItem where QuoteId=:quoteId]){

            if(qteLineItem.ProductName__c.contains('State Fee')){
                StateFeeAmount =StateFeeAmount + qteLineItem.TotalPrice;

            }
            else if(qteLineItem.ProductName__c.contains('FET')){
                FETTotalAmount =FETTotalAmount + qteLineItem.TotalPrice;
            }
            else if(qteLineItem.ProductName__c.contains('Misc. Charges')){
                qteToUpdate.Other_Charges__c=qteLineItem.TotalPrice;
            }
            else if(qteLineItem.ProductName__c.contains('Lift Gate Charges')){
                qteToUpdate.Lift_Gate_Charges__c=qteLineItem.TotalPrice;
            }
            else if(qteLineItem.ProductName__c.contains('Freight charges')){
                qteToUpdate.Freight_charges__c=qteLineItem.TotalPrice;
            }
            else{
                MasterTotalAmount =MasterTotalAmount + qteLineItem.TotalPrice;
            }
        }
     
        qteToUpdate.Id=quoteId[0];
        qteToUpdate.Total_Product_Amount__c=MasterTotalAmount;
        qteToUpdate.Total_FET_Amount__c=FETTotalAmount;
        qteToUpdate.Total_State_Fee__c=StateFeeAmount;
        update qteToUpdate;


       
     }
 
     public void AfterUpdate(Map<Id, sObject> newMap, Map<Id, sObject> oldMap){    
      
     }
    
     
}