public with sharing class AvalaraResponseDetails {
    public String id;	//0
	public String code;	//0Q0Ff00000005FpKAI
	public String companyId;	//7828481
	//public String date;	//2022-12-29
	public String paymentDate;	//2022-12-29
	public String status;	//Temporary
	public String type;	//SalesOrder
	public String batchCode;	//
	public String currencyCode;	//USD
	public String exchangeRateCurrencyCode;	//USD
	public String customerUsageType;	//
	public String entityUseCode;	//
	public String customerVendorCode;	//CA-0117
	public String customerCode;	//CA-0117
	public String exemptNo;	//
	public boolean reconciled;
	public String locationCode;	//
	public String reportingLocationCode;	//
	public String purchaseOrderNo;	//
	public String referenceCode;	//
	public String salespersonCode;	//eClouds Support
	public Double totalAmount;	//6523.76
	public Double totalExempt;	//6523.76
	public String totalDiscount;	//0
	public String totalTax;	//0
	public String totalTaxable;	//0
	public String totalTaxCalculated;	//0
	public String adjustmentReason;	//NotAdjusted
	public boolean locked;
	public String version;	//1
	public String exchangeRateEffectiveDate;	//2022-12-29
	public String exchangeRate;	//1
	public String description;	//Quote - Store Pick Up Inventory Test 2022-11-20
	public String modifiedDate;	//2022-12-29T13:16:10.9995464Z
	public String modifiedUserId;	//6501057
	public String taxDate;	//2022-12-29
	public lineItem[] lines;
	public cls_addresses[] addresses;
	public cls_summary[] summary;
	public cls_messages[] messages;
	public class lineItem {
		public String id;	//0
		public String transactionId;	//0
		public String lineNumber;	//0QLFf00000007j3OAA
		public String customerUsageType;	//
		public String entityUseCode;	//
		public String discountAmount;	//0
		public String exemptAmount;	//1050
		public String exemptCertId;	//0
		public String exemptNo;	//
		public boolean isItemTaxable;
		public String itemCode;	//AEOLUSD3
		public String lineAmount;	//1050
		public String quantity;	//3
		public String ref1;	//
		public String ref2;	//
		public String reportingDate;	//2022-12-29
		public String tax;	//0
		public String taxableAmount;	//0
		public String taxCalculated;	//0
		public String taxCode;	//PA3000301
		public String taxCodeId;	//99138
		public String taxDate;	//2022-12-29
		public boolean taxIncluded;
		public lineDetails[] details;
		public cls_nonPassthroughDetails[] nonPassthroughDetails;
		public String hsCode;	//
		public String costInsuranceFreight;	//0
		public String vatCode;	//
		public String vatNumberTypeId;	//0
	}
	public class lineDetails {
		public String id;	//0
		public String transactionLineId;	//0
		public String transactionId;	//0
		public String country;	//US
		public String region;	//AL
		public String exemptAmount;	//0
		public String jurisCode;	//01
		public String jurisName;	//ALABAMA
		public String stateAssignedNo;	//
		public String jurisType;	//STA
		public String jurisdictionType;	//State
		public String nonTaxableAmount;	//1050
		public String rate;	//0
		public String tax;	//0
		public String taxableAmount;	//0
		public String taxType;	//Use
		public String taxSubTypeId;	//U
		public String taxName;	//AL STATE TAX
		public String taxAuthorityTypeId;	//45
		public String taxCalculated;	//0
		public String rateType;	//General
		public String rateTypeCode;	//G
		public String unitOfBasis;	//PerCurrencyUnit
		public boolean isNonPassThru;
		public boolean isFee;
		public String reportingTaxableUnits;	//0
		public String reportingNonTaxableUnits;	//1050
		public String reportingExemptUnits;	//0
		public String reportingTax;	//0
		public String reportingTaxCalculated;	//0
		public String liabilityType;	//Seller
	}
	public class cls_nonPassthroughDetails {
	}
	public class cls_addresses {
		public String id;	//0
		public String transactionId;	//0
		public String boundaryLevel;	//Zip5
		public String line1;	//Street 2 Garden cityy Alabama
		public String line2;	//
		public String line3;	//
		public String city;	//Garden City
		public String region;	//AL
		public String postalCode;	//35070
		public String country;	//US
		public String taxRegionId;	//4017077
		public String latitude;	//34.012518
		public String longitude;	//-86.749034
	}
	public class cls_summary {
		public String country;	//US
		public String region;	//AL
		public String jurisType;	//State
		public String jurisCode;	//01
		public String jurisName;	//ALABAMA
		public String taxAuthorityType;	//45
		public String stateAssignedNo;	//
		public String taxType;	//Use
		public String taxSubType;	//U
		public String taxName;	//AL STATE TAX
		public String rateType;	//General
		public String taxable;	//0
		public String rate;	//0
		public String tax;	//0
		public String taxCalculated;	//0
		public Double nonTaxable;	//6523.76
		public String exemption;	//0
	}
	public class cls_messages {
		public String summary;	//SI UOM used
		public String details;	//SI UOM has been used for MeasurementType 'Length'.
		public String refersTo;	//UOM Code
		public String severity;	//Warning
		public String source;	//Avalara.AvaTax.TaxEngine
	}

	
}