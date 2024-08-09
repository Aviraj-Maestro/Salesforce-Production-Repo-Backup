import { LightningElement, api, track } from 'lwc';
import getRelevantWarehouses from '@salesforce/apex/LocationWiseInverntoryController.getRelevantWarehouses';

import { subscribe } from 'lightning/empApi';

export default class LocationWiseInventory extends LightningElement {
    @api recordId;

    @track warehouses;
    connectedCallback() {
        this.subscribeToChanges();
        this.getData();
    }
    
    get style() {
        return "background-color:yellow;"
    }

    get hasWarehouses() {
        return this.warehouses && this.warehouses.length > 0;
    }
    getData(){
        getRelevantWarehouses({
            opportunityId: this.recordId
        })
            .then(result => {
                console.log('result == ', result);
                this.warehouses = result.map(warehouse => {
                    warehouse['drawerButtonClass'] = 'slds-row_button slds-button slds-button_icon slds-button_icon-border-filled slds-path__trigger';

                    return warehouse;
                });
            })
            .catch(error => {
                console.log('error == ', error);
            })
    }

    openDrawer(event) {
        let recordId = event.currentTarget.dataset.id;
        let drawerLevel = event.currentTarget.dataset.level;

        this.warehouses.forEach(warehouse => {
            if (drawerLevel == 'warehouse') {
                if (warehouse.warehouseId == recordId) {
                    if (event.currentTarget.classList.contains('slds-path__trigger_open')) {
                        event.currentTarget.classList.remove('slds-path__trigger_open');
                        warehouse.isDrawerOpen = false;
                        warehouse.drawerButtonClass = 'slds-row_button slds-button slds-button_icon slds-button_icon-border-filled slds-path__trigger';
                    } else {
                        event.currentTarget.classList.add('slds-path__trigger_open');
                        warehouse.isDrawerOpen = true;
                        warehouse.drawerButtonClass = 'slds-row_button slds-button slds-button_icon slds-button_icon-border-filled slds-path__trigger slds-path__trigger_open';
                    }
                }
            }
            /*else if(drawerLevel == 'location'){
                warehouse.locations.forEach(location => {
                    if(location.locationId == recordId){
                        if(event.currentTarget.classList.contains('slds-path__trigger_open')){
                            event.currentTarget.classList.remove('slds-path__trigger_open');
                            location.isDrawerOpen = false;
                            location.drawerButtonClass = 'slds-row_button slds-button slds-button_icon slds-button_icon-border-filled slds-path__trigger';
                        }else{
                            event.currentTarget.classList.add('slds-path__trigger_open');
                            location.isDrawerOpen = true;
                            location.drawerButtonClass = 'slds-row_button slds-button slds-button_icon slds-button_icon-border-filled slds-path__trigger slds-path__trigger_open';
                        }
                    }
                })
            }*/
            /*}else if(drawerLevel == 'product'){
                warehouse.products.forEach(product => {
                    if(product.productId == recordId){
                        if(event.currentTarget.classList.contains('slds-path__trigger_open')){
                            event.currentTarget.classList.remove('slds-path__trigger_open');
                            product.isDrawerOpen = false;
                            product.drawerButtonClass = 'slds-row_button slds-button slds-button_icon slds-button_icon-border-filled slds-path__trigger';
                        }else{
                            event.currentTarget.classList.add('slds-path__trigger_open');
                            product.isDrawerOpen = true;
                            product.drawerButtonClass = 'slds-row_button slds-button slds-button_icon slds-button_icon-border-filled slds-path__trigger slds-path__trigger_open';
                        }
                    }
                })
            }*/
        })
        //alert('recordId == '+recordId);
    }


    messageCallback = (response) => {
        console.log('<==hello==>');
        if (response.data && response.data.payload) {
            this.getData();
        }

    };

    // Handles subscribe on load.
    subscribeToChanges() {
        console.log('<==hello==>');
        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe('/data/OpportunityChangeEvent', -1, this.messageCallback).then((response) => { });
    }
}