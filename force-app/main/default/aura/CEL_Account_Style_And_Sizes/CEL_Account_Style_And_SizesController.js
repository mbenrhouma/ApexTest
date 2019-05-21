({

    /**
     * doInit: Called at component initialization
     */
    doInit: function doInit(component) {
        var availableListAction = component.get('c.getAvailableList');
        availableListAction.setStorable();
        availableListAction.setCallback(this, function availableListActionCallback(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var availableList = response.getReturnValue();
                component.set('v.allTrousers', availableList.allTrousers);
                component.set('v.allTop', availableList.allTop);
                component.set('v.allDress', availableList.allDress);
                component.set('v.allKnitwear', availableList.allKnitwear);
                component.set('v.allShoes', availableList.allShoes);
                component.set('v.allGeneralStyle', availableList.allGeneralStyle);
                component.set('v.allWearing', availableList.allWearing);
                component.set('v.allColourTone', availableList.allColourTone);
            }
        });

        var getEditAccessAction = component.get('c.getFieldsAccess');

        getEditAccessAction.setCallback(this, function getEditAccessActionCallback(responseAccess) {
            var resultAccess = responseAccess.getReturnValue();
            component.set('v.fieldAccess', resultAccess);
        });

        $A.enqueueAction(availableListAction);
        $A.enqueueAction(getEditAccessAction);
    },

    /**
     * editRecord: Called when click on edit button
     */
    editRecord: function editRecord(component) {
        component.set('v.isEditMode', true);
    },

    /**
     * handleSave: Called when click on save button
     * show a toast on success or on error when saving
     */
    handleSave: function handleSave(component) {
        component.find('recordHandler').saveRecord(
                $A.getCallback(function saveRecordAction(saveResult) {
                    let toastEvent = $A.get('e.force:showToast');
                    if (saveResult.state === 'SUCCESS' || saveResult.state === 'DRAFT') {
                        toastEvent.setParams({
                            title: 'Success',
                            message: 'Record saved.',
                            type: 'success'
                        });
                        $A.get('e.force:refreshView').fire();
                        component.set('v.isEditMode', false);
                    } else if (saveResult.state === 'ERROR') {
                        let errorMsg = JSON.stringify(saveResult.error[0].message);
                        errorMsg = errorMsg.slice(0, -3);
                        errorMsg = errorMsg.substr(1);
                        toastEvent.setParams({
                            title: 'Error',
                            message: errorMsg,
                            type: 'error'
                        });
                        component.set('v.recordError', errorMsg);
                        errorMsg = '';
                    }
                    toastEvent.fire();
                }));
    },

    /**
     * handleCancel: Called when click on cancel button
     */
    handleCancel: function handleCancel(component) {
        component.set('v.isEditMode', false);
    }
});