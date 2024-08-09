@istest
public with sharing class MaestroBillingController_TC {
    static testmethod void  Positivetest(){
          // —— DATA PREPARATION ——
    // insert 1 Account
    Account acct = new Account(
                Name = 'Test Account');
        insert acct;
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

       AcctSeedERP__Warehouse__c warHouse = new AcctSeedERP__Warehouse__c();
       warHouse.City__c = 'Test City';
       warHouse.Country__c = 'Test Country';
       warHouse.State__c = 'Test State';
       warHouse.Street__c = 'Test Street';
       warHouse.Name = 'Test';
       warHouse.Avalara_Location_Code__c='1234';
       warHouse.Zip_Code__c = '202034';
       insert warHouse;

       Opportunity o = new Opportunity();
		
		o.Name = 'New Record';
		o.StageName = 'Posted';
        o.CloseDate= Date.today();
        insert o;

        OpportunityContactRole ocr = new OpportunityContactRole();
		ocr.ContactId = cont.Id;
		ocr.OpportunityId = o.Id;
		ocr.IsPrimary = TRUE;
		ocr.Role = 'Decision Maker';
		insert ocr;


        OpportunityContactRole ocr1 = new OpportunityContactRole();
			
		ocr1.ContactId = cont.Id;
		ocr1.OpportunityId = o.Id;
		ocr1.IsPrimary = FALSE;
		ocr1.Role = 'Receiving Contact';
		insert ocr1;


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
       Product2 FetProduct1 = new Product2(Name='FET BXCD1 Set of 2', isActive=true,StockKeepingUnit='ASD1 - FET',Section_Width__c='295',Aspect_Ratio__c='75',RIM__c='22.5',Family='FET');
         insert FetProduct1;
         
         PricebookEntry FETProduct1prciceEntry =new PricebookEntry(unitprice=0.01,Product2Id=FetProduct1.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                  isActive=true,UseStandardPrice = false);
         insert FETProduct1prciceEntry;

            AcctSeed__Accounting_Period__c acctPeriod = new AcctSeed__Accounting_Period__c(
                Name = '2023-04',
                AcctSeed__Start_Date__c = Date.newinstance(2023, 04, 1),
                AcctSeed__End_Date__c = Date.newinstance(2023, 04, 30),
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

        AcctSeed__Accounting_Settings__c settings = new AcctSeed__Accounting_Settings__c(
            Name = 'Test Settings',
            
            AcctSeed__Default_Ledger__c = ledger.Id,
            AcctSeed__Legacy_Default_Ledger__c = ledger.Id,
            AcctSeed__Enable_Product_Costing__c = true,
            AcctSeed__Display_Billable_Flag_in_Time_Card_Entry__c = true,
            AcctSeed__Enable_Billing_Period_Sensitive_Aging__c = true,
            AcctSeed__Enable_AP_Period_Sensitive_Aging__c = true,
            AcctSeed__Unapplied_Cash_GL_Account__c = glAccounts[1].Id,
            AcctSeed__AR_Control_GL_Account__c = glAccounts[2].Id,
            AcctSeed__Work_in_Process_GL_Account__c = glAccounts[3].Id,
            AcctSeed__AP_Control_GL_Account__c = glAccounts[4].Id,
            AcctSeed__Vouchers_Payable_GL_Account__c = glAccounts[5].Id,
            AcctSeed__Retained_Earnings_GL_Account__c = glAccounts[8].Id,
            AcctSeed__Current_Year_Earnings_GL_Account__c = glAccounts[9].Id,
            AcctSeed__Revenue_GL_Account__c = glAccounts[10].Id,
            AcctSeed__Inventory_Variance_GL_Account__c = glAccounts[13].Id,
            AcctSeed__Payment_Discount_GL_Account__c = glAccounts[14].Id
            );
            insert settings;
            
            // --- START HERE ---
            // Create Cash Receipt
            AcctSeed__Cash_Receipt__c CashR = new AcctSeed__Cash_Receipt__c(
            AcctSeed__Account__c = acct.Id,
            AcctSeed__Amount__c = 1,
            AcctSeed__Payment_Reference__c = '12345',
            AcctSeed__Bank_Account__c = glAccounts[0].Id, //'1000-Cash'
            AcctSeed__Credit_GL_Account__c = glAccounts[1].Id, //'1200-Accounts Receivable'
            AcctSeed__Accounting_Period__c = acctPeriod.id,
            AcctSeed__Ledger__c = ledger.id
            
            );
            
            insert CashR;

    // --- START HERE ---
    // Create BILLING RECORDS to post and unpost
        AcctSeed__Billing__c[] billings = new List <AcctSeed__Billing__c> ();

        billings.add(
                new AcctSeed__Billing__c(
                        AcctSeed__Billing_Cycle_Start_Date__c = System.today(),
                        AcctSeed__Billing_Cycle_End_Date__c = System.today() + 30,
                        AcctSeed__Date__c = System.today(),
                        AcctSeed__Customer__c = [Select Id From Account limit 1].Id,
                        AcctSeed__Status__c = 'Approved',
                        AcctSeed__Due_Date2__c = System.today() + 30,
                        AcctSeed__Ledger__c = ledger.Id,
                        AcctSeed__Billing_Format__c = PDFformats[0].Id,
                        AcctSeed__Accounting_Period__c = [Select Id From AcctSeed__Accounting_Period__c limit 1].Id,
                        AcctSeed__Opportunity__c=o.id
                )
        );

        billings.add(
                new AcctSeed__Billing__c(
                        AcctSeed__Billing_Cycle_Start_Date__c = System.today(),
                        AcctSeed__Billing_Cycle_End_Date__c = System.today() + 30,
                        AcctSeed__Date__c = System.today(),
                        AcctSeed__Customer__c = [Select Id From Account limit 1].Id,
                        AcctSeed__Status__c = 'Approved',
                        AcctSeed__Due_Date2__c = System.today() + 30,
                        AcctSeed__Ledger__c = ledger.Id,
                        AcctSeed__Billing_Format__c = PDFformats[0].Id,
                        AcctSeed__Accounting_Period__c = [Select Id From AcctSeed__Accounting_Period__c limit 1].Id,
                        AcctSeed__Opportunity__c=o.id
                )
        );

        insert billings;

        System.assertEquals(1, [Select count() FROM AcctSeed__Billing__c WHERE Id = :billings[0].Id]);


    // Create billing line records to post and unpost
        AcctSeed__Billing_Line__c[] bLines = new List <AcctSeed__Billing_Line__c> ();

        for (AcctSeed__Billing__c bill : billings) {
            AcctSeed__Billing_Line__c objBillingLine = new AcctSeed__Billing_Line__c();
            objBillingLine.AcctSeed__Billing__c = bill.id;
            objBillingLine.AcctSeed__Date__c = System.today();
            objBillingLine.AcctSeed__Rate__c = 25;
            objBillingLine.AcctSeed__Hours_Units__c = 1;
            objBillingLine.AcctSeed__Revenue_GL_Account__c = glAccounts[1].id;
            objBillingLine.AcctSeed__Product__c=prostateFee.Id;
            bLines.add(objBillingLine);

            objBillingLine = new AcctSeed__Billing_Line__c();
            objBillingLine.AcctSeed__Billing__c = bill.id;
            objBillingLine.AcctSeed__Date__c = System.today();
            objBillingLine.AcctSeed__Rate__c = 25;
            objBillingLine.AcctSeed__Hours_Units__c = 2;
            objBillingLine.AcctSeed__Revenue_GL_Account__c = glAccounts[1].id;
            objBillingLine.AcctSeed__Product__c=FetProduct1.Id;
            bLines.add(objBillingLine);
        }

        insert bLines;
        Product2 prod = new Product2(
            Name = 'Sample'
    );
    insert prod;

// --- START HERE ---

    List<AcctSeedERP__Sales_Order__c> salesOrders = new List<AcctSeedERP__Sales_Order__c>();
    salesOrders.add(
            new AcctSeedERP__Sales_Order__c(
                    AcctSeedERP__Customer__c = acct.Id,
                    AcctSeedERP__Ledger__c = ledger.Id,
                    Delivery_Type__c ='Store Pick up',
                    Warehouse_Location__c=warHouse.Id
            )
    );

    insert salesOrders;

    System.assertEquals(1, [Select count() FROM AcctSeedERP__Sales_Order__c WHERE Id = :salesOrders[0].Id]);

    AcctSeedERP__Sales_Order_Line__c sol = new AcctSeedERP__Sales_Order_Line__c(
            AcctSeedERP__Product__c = prod.id,
            AcctSeedERP__Quantity_Ordered__c = 1,
            AcctSeedERP__Sales_Order__c = salesOrders[0].id
    );

    insert sol;
        PageReference testPage = Page.MaestroBilling; 
       Test.setCurrentPage(testPage);
       testPage.getParameters().put('Id', billings[0].Id);
    
       MaestroBillingController controller= new MaestroBillingController();
    }
}