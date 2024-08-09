@IsTest
public class CalculateTaxTest {
    @TestSetup
    Public Static Void testSetup(){
        
        // Custom Setting for Avalara Mock Callout
        Avalara_API__c orgDefaultValues = new Avalara_API__c(
            Account_Id__c = '4C701AA1FBEB6288',
            Auth_Token__c = '2006745472',
            Endpoint__c = 'https://sandbox-rest.avatax.com/api/v2/transactions/createoradjust'
        );
        insert orgDefaultValues;
        
        
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

        AcctSeedERP__Warehouse__c warHouse = new AcctSeedERP__Warehouse__c();
        warHouse.City__c = 'Test City';
        warHouse.Country__c = 'Test Country';
        warHouse.State__c = 'Test State';
        warHouse.Street__c = 'Test Street';
        warHouse.Name = 'Test';
        warHouse.Avalara_Location_Code__c='1234';
        warHouse.Zip_Code__c = '202034';
        insert warHouse;
        
        Account_Adddress__c add= new Account_Adddress__c();
        add.Shipping_City__c='test';
        add.Shipping_Country__c='test';
        add.Shipping_State_Province__c='test';
        add.Shipping_Street__c='test';
        add.Shipping_Zip_Postal_Code__c='test';
        add.Account__c=Acc[0].Id;
        insert add;
        
        List<Product2> Pronew = new List<Product2>();
        Product2 Pronew1 = new Product2();
        // Pro1.id=Acc1.id;
        Pronew1.Name=Acc1.name;
        Pronew1.PATTERN__c='HIGHWAY D12';
        Pronew1.RIM__c='22.5';
        Pronew1.Tyre_Type__c='New';
        Pronew1.WEIGHT_IN_LBS__c=Decimal.valueOf('107.00');
        Pronew1.Description='test';
        Pronew1.Width_Inches__c='25.5';
        Pronew1.Tread_Width_In_Inches__c=25.5;
        
        Pronew1.Tax_Code__c='PA3000301';
        Pronew1.StockKeepingUnit='AEOLUSG2';
        Pronew1.Product_Type__c='Base Product';
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
        Pro1.Tread_Width_In_Inches__c=25.5;
        Pro1.Tax_Code__c='PA3000301';
        Pro1.StockKeepingUnit='AEOLUSG3 -2';
        Pro1.Product_Type__c='Kit Product';
        Pro1.Studded__c='False';
        Pro1.Product_Master__c= Pronew1.id;
        Pro1.Product_Master__c= Pronew1.id;
        Pro.add(Pro1);
        insert Pro;
        
          //Record for account address
        Account_Adddress__c abc = New Account_Adddress__c();
            abc.Name = 'a1';
            abc.Billing_City__c = 'Jakarta';
            abc.Billing_State_Province__c = 'Indonesia';
            abc.Billing_Country__c = 'India';
            abc.Billing_Street__c = 'C-45, Downtown Extension';
        insert abc;
           
            
        
        
        Product2 prostateFee = new Product2(Name='State Fee', isActive=true,StockKeepingUnit='ASDFee',Section_Width__c='295',Aspect_Ratio__c='75',RIM__c='22.5',Family='Service Product');
        insert prostateFee;
        
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
        
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prostateFee.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice2;
        
        PricebookEntry stateFeeEntry = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prostateFee.Id, UnitPrice = 12000, IsActive = true);
        insert stateFeeEntry;
        
        
        
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
        opp1.Looking_for__c='Service';
        opp1.Looking_for__c='Store Pick up';
        Opp1.StageName='negotiating';
        opp1.CloseDate=system.today();
        opp1.Looking_for__c='Tire';
        opp1.Delivery_Type__c='Door Delivery';
        opp1.Ship_to_Address__c=add.Id;
        opp1.Ship_From_Address__c=warHouse.Id;
        Opp.add(opp1);

        Opportunity opp2 = new Opportunity();
        opp2.accountid=acc1.id;
        opp2.name=Acc1.Name;
        opp2.Pricebook2Id=customPB.id;
        opp2.Looking_for__c='Service';
        opp2.Looking_for__c='Store Pick up';
        Opp2.StageName='negotiating';
        opp2.CloseDate=system.today();
        opp2.Looking_for__c='Tire';
        opp2.Delivery_Type__c='Store Pick Up';
        opp2.Ship_to_Address__c=add.Id;
        opp2.Warehouse_Location__c=warHouse.Id;
        Opp.add(opp2);

        insert opp;
        
        
        List<OpportunityLineItem> OppLine = new List<OpportunityLineItem>();
        OpportunityLineItem oppLine1= new OpportunityLineItem();
        oppLine1.opportunityid = opp[0].id;
        oppLine1.Quantity= Decimal.valueof('4');
        oppLine1.Group__c='AEOLUSG3 - 2';
        oppLine1.UnitPrice=Decimal.valueof('8700.00');
        oppLine1.Product2Id= pronew1.id;
        oppLine1.Description ='Opportunity - Store Pick Up Inventory Test';
        oppLine1.PricebookEntryId=customPrice.id;
        oppLine.add(oppLine1);

        OpportunityLineItem oppLine2= new OpportunityLineItem();
        oppLine2.opportunityid = opp[1].id;
        oppLine2.Quantity= Decimal.valueof('4');
        oppLine2.Group__c='AEOLUSG3 - 2';
        oppLine2.UnitPrice=Decimal.valueof('8700.00');
        oppLine2.Product2Id= pronew1.id;
        oppLine2.Description ='Opportunity - Store Pick Up Inventory Test';
        oppLine2.PricebookEntryId=customPrice.id;
        oppLine.add(oppLine2);
        insert oppLine;
        
        
        Quote newQuote = new Quote();
        newQuote.Name = 'Test Quote';
        newQuote.OpportunityId = opp[0].Id;
        newQuote.Pickup_Fitment_Address__c = 'Bakersfield, CA';
        newQuote.Delivery_Type__c='Door Delivery';
        newQuote.Ship_to_Address__c=add.Id;
        newQuote.Ship_From_Address__c=warHouse.Id;
        insert newQuote;
        
        
        QuoteLineItem qli= new QuoteLineItem();
        qli.QuoteId = newQuote.id;
        qli.Quantity= Decimal.valueof('4');
      
        qli.UnitPrice=Decimal.valueof('8700.00');
        qli.Product2Id=pronew1.id;
        qli.Description ='Quote - Store Pick Up Inventory Test';
       
        qli.PricebookEntryId=customPrice.id;
        
        insert qli;
        
        Quote newQuote1 = new Quote();
        newQuote1.Name = 'Test Quote';
        newQuote1.OpportunityId = opp[0].Id;
        newQuote1.Pickup_Fitment_Address__c = 'Bakersfield, CA';
        newQuote1.Delivery_Type__c='Store Pick up';
        newQuote1.Ship_to_Address__c=add.Id;
        newQuote1.Ship_From_Address__c=warHouse.Id;
        newQuote1.Warehouse_Location__c=warHouse.Id;
        insert newQuote1;

        QuoteLineItem qli1= new QuoteLineItem();
        qli1.QuoteId = newQuote1.id;
        qli1.Quantity= Decimal.valueof('4');
      
        qli1.UnitPrice=Decimal.valueof('8700.00');
        qli1.Product2Id=Pro1.id;
        qli1.Description ='Quote - Store Pick Up Inventory Test';
       
        qli1.PricebookEntryId=customPrice.id;
        
        insert qli1;

        AcctSeed__Accounting_Period__c acctPeriod = new AcctSeed__Accounting_Period__c(
            Name = '1991-10',
            AcctSeed__Start_Date__c = Date.newinstance(1991, 10, 1),
            AcctSeed__End_Date__c = Date.newinstance(1991, 10, 31),
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
        
        List<AcctSeedERP__Sales_Order__c> salesOrders = new List<AcctSeedERP__Sales_Order__c>();
        salesOrders.add(
            new AcctSeedERP__Sales_Order__c(
                AcctSeedERP__Customer__c = acc1.Id,
                AcctSeedERP__Ledger__c = ledger.Id,
                AcctSeedERP__Opportunity__c = opp[0].Id,
                Ship_to_Address__c=add.Id,
                Ship_From_Address__c=warHouse.Id,
                Delivery_Type__c='Door Delivery'
            )
        );
        
        insert salesOrders;
        
        AcctSeedERP__Sales_Order_Line__c sol = new AcctSeedERP__Sales_Order_Line__c(
            AcctSeedERP__Product__c = Pro1.id,
            AcctSeedERP__Quantity_Ordered__c = 1,
            AcctSeedERP__Sales_Order__c = salesOrders[0].id,
            Group__c='12345'
        );
        
        insert sol;
        
        AcctSeed__Billing__c billing = new AcctSeed__Billing__c(
            AcctSeed__Billing_Cycle_Start_Date__c = System.today(),
            AcctSeed__Billing_Cycle_End_Date__c = System.today() + 30,
            AcctSeed__Date__c = System.today(),
            AcctSeed__Customer__c = [Select Id From Account limit 1].Id,
            AcctSeed__Status__c = 'Approved',
            AcctSeed__Due_Date2__c = System.today() + 30,
            AcctSeed__Ledger__c = ledger.Id,
            AcctSeed__Billing_Format__c = PDFformats[0].Id,
            AcctSeed__Accounting_Period__c = [Select Id From AcctSeed__Accounting_Period__c limit 1].Id,
            AcctSeed__Opportunity__c = opp[0].Id,   
            Ship_to_Address__c=add.Id,
            Ship_From_Address__c=warHouse.Id,
          Delivery_Type__c='Door Delivery'
        );
        insert billing;
        
        AcctSeed__Billing_Line__c objBillingLine = new AcctSeed__Billing_Line__c();
        objBillingLine.AcctSeed__Billing__c = billing.id;
        objBillingLine.AcctSeed__Date__c = System.today();
        objBillingLine.AcctSeed__Rate__c = 25;
        objBillingLine.AcctSeed__Hours_Units__c = 1;
        objBillingLine.AcctSeed__Revenue_GL_Account__c = glAccounts[1].id;
        objBillingLine.AcctSeed__Product__c=Pro1.Id;
        insert objBillingLine;

        AcctSeed__Billing__c billing1 = new AcctSeed__Billing__c(
            AcctSeed__Billing_Cycle_Start_Date__c = System.today(),
            AcctSeed__Billing_Cycle_End_Date__c = System.today() + 30,
            AcctSeed__Date__c = System.today(),
            AcctSeed__Customer__c = [Select Id From Account limit 1].Id,
            AcctSeed__Status__c = 'Approved',
            AcctSeed__Due_Date2__c = System.today() + 30,
            AcctSeed__Ledger__c = ledger.Id,
            AcctSeed__Billing_Format__c = PDFformats[0].Id,
            AcctSeed__Accounting_Period__c = [Select Id From AcctSeed__Accounting_Period__c limit 1].Id,
            AcctSeed__Opportunity__c = opp[0].Id,   
            Ship_to_Address__c=add.Id,
            Ship_From_Address__c=warHouse.Id,
            Warehouse_Location__c=warHouse.Id,
            Delivery_Type__c='Store Pick up'
        );
        insert billing1;
        
        AcctSeed__Billing_Line__c objBillingLine1 = new AcctSeed__Billing_Line__c();
        objBillingLine1.AcctSeed__Billing__c = billing1.id;
        objBillingLine1.AcctSeed__Date__c = System.today();
        objBillingLine1.AcctSeed__Rate__c = 25;
        objBillingLine1.AcctSeed__Hours_Units__c = 1;
        objBillingLine1.AcctSeed__Revenue_GL_Account__c = glAccounts[1].id;
        objBillingLine1.AcctSeed__Product__c=Pro1.Id;
        insert objBillingLine1;
        
        
    }
    
    @isTest
    Public Static Void CalculateTaxOpportunity(){
        Opportunity opp = [Select Id From Opportunity  Limit 1];
        OpportunityLineItem lineItem = [Select Id From OpportunityLineItem Where OpportunityId =: opp.Id Limit 1];
        avalaraMockResponse mock = new avalaraMockResponse(opp.Id, lineItem.Id);
        Test.setMock(HttpCalloutMock.class, mock);
        test.startTest();
        AvalaraHttpCallOut callout = new AvalaraHttpCallOut();
       // try {
            CalculateTax.calculateTax(opp.Id, 'Opportunity');
       // } catch (Exception Ex) {
            
       // }
     
        test.stopTest();
    }
    @isTest
    Public Static Void CalculateTaxOpportunity1(){
        List<Opportunity> opp = [Select Id From Opportunity];
        OpportunityLineItem lineItem = [Select Id From OpportunityLineItem Where OpportunityId =: opp[1].Id Limit 1];
        avalaraMockResponse mock = new avalaraMockResponse(opp[1].Id, lineItem.Id);
        Test.setMock(HttpCalloutMock.class, mock);
        test.startTest();
        AvalaraHttpCallOut callout = new AvalaraHttpCallOut();
       // try {
            CalculateTax.calculateTax(opp[1].Id, 'Opportunity');
       // } catch (Exception Ex) {
            
       // }
     
        test.stopTest();
    }
    
    //Test Tax Calculation on Quote
    @isTest
    Public Static Void CalculateTaxQuote(){
        Quote qt = [Select Id From Quote  Limit 1];
        QuoteLineItem lineItem = [Select Id From QuoteLineItem Where QuoteId =: qt.Id Limit 1];
        avalaraMockResponse mock = new avalaraMockResponse(qt.Id, lineItem.Id);
        Test.setMock(HttpCalloutMock.class, mock);
        test.startTest();
        AvalaraHttpCallOut callout = new AvalaraHttpCallOut();
        CalculateTax.calculateTax(qt.Id, 'Quote');
        test.stopTest();
    }
    @isTest
    Public Static Void CalculateTaxQuote1(){
        List<Quote> qt = [Select Id From Quote];
        QuoteLineItem lineItem = [Select Id From QuoteLineItem Where QuoteId =: qt[1].Id Limit 1];
        avalaraMockResponse mock = new avalaraMockResponse(qt[1].Id, lineItem.Id);
        Test.setMock(HttpCalloutMock.class, mock);
        test.startTest();
        AvalaraHttpCallOut callout = new AvalaraHttpCallOut();
        CalculateTax.calculateTax(qt[1].Id, 'Quote');
        test.stopTest();
    }
    
    //Test Tax Calculation on Sales Order
    @isTest
    Public Static Void CalculateTaxSalesOrder(){
        AcctSeedERP__Sales_Order__c so = [Select Id From AcctSeedERP__Sales_Order__c Limit 1];
        AcctSeedERP__Sales_Order_Line__c lineItem = [Select Id From AcctSeedERP__Sales_Order_Line__c Where AcctSeedERP__Sales_Order__c =: so.id Limit 1];
        avalaraMockResponse mock = new avalaraMockResponse(so.Id, lineItem.Id);
        Test.setMock(HttpCalloutMock.class, mock);
        test.startTest();
        AvalaraHttpCallOut callout = new AvalaraHttpCallOut();
        CalculateTax.calculateTax(so.Id, 'AcctSeedERP__Sales_Order__c');
        test.stopTest();
    }
    
    //Test Tax Calculation on Billing
    @isTest
    Public Static Void CalculateTaxBilling(){
        AcctSeed__Billing__c bill = [Select Id From AcctSeed__Billing__c  Limit 1];
        AcctSeed__Billing_Line__c lineItem = [Select Id From AcctSeed__Billing_Line__c Where AcctSeed__Billing__c =: bill.Id Limit 1];
        avalaraMockResponse mock = new avalaraMockResponse(bill.Id, lineItem.Id);
        Test.setMock(HttpCalloutMock.class, mock);
        test.startTest();
        AvalaraHttpCallOut callout = new AvalaraHttpCallOut();
        
         CalculateTax.calculateTax(bill.Id, 'AcctSeed__Billing__c');
       
        test.stopTest();
    }
    @isTest
    Public Static Void CalculateTaxBilling1(){
        LIST<AcctSeed__Billing__c> bill = [Select Id From AcctSeed__Billing__c];
        AcctSeed__Billing_Line__c lineItem = [Select Id From AcctSeed__Billing_Line__c Where AcctSeed__Billing__c =: bill[1].Id Limit 1];
        avalaraMockResponse mock = new avalaraMockResponse(bill[1].Id, lineItem.Id);
        Test.setMock(HttpCalloutMock.class, mock);
        test.startTest();
        AvalaraHttpCallOut callout = new AvalaraHttpCallOut();
        
         CalculateTax.calculateTax(bill[1].Id, 'AcctSeed__Billing__c');
       
        test.stopTest();
    }
}