public with sharing class PostAvalaraAndCreateJEQueable implements Queueable, Database.AllowsCallouts{
    AcctSeed__Billing__c acctBilling= new AcctSeed__Billing__c();
    public String accountId;
    public String authToken;
    public String BaseEndpoint;
    public string commitOrUncommit;
    public PostAvalaraAndCreateJEQueable(AcctSeed__Billing__c billing,string commitOrUncommit) {
        this.acctBilling = billing;
        Avalara_API__c avalApi = Avalara_API__c.getInstance();
        this.accountId = avalApi.Account_Id__c;
        this.authToken = avalApi.Auth_Token__c;
        this.BaseEndpoint= avalApi.Base_End_Point__c;
        this.commitOrUncommit=commitOrUncommit;
      
    }
    public void execute(QueueableContext qc) {
        try{
                HttpResponse response;
                Http http;
                HttpRequest req;          
                if(this.commitOrUncommit=='commit'){

                     response = new HttpResponse();

                     http = new Http();
                     req = new HttpRequest();               
                    String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(accountId +':'+authToken));
                    req.setEndpoint(this.BaseEndpoint+'/companies/MAE-BAKERSFEILD/transactions/Billing - '+this.acctBilling.Name+'/commit');

                    req.setMethod('POST');
                    req.setHeader('Content-Type','application/json');
                    req.setHeader('Authorization',authorizationHeader);
                    req.setBody('{"commit":true}');
                    response = http.send(req);
                    if(response.getStatusCode() == 201 || response.getStatusCode() == 200){
                        List<AcctSeed__Journal_Entry_Line__c> jrnlEntryLinesList = new List<AcctSeed__Journal_Entry_Line__c>();
                        this.acctBilling=[Select Id,Name, AcctSeed__Sales_Tax3__c,AcctSeed__Accounting_Period__c,AcctSeed__Ledger__c,AcctSeed__Customer__c from  AcctSeed__Billing__c where id=:this.acctBilling.Id];
                        AcctSeed__GL_Account__c acctReceivable=[select id from AcctSeed__GL_Account__c where Name='50-Accounts Receivable(A/R)'];
                        AcctSeed__GL_Account__c acctSalesTaxPayable=[select id from AcctSeed__GL_Account__c where Name='67-Sales Tax Payable'];
                        AcctSeed__Journal_Entry__c[] journalEntries = new List <AcctSeed__Journal_Entry__c>();

                        AcctSeed__Journal_Entry__c jrnlEntryRec = new AcctSeed__Journal_Entry__c();
                        jrnlEntryRec.Name = this.acctBilling.Name;
                        jrnlEntryRec.AcctSeed__Journal_Date__c = System.Today();
                    // jrnlEntryRec.AcctSeed__Reference__c = salesRec.Salesforce_Project__r.Name+' - '+salesRec.Name+' - Commission Gross up';
                        jrnlEntryRec.AcctSeed__Status__c = 'Approved';

                        jrnlEntryRec.AcctSeed__Ledger__c=this.acctBilling.AcctSeed__Ledger__c;
                        jrnlEntryRec.Billing__c = this.acctBilling.Id;
                        jrnlEntryRec.AcctSeed__Accounting_Period__c = this.acctBilling.AcctSeed__Accounting_Period__c;
                        journalEntries.add(jrnlEntryRec);

                        insert journalEntries;
                        for (AcctSeed__Journal_Entry__c journalEntry : journalEntries) {
                            AcctSeed__Journal_Entry_Line__c firstJrnlEntrylineRec = new AcctSeed__Journal_Entry_Line__c();
                            firstJrnlEntrylineRec.AcctSeed__Journal_Entry__c=jrnlEntryRec.Id;
                            firstJrnlEntrylineRec.AcctSeed__Date__c = system.today();
                            firstJrnlEntrylineRec.AcctSeed__GL_Account__c = acctReceivable.Id;
                            firstJrnlEntrylineRec.AcctSeed__Debit__c = this.acctBilling.AcctSeed__Sales_Tax3__c;
                            firstJrnlEntrylineRec.AcctSeed__Account__c = this.acctBilling.AcctSeed__Customer__c;
                            jrnlEntryLinesList.add(firstJrnlEntrylineRec);

                            AcctSeed__Journal_Entry_Line__c secondjrnlEntrylineRec = new AcctSeed__Journal_Entry_Line__c();
                            secondjrnlEntrylineRec.AcctSeed__Journal_Entry__c=jrnlEntryRec.Id;
                            secondjrnlEntrylineRec.AcctSeed__Date__c = system.today();
                            secondjrnlEntrylineRec.AcctSeed__GL_Account__c = acctSalesTaxPayable.Id;
                            secondjrnlEntrylineRec.AcctSeed__Credit__c = this.acctBilling.AcctSeed__Sales_Tax3__c;
                            secondjrnlEntrylineRec.AcctSeed__Account__c = this.acctBilling.AcctSeed__Customer__c;
                            jrnlEntryLinesList.add(secondjrnlEntrylineRec);
                        }
                        insert jrnlEntryLinesList;

                        AcctSeed.PostResult[] postResults = AcctSeed.JournalEntryPostService.postJournalEntries(journalEntries);
                    }
                }else if(this.commitOrUncommit=='uncommit'){
                    AcctSeed__Journal_Entry__c[] journalEntries = [Select Id from AcctSeed__Journal_Entry__c where Billing__c=:this.acctBilling.Id];
                    AcctSeed.PostResult[] unpostResults = AcctSeed.JournalEntryPostService.unpostJournalEntries(journalEntries);
                

                    for (AcctSeed.PostResult theResult : unpostResults) {
                        if (theResult.isSuccess) {
                            calloutforUncommit(theResult.id,this.accountId,this.authToken,this.acctBilling.Name,this.BaseEndpoint);
                            
                        } 

                    }
                }
            }catch(Exception Ex){

            }
        }

        @future(callout = true)
        public static void calloutforUncommit(Id journalEntryId,String accountId,String authToken,String billingName,string baseEndPoint){
            HttpResponse response = new HttpResponse();
            Http http = new Http();
            HttpRequest req = new HttpRequest();     
                String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(accountId +':'+authToken));
                req.setEndpoint(baseEndPoint+'/companies/MAE-BAKERSFEILD/transactions/Billing - '+billingName+'/uncommit?documentType=1');

                req.setMethod('POST');
                req.setHeader('Content-Type','application/json');
                req.setHeader('Authorization',authorizationHeader);
                        
                response = http.send(req);
                if(response.getStatusCode() == 201 || response.getStatusCode() == 200){
                    AcctSeed__Journal_Entry__c[] journalEntries=[Select Id from AcctSeed__Journal_Entry__c where id=:journalEntryId];
                    Delete journalEntries;
                } 
        }
        
    
    
}