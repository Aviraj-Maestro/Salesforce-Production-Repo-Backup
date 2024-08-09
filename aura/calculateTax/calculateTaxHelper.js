({
    calculateTaxOnQuote : function(component, event, helper) {  
        var action = component.get("c.calculateTax");
        action.setParams({ recordId: component.get("v.recordId") });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let responseData = response.getReturnValue();
                console.log(responseData);
                if(responseData){
                    helper.showToast(component, event, helper, "Success!", "Tax calculated succesfully.", "success");
                }else{
                    helper.showToast(component, event, helper, "Error!", "This Transaction can not be modified, since it's already locked in avalara.", "error");
                }
                $A.get("e.force:closeQuickAction").fire();
            }
            else {
                console.log("Failed with state: " + state);
                helper.showToast(component, event, helper, "Error!", "Error while calculating tax.", "error");
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    },
    calculateTaxOnSalesOrder : function(component, event, helper) {  
        var action = component.get("c.calculateTax");
        action.setParams({ recordId: component.get("v.recordId") });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let responseData = response.getReturnValue();
                if(responseData){
                    helper.showToast(component, event, helper, "Success!", "Tax calculated succesfully.", "success");
                }else{
                    helper.showToast(component, event, helper, "Error!", "This Transaction can not be modified, since it's already locked in avalara.", "error");
                }
                $A.get("e.force:closeQuickAction").fire();
            }
            else {
                console.log("Failed with state: " + state);
                helper.showToast(component, event, helper, "Error!", "Error while calculating tax.", "error");
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    },
    calculateTaxOnOpportunity : function(component, event, helper) {  
        var action = component.get("c.calculateTax");
        action.setParams({ recordId: component.get("v.recordId") });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let responseData = response.getReturnValue();
                if(responseData){
                    helper.showToast(component, event, helper, "Success!", "Tax calculated succesfully.", "success");
                }else{
                    helper.showToast(component, event, helper, "Error!", "This Transaction can not be modified, since it's already locked in avalara.", "error");
                }
                $A.get("e.force:closeQuickAction").fire();
            }
            else {
                console.log("Failed with state: " + state);
                helper.showToast(component, event, helper, "Error!", "Error while calculating tax.", "error");
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    },
    calculateTaxOnbilling: function(component, event, helper) {  
        var action = component.get("c.calculateTax");
        action.setParams({ recordId: component.get("v.recordId") });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let responseData = response.getReturnValue();
                if(responseData){
                    helper.showToast(component, event, helper, "Success!", "Tax calculated succesfully.", "success");
                }else{
                    helper.showToast(component, event, helper, "Error!", "This Transaction can not be modified, since it's already locked in avalara.", "error");
                }
                $A.get("e.force:closeQuickAction").fire();
            }
            else {
                console.log("Failed with state: " + state);
                helper.showToast(component, event, helper, "Error!", "Error while calculating tax.", "error");
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    },

    showToast : function(component, event, helper, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    }
})