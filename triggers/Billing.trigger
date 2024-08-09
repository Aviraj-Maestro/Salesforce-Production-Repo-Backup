trigger Billing on AcctSeed__Billing__c (after insert,before delete,after update,before update,before insert,after delete) {
    TriggerDispatcher.Run(new BillingTriggerHandler());
}