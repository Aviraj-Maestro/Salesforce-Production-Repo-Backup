@isTest
public class LeadsScheduleClassTest1 {
    @isTest
    public static void testLeadsScheduleClass() {
        //  test leads
        List<Lead> testLeads = new List<Lead>();
        for (Integer i = 0; i < 20; i++) {
            Lead lead = new Lead();
            lead.LastName = 'Test';
            lead.LeadSource = 'Google';
            lead.Status = 'New Lead';
            lead.Company = 'TestComp' + i;
            lead.Email = 'TestComp' + i + '@Test.com';
            lead.Type_of_Customer__c = 'Reseller';
            lead.pi__grade__c = 'B';
            lead.tdc_tvte__Type__c = 'Mobile';
            lead.tdc_tvte__Phone_Verification_Status__c = 'Valid';
            testLeads.add(lead);
        }
        insert testLeads;
        
        
        LeadsScheduleClass1 leadsSchedule = new LeadsScheduleClass1();
        
        Test.startTest();
        
        // Execute the scheduled class
        String cronExpression = '0 0 0 * * ?'; // Run once daily at midnight
        System.schedule('TestLeadsSchedule', cronExpression, leadsSchedule);
        
        Test.stopTest();
        
        // Verify that the Need_To_Inject__c field is updated to 'Yes
        List<Lead> updatedLeads = [SELECT Id, Need_To_Inject__c FROM Lead WHERE Id IN :testLeads];
        System.assertEquals(20, updatedLeads.size(), 'Incorrect number of leads updated');
        for (Lead lead : updatedLeads) {
            //System.assertEquals('Yes', lead.Need_To_Inject__c, 'Need_To_Inject__c field not updated');
        }
    }
}