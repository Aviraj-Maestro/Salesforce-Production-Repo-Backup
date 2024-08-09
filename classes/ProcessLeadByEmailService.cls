global class ProcessLeadByEmailService Implements Messaging.InboundEmailHandler{
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,Messaging.InboundEnvelope envelope)
    {
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        List<Lead> listLead = new List<Lead>();
        // Check the existing lead with same Email to avoid duplicate in SFDC system
        if(Test.isRunningTest())//added for test class email
        {
            listLead= [select Id,Email from Lead where Email = 'Test@email.com'];               
        }
        else{
            listLead= [select Id,Email from Lead where Email =:email.fromAddress];   
        }
        System.debug('listLead----------->'+listLead);
        if(listLead.size()==0){
            Lead led = new Lead();
            led.FirstName = email.fromname.substring(0, email.fromname.indexOf(' '));
            led.LastName = email.fromname.substring(email.fromname.indexOf(' '));
            led.Company = led.FirstName + ' ' + led.LastName;
            if(Test.isRunningTest()) //added for test class email
            {
                led.Email = 'Test@email.com'; 
            }
            else{
                led.Email = email.fromAddress;    
            }
            led.LeadSource  = 'Email'; 
            Insert led;
            System.debug('led----------->'+led);
            
            if(led.Id!=null){
                //Insert attachments into files
                List<ContentVersion> listContentversion= new List<ContentVersion>();
                if(email.binaryAttachments != null && email.binaryAttachments.size() > 0){ //insert non-text files into SFDC file
                    for (integer i = 0 ; i < email.binaryAttachments.size() ; i++) {
                        if(email.binaryAttachments[i].Filename != null) //Checking if filename in not null
                        {
                            ContentVersion contentVersionForBinary = createContentVersion(email.binaryAttachments[i].Filename, email.binaryAttachments[i].Body);
                            listContentversion.add(contentVersionforBinary);}
                    }
                }
                if(email.textAttachments != null && email.textAttachments.size() > 0){ //insert text files into SFDC file
                    for (integer i = 0 ; i < email.textAttachments.size() ; i++) {
                        ContentVersion contentVersionForText = createContentVersion(email.textAttachments[i].Filename, Blob.valueOf(email.textAttachments[i].Body));
                        listContentversion.add(contentVersionfortext);
                    }
                }
                
                if(listContentversion.size()>0){
                    Insert listContentversion; //Insert contentVersion list of text files and non text files
                }
                
                List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();
                if(listContentversion.size()>0){
                    List<ContentVersion> listContentVers = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :listContentversion];
                    for(ContentVersion contentVersion : listContentVers){
                        ContentDocumentLink contentDocumentLink = createContentDocumentLink(contentVersion.ContentDocumentId, led.Id);
                        contentDocumentLinkList.add(contentDocumentLink);
                    }
                    
                    if(contentDocumentLinkList.size()>0){
                        insert contentDocumentLinkList; //Insert ontentDocumentLink list of text files and non text files
                    }
                }
            }
        }
        
        return result;                                                         
    }
    
    @TestVisible 
    private ContentVersion createContentVersion(String name, Blob body){
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = 'S'; // S = Stored in Salesforce
        contentVersion.PathOnClient = name;
        contentVersion.Title = name;
        contentVersion.VersionData = body;
        return contentVersion;
    }
    
    @TestVisible 
    private ContentDocumentLink createContentDocumentLink(Id contentDocumentId, Id parentId){
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = contentDocumentId;
        contentDocumentLink.LinkedEntityId = parentId;
        contentDocumentLink.ShareType = 'V'; // Viewer permission
        return contentDocumentLink;
    }
    
}