({
    /**
     * doInit: Called at component initialization
     */
    doInit: function doInit(component) {
        var newTask= {
            Subject: '',
            ActivityDate: '',
            Description: '',
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
        
        //get stores list
        var getAvailableListAction = component.get('c.getAvailableList');
        getAvailableListAction.setCallback(this, function getAvailableListActionCallback(responseList) {
            var availableListState = responseList.getState();
            if (availableListState === 'SUCCESS') {
                var listResult = responseList.getReturnValue();
                component.set('v.storeList', listResult.availableStores);
            }
        });
        
        $A.enqueueAction(getAccessAction);
        $A.enqueueAction(getAvailableListAction);
        
    },
    
    
    /**
     * handleSave: Called when click on save button
     * show a toast on success or on error when saving
     */
    handleSave: function handleSave(component,helper) {
        var task = component.get('v.task');
        var stores = component.find('InputSelectMultipleStores').get('v.value');
        if (stores != '') {
            var saveAction = component.get('c.saveTasksByStore');
            saveAction.setParams({
                taskToCreate: task,
                storesList: stores
            });
            saveAction.setCallback(this, function saveActionCallback(response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    var saveResult = response.getReturnValue();
                    var result = saveResult.result;
                    var message = saveResult.message;
                    
                    if(result === 'true'){
                        component.find('InputSelectMultipleStores').set('v.value','');
                        window.alert(message);
                        $A.get('e.force:refreshView').fire();
                        
                        
                    }
                    else{
                        window.alert(message);
                        
                    }
                }
            });
            $A.enqueueAction(saveAction);
        }
        
        else{
            window.alert($A.get('$Label.c.cel_task_create_no_store_selected'));
        }  
    }
});