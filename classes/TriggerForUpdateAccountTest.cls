@isTest 
public class TriggerForUpdateAccountTest {


    static testMethod void testEx1() 
    {
        Account testAccount = new Account();
        testAccount.Name='Test Account' ;
        insert testAccount;
        ContentVersion contentVersion = new ContentVersion(
                    Title          = 'Reseller Certificate',
                    PathOnClient   = 'Pic.jpg',
                    VersionData    = Blob.valueOf('Test Content'),
                    IsMajorVersion = true);
            insert contentVersion;

            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];


            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = testAccount.Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
        delete documents[0];
    }
}