@isTest
public with sharing class PlaceOrderFromWooCommerce_TC {
    @isTest
    static void PositiveTest(){
        Woocommerce_IQA_API__c API= new Woocommerce_IQA_API__c();
        API.Sync_URL__c='http://maestrotire.com/wp-json/sf-sync/v1/sync_product_stock';
        API.header__c='admin:takecare';
        insert API;

        Test.startTest();
        AcctSeed__Accounting_Period__c acctPeriod = new AcctSeed__Accounting_Period__c(
            Name = '2022-10',
            AcctSeed__Start_Date__c = Date.newinstance(2022, 10, 1),
            AcctSeed__End_Date__c = Date.newinstance(2022, 10, 30),
            AcctSeed__Status__c = 'Open');
            insert acctPeriod;


    // insert 4 billing formats
        AcctSeed__Billing_Format__c[] PDFformats = new List<AcctSeed__Billing_Format__c>();
        PDFformats.add(
                new AcctSeed__Billing_Format__c(
                        Name = 'Default Billing Product',
                        AcctSeed__Visualforce_PDF_Page__c = 'BillingProductPDF',
                        AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                        AcctSeed__Type__c = 'Billing',
                        AcctSeed__Sort_Field__c = 'Name'
                )
        );

        PDFformats.add(
                new AcctSeed__Billing_Format__c(
                        Name = 'Default Billing Service',
                        AcctSeed__Visualforce_PDF_Page__c = 'BillingServicePDF',
                        AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                        AcctSeed__Type__c = 'Billing',
                        AcctSeed__Sort_Field__c = 'Name'
                )
        );

        PDFformats.add(
                new AcctSeed__Billing_Format__c (
                        Name = 'Billing Outstanding Statement',
                        AcctSeed__Visualforce_PDF_Page__c = 'BillingOutstandingStatementPDF',
                        AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                        AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
                        AcctSeed__Type__c = 'Outstanding Statement'
                )
        );

        PDFformats.add(
                new AcctSeed__Billing_Format__c (
                        Name = 'Billing Activity Statement',
                        AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF',
                        AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                        AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
                        AcctSeed__Type__c = 'Activity Statement'
                )
        );

        PDFformats.add(
                new AcctSeed__Billing_Format__c(
                        Name = 'Default Purchase Order',
                        AcctSeed__Visualforce_PDF_Page__c = 'BillingServicePDF',
                        AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                        AcctSeed__Type__c = 'Purchase Order',
                        AcctSeed__Sort_Field__c = 'Name'
                )
        );

        PDFformats.add(
                new AcctSeed__Billing_Format__c(
                        Name = 'Default Packing Slip',
                        AcctSeed__Visualforce_PDF_Page__c = 'BillingServicePDF',
                        AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                        AcctSeed__Type__c = 'Packing Slip',
                        AcctSeed__Sort_Field__c = 'Name'
                )
        );

        insert PDFformats;

   
        //#0
       AcctSeed__GL_Account__c[] glAccounts = new List<AcctSeed__GL_Account__c>();
 // 0
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1000-Cash',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Bank__c = true,
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Cash')
        );
 
        // 1
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1205-Unapplied A/R',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Cash'
            )
        );
 
        // 2
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1200-Accounts Receivable',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Assets'
            )
        );
 
    // 3
    glAccounts.add(
        new AcctSeed__GL_Account__c(
            Name = '1600-Work In Process',
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Assets',
            AcctSeed__Sub_Type_2__c = 'Current Assets'
        )
    );
 
    // 4
    glAccounts.add(
        new AcctSeed__GL_Account__c(
            Name = '2000-Accounts Payable',
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Liabilities',
            AcctSeed__Sub_Type_2__c = 'Current Liabilities'
        )
    );
 
    // 5
    glAccounts.add(
        new AcctSeed__GL_Account__c(
            Name = '2010-Vouchers Payable',
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Liabilities',
            AcctSeed__Sub_Type_2__c = 'Current Liabilities'
    )
 );
 
    // 6
    glAccounts.add(
        new AcctSeed__GL_Account__c(
            Name = '3050-Retained Earnings',
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Owners Equity',
            AcctSeed__Sub_Type_2__c = 'Equity'
        )
    );
 
    // 7
    glAccounts.add(
        new AcctSeed__GL_Account__c(
            Name = '3060-Current Year Earnings',
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Owners Equity',
            AcctSeed__Sub_Type_2__c = 'Equity'
        )
    );
    
    // 8
    glAccounts.add(
        new AcctSeed__GL_Account__c(
            Name = '4000-Product Revenue',
            AcctSeed__Active__c = true,
         
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Assets',
            AcctSeed__Sub_Type_2__c = 'Product Family 1'
        )
    );
 
    // 9
    glAccounts.add(
        new AcctSeed__GL_Account__c(
            Name = '5010-Inventory Cost Variance',
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Balance Sheet',
        
            AcctSeed__Sub_Type_1__c = 'Assets',
            AcctSeed__Sub_Type_2__c = 'Materials'
        )
    );
 
    // 10
    glAccounts.add(
        new AcctSeed__GL_Account__c(
            Name = '5040-Vendor Payment Discounts',
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Expense',
            AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold',
            AcctSeed__Sub_Type_2__c = 'Materials'
        )
    );
 
    // 11
    glAccounts.add(
        new AcctSeed__GL_Account__c(
            Name = 'zLabor Clearing',
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Expense'
        )
    );
 
    // 12
    glAccounts.add(
        new AcctSeed__GL_Account__c(
            Name = 'zProject Labor',
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Expense'
        )
    );
    
    // 13
    glAccounts.add(
        new AcctSeed__GL_Account__c(
            Name = '4900-Customer Payment Discounts',
            AcctSeed__Active__c = true,
            AcctSeed__Bank__c = false,
            AcctSeed__Type__c = 'Revenue',
            AcctSeed__Sub_Type_1__c = 'Product Revenue',
            AcctSeed__Sub_Type_2__c = 'Product Family 1'
        )
    );
    
    // 14
    glAccounts.add(
        new AcctSeed__GL_Account__c(
            Name = '1400-Prepaid Expenses',
            AcctSeed__Active__c = true,
            AcctSeed__Bank__c = false,
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Assets',
            AcctSeed__Sub_Type_2__c = 'Current Assets'
        )
    );

        insert glAccounts;

    // insert 1 Ledger records
        AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c(
                Name = 'Actual',
                AcctSeed__Type__c = 'Transactional',
                AcctSeed__Default_Bank_Account__c = glAccounts[0].id,
                AcctSeed__Default_Billing_Format__c = PDFformats[0].Id,
                AcctSeed__Billing_Outstanding_Statement_Format__c = PDFformats[2].Id,
                AcctSeed__Billing_Activity_Statement_Format__c = PDFformats[3].Id,
                AcctSeed__Default_Purchase_Order_Format__c = PDFformats[4].Id,
                AcctSeed__Default_Packing_Slip_Format__c = PDFformats[5].Id);

        insert ledger;

        List<State_Tire_Fee_Calculator__c> lstStateFee= new List<State_Tire_Fee_Calculator__c>();
        lstStateFee.add(new State_Tire_Fee_Calculator__c(
        Delivery_State__c='California',
        Tire_Rim__c='>20',
        Section_Width__c='20',
        State_Fees__c=2));
        lstStateFee.add(new State_Tire_Fee_Calculator__c(
            Delivery_State__c='California',
            Tire_Rim__c='<11',
            Section_Width__c='20',
            State_Fees__c=2));
      
        insert lstStateFee;
        
       Product2 prostateFee = new Product2(Name='State Fee', isActive=true,StockKeepingUnit='ASDFee',Section_Width__c='295',Aspect_Ratio__c='75',RIM__c='22.5',Family='Service Product');
       insert prostateFee;
      
       PricebookEntry StateFeeprciceEntry =new PricebookEntry(unitprice=0.01,Product2Id=prostateFee.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                  isActive=true,UseStandardPrice = false);
         insert StateFeeprciceEntry;



         Product2 FetProduct2 = new Product2(Name='FET-ARISUN 295/75R22.5 AD737 - 14 PR', isActive=true,StockKeepingUnit='TH99544 - FET',Section_Width__c='295',Aspect_Ratio__c='75',RIM__c='22.5',Family='FET');
         insert FetProduct2;
         
         PricebookEntry FETProduct2prciceEntry =new PricebookEntry(unitprice=0.01,Product2Id=FetProduct2.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                  isActive=true,UseStandardPrice = false);
         insert FETProduct2prciceEntry;

          Product2 ProductMaster = new Product2(Name='AD737',AcctSeed__Inventory_Product__c=true,AcctSeed__Expense_GL_Account__c=glAccounts[12].id,AcctSeed__Inventory_GL_Account__c=glAccounts[1].id,AcctSeed__Inventory_Type__c='Purchased',AcctSeed__Revenue_GL_Account__c = glAccounts[7].Id, isActive=true,StockKeepingUnit='TH99544',Section_Width__c='295',Aspect_Ratio__c='75',RIM__c='22.5',Family='Sales Product',FET_Product__c=FETProduct2prciceEntry.Product2Id);
          insert ProductMaster;
          
          PricebookEntry productMasterPriceBookEntry =new PricebookEntry(unitprice=0.01,Product2Id=ProductMaster.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                   isActive=true,UseStandardPrice = false);
          insert productMasterPriceBookEntry;

          Product2 ProductChild = new Product2(Name='Arisun AD737 (Set of 8)', isActive=true,StockKeepingUnit='TH99544-C',Section_Width__c='295',Product_Master__c=productMasterPriceBookEntry.Product2Id,Aspect_Ratio__c='75',RIM__c='22.5',Family='Sales Product',FET_Product__c=FETProduct2prciceEntry.Product2Id);
          insert ProductChild;
          
          PricebookEntry productChildPriceBookEntry =new PricebookEntry(unitprice=0.01,Product2Id=ProductChild.Id,Pricebook2Id=Test.getStandardPricebookId(),
                isActive=true,UseStandardPrice = false);
            insert productChildPriceBookEntry;

          AcctSeedERP__Warehouse__c warehouese=new AcctSeedERP__Warehouse__c(Name='BAKERSFIELD',State__c='California');
          insert warehouese;

          List<AcctSeedERP__Location__c> lstLocation= new List<AcctSeedERP__Location__c>();
          lstLocation.add(new AcctSeedERP__Location__c(Name='Test Location 1',AcctSeedERP__Warehouse__c=warehouese.Id,Allocation_Priority__c=1));
          lstLocation.add(new AcctSeedERP__Location__c(Name='Test Location 2',AcctSeedERP__Warehouse__c=warehouese.Id,Allocation_Priority__c=2));
          insert lstLocation;


          AcctSeedERP__Inventory_Balance__c iqa1 =new AcctSeedERP__Inventory_Balance__c(AcctSeedERP__Product__c=ProductMaster.Id,AcctSeedERP__Warehouse__c=warehouese.Id,AcctSeedERP__Location__c=lstLocation[0].Id);
          AcctSeedERP__Inventory_Balance__c iqa2 =new AcctSeedERP__Inventory_Balance__c(AcctSeedERP__Product__c=ProductMaster.Id,AcctSeedERP__Warehouse__c=warehouese.Id,AcctSeedERP__Location__c=lstLocation[1].Id);
          insert iqa1;
          insert iqa2;

          List<AcctSeedERP__Inbound_Inventory_Movement__c> lstInventoryMoveMent=new List<AcctSeedERP__Inbound_Inventory_Movement__c>();
          lstInventoryMoveMent.add(new AcctSeedERP__Inbound_Inventory_Movement__c(AcctSeedERP__Type__c='Accounting',AcctSeedERP__Quantity__c=2,AcctSeedERP__Movement_Date__c=System.Today(),AcctSeedERP__Inventory_Balance__c=iqa1.id,AcctSeedERP__Unit_Cost__c=100,AcctSeedERP__Ledger__c=ledger.Id, AcctSeedERP__Credit_GL_Account__c = glAccounts[1].id  ));
          lstInventoryMoveMent.add(new AcctSeedERP__Inbound_Inventory_Movement__c(AcctSeedERP__Type__c='Accounting',AcctSeedERP__Quantity__c=2,AcctSeedERP__Movement_Date__c=System.Today(),AcctSeedERP__Inventory_Balance__c=iqa2.id,AcctSeedERP__Unit_Cost__c=100,AcctSeedERP__Ledger__c=ledger.Id, AcctSeedERP__Credit_GL_Account__c = glAccounts[1].id  ));
          
          insert lstInventoryMoveMent;


          AcctSeedERP__Warehouse__c boonwarehouese=new AcctSeedERP__Warehouse__c(Name='Fonatana',State__c='California');
          insert boonwarehouese;

          List<AcctSeedERP__Location__c> lstLocationCali= new List<AcctSeedERP__Location__c>();
          lstLocationCali.add(new AcctSeedERP__Location__c(Name='Test Location cali 11',AcctSeedERP__Warehouse__c=boonwarehouese.Id,Allocation_Priority__c=1));
          lstLocationCali.add(new AcctSeedERP__Location__c(Name='Test Location cali 12',AcctSeedERP__Warehouse__c=boonwarehouese.Id,Allocation_Priority__c=1));
          insert lstLocationCali;

          AcctSeedERP__Inventory_Balance__c iqa3 =new AcctSeedERP__Inventory_Balance__c(AcctSeedERP__Product__c=ProductMaster.Id,AcctSeedERP__Warehouse__c=boonwarehouese.Id,AcctSeedERP__Location__c=lstLocationCali[0].Id);
          insert iqa3;

          AcctSeedERP__Inventory_Balance__c iqa4 =new AcctSeedERP__Inventory_Balance__c(Id=iqa3.Id,AcctSeedERP__Location__c=lstLocationCali[1].Id);
          update iqa4;
          delete iqa4;

         


        String fakeresp='{"shipping_lines":[{"id":668,"method_title":"Store Pick up","method_id":"local_pickup_plus","instance_id":"0","total":"0.00","total_tax":"0.00","taxes":[{"id":0,"total":"0","subtotal":"","rate_code":"AVATAX-TX-STATE-TAX"}],"meta_data":[{"id":7327,"key":"_pickup_location_id","value":"931","display_key":"_pickup_location_id","display_value":"931"},{"id":7328,"key":"_pickup_location_name","value":"Fontana","display_key":"_pickup_location_name","display_value":"Fontana"},{"id":7329,"key":"_pickup_location_address","value":{"country":"US","state":"CA","postcode":"92337","city":"Fontana","address_1":"11275 Banana Ave","address_2":""},"display_key":"_pickup_location_address","display_value":{"country":"US","state":"CA","postcode":"92337","city":"Fontana","address_1":"11275 Banana Ave","address_2":""}},{"id":7330,"key":"_pickup_location_phone","value":"+1-218-500-0090","display_key":"_pickup_location_phone","display_value":"+1-218-500-0090"},{"id":7374,"key":"_pickup_items","value":[666],"display_key":"_pickup_items","display_value":[666]}]}], "billing": { "first_name": "Ashish", "last_name": "Kumar", "company": "Xoance Software & Services Private Limited", "address_1": "14587 Valley Blvd", "address_2": "", "city": "Fontana", "state": "California", "postcode": "92335", "country": "USA", "email": "ashish.perisun@gmail.com", "phone": "9717273600" }, "shipping": { "first_name": "Ashish", "last_name": "Kumar", "company": "Xoance Software & Services Private Limited", "address_1": "14587 Valley Blvd", "address_2": "", "city": "Fontana", "state": "California", "postcode": "92335", "country": "USA", "phone": "" }, "line_items": [ { "id": 983, "name": "AD737", "product_id": 743, "variation_id": 0, "quantity": 1, "tax_class": "", "subtotal": "0.00", "subtotal_tax": "0.00", "total": "0.00", "total_tax": "0.00", "taxes": [], "meta_data": [ { "id": 10165, "key": "_composite_children", "value": [ "6830d21931e8aa62790934d544a89c8d" ], "display_key": "_composite_children", "display_value": [ "6830d21931e8aa62790934d544a89c8d" ] }, { "id": 10166, "key": "_composite_data", "value": { "1636764004": { "product_id": 742, "quantity": 1, "quantity_min": 1, "quantity_max": 5, "discount": "", "optional": "no", "static": "no", "title": "Unit", "composite_id": 743, "type": "bundle", "stamp": { "59": { "product_id": 738, "quantity": 8, "title": "Set of 8", "discount": "" } } } }, "display_key": "_composite_data", "display_value": { "1636764004": { "product_id": 742, "quantity": 1, "quantity_min": 1, "quantity_max": 5, "discount": "", "optional": "no", "static": "no", "title": "Unit", "composite_id": 743, "type": "bundle", "stamp": { "59": { "product_id": 738, "quantity": 8, "title": "Set of 8", "discount": "" } } } } }, { "id": 10167, "key": "_composite_cart_key", "value": "45b44412f1c5001489cf874d6b9ff053", "display_key": "_composite_cart_key", "display_value": "45b44412f1c5001489cf874d6b9ff053" }, { "id": 10168, "key": "_wc_avatax_origin_address", "value": { "address_1": "539 W COMMERCE ST # 3127", "city": "DALLAS", "state": "TX", "postcode": "75208-1953", "country": "US" }, "display_key": "_wc_avatax_origin_address", "display_value": { "address_1": "539 W COMMERCE ST # 3127", "city": "DALLAS", "state": "TX", "postcode": "75208-1953", "country": "US" } }, { "id": 10169, "key": "_wc_avatax_destination_address", "value": { "address_1": "14587 Valley Blvd", "address_2": "", "city": "Fontana", "state": "CA", "country": "US", "postcode": "92335" }, "display_key": "_wc_avatax_destination_address", "display_value": { "address_1": "14587 Valley Blvd", "address_2": "", "city": "Fontana", "state": "CA", "country": "US", "postcode": "92335" } } ], "sku": "TH99544-C", "price": 0, "parent_name": null, "composite_parent": "", "composite_children": [ 984 ], "bundled_by": "", "bundled_item_title": "", "bundled_items": [] }, { "id": 984, "name": "Arisun AD737 (Set of 8)", "product_id": 742, "variation_id": 0, "quantity": 1, "tax_class": "", "subtotal": "2598.14", "subtotal_tax": "0.00", "total": "2598.14", "total_tax": "0.00", "taxes": [], "meta_data": [ { "id": 10179, "key": "_composite_parent", "value": "45b44412f1c5001489cf874d6b9ff053", "display_key": "_composite_parent", "display_value": "45b44412f1c5001489cf874d6b9ff053" }, { "id": 10180, "key": "_composite_item", "value": "1636764004", "display_key": "_composite_item", "display_value": "1636764004" }, { "id": 10181, "key": "_component_priced_individually", "value": "yes", "display_key": "_component_priced_individually", "display_value": "yes" }, { "id": 10182, "key": "_composite_data", "value": { "1636764004": { "product_id": 742, "quantity": 1, "quantity_min": 1, "quantity_max": 5, "discount": "", "optional": "no", "static": "no", "title": "Unit", "composite_id": 743, "type": "bundle", "stamp": { "59": { "product_id": 738, "quantity": 8, "title": "Set of 8", "discount": "" } } } }, "display_key": "_composite_data", "display_value": { "1636764004": { "product_id": 742, "quantity": 1, "quantity_min": 1, "quantity_max": 5, "discount": "", "optional": "no", "static": "no", "title": "Unit", "composite_id": 743, "type": "bundle", "stamp": { "59": { "product_id": 738, "quantity": 8, "title": "Set of 8", "discount": "" } } } } }, { "id": 10183, "key": "_composite_cart_key", "value": "6830d21931e8aa62790934d544a89c8d", "display_key": "_composite_cart_key", "display_value": "6830d21931e8aa62790934d544a89c8d" }, { "id": 10184, "key": "_composite_item_needs_shipping", "value": "yes", "display_key": "_composite_item_needs_shipping", "display_value": "yes" }, { "id": 10185, "key": "_bundled_items", "value": [ "a7ac7c99298df0043b85cd660c3a7bdf" ], "display_key": "_bundled_items", "display_value": [ "a7ac7c99298df0043b85cd660c3a7bdf" ] }, { "id": 10186, "key": "_bundle_group_mode", "value": "composited", "display_key": "_bundle_group_mode", "display_value": "composited" }, { "id": 10187, "key": "_stamp", "value": { "59": { "product_id": 738, "quantity": 8, "title": "Set of 8", "discount": "" } }, "display_key": "_stamp", "display_value": { "59": { "product_id": 738, "quantity": 8, "title": "Set of 8", "discount": "" } } }, { "id": 10188, "key": "_bundle_cart_key", "value": "6830d21931e8aa62790934d544a89c8d", "display_key": "_bundle_cart_key", "display_value": "6830d21931e8aa62790934d544a89c8d" }, { "id": 10189, "key": "_bundle_weight", "value": "507.84", "display_key": "_bundle_weight", "display_value": "507.84" }, { "id": 10190, "key": "_wc_avatax_origin_address", "value": { "address_1": "539 W COMMERCE ST # 3127", "city": "DALLAS", "state": "TX", "postcode": "75208-1953", "country": "US" }, "display_key": "_wc_avatax_origin_address", "display_value": { "address_1": "539 W COMMERCE ST # 3127", "city": "DALLAS", "state": "TX", "postcode": "75208-1953", "country": "US" } }, { "id": 10191, "key": "_wc_avatax_destination_address", "value": { "country": "US", "state": "CA", "postcode": "93307", "city": "BAKERSFIELD", "address_1": "2546, SOUTH UNION AVENUE", "address_2": "BAKERSFIELD" }, "display_key": "_wc_avatax_destination_address", "display_value": { "country": "US", "state": "CA", "postcode": "93307", "city": "BAKERSFIELD", "address_1": "2546, SOUTH UNION AVENUE", "address_2": "BAKERSFIELD" } } ], "sku": "TH99544 - 8", "price": 2598.13999999999987267074175179004669189453125, "parent_name": null, "composite_parent": 983, "composite_children": [], "bundled_by": "", "bundled_item_title": "", "bundled_items": [ 985 ] }, { "id": 985, "name": "Set of 8", "product_id": 738, "variation_id": 0, "quantity": 8, "tax_class": "", "subtotal": "0.00", "subtotal_tax": "0.00", "total": "0.00", "total_tax": "0.00", "taxes": [], "meta_data": [ { "id": 10202, "key": "_bundled_by", "value": "6830d21931e8aa62790934d544a89c8d", "display_key": "_bundled_by", "display_value": "6830d21931e8aa62790934d544a89c8d" }, { "id": 10203, "key": "_bundled_item_id", "value": "59", "display_key": "_bundled_item_id", "display_value": "59" }, { "id": 10204, "key": "_bundled_item_priced_individually", "value": "no", "display_key": "_bundled_item_priced_individually", "display_value": "no" }, { "id": 10205, "key": "_bundled_item_title", "value": "Set of 8", "display_key": "_bundled_item_title", "display_value": "Set of 8" }, { "id": 10206, "key": "_stamp", "value": { "59": { "product_id": 738, "quantity": 8, "title": "Set of 8", "discount": "" } }, "display_key": "_stamp", "display_value": { "59": { "product_id": 738, "quantity": 8, "title": "Set of 8", "discount": "" } } }, { "id": 10207, "key": "_bundle_cart_key", "value": "a7ac7c99298df0043b85cd660c3a7bdf", "display_key": "_bundle_cart_key", "display_value": "a7ac7c99298df0043b85cd660c3a7bdf" }, { "id": 10208, "key": "_bundled_item_needs_shipping", "value": "no", "display_key": "_bundled_item_needs_shipping", "display_value": "no" }, { "id": 10209, "key": "_wc_avatax_origin_address", "value": { "address_1": "539 W COMMERCE ST # 3127", "city": "DALLAS", "state": "TX", "postcode": "75208-1953", "country": "US" }, "display_key": "_wc_avatax_origin_address", "display_value": { "address_1": "539 W COMMERCE ST # 3127", "city": "DALLAS", "state": "TX", "postcode": "75208-1953", "country": "US" } }, { "id": 10210, "key": "_wc_avatax_destination_address", "value": { "address_1": "14587 Valley Blvd", "address_2": "", "city": "Fontana", "state": "CA", "country": "US", "postcode": "92335" }, "display_key": "_wc_avatax_destination_address", "display_value": { "address_1": "14587 Valley Blvd", "address_2": "", "city": "Fontana", "state": "CA", "country": "US", "postcode": "92335" } } ], "sku": "TH99544", "price": 0, "parent_name": null, "composite_parent": "", "composite_children": [], "bundled_by": 984, "bundled_item_title": "Set of 8", "bundled_items": [] } ], "customer_info": { "user_email": "ashish.perisun@gmail.com", "first_name": "Ashish", "last_name": "Kumar" }, "warehouse_info": { "warehouse_id": "932",  "warehouse_sf_id": "'+warehouese.Id+'", "warehouse_name": "BAKERSFIELD" } }';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
     
         req.requestURI = '/services/apexrest/api/Order/';  //Request URL
         req.httpMethod = 'POST';//HTTP Request Type
         req.requestBody = Blob.valueof(fakeresp);
         RestContext.request = req;
         RestContext.response= res;

       

         Test.setMock(HttpCalloutMock.class, new IQACallOutMock());
         PlaceOrderFromWoocomerce.doPost();

        
        // delete iqa2;
     
         //HttpResponse res = InventoryBalanceCallout.getInfoFromExternalService(myCase.Id);
        Test.stopTest();
    }
}