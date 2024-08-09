@isTest
public class ContentDocumentLink_TestClass {
	
    static testMethod void testMethodContentDocumentLink(){
        Account accountObj = new Account(Name='test account');
        insert accountObj;
    	
        Pricebook2 Price1 =new pricebook2();
        Price1.Name='test';
        insert Price1;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        Account_Adddress__c add= new Account_Adddress__c();
        add.Shipping_City__c='test';
        add.Shipping_Country__c='test';
        add.Shipping_State_Province__c='test';
        add.Shipping_Street__c='test';
        add.Shipping_Zip_Postal_Code__c='test';
        add.Account__c=accountObj.Id;
        add.IsAddressFromCustomUI__c = true;
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
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Opportunity opp1 = new Opportunity();
        opp1.accountid=accountObj.id;
        opp1.name=accountObj.Name;
        opp1.Pricebook2Id=pricebookId;
        opp1.Looking_for__c='Service';
        opp1.Looking_for__c='Store Pick up';
        Opp1.StageName='negotiating';
        opp1.CloseDate=system.today();
        opp1.Looking_for__c='Tire';
        opp1.Delivery_Type__c='Store Pick Up';
        opp1.Ship_to_Address__c=add.Id;
        opp1.Ship_From_Address__c=warHouse.Id;
        opp1.Warehouse_Location__c=warHouse.Id;
        insert opp1;
        
        Product2 Pronew1 = new Product2();
        Pronew1.Name=accountObj.name;
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
        insert Pronew1;
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = pronew1.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = pronew1.Id, UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
        List<OpportunityLineItem> listOfOpportunityLineItem = new List<OpportunityLineItem>();
        /*OpportunityLineItem oppLine1= new OpportunityLineItem();
        oppLine1.opportunityid = opp1.id;
        oppLine1.Quantity= Decimal.valueof('4');
        oppLine1.Group__c='AEOLUSG3 - 2';
        oppLine1.UnitPrice=Decimal.valueof('8700.00');
        oppLine1.Product2Id= pronew1.id;
        oppLine1.Description ='Opportunity - Store Pick Up Inventory Test';
        oppLine1.PricebookEntryId=customPrice.id;
        listOfOpportunityLineItem.add(oppLine1);*/
        
        OpportunityLineItem oppLine2= new OpportunityLineItem();
        oppLine2.opportunityid = opp1.id;
        oppLine2.Quantity= Decimal.valueof('4');
        oppLine2.Group__c='AEOLUSG3 - 2';
        oppLine2.UnitPrice=Decimal.valueof('8700.00');
        oppLine2.Product2Id= pronew1.id;
        oppLine2.Description ='Opportunity - Store Pick Up Inventory Test';
        oppLine2.PricebookEntryId=standardPrice.id;
        listOfOpportunityLineItem.add(oppLine2);
        insert listOfOpportunityLineItem;
        
        Quote newQuote = new Quote();
        newQuote.Name = 'Test Quote';
        newQuote.OpportunityId = opp1.Id;
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
        qli.PricebookEntryId=standardPrice.Id;
        insert qli;
        
        AcctSeed__GL_Account__c glAccounts= new AcctSeed__GL_Account__c(Name = '1000-Cash',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Bank__c = true,
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Cash');
        insert glAccounts;
        
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
            
        AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c(Name = 'Actual',
            AcctSeed__Type__c = 'Transactional',
            AcctSeed__Default_Bank_Account__c = glAccounts.id,
            AcctSeed__Default_Billing_Format__c = PDFformats[0].Id,
            AcctSeed__Billing_Outstanding_Statement_Format__c = PDFformats[2].Id,
            AcctSeed__Billing_Activity_Statement_Format__c = PDFformats[3].Id,
            AcctSeed__Default_Purchase_Order_Format__c = PDFformats[4].Id,
            AcctSeed__Default_Packing_Slip_Format__c = PDFformats[5].Id);
        insert ledger;
        
        AcctSeed__Accounting_Period__c acctPeriod = new AcctSeed__Accounting_Period__c(
            Name = '1991-10',
            AcctSeed__Start_Date__c = Date.newinstance(1991, 10, 1),
            AcctSeed__End_Date__c = Date.newinstance(1991, 10, 31),
            AcctSeed__Status__c = 'Open');
        insert acctPeriod;
        
        AcctSeed__Billing__c billing = new AcctSeed__Billing__c(
            AcctSeed__Billing_Cycle_Start_Date__c = System.today(),
            AcctSeed__Billing_Cycle_End_Date__c = System.today() + 30,
            AcctSeed__Date__c = System.today(),
            AcctSeed__Customer__c = accountObj.Id,
            AcctSeed__Status__c = 'Approved',
            AcctSeed__Due_Date2__c = System.today() + 30,
            AcctSeed__Ledger__c = ledger.Id,
            AcctSeed__Billing_Format__c = PDFformats[0].Id,
            AcctSeed__Accounting_Period__c = acctPeriod.Id,
            AcctSeed__Opportunity__c = opp1.Id,   
            Ship_to_Address__c=add.Id,
            Ship_From_Address__c=warHouse.Id,
          Delivery_Type__c='Door Delivery'
        );
        insert billing;
        
        ContentVersion contentVersion = new ContentVersion(Title = 'test',PathOnClient = 'test.jpg',VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
    	insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
    
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = billing.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        insert cdl;
        
        
    }
}