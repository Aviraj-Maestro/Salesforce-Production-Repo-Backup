import { LightningElement, api, track, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import createPayableAndPayableLines from '@salesforce/apex/CreatePayable.createPayableAndPayableLines';
import getRecordInfo from '@salesforce/apex/CreatePayable.getRecordInfo';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'



export default class CreatePayable extends LightningElement {
    @api recordId;
    value = [];
    vendorIssueDate;
    vendorDueDate;
    vendorPayeeReference;
    shippingIssueDate;
    shippingDueDate;
    shippingPayeeReference;
    customclearingIssueDate;
    customclearingDueDate;
    customclearingPayeeReference;
    customDutyVendorIssueDate;
    customDutyVendorDueDate;
    customDutyVendorPayeeReference;
    localtruckingIssueDate;
    localtruckingDueDate;
    localtruckingPayeeReference;
    othervendor1IssueDate;
    othervendor1DueDate;
    othervendor1PayeeReference;
    othervendor2IssueDate;
    othervendor2DueDate;
    othervendor2PayeeReference;
    purchageOrderRecordTypeName;
    @track displayFields = {productVendor: false, shippingCompany: false, customClearingAgent: false, customDutyVendor: false, localTrucking: false, otherVendor1: false, otherVendor2: false};
    //@track displayFields = {productVendor: true, shippingCompany: true, customClearingAgent: true, customDutyVendor: true, localTrucking: true, otherVendor1: true, otherVendor2: true};

    @wire(getRecordInfo, {recordId: '$recordId'})
    wiredRecord({data, error}){
        if(data){
            this.purchageOrderRecordTypeName = data.RecordType.Name;
        }
        if(error){
            console.log('error==========>'+error);
        }
    }


    get internationalPO(){
        if(this.purchageOrderRecordTypeName == 'Purchase Order International'){
            return true;
        }else{
            return false;
        }
    }
    get domesticPO(){
         if(this.purchageOrderRecordTypeName == 'Purchase Order Domestic'){
            return true;
        }else{
            return false;
        }
    }


    isLoading = false;
    get options() {
        return [
            { label: 'Product Vendor', value: 'productvendor' },
            { label: 'Shipping Company', value: 'shippingcompany' },
            { label: 'Custom Clearing Agent', value: 'customclearingagent' },
        ];
    }
    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleChange(event) {
        switch (event.target.name) {
            case 'vendorIssueDate':
                this.vendorIssueDate = event.target.value;
                break;
            case 'vendorDueDate':
                this.vendorDueDate = event.target.value;
                break;
            case 'vendorPayeeReference':
                this.vendorPayeeReference = event.target.value;
                break;
            case 'shippingIssueDate':
                this.shippingIssueDate = event.target.value;
                break;
            case 'shippingDueDate':
                this.shippingDueDate = event.target.value;
                break;
            case 'shippingPayeeReference':
                this.shippingPayeeReference = event.target.value;
                break;
            case 'customclearingIssueDate':
                this.customclearingIssueDate = event.target.value;
                break;
            case 'customclearingDueDate':
                this.customclearingDueDate = event.target.value;
                break;
            case 'customclearingPayeeReference':
                this.customclearingPayeeReference = event.target.value;
                break;
            case 'customDutyVendorIssueDate':
                this.customDutyVendorIssueDate = event.target.value;
                break;
            case 'customDutyVendorDueDate':
                this.customDutyVendorDueDate = event.target.value;
                break;
            case 'customDutyVendorPayeeReference':
                this.customDutyVendorPayeeReference = event.target.value;
                break;
            case 'localtruckingIssueDate':
                this.localtruckingIssueDate = event.target.value;
                break;
            case 'localtruckingDueDate':
                this.localtruckingDueDate = event.target.value;
                break;
            case 'localtruckingPayeeReference':
                this.localtruckingPayeeReference = event.target.value;
                break;
            case 'othervendor1IssueDate':
                this.othervendor1IssueDate = event.target.value;
                break;
            case 'othervendor1DueDate':
                this.othervendor1DueDate = event.target.value;
                break;
            case 'othervendor1PayeeReference':
                this.othervendor1PayeeReference = event.target.value;
                break;
            case 'othervendor2IssueDate':
                this.othervendor2IssueDate = event.target.value;
                break;
            case 'othervendor2DueDate':
                this.othervendor2DueDate = event.target.value;
                break;
            case 'othervendor2PayeeReference':
                this.othervendor2PayeeReference = event.target.value;
                break;
            default:
           
        }


    }

    handleChangeCheck(event) {
        console.log(JSON.stringify(event.target.classList[0]));
        let className;
        let sectionName;
        switch (event.target.classList[0]) {
            case 'vendor1':
                className = '.vendor';
                sectionName = 'productVendor';
                break;
            case 'shipping1':
                className = '.shipping';
                sectionName = 'shippingCompany';
                break;
            case 'customclearing1':
                className = '.customclearing';
                sectionName = 'customClearingAgent';
                break;
            case 'customDutyVendor1':
                className = '.customDutyVendor';
                sectionName = 'customDutyVendor';
                break;
            case 'localtrucking1':
                className = '.localtrucking';
                sectionName = 'localTrucking';
                break;
            case 'othervendor11':
                className = '.othervendor1';
                sectionName = 'otherVendor1';
                break;
            case 'othervendor21':
            className = '.othervendor2';
            sectionName = 'otherVendor2';
            break;
                
            default:
            // code block
        }
        this.displaySections(event.target.checked, sectionName, className);
        //this.changeRequired(event.target.checked, className);
        
    }
    displaySections(checked, sectionName, className){
        if(checked){
            this.displayFields[sectionName] = true;
        }else{
            this.displayFields[sectionName] = false;
        }
        //this.changeRequired(checked, className);
    }
    
    changeRequired(checked, className) {
        const isInputsCorrect = [...this.template.querySelectorAll(className)];
        console.log(isInputsCorrect);
        isInputsCorrect.map(val => {
            val.required = checked;
        });

        if (!checked) {
            const removeValidation = [...this.template.querySelectorAll(className)]
                .reduce((validSoFar, inputField) => {
                    inputField.reportValidity();
                    return validSoFar && inputField.checkValidity();
                }, false);
        }
    }

    handleCreatePayable(event) {
        
        const isInputsCorrect = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
        if ( isInputsCorrect) {
            let _toSave=[];
            let _typesToSave=[];

        if(this.template.querySelector('.vendor1').checked){
            _typesToSave.push('productvendor');
            _toSave.push({
                ProductVendor :{
                    issueDate : this.vendorIssueDate,
                    dueDate : this.vendorDueDate,
                    payeeReference : this.vendorPayeeReference
                }
            })
            
        }
        if(this.template.querySelector('.shipping1').checked){
            _typesToSave.push('shippingcompany');
            _toSave.push({
                ShippingVendor :{
                    issueDate : this.shippingIssueDate,
                    dueDate : this.shippingDueDate,
                    payeeReference : this.shippingPayeeReference
                }
            })
            
        }
        if(this.internationalPO){
            if(this.template.querySelector('.customclearing1').checked){
                _typesToSave.push('customclearingagent');
                _toSave.push({
                    CustomclearingAgent :{
                        issueDate : this.customclearingIssueDate,
                        dueDate : this.customclearingDueDate,
                        payeeReference : this.customclearingPayeeReference
                    }
                })
                
            }
            if(this.template.querySelector('.customDutyVendor1').checked){
                _typesToSave.push('customDutyVendor');
                _toSave.push({
                    CustomDutyVendor :{
                        issueDate : this.customDutyVendorIssueDate,
                        dueDate : this.customDutyVendorDueDate,
                        payeeReference : this.customDutyVendorPayeeReference
                    }
                })
                
            }
            if(this.template.querySelector('.localtrucking1').checked){
                _typesToSave.push('localtrucking');
                _toSave.push({
                    LocalTrucking :{
                        issueDate : this.localtruckingIssueDate,
                        dueDate : this.localtruckingDueDate,
                        payeeReference : this.localtruckingPayeeReference
                    }
                })
                
            }
        }
        if(this.template.querySelector('.othervendor11').checked){
            _typesToSave.push('otherVendor_1');
            _toSave.push({
                OtherVendor_1 :{
                    issueDate : this.othervendor1IssueDate,
                    dueDate : this.othervendor1DueDate,
                    payeeReference : this.othervendor1PayeeReference
                }
            })
            
        }
        if(this.template.querySelector('.othervendor21').checked){
            _typesToSave.push('otherVendor_2');
            _toSave.push({
                OtherVendor_2 :{
                    issueDate : this.othervendor2IssueDate,
                    dueDate : this.othervendor2DueDate,
                    payeeReference : this.othervendor2PayeeReference
                }
            })
            
        }
        console.log('_typesToSave :>> ',JSON.stringify(_typesToSave.join(',')));
        console.log('_toSave :>> ',JSON.stringify( _toSave));

            this.isLoading = true;
            createPayableAndPayableLines({
                types: JSON.stringify(_typesToSave.join(',')),
                values :  JSON.stringify(_toSave),
                purchaseOrderId: this.recordId,
                issueDate: this.issueDate,
                dueDate: this.dueDate,
                payeeReference: this.payeeReference
            })
                .then(createdPayable => {
                    const event = new ShowToastEvent({
                        title: "Success!",
                        message: 'Succesfully created payable.',
                        variant: 'success'
                    });
                    this.dispatchEvent(event);
                    this.closeAction();
                })
                .catch(error => {
                    console.log('error :>> ', error);
                    const event = new ShowToastEvent({
                        title: "Error!",
                        message: error.body.message,
                        variant: 'Error'
                    });
                    this.dispatchEvent(event);

                })
                .finally(() => {
                    this.isLoading = false;
                })

        } else {
           // checkboxGroup.reportValidity();
        }

    }
}