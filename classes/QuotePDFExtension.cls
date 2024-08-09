public class QuotePDFExtension {

    
    public static String recordId{get;set;}
    public static String pickupAddress{get;set;}
    public static Quote qt{get;set;}
    
    
    public QuotePDFExtension(ApexPages.StandardController stdController){
        recordId = System.currentPageReference().getParameters().get('id');
        if(System.currentPageReference().getParameters().get('id') != null){
            qt = [SELECT ID, Pickup_Fitment_Address__c from Quote where Id = :System.currentPageReference().getParameters().get('id')];
            if(qt.Pickup_Fitment_Address__c != null){
                Pickup_Fitment_Address__mdt pickupMetadata = [SELECT Id, Pickup_Fitment_Address_Label__c, Pickup_Fitment_Address__c FROM Pickup_Fitment_Address__mdt  where Pickup_Fitment_Address_Label__c = :qt.Pickup_Fitment_Address__c];
                pickupAddress = pickupMetadata.Pickup_Fitment_Address__c;
            }
        }
        
        
    }
    
    public QuotePDFExtension(){
        recordId = System.currentPageReference().getParameters().get('id');        
    }
    
    /*public List<QuoteLineItem> getQuoteLineItemsList(){
        
    }*/
    
    public PageReference savePDF(){
        PageReference PDf = Page.QuotePDF;
        if(pdf!= null){
            System.debug('recordId here :::' + recordId);
            System.debug('recordId here2 :::' + System.currentPageReference().getParameters().get('id'));
            PDf.getParameters().put('Id',System.currentPageReference().getParameters().get('id'));
           
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; 
            conVer.PathOnClient = 'Quote.pdf'; 
            conVer.Title = 'Quote PDF '+String.valueOf(Date.today()); 
            if(!Test.isRunningTest()){
                conVer.VersionData = PDf.getContent(); 
            }else{
                conVer.VersionData = Blob.valueOf('Test is Running');
            }
            
            insert conVer;
            
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
            System.debug('recordId :::' + recordId);
            ContentDocumentLink conDocLink = New ContentDocumentLink();
            conDocLink.LinkedEntityId = System.currentPageReference().getParameters().get('id'); 
            conDocLink.ContentDocumentId = conDoc;  
            conDocLink.shareType = 'V';
            insert conDocLink;
            PageReference pageRef = new PageReference('https://maestrotradex.lightning.force.com/lightning/r/Quote/' + System.currentPageReference().getParameters().get('id')+'/related/AttachedContentDocuments/view');
        	pageRef.setRedirect(true);
            return pageRef;
        	
        }
        else{return null;}
        
        
    }
    

}