({
    /**
     * doInit: Called at component initialization
     */
    doInit: function doInit(component) {
        var action = component.get('c.getContactDetails');

        action.setParams({
            accountId: component.get('v.recordId')
        });

        action.setCallback(this, function actionCallBack(response) {
            var result = response.getReturnValue();
            component.set('v.account', result);
        });

        var availableListAction = component.get('c.getAvailableList');
        availableListAction.setStorable();
        availableListAction.setCallback(this, function availableListActionCallback(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var availableList = response.getReturnValue();

                component.set('v.allCountries', availableList.allCountries);
                component.set('v.allLanguages', availableList.allLanguages);
                component.set('v.allChannels', availableList.allChannels);
                component.set('v.allAppointment', availableList.allAppointment);

                $A.enqueueAction(action);
            }
        });

        $A.enqueueAction(availableListAction);

        var getEditAccessAction = component.get('c.getFieldsAccess');

        getEditAccessAction.setCallback(this, function getEditAccessActionCallback(responseAccess) {
            var resultAccess = responseAccess.getReturnValue();
            component.set('v.fieldAccess', resultAccess);
        });
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
    },
    /**
     * handleEvent:
     */
    handleEvent: function handleEvent() {
        // refresh Component A here
        $A.get('e.force:refreshView').fire();
    },


    /**
     * changeStateSectionOne:
     */
    changeStateSectionOne: function changeStateSectionOne(component) {
        component.set('v.isExpandedSectionOne', !component.get('v.isExpandedSectionOne'));
    },


    /**
     * changeStateSectionTwo:
     */
    changeStateSectionTwo: function changeStateSectionTwo(component) {
        component.set('v.isExpandedSectionTwo', !component.get('v.isExpandedSectionTwo'));
    }
});