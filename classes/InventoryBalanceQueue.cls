public with sharing class InventoryBalanceQueue implements Queueable{
    public  set<Id> inventoryBalanceId;
    public InventoryBalanceQueue( set<Id> inventoryBalanceId) {
        this.inventoryBalanceId = inventoryBalanceId;
    }

    public void execute(QueueableContext context) {
        InventoryBalanceCallout.post(inventoryBalanceId);
      }
}