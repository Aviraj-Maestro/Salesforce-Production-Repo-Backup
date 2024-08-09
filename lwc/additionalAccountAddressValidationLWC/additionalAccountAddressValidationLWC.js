import { LightningElement,api } from 'lwc';
import accountAddressValidationModal from 'c/additionalAccountAddressValidationModal';
import { NavigationMixin } from 'lightning/navigation';

export default class AdditionalAccountAddressValidationLWC extends NavigationMixin(LightningElement) {
    @api currentRecordId;

    connectedCallback(){
        this[NavigationMixin.Navigate]({
            type:'standard__recordPage',
            attributes:{
                recordId:this.currentRecordId,
                actionName:'view'
            }
        });
        accountAddressValidationModal.open({size:'small',recordIdValue:this.currentRecordId});
    }
}