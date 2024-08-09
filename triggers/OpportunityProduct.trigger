trigger OpportunityProduct on OpportunityLineItem (after insert,after update,before delete) {

    if( RecursiveTrigger.isFirstTime == True){    
        if(Trigger.IsAfter && Trigger.IsInsert){
        RecursiveTrigger.isFirstTime = false;
        TriggerDispatcher.Run(new OpportunityProductTriggerHandler());
        }
        
    }
    
    if( RecursiveTrigger.isUpdateFirstTime == True){    
        if(Trigger.IsAfter && Trigger.IsUpdate ){
          RecursiveTrigger.isUpdateFirstTime=false;
          TriggerDispatcher.Run(new OpportunityProductTriggerHandler());
          }
      }

        if( RecursiveTrigger.isDeleteFirstTime == True){    
        
        if(Trigger.IsBefore && Trigger.IsDelete){
          RecursiveTrigger.isDeleteFirstTime=false;
          TriggerDispatcher.Run(new OpportunityProductTriggerHandler());
          }
        }

}