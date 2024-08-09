@isTest 
public class QuotePDFExtensionTest 
{
    static testMethod void testEx1() 
    {
        Account testAccount = new Account();
        testAccount.Name='Test Account' ;
        insert testAccount;
        
        /*Contact cont = new Contact ();
        cont.FirstName = 'FirstName';
        cont.LastName = 'LastName';
        cont.Email='email@email.com';
        cont.phone='12345678';
        insert cont;*/
        
        Account acct = new Account(Name='TEST_ACCT');
        insert acct;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acct.id;
        opp.Name = 'Test Opp';
        opp.StageName = 'Prospecting';
        opp.CloseDate = Date.today();
        insert opp;
        
        Quote qt = new Quote();
        qt.Name = 'Test Quote';
        qt.OpportunityId = opp.id;
        qt.Pickup_Fitment_Address__c = 'Pickup Location - Delhi';
        insert qt;
        
        /*ContentVersion contentVersion = new ContentVersion(
            Title = 'Tyres',
            PathOnClient = 'Tyres.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = acct.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;*/
        
        System.Test.StartTest(); 
        PageReference pageRef = Page.QuotePDF; 
        pageRef.getParameters().put('Id', String.valueOf(acct.Id));
        System.Test.setCurrentPage(pageRef);
        QuotePDFExtension cls = new QuotePDFExtension();
        cls.savePDF();
        
        
        
        PageReference pageRef2 = Page.QuotePDF;
        pageRef2.getParameters().put('id', String.valueOf(qt.Id));
        System.Test.setCurrentPage(pageRef2);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(qt);
        QuotePDFExtension cls2 = new QuotePDFExtension(sc);
        System.Test.StopTest();
    }
    
    
}