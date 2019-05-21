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
        $A.enqueueAction(action);
        var getEditAccessAction = component.get('c.getFieldsAccess');
        getEditAccessAction.setCallback(this, function getEditAccessActionCallback(responseAccess) {
            var resultAccess = responseAccess.getReturnValue();
            component.set('v.fieldAccess', resultAccess);
        });
        $A.enqueueAction(getEditAccessAction);
    },
    handleEvent: function handleEvent() {
    // refresh Component A here
        $A.get('e.force:refreshView').fire();
    },

    changeStateSectionOne: function changeStateSectionOne(component) {
        component.set('v.isExpandedSectionOne', !component.get('v.isExpandedSectionOne'));
    },

    changeStateSectionTwo: function changeStateSectionTwo(component) {
        component.set('v.isExpandedSectionTwo', !component.get('v.isExpandedSectionTwo'));
    },
    changeContactTabLayout: function changeContactTabLayout(component) {
        component.set('v.isEditContactTab', true);
    },
    /**
     * clickCancel: Handle when cancel
     */
    clickCancel: function clickCancel(component) {
        component.set('v.isEditContactTab', false);
        var event = component.getEvent('CEL_EventContactDetail');
        event.fire();
    },

    sendToDqm: function sendToDqm(component, event) {
        var id = event.getSource().get('v.value');
        if (id === 'false') {
            component.set('v.account.cel_do_not_send_to_dqm__c', false);
        } else {
            component.set('v.account.cel_do_not_send_to_dqm__c', true);
        }

        var newAcc = component.get('v.account');
        var action = component.get('c.updateDQM');
        action.setParams({
            acc: newAcc
        });
        action.setCallback(this, function actionCallBack(a) {
            var state = a.getState();
            if (state === 'SUCCESS') {
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * clickSave: Handle when click save button
     */

    createAccount: function createAccount(component) {
        var newAcc = component.get('v.account');
        var action = component.get('c.saveAccount');

        action.setParams({
            acc: newAcc
        });

        action.setCallback(this, function actionCallBack(a) {
            var state = a.getState();
            if (state === 'SUCCESS') {
                component.set('v.isEditContactTab', false);
              //  var event = component.getEvent("CEL_EventContactDetail");
               // event.fire();
            }
        });
        $A.enqueueAction(action);
    }
});