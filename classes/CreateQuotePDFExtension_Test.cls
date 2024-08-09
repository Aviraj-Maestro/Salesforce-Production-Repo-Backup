@isTest
public class CreateQuotePDFExtension_Test{

    @testSetup static void createSampleData(){
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
        add.IsAddressFromCustomUI__c=true;
        insert add;
        
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
        Pronew1.Product_Category__c='Tires';
        Pronew1.Tax_Code__c='PA3000301';
        Pronew1.StockKeepingUnit='AEOLUSG2';
        Pronew1.Product_Type__c='Base Product';
        Pronew1.Studded__c='False';
        insert Pronew1;
        
        
        Product2 Pro1 = new Product2();
        Pro1.Name='FET-'+Acc1.name;
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
        insert Pro1;
        
        //Record for account address
        Account_Adddress__c abc = New Account_Adddress__c();
        abc.Name = 'a1';
        abc.Billing_City__c = 'Jakarta';
        abc.Billing_State_Province__c = 'Indonesia';
        abc.Billing_Country__c = 'India';
        abc.Billing_Street__c = 'C-45, Downtown Extension';
        abc.IsAddressFromCustomUI__c=true;
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
        AccAd1.IsAddressFromCustomUI__c=true;
        AccAd.add(AccAd1);
        Insert AccAd;
        
        Contact con = new Contact();
        con.LastName = 'Last';
        con.AccountId= Acc[0].Id;
        con.MailingCity = 'Test City';
        con.MailingCountry = 'India';
        con.MailingPostalCode = '234234';
        con.MailingStreet = 'Test Streeet';
        con.MailingState = 'Delhi';
        insert con;
        
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
        opp1.Ship_to_Contact__c=con.Id;
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
        opp2.Ship_to_Contact__c=con.Id;
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
        oppLine2.Product2Id= Pro1.id;
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
        newQuote.Quote_Date__c=system.today();
        insert newQuote;
        List<QuoteLineItem> listOfQLI= new List<QuoteLineItem>();
        
        QuoteLineItem qli= new QuoteLineItem();
        qli.QuoteId = newQuote.id;
        qli.Quantity= Decimal.valueof('4');
      
        qli.UnitPrice=Decimal.valueof('8700.00');
        qli.Product2Id=pronew1.id;
        qli.Description ='Quote - Store Pick Up Inventory Test';
       	qli.Group__c = '123';
        qli.PricebookEntryId=customPrice.id;
        listOfQLI.add(qli);
        
        QuoteLineItem qli2= new QuoteLineItem();
        qli2.QuoteId = newQuote.id;
        qli2.Quantity= Decimal.valueof('4');
      
        qli2.UnitPrice=Decimal.valueof('8700.00');
        qli2.Product2Id=pro1.id;
        qli2.Description ='Quote - Store Pick Up Inventory Test';
       	qli2.Group__c = '123';
        qli2.PricebookEntryId=customPrice.id;
        listOfQLI.add(qli2);
        insert listOfQLI;
    
    }
    
    @isTest static void quotePDFSuccessTest(){
        Quote quoteObj = [select id from Quote limit 1];
        ApexPages.CurrentPage().getParameters().put('Id',quoteObj.Id);
        CreateQuotePDFExtension createQuotePDFExtensionObject = new CreateQuotePDFExtension();
        createQuotePDFExtensionObject.createPDFContent();
        
        
    }

}