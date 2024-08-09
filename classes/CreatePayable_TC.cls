@istest
public with sharing class CreatePayable_TC {
    @istest static void PositiveTest(){
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
         // #4
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
 
         AcctSeed__GL_Account__c cashGL = new AcctSeed__GL_Account__c(
            Name = '1000-Cash',                 
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Bank__c = true,
            AcctSeed__Sub_Type_1__c = 'Assets',
            AcctSeed__Sub_Type_2__c = 'Cash');
       insert CashGL;
       AcctSeed__GL_Account__c cashGL1 = new AcctSeed__GL_Account__c(
        Name = '2010-Vouchers Payable',                 
        AcctSeed__Active__c = true,
        AcctSeed__Type__c = 'Balance Sheet',
        AcctSeed__Bank__c = false,
        AcctSeed__Sub_Type_1__c = 'Assets',
        AcctSeed__Sub_Type_2__c = 'Cash');
   insert CashGL1;
 AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c(
            Name = 'Actual',
            AcctSeed__Type__c = 'Transactional',
            AcctSeed__Default_Bank_Account__c = CashGL.id,
            AcctSeed__Default_Billing_Format__c = PDFformats[0].Id,
            AcctSeed__Billing_Outstanding_Statement_Format__c = PDFformats[2].Id,
            AcctSeed__Billing_Activity_Statement_Format__c = PDFformats[3].Id,
            AcctSeed__Default_Purchase_Order_Format__c = PDFformats[4].Id,
            AcctSeed__Default_Packing_Slip_Format__c = PDFformats[5].Id);
    insert ledger;
 
    AcctSeed__Accounting_Period__c acctPeriod = new AcctSeed__Accounting_Period__c(
        Name = '2022-05',
        AcctSeed__Start_Date__c = Date.newinstance(2022, 05, 1),
        AcctSeed__End_Date__c = Date.newinstance(2022, 05, 31),
        AcctSeed__Status__c = 'Open');
insert acctPeriod;
         Account acct = new Account(Name = 'Test');
         insert acct;
 
 // insert 1 Product
         Product2 prod = new Product2(
                 Name = 'Sample',
                 Family='Base Product',
                 AcctSeed__Inventory_Type__c='Purchased',
                 AcctSeed__Expense_GL_Account__c=CashGL.id,
                 AcctSeed__Inventory_GL_Account__c=CashGL.id,
                 AcctSeed__Revenue_GL_Account__c=CashGL.id
         );
         insert prod;
         // START HERE
         // create Purchase Order
         AcctSeedERP__Purchase_Order__c po = new AcctSeedERP__Purchase_Order__c(
                 AcctSeedERP__Purchase_Order_Format__c = PDFformats[4].Id,
                 AcctSeedERP__Ledger__c = ledger.Id ,
                 AcctSeedERP__Vendor__c= acct.ID,
                 Custom_Duty_Vendor__c=acct.ID,
                 Local_Trucking__c=acct.ID,
                 Other_Vendor_1__c=acct.ID,
                 Other_Vendor_2__c=acct.ID,
                 Vendor_Custom_Clearing_Agent__c= acct.ID,
                 Vendor_Freight__c= acct.ID,
                 Total_PO_Value__c=100,
                 Total_Custom_Duty__c=300,
                 Total_Port_Charges_without_custom_duty__c=2000,
                 Total_Quantity__c=4000,
                 Total_Ocean_Freight__c=300,
                 Local_Transportation__c=2000,
                 Other_Charges_1__c=2000,
                 Other_Charges_2__c=2000
 


         );
         insert po;

         AcctSeedERP__Purchase_Order_Line__c pol = new AcctSeedERP__Purchase_Order_Line__c(
            AcctSeedERP__Purchase_Order__c = po.Id,
            AcctSeedERP__Quantity__c=1,
            AcctSeedERP__Unit_Price__c=100,
            AcctSeedERP__Product__c= prod.Id,       
            Purchase_Price__c=100

        );
    insert pol;
Id recordtypeId=Schema.SObjectType.AcctSeedERP__Purchase_Order__c.getRecordTypeInfosByName().get('Purchase Order Domestic').getRecordTypeId();
    AcctSeedERP__Purchase_Order__c po1 = new AcctSeedERP__Purchase_Order__c(
        AcctSeedERP__Purchase_Order_Format__c = PDFformats[4].Id,
        AcctSeedERP__Ledger__c = ledger.Id ,
        AcctSeedERP__Vendor__c= acct.ID,
        Custom_Duty_Vendor__c=acct.ID,
        Local_Trucking__c=acct.ID,
        Other_Vendor_1__c=acct.ID,
        Other_Vendor_2__c=acct.ID,
        Vendor_Custom_Clearing_Agent__c= acct.ID,
        Vendor_Freight__c= acct.ID,
        Total_PO_Value__c=100,
        Total_Custom_Duty__c=300,
        Total_Port_Charges_without_custom_duty__c=2000,
        Total_Quantity__c=4000,
        Total_Ocean_Freight__c=300,
        Local_Transportation__c=2000,
        Other_Charges_1__c=2000,
        Other_Charges_2__c=2000,
        RecordTypeId=recordtypeId



);
insert po1;

AcctSeedERP__Purchase_Order_Line__c pol1 = new AcctSeedERP__Purchase_Order_Line__c(
   AcctSeedERP__Purchase_Order__c = po1.Id,
   AcctSeedERP__Quantity__c=1,
   AcctSeedERP__Unit_Price__c=100,
   AcctSeedERP__Product__c= prod.Id,       
   Purchase_Price__c=100

);
insert pol1;


    AcctSeedERP__Purchase_Order__c getRecordInfo=CreatePayable.getRecordInfo(po.Id);
               try {
                string values='[{"ProductVendor":{"issueDate":"2022-05-15","dueDate":"2022-05-18","payeeReference":"Test"}},{"ShippingVendor":{"issueDate":"2022-05-15","dueDate":"2022-05-18","payeeReference":"res"}},{"CustomclearingAgent":{"issueDate":"2022-05-15","dueDate":"2022-05-18","payeeReference":"Tess"}},{"CustomDutyVendor":{"issueDate":"2022-05-15","dueDate":"2022-05-18","payeeReference":"wer"}},{"LocalTrucking":{"issueDate":"2022-05-15","dueDate":"2022-05-18","payeeReference":"wer1"}},{"OtherVendor_1":{"issueDate":"2022-05-15","dueDate":"2022-05-18","payeeReference":"wer1edf"}},{"OtherVendor_2":{"issueDate":"2022-05-15","dueDate":"2022-05-18","payeeReference":"wer1e"}}]';

                string str=  CreatePayable.createPayableAndPayableLines('productvendor,shippingcompany,customclearingagent,customDutyVendor,localtrucking,otherVendor_1,otherVendor_2',values,String.valueOf(po.id),String.valueOf(System.Today()),String.valueOf(System.Today()),'1234');

                               
               } catch (Exception Ex) {
                
               }
               
                
    }

    @istest static void Secondtest(){
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
        // #4
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

        AcctSeed__GL_Account__c cashGL = new AcctSeed__GL_Account__c(
           Name = '1000-Cash',                 
           AcctSeed__Active__c = true,
           AcctSeed__Type__c = 'Balance Sheet',
           AcctSeed__Bank__c = true,
           AcctSeed__Sub_Type_1__c = 'Assets',
           AcctSeed__Sub_Type_2__c = 'Cash');
      insert CashGL;
      AcctSeed__GL_Account__c cashGL1 = new AcctSeed__GL_Account__c(
       Name = '2010-Vouchers Payable',                 
       AcctSeed__Active__c = true,
       AcctSeed__Type__c = 'Balance Sheet',
       AcctSeed__Bank__c = false,
       AcctSeed__Sub_Type_1__c = 'Assets',
       AcctSeed__Sub_Type_2__c = 'Cash');
  insert CashGL1;
AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c(
           Name = 'Actual',
           AcctSeed__Type__c = 'Transactional',
           AcctSeed__Default_Bank_Account__c = CashGL.id,
           AcctSeed__Default_Billing_Format__c = PDFformats[0].Id,
           AcctSeed__Billing_Outstanding_Statement_Format__c = PDFformats[2].Id,
           AcctSeed__Billing_Activity_Statement_Format__c = PDFformats[3].Id,
           AcctSeed__Default_Purchase_Order_Format__c = PDFformats[4].Id,
           AcctSeed__Default_Packing_Slip_Format__c = PDFformats[5].Id);
   insert ledger;

   AcctSeed__Accounting_Period__c acctPeriod = new AcctSeed__Accounting_Period__c(
       Name = '2022-05',
       AcctSeed__Start_Date__c = Date.newinstance(2022, 05, 1),
       AcctSeed__End_Date__c = Date.newinstance(2022, 05, 31),
       AcctSeed__Status__c = 'Open');
insert acctPeriod;
        Account acct = new Account(Name = 'Test');
        insert acct;

// insert 1 Product
        Product2 prod = new Product2(
                Name = 'Sample',
                Family='Base Product',
                AcctSeed__Inventory_Type__c='Purchased',
                AcctSeed__Expense_GL_Account__c=CashGL.id,
                AcctSeed__Inventory_GL_Account__c=CashGL.id,
                AcctSeed__Revenue_GL_Account__c=CashGL.id
        );
        insert prod;
        // START HERE
        // create Purchase Order
      
Id recordtypeId=Schema.SObjectType.AcctSeedERP__Purchase_Order__c.getRecordTypeInfosByName().get('Purchase Order Domestic').getRecordTypeId();
   AcctSeedERP__Purchase_Order__c po1 = new AcctSeedERP__Purchase_Order__c(
       AcctSeedERP__Purchase_Order_Format__c = PDFformats[4].Id,
       AcctSeedERP__Ledger__c = ledger.Id ,
       AcctSeedERP__Vendor__c= acct.ID,
       Custom_Duty_Vendor__c=acct.ID,
       Local_Trucking__c=acct.ID,
       Other_Vendor_1__c=acct.ID,
       Other_Vendor_2__c=acct.ID,
       Vendor_Custom_Clearing_Agent__c= acct.ID,
       Vendor_Freight__c= acct.ID,
       Total_PO_Value__c=100,
       Total_Custom_Duty__c=300,
       Total_Port_Charges_without_custom_duty__c=2000,
       Total_Quantity__c=4000,
       Total_Ocean_Freight__c=300,
       Local_Transportation__c=2000,
       Other_Charges_1__c=2000,
      
       Other_Charges_2__c=2000,
       RecordTypeId=recordtypeId



);
insert po1;

AcctSeedERP__Purchase_Order_Line__c pol1 = new AcctSeedERP__Purchase_Order_Line__c(
  AcctSeedERP__Purchase_Order__c = po1.Id,
  AcctSeedERP__Quantity__c=1,
  AcctSeedERP__Unit_Price__c=100,
  AcctSeedERP__Product__c= prod.Id,      
  Total_Freight_1__c=3000,
  Other_Charges_1__c=5000,
  Other_Charges_2__c=6000, 
  Purchase_Price__c=100

);
insert pol1;



             
              
                string values='[{"ProductVendor":{"issueDate":"2022-05-15","dueDate":"2022-05-18","payeeReference":"Testd"}},{"ShippingVendor":{"issueDate":"2022-05-15","dueDate":"2022-05-18","payeeReference":"resD"}},{"OtherVendor_1":{"issueDate":"2022-05-15","dueDate":"2022-05-18","payeeReference":"wer1edfD"}},{"OtherVendor_2":{"issueDate":"2022-05-15","dueDate":"2022-05-18","payeeReference":"wer1eD"}}]';

                string str=  CreatePayable.createPayableAndPayableLines('productvendor,shippingcompany,otherVendor_1,otherVendor_2',values,String.valueOf(po1.id),String.valueOf(System.Today()),String.valueOf(System.Today()),'1234');


               
             
    }
}