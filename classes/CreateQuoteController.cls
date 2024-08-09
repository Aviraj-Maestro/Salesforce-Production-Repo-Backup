public class CreateQuoteController {
    @AuraEnabled
    public static List<String> getProductFamily(String recordId){
        Set<String> prodFamily = new Set<String>();
        List<String> prodFamilyList = new List<String>();
        for(OpportunityLineItem oppLineItem : [SELECT Id, OpportunityId, Product2.Name, Name, TotalPrice, UnitPrice, ListPrice, Quantity FROM OpportunityLineItem Where OpportunityId =: recordId AND (e_Product_Family__c =: 'Sales Product' OR e_Product_Family__c =: 'FET')]){
            String familyName = oppLineItem.Product2.Name;
            if(familyName.containsIgnoreCase('FET-')){
                familyName = familyName.removeStart('FET-');
            }
            if(familyName.contains(' ')){
                familyName = familyName.split(' ')[0];
            }           
            prodFamily.add(familyName);
        }
        prodFamilyList.addAll(prodFamily);
        return prodFamilyList;
    }
    
    @AuraEnabled
    public static Result processSelectedProductFamily(String recordId, List<String> selectedProductFamilyRecords){
        Result res = new Result();
        try{
            List<OpportunityLineItem> oppLine = [SELECT Id, Description, Product2Id, PricebookEntryId, Group__c, OpportunityId, Product2.Name, Name, TotalPrice, UnitPrice, ListPrice, Quantity FROM OpportunityLineItem Where OpportunityId =: recordId AND (ProductCode = 'State Fee' OR (Product2.Name Like: selectedProductFamilyRecords AND (e_Product_Family__c =: 'Sales Product' OR e_Product_Family__c =: 'FET')))];
            if(oppLine.size()>0){
                List<QuoteLineItem> quoteLineItemList = new List<QuoteLineItem>();
                recordType rd = [SELECT Id, DeveloperName from recordType where sObjectType = 'Quote' and DeveloperName = 'B2B_Container'];
                Opportunity opp = [Select Id, Name, createdDate from Opportunity Where Id =: recordId];

                Date createdDate = date.newinstance(opp.createdDate.year(), opp.createdDate.month(), opp.createdDate.day());
                Quote q = new Quote();
                q.Name = (opp.Name + ' '+ System.today()).remove(' 00:00:00');
                q.OpportunityId = opp.ID;
                q.Quote_Date__c = createdDate;
                q.Quote_Type__c = '';
                q.RecordTypeId = rd.Id;
                
                insert q;
                
                System.debug(recordId);      
                System.debug(selectedProductFamilyRecords);      
                for(OpportunityLineItem oppLineItem : oppLine){
                    QuoteLineItem qlitem = new QuoteLineItem();
                    qlitem.QuoteId = q.Id;
                    qlitem.Quantity = oppLineItem.Quantity;
                    qlitem.UnitPrice = oppLineItem.UnitPrice;
                    qlitem.Description = oppLineItem.Description;
                    qlitem.PricebookEntryId = oppLineItem.PricebookEntryId;
                    qlitem.Product2Id = oppLineItem.Product2Id;
                    qlitem.Group__c = oppLineItem.Group__c;
             
                    
                    quoteLineItemList.add(qlitem);
                }
                if(quoteLineItemList.size() > 0){
                    insert quoteLineItemList;
                }
                
                res.isSuccess  = true;
                res.message = '';
            } else{
                res.isSuccess  = false;
                res.message = 'No Opportunity Product in Sales Product Family';
            }
        }catch(Exception ex){
            res.isSuccess  = false;
            res.message = ex.getMessage();
        } 
        return res;
    } 
    
    public class Result{
        @AuraEnabled
        public Boolean isSuccess;
        
        @AuraEnabled
        public String message;
    }
    
}