({
	onLoadFunction:function(component, event, helper) {
		var pageReference = component.get("v.pageReference");
        component.set("v.parentRecordId", pageReference.state.c__parentId);
	},
    onPageReferenceChanged:function(component,event,helper){
         $A.get('e.force:refreshView').fire();
    }
})