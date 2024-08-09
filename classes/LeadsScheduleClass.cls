public class LeadsScheduleClass implements schedulable
{
    
    // Fetch leads having craeteddate > 16 May 2023 and  Need_To_Inject__c as Null
    List<Lead> needToInjectLeads = new List<Lead>([select Id,Need_To_Inject__c 
                         						from Lead 
                         						where Need_To_Inject__c = null 
                         						and CreatedDate > 2021-05-16T00:00:00.000+0000
                                                and LastName = 'Test'
                         						limit 20]);
    List<Lead> leadsToUpdate = new List<Lead>();
    //update Need_To_Inject__c field
 	public void execute(SchedulableContext SC)
 	{
 	
        for(Lead leadObj : needToInjectLeads){
            if(leadsToUpdate!= null){
            leadObj.Need_To_Inject__c = 'Yes';
            leadsToUpdate.add(leadObj);
            }
        }
     update leadsToUpdate;
 	}
}