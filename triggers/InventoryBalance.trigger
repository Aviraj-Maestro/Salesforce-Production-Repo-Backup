trigger InventoryBalance on AcctSeedERP__Inventory_Balance__c (after update,before update,after insert,before insert,before delete,after delete) {
    TriggerDispatcher.Run(new InventoryBalanceTriggerHandler());
}