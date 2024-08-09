trigger Quote on Quote (after insert,before delete,after update,before update,before insert,after delete) {
    TriggerDispatcher.Run(new QuoteTriggerHandler());
}