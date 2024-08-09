public class TriggerDispatcher{
	/**
	 * @Author        : V.S.Marimuthu
	 * @CreatedOn     : March 17 ,2020
	 * @Purpose       : Dispatcher class for running the trigger handler class
	 **/
	public static void Run(ITriggerHandler handler){
		// Check to see if trigger is disabled. If it is disabled then return without running
		if (handler.IsDisabled())
			return;
		// Detect the current trigger context and fire the relevant methods on trigger handler
		// Before trigger logic
		if (Trigger.IsBefore){
			if (Trigger.IsInsert)
				handler.BeforeInsert(trigger.new);
			//if (Trigger.IsUpdate)
			//	handler.BeforeUpdate(trigger.newMap, trigger.oldMap);
			if (Trigger.IsDelete)
				handler.BeforeDelete(trigger.oldMap);
		}
		//isBefore
		// After trigger logic
		if (Trigger.IsAfter){
			if (Trigger.IsInsert)
				handler.AfterInsert(trigger.new);
			if (Trigger.IsUpdate)
				handler.AfterUpdate(trigger.newMap, trigger.oldMap);
			//if (Trigger.IsDelete)
			//	handler.AfterDelete(trigger.oldMap);
		//	if (Trigger.IsUnDelete )
			//	handler.AfterUndelete(trigger.new);
		}
		//isAfter
	}
}