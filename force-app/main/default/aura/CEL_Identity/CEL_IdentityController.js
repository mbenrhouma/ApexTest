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
                component.set('v.allCountries', availableList.allCountries);
                component.set('v.allTitles', availableList.allTitles);
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

    editRecord: function editRecord(component) {
        component.set('v.isEditMode', true);
    },
    handleSave: function handleSave(component) {
        component.find('recordHandler').saveRecord($A.getCallback(function saveRecordAction(saveResult) {
            if (saveResult.state === 'SUCCESS' || saveResult.state === 'DRAFT') {
                $A.get('e.force:refreshView').fire();
                component.set('v.isEditMode', false);
            }
        }));
    },

    handleCancel: function handleCancel(component) {
        component.set('v.isEditMode', false);
    }

});