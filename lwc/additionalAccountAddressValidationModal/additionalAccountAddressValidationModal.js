import { LightningElement,api } from 'lwc';
import LightningModal from 'lightning/modal';
import validateAdditionalAccountAddress from '@salesforce/apex/AdditionAccountAddressValidationClass.validateAdditionalAccountAddress';
import createAdditionAccountAddressRecord from '@salesforce/apex/AdditionAccountAddressValidationClass.createAdditionAccountAddressRecord';

export default class AdditionalAccountAddressValidationModal extends LightningModal{
    @api recordIdValue;
    showFirstScreen = true;
    showErrorSecondScreen = false;
    showSuccessSecondScreen = false;
    fieldNames = [{'label':'name','fieldValue':'','value':'Additional Account Address','required':true,'label1':'line1','value1':'Shipping Street','fieldValue1':'','required1':false},{'label':'city','value':'Shipping City','required':false,'fieldValue':'','label1':'region','value1':'Shipping State/Province','fieldValue1':'','required1':false},{'label':'country','fieldValue':'','value':'Shipping Country','required':false,'label1':'postalCode','fieldValue1':'','value1':'Shipping Zip/Postal Code','required1':false}];
    errorMessage = '';
    addressResult = '';
    showSpinner = false;
    
    setAccountAdditionalAddress(event){
        
        this.errorMessage = '';
        if(event.target.name=='validate'){
            this.validateAdditionalAddress();    
        }else if(event.target.name=='fixAddress'){
            this.editOriginalAddress();    
        }else if(event.target.name!='validate' && event.target.name!='fixAddress'){
            this.createAdditionalAddress(event.target.name);
        }
    }

    editOriginalAddress(){
        this.showFirstScreen = true;    
        this.showErrorSecondScreen = false;
        this.showSuccessSecondScreen = false;
        const mapOfJSON= new Map(Object.entries(this.addressResult.originalAddressWrapper));
        
        this.fieldNames.forEach(field => {
            for (let [key, value] of mapOfJSON) {
                if(key==field.label){
                    field.fieldValue = value;  
                }else if(key==field.label1){
                    field.fieldValue1 = value;
                }
            }
        });
        
    }

    createAdditionalAddress(buttonName){
        this.showSpinner=false;
        createAdditionAccountAddressRecord({additionalAddressResponse:JSON.stringify(this.addressResult),buttonName:buttonName})
        .then(result =>{
            if(result.recordId){
                window.location = '/'+result.recordId;
            }else if(result.message){
                this.errorMessage = result.message;
            }
        })
        .catch(error=>{

        });;
        this.showSpinner = false;
    }

    validateAdditionalAddress(){
        const inputFields = this.template.querySelectorAll('lightning-input');
       
        if(inputFields) {
            var prepareJSONString = '';
            var isNameBlank = '';
            var addressArray = []; 
            inputFields.forEach(field => {
                isNameBlank = (field.name=='name' && !field.value)?true:isNameBlank;
                if(field.name!='name' && field.value==''){
                    addressArray.push(field.name);
                }
                prepareJSONString += '"'+field.name+'":"'+field.value+'",';
            });

            if(isNameBlank){
                this.errorMessage = 'Please fill valid Additional Account Address';
            }else if(addressArray.length==5){
                this.errorMessage = 'Please fill atleast one shipping address field';
            }else if(prepareJSONString!=''){
                this.callAddressValidationAPI(prepareJSONString);
            }
        }
    }

    callAddressValidationAPI(prepareJSONString){
        this.showSpinner=false;
        prepareJSONString = '{'+prepareJSONString+'"accountId":"'+this.recordIdValue+'"}';
        validateAdditionalAccountAddress({userEnteredAddress:prepareJSONString})
        .then(result=>{
            this.errorMessage = '';
            this.addressResult = result;
            if(result.isAddressExist){
                this.showSuccessSecondScreen = true;
            }else if(!result.isAddressExist){
                this.showErrorSecondScreen = true;
            }
            this.showSpinner=false;
            this.showFirstScreen = false;
        })
        .catch(error=>{
            this.showSpinner=false;
            this.showFirstScreen = true;
            this.errorMessage = 'Address validation service is down. Please try after sometime.';
        });

    }
}