public with sharing class AvalaraRequestParser {
   
	public String adjustmentReason;
	public String adjustmentDescription;
	public cls_createTransactionModel createTransactionModel;
	public class cls_createTransactionModel {
		public cls_lines[] lines;
		public String type;
		public String Code;
		public String ReportingLocationCode; 
		public String companyCode;
		public String date_x;
		public String customerCode;
		public String purchaseOrderNo;
		public String ReferenceCode;
		public String SalespersonCode;
		public cls_addresses addresses;
		public boolean commit_x; 
		public String currencyCode;
		public String description;
		public String customerUsageType;
		public String entityUseCode;
		public String exemptionNo;
	}
	
	public class cls_lines {
		public String number_x;	
		public Decimal quantity;	
		public Double amount;	
		public String taxCode;	
		public String description;
		public String itemCode;
		public cls_parameters[] parameters;
	}
	public class cls_parameters {
		public String name;	
		public String value;
        public String unit;
	}
	public class cls_parameters1 {
		public String name;	
		public String value;
      
	}
	public class cls_addresses {
		public cls_ShipFrom ShipFrom;
		public cls_ShipTo ShipTo;
		public cls_SingleLocation SingleLocation;
	}
	public class cls_ShipFrom {
		public String line1;	
		public String city;	
		public String region;	
		public String country;	
		public String postalCode;	
	}
	public class cls_ShipTo {
		public String line1;	
		public String city;	
		public String region;	
		public String country;	
		public String postalCode;	
	}
	public class cls_SingleLocation {
		public String line1 {get;set;} 
		public String line2 {get;set;} 
		public String city {get;set;} 
		public String region {get;set;} 
		public String country {get;set;} 
		public String postalCode {get;set;} 
	}
	// Commented by Amit
	/*public class Addresses {
		public SingleLocation singleLocation {get;set;} 
	}
	
	public class Parameters {
		public String name {get;set;} 
		public String value {get;set;} 
        public void Parameters(String name,String value){
            this.name=name;
            this.value=value;
        }
	}
	
	
	
	public List<Lines> lines {get;set;} 
	public String type {get;set;} 
	public String companyCode {get;set;} 
	public String date_Z {get;set;} 
	public String customerCode {get;set;} 
	public String purchaseOrderNo {get;set;} 
	public Addresses addresses {get;set;} 
	public Boolean commit_Z {get;set;} 
	public String currencyCode {get;set;} 

	
	
	public class Lines {
		public String number_Z {get;set;} 
		public String taxCode {get;set;} 
		public String itemCode {get;set;} 
		public String description {get;set;} 
		public List<Parameters> parameters {get;set;} 
		public Decimal quantity {get;set;} 
		public Double amount {get;set;} 

	}*/


}