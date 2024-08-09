/**
 * @Author        : V.S.Marimuthu
 * @CreatedOn     : March 17 ,2020
 * @Purpose       : Base Trigger framework for all objects.Implement this if you write any trigger
 **/
public interface ITriggerHandler{
	// Before methods of DML operations
	void BeforeInsert(List<Sobject> newItems);
	//void BeforeUpdate(Map<id, sObject> newItems, Map<id, sObject> oldItems);
	void BeforeDelete(Map<id, sObject> oldItems);
	// After methods of DML Operations
	void AfterInsert(List<Sobject> newItems);
	void AfterUpdate(Map<id, sObject> newItems, Map<id, sObject> oldItems);
	//void AfterDelete(Map<id, sObject> oldItems);
	//void AfterUndelete(List<Sobject> newItems);

	// Method to disable Trigger
	Boolean IsDisabled();
}