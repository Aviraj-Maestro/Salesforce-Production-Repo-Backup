import { LightningElement, track, api } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';
import productFamily from "@salesforce/apex/CreateQuoteController.getProductFamily";
import processSelectedProductFamilyrecs from "@salesforce/apex/CreateQuoteController.processSelectedProductFamily";
export default class CreateQuote extends LightningElement {
    @api recordId;
    @track familyList;
    @api availableActions;
    message = '';
    isProdFamSelected = true;
    selectedFamilyValues;
    
    
    connectedCallback() {
        
        this.getProductFamily();
    }

    getProductFamily() {
        productFamily({ recordId: this.recordId })
            .then(result => {
                this.familyList = [];
                this.familyList = result;
                console.log(this.familyList);
                this.selectedFamilyValues = [];
            }).catch(error => {

            });
    }
    handleFamilyCheckbox(event) {
        let values = event.currentTarget.dataset.id;
        if (event.target.checked) {
            this.selectedFamilyValues.push(('%' + values + '%'));
        } else {
            try {
                this.index = this.selectedFamilyValues.indexOf(('%' + values + '%'));
                this.selectedFamilyValues.splice(this.index, 1);
            } catch (err) {
                //error message
            }
        }
    }
    disconnectedCallback() {
        //this.processSelectedFamily();
    }
    @api
    validate() {
        const validity = {
            isValid: true,
            errorMessage: 'Please select at least One Product Family.'
        };
        if(this.selectedFamilyValues.length>0){
            validity.isValid = true;
            this.processSelectedFamily();
        }else{
            validity.isValid = false;
            
        }
        return validity;
    }
    processSelectedFamily() {
        console.log('this.selectedFamilyValues>>>>'+this.selectedFamilyValues);
        console.log(this.selectedFamilyValues.length);
        if (this.selectedFamilyValues.length > 0) {
            this.isProdFamSelected = true;
            processSelectedProductFamilyrecs({ recordId: this.recordId, selectedProductFamilyRecords: this.selectedFamilyValues })
                .then(result => {
                    console.log('result===>');
                    console.log(result);
                    if (result.isSuccess) {
                        this.handleGoNext();
                    } else {
                        console.log(result.isSuccess);
                         console.log(result.message);
                        this.isProdFamSelected = false;
                        this.message = result.message;
                    }
                }).catch(error => {
                    console.log(error);
                });

        } else {
            this.isProdFamSelected = false;
            this.message = 'Please select Product Family.';
        }
    }
    handleGoNext() {
        // check if NEXT is allowed on this screen
        if (this.availableActions.find((action) => action === 'NEXT')) {
            // navigate to the next screen
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
         else if (this.availableActions.find((action) => action === 'FINISH')) {
            // navigate to the next screen
            const navigateNextEvent = new FlowNavigationFinishEvent();
            this.dispatchEvent(navigateNextEvent);
        }
    }
    handleGoBack() {
        if (this.availableActions.find((action) => action === "BACK")) {
            const navigateBackEvent = new FlowNavigationBackEvent();
            this.dispatchEvent(navigateBackEvent);
        }
    }
}