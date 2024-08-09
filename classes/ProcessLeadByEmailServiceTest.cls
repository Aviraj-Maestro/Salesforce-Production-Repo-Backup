@istest
private class ProcessLeadByEmailServiceTest {
    static testMethod void testLeadEmailService() {  
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'Test';
        email.fromname = 'Test Test';
        env.fromAddress = 'Test@email.com';
        email.plainTextBody = 'Test';
        
        Messaging.InboundEmail.BinaryAttachment[] bAttachments = new List<Messaging.InboundEmail.BinaryAttachment> {
            new Messaging.InboundEmail.BinaryAttachment(),
                new Messaging.InboundEmail.BinaryAttachment()
                };
                    
        bAttachments[0].body = Blob.valueOf('columnHeader1,columnHeader2\nval11,val12\n,...'); 
        bAttachments[0].filename = 'attach1.csv';  
        bAttachments[0].mimeTypeSubType = 'text/csv';
        
        email.BinaryAttachments = bAttachments;
        Lead led = new Lead();
        led.FirstName = email.fromname.substring(0, email.fromname.indexOf(' '));
        led.LastName = email.fromname.substring(email.fromname.indexOf(' '));
        led.Company = led.FirstName + ' ' + led.LastName;
        led.Email = email.fromAddress; 
        led.LeadSource  = 'Email'; 
        led.Phone='9876543218';
        Insert led;
        
        ProcessLeadByEmailService emailProcess = new ProcessLeadByEmailService();
        List<ContentVersion> listContentversion= new List<ContentVersion>();
        emailProcess.handleInboundEmail(email, env);
        ContentVersion contentVersionForText=emailProcess.createContentVersion(email.binaryAttachments[0].Filename, email.binaryAttachments[0].Body);
        listContentversion.add(contentVersionForText);
        insert listContentversion;
        emailProcess.createContentDocumentLink(listContentversion[0].ContentDocumentId, led.Id);
    }  
    
}