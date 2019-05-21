({
    /**
     * doInit: Called at component initialization
     */
    doInit: function doInit(component) {
        var newTask= {
            Subject: '',
            ActivityDate: '',
            Description: ''

        };
        component.set('v.task', newTask);
        
        var getAccessAction = component.get('c.getUserAccess');
        getAccessAction.setCallback(this, function getAccessActionCallback(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var saveResult = response.getReturnValue();
                component.set('v.hasAccess', saveResult);
                
            } 
        });
        
        $A.enqueueAction(getAccessAction);
        
    },
    
    
    /**
     * handleSave: Called when click on save button
     * show a toast on success or on error when saving
     */
    handleSave: function handleSave(component,helper) {
        var task = component.get('v.task');
        var recordId = component.get('v.recordId');
        let toastEvent = $A.get('e.force:showToast');
        var saveAction = component.get('c.saveTasksByStore');
        saveAction.setParams({
            taskToCreate: task,
            storeId: recordId
        });
        saveAction.setCallback(this, function saveActionCallback(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var saveResult = response.getReturnValue();
                var result = saveResult.result;
                var message = saveResult.message;
                
                if(result === 'true'){
                    component.find('notifLib').showNotice({
                        "variant": "success",
                        "header": $A.get('$Label.c.cel_task_create_success_header'),
                        "message": message
                    });
                    $A.get("e.force:closeQuickAction").fire();
                }
                else{
                    component.find('notifLib').showNotice({
                        "variant": "error",
                        "header": $A.get('$Label.c.cel_task_create_error_header'),
                        "message": message
                    });
                }
            } 
        });
        
        $A.enqueueAction(saveAction);
    }
});