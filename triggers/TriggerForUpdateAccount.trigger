trigger TriggerForUpdateAccount on ContentDocument (before delete) {
 list<contentDocument> contnt = trigger.old;
    list<account> parent = new list<account>();
list<id> parentList = new list<id>();
    list<id> link = new list<id>();
    map<id,id> acclmap = new map<id,id>();
     for(contentDocument con : contnt)
    {
        link.add(con.id);
    }
    list<ContentDocumentLink> link2 = [SELECT id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink where ContentDocumentId in: link];
     system.debug(link2);
    if(link2.size()>0)
    {
        for(ContentDocumentLink con : link2)
    {
       system.debug(con);
        String myIdPrefix = String.valueOf(con.LinkedEntityId).substring(0,3);
        if(myIdPrefix == '001')
        acclmap.put(con.ContentDocumentId,con.LinkedEntityId);
    }
    }
    for(contentDocument con : contnt)
    {
        system.debug(con);
         String Prefix = String.valueOf(con.Title);
        String ParentId = acclmap.get(con.Id);
        String myIdPrefix = String.valueOf(ParentId).substring(0,3);
        if(myIdPrefix == '001')
        {
            account nacc = new account();
            nacc.id = ParentId;
                if(Prefix == 'Reseller Certificate')
            {
                nacc.Reseller_Certificate__c = false;
            }
              if(Prefix == 'EIN Number')
            {
                nacc.EIN_Number__c = false;
            }
               if(Prefix == 'W9 Form')
            {
                system.debug('w9');
                nacc.W9_Form__c = false;
            }
            parent.add(nacc);
            system.debug(parent);
        /*if(acclmap.containsKey(con.Title))
        {
            
            acclmap.get(con.Title).add(con.ParentId);
        }
            else
            {
                list<id> parentList = new list<id>();
            }
         String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0,3);
        if(myIdPrefix == '001')
         parentList.add(con.ParentId);    */ 
        }
    }
system.debug(parent);
    if(parent.size() > 0)
    {
        update parent;
    } 
}