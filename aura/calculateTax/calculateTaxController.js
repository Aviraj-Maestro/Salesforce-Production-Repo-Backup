({
    doInit : function(component, event, helper) {
        let objectApiNameJs = component.get("v.sObjectName");
        var action = component.get("c.calculateTax");
        action.setParams({ recordId: component.get("v.recordId"), objectApiName: objectApiNameJs });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
                let responseData = response.getReturnValue();
                console.log(responseData);
                helper.showToast(component, event, helper, responseData.title, responseData.message, responseData.variant);
                
                /*if(responseData){
                    helper.showToast(component, event, helper, "Success!", "Tax calculated succesfully.", "success");
                }else{
                    helper.showToast(component, event, helper, "Error!", "This Transaction can not be modified, since it's already locked in avalara.", "error");
                }*/
                
                $A.get("e.force:closeQuickAction").fire();
            }
            else {
                console.log("Failed with state: " + state);
                helper.showToast(component, event, helper, "Error!", "Error while calculating tax.", "error");
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    }
})