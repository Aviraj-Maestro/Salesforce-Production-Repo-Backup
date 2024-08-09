@isTest
public class QuoteTrigger_TC {
    static testmethod void  Positivetest(){

        Date closeDt = Date.Today();
        
         date myDate = date.today();
        
        Account a2 = new Account(Name ='Testing',ShippingState='Alabama',ShippingCountry='USA');
        insert a2;

        Contact cont = new Contact();
		cont.FirstName='Test';
		cont.LastName='Test';
        Cont.MailingCountry='USA';
        Cont.MailingState='Alabama';
		cont.Accountid= a2.id;
		insert cont;

        Account_Adddress__c add= new Account_Adddress__c();
        add.Shipping_City__c='test';
        add.Shipping_Country__c='test';
        add.Shipping_State_Province__c='test';
        add.Shipping_Street__c='test';
        add.Shipping_Zip_Postal_Code__c='test';
        add.Account__c=A2.Id;
        insert add;

        AcctSeedERP__Warehouse__c warHouse = new AcctSeedERP__Warehouse__c();
        warHouse.City__c = 'Test City';
        warHouse.Country__c = 'Test Country';
        warHouse.State__c = 'Test State';
        warHouse.Street__c = 'Test Street';
        warHouse.Name = 'Test';
        warHouse.Avalara_Location_Code__c='1234';
        warHouse.Zip_Code__c = '202034';
        insert warHouse;

        State_Tire_Fee_Calculator__c stateTireFee= new State_Tire_Fee_Calculator__c();
        stateTireFee.Delivery_State__c='Alabama';
        stateTireFee.Tire_Rim__c='<11';
        stateTireFee.Section_Width__c='20';
        stateTireFee.State_Fees__c=2;
        insert stateTireFee;

        State_Tire_Fee_Calculator__c stateTireFee11= new State_Tire_Fee_Calculator__c();
        stateTireFee11.Delivery_State__c='Alabama';
        stateTireFee11.Tire_Rim__c='<=22.5';
        stateTireFee11.Section_Width__c='20';
        stateTireFee11.State_Fees__c=2;
        insert stateTireFee11;

        State_Tire_Fee_Calculator__c stateTireFee12= new State_Tire_Fee_Calculator__c();
        stateTireFee12.Delivery_State__c='Alabama';
        stateTireFee12.Tire_Rim__c='10-30';
        stateTireFee12.Section_Width__c='20';
        stateTireFee12.State_Fees__c=2;
        insert stateTireFee12;

        State_Tire_Fee_Calculator__c stateTireFee13= new State_Tire_Fee_Calculator__c();
        stateTireFee13.Delivery_State__c='Alabama';
        stateTireFee13.Tire_Rim__c='>20';
        stateTireFee13.Section_Width__c='20';
        stateTireFee13.State_Fees__c=2;
        insert stateTireFee13;

  
        
        Product2 prostateFee = new Product2(Name='State Fee', isActive=true,StockKeepingUnit='ASDFee',Section_Width__c='295',Aspect_Ratio__c='75',RIM__c='22.5',Family='Service Product');
        insert prostateFee;
       
       
        PricebookEntry pbestateFee =new PricebookEntry(unitprice=0.01,Product2Id=prostateFee.Id,Pricebook2Id=Test.getStandardPricebookId(),
        isActive=true,UseStandardPrice = false);
        insert pbestateFee;
       
       
        
    


         Account a3 = new Account(Name ='Testing',ShippingState='North Carolina',ShippingCountry='USA');
         insert a3;
         
        Contact cont1 = new Contact();
		cont1.FirstName='Test';
		cont1.LastName='Test';
        cont1.MailingCountry='USA';
        cont1.MailingState='Alabama';
		cont1.Accountid= a3.id;
		insert cont1;
         State_Tire_Fee_Calculator__c stateTireFee21= new State_Tire_Fee_Calculator__c();
         stateTireFee21.Delivery_State__c='North Carolina';
         stateTireFee21.Tire_Rim__c='10-30';
         stateTireFee21.Section_Width__c='20';
         stateTireFee21.State_Fees__c=2;
         insert stateTireFee21;
 
         
 
         opportunity oppr1 = new opportunity(Name='testing DIE 4/6/2016' ,  AccountId= a3.Id,StageName = 'Estimate', 
                                            CloseDate = closeDt,Delivery_Type__c='Door Delivery',Looking_for__c='Tire',Ship_to_Contact__c=cont1.Id  ,ship_to_Address__c=add.Id,
                                            Warehouse_Location__c=warHouse.Id,Ship_From_Address__c=warHouse.Id);
         insert oppr1;
         

         Product2 FetProduct1 = new Product2(Name='FET BXCD1 Set of 2', isActive=true,StockKeepingUnit='ASD1 - FET',Section_Width__c='295',Aspect_Ratio__c='75',RIM__c='22.5',Family='FET');
         insert FetProduct1;
         
         PricebookEntry FETProduct1prciceEntry =new PricebookEntry(unitprice=0.01,Product2Id=FetProduct1.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                  isActive=true,UseStandardPrice = false);
         insert FETProduct1prciceEntry;
         
         Product2 pro3 = new Product2(Name='BXCD1 Set of 2', isActive=true,StockKeepingUnit='ASD1-',Section_Width__c='295',Aspect_Ratio__c='75',RIM__c='22.5',Family='Sales Product',FET_Product__c=FetProduct1.Id);
         insert pro3;
         
         PricebookEntry pbe3 =new PricebookEntry(unitprice=0.01,Product2Id=pro3.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                  isActive=true,UseStandardPrice = false);
         insert pbe3;

         List<OpportunityLineItem> lstOpportunityLineItemToInsert=new List<OpportunityLineItem>();
         
          OpportunityLineItem OPplineitem3 = new OpportunityLineItem (Quantity=2, OpportunityId=oppr1.Id,UnitPrice=0.01,PriceBookEntryId=pbe3.Id
                                             );
         lstOpportunityLineItemToInsert.add(OPplineitem3);

         Product2 FetProduct2 = new Product2(Name='FET BXCD1 Set of 4', isActive=true,StockKeepingUnit='ASD23 - FET',Section_Width__c='295',Aspect_Ratio__c='75',RIM__c='22.5',Family='FET');
         insert FetProduct2;
         
         PricebookEntry FETProduct2prciceEntry =new PricebookEntry(unitprice=0.01,Product2Id=FetProduct2.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                  isActive=true,UseStandardPrice = false);
         insert FETProduct2prciceEntry;

          Product2 pro13 = new Product2(Name='BXCD1 Set of 4', isActive=true,StockKeepingUnit='ASD23',Section_Width__c='295',Aspect_Ratio__c='75',RIM__c='22.5',Family='Sales Product',FET_Product__c=FetProduct2.Id);
          insert pro13;
          
          PricebookEntry pbe13 =new PricebookEntry(unitprice=0.01,Product2Id=pro13.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                   isActive=true,UseStandardPrice = false);
          insert pbe13;
          
           OpportunityLineItem OPplineitem13 = new OpportunityLineItem (Quantity=2, OpportunityId=oppr1.Id,UnitPrice=0.01,PriceBookEntryId=pbe13.Id
                                              );
           lstOpportunityLineItemToInsert.add(OPplineitem13);
           insert lstOpportunityLineItemToInsert;
           List<Quote> lstQuote = new List<Quote>();

           lstQuote.add(new Quote(OpportunityId = oppr1.Id, Name = 'Test Quote', Pricebook2Id = Test.getStandardPricebookId(),Ship_From_Address__c=warHouse.Id));
          
            insert lstQuote;
           
           try {
            update lstQuote;
          
           } catch (Exception Ex) {
            
            
           }
           try {
       
            delete lstQuote;
           } catch (Exception Ex) {
            
            
           }
         
 
          OpportunityLineItem OPplineitemUpdate= new OpportunityLineItem();
          OPplineitemUpdate.Id=OPplineitem3.Id;
          OPplineitemUpdate.Quantity=3;
         // update OPplineitemUpdate;
          delete OPplineitemUpdate;

          OpportunityLineItem OPplineitemUpdate12= new OpportunityLineItem();
          OPplineitemUpdate12.Id=OPplineitem13.Id;
          OPplineitemUpdate12.Quantity=3;
         // update OPplineitemUpdate12;
          delete OPplineitemUpdate12;

          State_Tire_Fee_Calculator__c stateTireFee14= new State_Tire_Fee_Calculator__c();
          stateTireFee14.Delivery_State__c='California';
          stateTireFee14.Tire_Rim__c='>20';
          stateTireFee14.Section_Width__c='20';
          stateTireFee14.State_Fees__c=2;
          insert stateTireFee14;
          
          opportunity oppr2 = new opportunity(Name='testing DIE 4/6/2015' ,  AccountId= a3.Id,StageName = 'Estimate', 
          CloseDate = closeDt,Delivery_Type__c='Door Delivery',Looking_for__c='Tire',Ship_to_Contact__c=cont1.Id,ship_to_Address__c=add.Id,
          Warehouse_Location__c=warHouse.Id,Ship_From_Address__c=warHouse.Id);
            insert oppr2;

            Product2 FetProduct4 = new Product2(Name='FET BXCD1 Set of 4', isActive=true,StockKeepingUnit='ASD12 - FET',Section_Width__c='295',Aspect_Ratio__c='75',RIM__c='22.5',Family='FET');
         insert FetProduct4;
         
         PricebookEntry FETProduct4prciceEntry =new PricebookEntry(unitprice=0.01,Product2Id=FetProduct4.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                  isActive=true,UseStandardPrice = false);
         insert FETProduct4prciceEntry;

            Product2 pro4 = new Product2(Name='BXCD1 Set of 4', isActive=true,StockKeepingUnit='ASD12-',Section_Width__c='295',Aspect_Ratio__c='75',RIM__c='22.5',Family='Sales Product',FET_Product__c=FetProduct4.Id);
            insert pro4;

            PricebookEntry pbe4 =new PricebookEntry(unitprice=0.01,Product2Id=pro4.Id,Pricebook2Id=Test.getStandardPricebookId(),
                            isActive=true,UseStandardPrice = false);
            insert pbe4;

            OpportunityLineItem OPplineitem4 = new OpportunityLineItem (Quantity=2, OpportunityId=oppr2.Id,UnitPrice=0.01,PriceBookEntryId=pbe4.Id
                    );
            insert OPplineitem4;
           
            delete OPplineitem4;








            

            opportunity opprToUpdate = new opportunity(Name='Opportunity test 1' , AccountId= a3.Id,StageName = 'Estimate', 
                                            CloseDate = closeDt,Delivery_Type__c='Door Delivery',Looking_for__c='Tire',Ship_to_Contact__c=cont1.Id,Pricebook2Id=Test.getStandardPricebookId(),ship_to_Address__c=add.Id,
                                            Warehouse_Location__c=warHouse.Id,Ship_From_Address__c=warHouse.Id);
             insert opprToUpdate;

             Product2 Product1ToUpdate = new Product2(Name='Product Set of 2', isActive=true,StockKeepingUnit='PROD1-TEST',Section_Width__c='295',Aspect_Ratio__c='75',RIM__c='22.5',Family='Sales Product',FET_Product__c=FetProduct4.Id);
             insert Product1ToUpdate;
             
             PricebookEntry ProceBookEntryToUpdate1 =new PricebookEntry(unitprice=0.01,Product2Id=Product1ToUpdate.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                      isActive=true,UseStandardPrice = false);
             insert ProceBookEntryToUpdate1;



             Product2 Product2ToUpdate = new Product2(Name='Product Set of 4', isActive=true,StockKeepingUnit='PROD2',Section_Width__c='295',Aspect_Ratio__c='75',RIM__c='22.5',Family='Sales Product',FET_Product__c=FetProduct4.Id);
             insert Product2ToUpdate;
             
             PricebookEntry ProceBookEntryToUpdate2 =new PricebookEntry(unitprice=0.01,Product2Id=Product2ToUpdate.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                      isActive=true,UseStandardPrice = false);
             insert ProceBookEntryToUpdate2;

             Product2 Product3ToUpdate = new Product2(Name='Product Set of 6', isActive=true,StockKeepingUnit='PROD3-TEST',Section_Width__c='295',Aspect_Ratio__c='75',RIM__c='22.5',Family='Sales Product',FET_Product__c=FetProduct4.Id);
             insert Product3ToUpdate;
             
             PricebookEntry ProceBookEntryToUpdate3 =new PricebookEntry(unitprice=0.01,Product2Id=Product3ToUpdate.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                      isActive=true,UseStandardPrice = false);
             insert ProceBookEntryToUpdate3;

             Product2 Product4ToUpdate = new Product2(Name='Product Set of 8', isActive=true,StockKeepingUnit='PROD4-TEST',Section_Width__c='295',Aspect_Ratio__c='75',RIM__c='22.5',Family='Sales Product',FET_Product__c=FetProduct4.Id);
             insert Product4ToUpdate;
             
             PricebookEntry ProceBookEntryToUpdate4 =new PricebookEntry(unitprice=0.01,Product2Id=Product4ToUpdate.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                      isActive=true,UseStandardPrice = false);
             insert ProceBookEntryToUpdate4;


             Product2 Product5ToUpdate = new Product2(Name='Product', isActive=true,StockKeepingUnit='PROD5-TEST',Section_Width__c='295',Aspect_Ratio__c='75',RIM__c='22.5',Family='Sales Product',FET_Product__c=FetProduct4.Id);
             insert Product5ToUpdate;
             
             PricebookEntry ProceBookEntryToUpdate5 =new PricebookEntry(unitprice=0.01,Product2Id=Product5ToUpdate.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                      isActive=true,UseStandardPrice = false);
             insert ProceBookEntryToUpdate5;


             Product2 shippingHandlingProduct1 = new Product2(Name='Lift Gate Charges', isActive=true,Family='Shipping and Handling');
             insert shippingHandlingProduct1;
             
             PricebookEntry shippingHandlingProceBookEntry1 =new PricebookEntry(unitprice=1,Product2Id=shippingHandlingProduct1.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                      isActive=true,UseStandardPrice = false);
             insert shippingHandlingProceBookEntry1;


             Product2 shippingHandlingProduct2 = new Product2(Name='Freight charges', isActive=true,Family='Shipping and Handling');
             insert shippingHandlingProduct2;
             
             PricebookEntry shippingHandlingProceBookEntry2 =new PricebookEntry(unitprice=1,Product2Id=shippingHandlingProduct2.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                      isActive=true,UseStandardPrice = false);
             insert shippingHandlingProceBookEntry2;


             Product2 shippingHandlingProduct3 = new Product2(Name='Misc. Charges', isActive=true,Family='Shipping and Handling');
             insert shippingHandlingProduct3;
             
             PricebookEntry shippingHandlingProceBookEntry3 =new PricebookEntry(unitprice=1,Product2Id=shippingHandlingProduct3.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                      isActive=true,UseStandardPrice = false);
             insert shippingHandlingProceBookEntry3;

             List<OpportunityLineItem> OpportunityLineItemToInsert=new List<OpportunityLineItem>();
              OpportunityLineItem OPplineitemForUpodate1 = new OpportunityLineItem (Quantity=2, OpportunityId=opprToUpdate.Id,UnitPrice=0.01,PriceBookEntryId=ProceBookEntryToUpdate1.Id,Group__c='PROD1'
                                                 );
              OpportunityLineItemToInsert.add(OPplineitemForUpodate1);


              OpportunityLineItem OPplineitemForUpodate2 = new OpportunityLineItem (Quantity=2, OpportunityId=opprToUpdate.Id,UnitPrice=0.01,PriceBookEntryId=ProceBookEntryToUpdate2.Id,Group__c='PROD2'
              );
              OpportunityLineItemToInsert.add(OPplineitemForUpodate2);

              OpportunityLineItemToInsert.add(new OpportunityLineItem (Quantity=2, OpportunityId=opprToUpdate.Id,UnitPrice=0.01,PriceBookEntryId=ProceBookEntryToUpdate3.Id,Group__c='PROD3'));
              OpportunityLineItemToInsert.add(new OpportunityLineItem (Quantity=2, OpportunityId=opprToUpdate.Id,UnitPrice=0.01,PriceBookEntryId=ProceBookEntryToUpdate4.Id,Group__c='PROD4'));
              OpportunityLineItemToInsert.add(new OpportunityLineItem (Quantity=2, OpportunityId=opprToUpdate.Id,UnitPrice=0.01,PriceBookEntryId=ProceBookEntryToUpdate5.Id,Group__c='PROD5'));
           
              insert OpportunityLineItemToInsert;
              List<OpportunityLineItem> OpportunityLineItemToUpdate=new List<OpportunityLineItem>();
              for(OpportunityLineItem oppline :OpportunityLineItemToInsert){
                OpportunityLineItemToUpdate.add(new OpportunityLineItem(Id=oppline.Id,Quantity=3));
              }
              update OpportunityLineItemToUpdate;

         
              Quote newQuote = new Quote();
              newQuote.Name = 'Test Quote';
              newQuote.OpportunityId = opprToUpdate.Id;
              newQuote.Pickup_Fitment_Address__c = 'Bakersfield, CA';
              insert newQuote;
              
              
              QuoteLineItem qli= new QuoteLineItem();
              qli.QuoteId = newQuote.id;
              //not writeable  oppLine1.Name = opp1.Name;
              qli.Quantity= Decimal.valueof('4');
              //not writeable  oppLine1.ProductCode='AEOLUSG3 - 2';
              qli.Group__c='AEOLUSG3 - 2';
              qli.UnitPrice=Decimal.valueof('8700.00');
              qli.Product2Id= Product3ToUpdate.id;
              qli.Description ='Quote - Store Pick Up Inventory Test';
              qli.PricebookEntryId=ProceBookEntryToUpdate1.id;
              
              insert qli;
      
      
            
              
            //   AcctSeedERP__Inventory_Balance__c inventory = new AcctSeedERP__Inventory_Balance__c();
            //   inventory.AcctSeedERP__Location__c = location.Id;
            //   inventory.Qty_Available__c = '10';
            //   inventory.AcctSeedERP__Warehouse__c = warHouse.Id;
            //   inventory.AcctSeedERP__Product__c = Pro1.id;
            //   insert inventory;

         }

  
}