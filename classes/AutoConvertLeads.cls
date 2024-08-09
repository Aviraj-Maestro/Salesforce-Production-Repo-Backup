public class AutoConvertLeads 
{     @InvocableMethod
    public static void LeadAssign(List<id> LeadIds)
    {
        LeadStatus CLeadStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true Limit 1];
        List<Database.LeadConvert> MassLeadconvert = new List<Database.LeadConvert>();
        for(id currentlead: LeadIds)
        {
            Database.LeadConvert Leadconvert = new Database.LeadConvert();
            Leadconvert.setLeadId(currentlead);
            Leadconvert.setConvertedStatus(CLeadStatus.MasterLabel);
            MassLeadconvert.add(Leadconvert);
        } 
        if (!MassLeadConvert.isEmpty())
        {
          List<Database.LeadConvertResult> lcr = Database.convertLead(MassLeadconvert);  
        }
    }
}