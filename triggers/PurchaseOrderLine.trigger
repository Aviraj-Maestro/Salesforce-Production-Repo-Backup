trigger PurchaseOrderLine on AcctSeedERP__Purchase_Order_Line__c (before insert,after update,after insert,before delete) {
    TriggerDispatcher.Run(new PurchaseOrderLineTriggerHandler());
}