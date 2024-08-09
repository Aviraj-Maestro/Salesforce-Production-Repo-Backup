public class LeadsScheduleClass1 implements schedulable
{

    //update Need_To_Inject__c field
 	public void execute(SchedulableContext SC)
 	{
        List<Lead> leadsToUpdate = new List<Lead>();
        Integer numOfLeads = Integer.ValueOf(System.Label.Number_of_leads);
		List<String> gradeLabelValue = System.Label.Account_Engagement_Grade.split(',');
        List<Lead> needToInjectLeads = new List<Lead>();
        
        try{
   	 // Fetch leads having Need_To_Inject__c as Null and Account_Engagement_Grade as defined in custom label
  	 needToInjectLeads = [select Id,Need_To_Inject__c 
                         from Lead 
                         where Need_To_Inject__c = null 
                         and pi__grade__c IN :gradeLabelValue
                         and tdc_tvte__Type__c != 'Landline'
                         and tdc_tvte__Phone_Verification_Status__c = 'Valid'
                         limit :numOfLeads];
  
        }catch(QueryException e){
		System.debug('Error--'+e.getMessage());
		}
 	
        try{
        for(Lead leadObj : needToInjectLeads){
            if(leadsToUpdate!= null){
            leadObj.Need_To_Inject__c = 'Yes';
            leadsToUpdate.add(leadObj);
            }
        }
    	 update leadsToUpdate;

        }catch(DmlException e){
		System.debug('Error--'+e.getMessage());
		}
        
	}
}