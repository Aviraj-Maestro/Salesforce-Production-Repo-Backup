@istest
private class AutoConvertLeadsTest {
    
    @testSetup static void setup() {
      Lead objLead = new Lead( FirstName = 'Test', LastName = 'Sample', Company = 'Testing Sample Co',
                               phone='9898987654');  
        insert objLead;  
        
    }
     static testMethod void testLeadConv() {  
        
        Lead lead= [select Id,FirstName,LastName,Company,phone from Lead where phone='9898987654'];
        List<Id> listLead= new List<Id>();
        listLead.add(lead.Id);
        test.startTest();
        AutoConvertLeads.LeadAssign(listLead) ;
        test.stopTest();
      
     }  

}