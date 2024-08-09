@isTest
public class LocationWiseInverntoryControllerTest {
    @testSetup
    public static void setupTestData(){
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Reseller').getRecordTypeId();
        
        List<Account> Acc = new List<Account>();
        Account acc1 = new Account();
        acc1.AcctSeed__Exemption_Number__c='12000-3456';
        acc1.Name='Test';
        Acc1.Phone='8700203559';
        acc1.RecordTypeId= recordTypeIdAccount;
        acc1.AcctSeed__Entity_Use_Code__c='G';
        acc1.BillingCity='allbama city';
        acc1.BillingCountry='USA';
        acc1.BillingState='Alaska';
        acc1.BillingPostalCode='36117';
        acc1.ShippingCity='test city';
        acc1.ShippingCountry='USA';
        acc1.ShippingState='Alaska';
        acc1.ShippingStreet='Test1';
        acc1.ShippingPostalCode='36119';
        Acc.add(acc1);
        insert Acc;
        
        Contact con = new Contact();
        con.LastName = 'Last';
        con.AccountId= Acc[0].Id;
        con.MailingCity = 'Test City';
        con.MailingCountry = 'India';
        con.MailingPostalCode = '234234';
        con.MailingStreet = 'Test Streeet';
        con.MailingState = 'Delhi';
        insert con;
        
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
        
        List<AcctSeed__GL_Account__c> glAccounts = new List<AcctSeed__GL_Account__c>();
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '2000-Accounts Payable',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Liabilities',
                AcctSeed__Sub_Type_2__c = 'Current Liabilities',
                AcctSeed__Bank__c = true
            )
        );
        insert glAccounts;
        
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
        
        AcctSeedERP__Warehouse__c warHouse = new AcctSeedERP__Warehouse__c();
        warHouse.City__c = 'Test City';
        warHouse.Country__c = 'Test Country';
        warHouse.State__c = 'Test State';
        warHouse.Street__c = 'Test Street';
        warHouse.Name = 'Test';
        warHouse.Zip_Code__c = '202034';
        insert warHouse;
        
        AcctSeedERP__Location__c location = new AcctSeedERP__Location__c();
        location.Name = 'Warehouse location';
        location.AcctSeedERP__Warehouse__c = warHouse.Id;
        insert location;
        
        
        
        List<Product2> Pronew = new List<Product2>();
        Product2 Pronew1 = new Product2();
        Pronew1.Name=Acc1.name;
        Pronew1.PATTERN__c='HIGHWAY D12';
        Pronew1.RIM__c='22.5';
        Pronew1.Tyre_Type__c='New';
        Pronew1.WEIGHT_IN_LBS__c=Decimal.valueOf('107.00');
        Pronew1.Description='test';
        Pronew1.Width_Inches__c='25.5';
        Pronew1.Tax_Code__c='FR030000';
        Pronew1.StockKeepingUnit='AEOLUSG2';
        Pronew1.Product_Type__c='Kit Product';
        Pronew1.Studded__c='False';
        Pronew.add(Pronew1);
        insert Pronew;
        
        
        List<Product2> Pro = new List<Product2>();
        Product2 Pro1 = new Product2();
        Pro1.Name=Acc1.name;
        Pro1.PATTERN__c='HIGHWAY D12';
        Pro1.RIM__c='19.5';
        Pro1.Tyre_Type__c='New';
        Pro1.WEIGHT_IN_LBS__c=Decimal.valueOf('107.00');
        Pro1.Description='test';
        Pro1.Width_Inches__c='25';
        Pro1.Tax_Code__c='PA3000301';
        Pro1.StockKeepingUnit='AEOLUSG3 -2';
        Pro1.Product_Type__c='Kit Product';
        Pro1.Studded__c='False';
        Pro1.Product_Master__c= Pronew1.id;
        Pro1.Family = 'Sales Product';
        Pro1.IsActive = true;
        Pro1.AcctSeed__Inventory_Product__c = true;
        Pro1.AcctSeed__Expense_GL_Account__c = glAccounts[0].Id;
        Pro1.AcctSeed__Inventory_GL_Account__c = glAccounts[0].Id;
        Pro1.AcctSeed__Inventory_Type__c = 'Manufactured';
        Pro1.AcctSeed__Revenue_GL_Account__c = glAccounts[0].Id;
        Pro.add(Pro1);
        insert Pro;
        
        
        
        
        List<Pricebook2> Price = new List<Pricebook2>();
        Pricebook2 Price1 =new pricebook2();
        Price1.Name='test';
        Price.add(Price1);
        insert Price;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = pronew1.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = pronew1.Id, UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
        
        
        List<PricebookEntry> Priceb = new List<PricebookEntry>();
        PricebookEntry Priceb1 =new PricebookEntry();
        Priceb1.Pricebook2Id = Price1.id;
        priceb1.UnitPrice=1000;
        priceb1.Product2Id=pronew1.id;
        Priceb.add(Priceb1);
        Insert Priceb;
        
        
        
        List<Account_Adddress__c> AccAd = new List<Account_Adddress__c>();
        Account_Adddress__c AccAd1 = new Account_Adddress__c();
        AccAd1.Billing_City__c='test';
        AccAd1.Billing_Country__c='USA';
        AccAd1.Billing_State_Province__c='Alaska';
        AccAd1.Billing_Street__c='Test City';
        AccAd1.Billing_Zip_Postal_Code__c='36119';
        AccAd.add(AccAd1);
        Insert AccAd;
        
        
        
        List<opportunity> Opp = new List<opportunity>();
        Opportunity opp1 = new Opportunity();
        opp1.accountid=acc1.id;
        opp1.name=Acc1.Name;
        opp1.Pricebook2Id=customPB.id;
        opp1.Looking_for__c='Tire';
        Opp1.StageName='negotiating';
        Opp1.Delivery_Type__c = 'Door Delivery';
        Opp1.Ship_to_Contact__c = con.Id;
        opp1.CloseDate=system.today();
        Opp.add(opp1);
        insert opp;
        
        
        List<OpportunityLineItem> OppLine = new List<OpportunityLineItem>();
        OpportunityLineItem oppLine1= new OpportunityLineItem();
        oppLine1.opportunityid = opp1.id;
        //not writeable  oppLine1.Name = opp1.Name;
        oppLine1.Quantity= Decimal.valueof('4');
        //not writeable  oppLine1.ProductCode='AEOLUSG3 - 2';
        oppLine1.Group__c='AEOLUSG3 - 2';
        oppLine1.UnitPrice=Decimal.valueof('8700.00');
        oppLine1.Product2Id= Pro1.id;
        oppLine1.Description ='Opportunity - Store Pick Up Inventory Test';
        oppLine1.PricebookEntryId=customPrice.id;
        oppLine.add(oppLine1);
        insert oppLine;
        
        Quote newQuote = new Quote();
		newQuote.Name = 'Test Quote';
        newQuote.OpportunityId = opp[0].Id;
        newQuote.Pickup_Fitment_Address__c = 'Bakersfield, CA';
        insert newQuote;
        
        
        QuoteLineItem qli= new QuoteLineItem();
        qli.QuoteId = newQuote.id;
        //not writeable  oppLine1.Name = opp1.Name;
        qli.Quantity= Decimal.valueof('4');
        //not writeable  oppLine1.ProductCode='AEOLUSG3 - 2';
        qli.Group__c='AEOLUSG3 - 2';
        qli.UnitPrice=Decimal.valueof('8700.00');
        qli.Product2Id= Pro1.id;
        qli.Description ='Quote - Store Pick Up Inventory Test';
        qli.PricebookEntryId=customPrice.id;
        insert qli;
        
        AcctSeedERP__Inventory_Balance__c inventory = new AcctSeedERP__Inventory_Balance__c();
        inventory.AcctSeedERP__Location__c = location.Id;
        inventory.Qty_Available__c = '10';
        inventory.AcctSeedERP__Warehouse__c = warHouse.Id;
        inventory.AcctSeedERP__Product__c = Pro1.id;
        insert inventory;
        
        
    }
    
    @isTest
    public static void test1(){
        Id oppId = [Select Id From Opportunity Limit 1][0].Id;
        Test.startTest();
        LocationWiseInverntoryController.getRelevantWarehouses(oppId);
        Test.stopTest();
    }
    
    @isTest
    public static void test2(){
        Id oppId = [Select Id From Quote Limit 1][0].Id;
        Test.startTest();
        LocationWiseInverntoryController.getRelevantWarehouses(oppId);
        Test.stopTest();
    }
}