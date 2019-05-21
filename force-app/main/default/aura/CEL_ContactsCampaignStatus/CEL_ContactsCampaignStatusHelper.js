({
    /*
    * fetchcontacts : get the contact list
    */
    fetchcontacts: function fetchcontacts(component) {
        var action = component.get('c.getContacts');
        var campaignId = component.get('v.recordId');
        var filterName = component.find('filtName').get('v.value');
        var filterCustomerCode = component.find('filtCustomerCode').get('v.value');

        action.setParams({
            campaignIds: campaignId,
            filterName: filterName,
            customerCode: filterCustomerCode
        });

        action.setCallback(this, function actionCallback(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var contactList = response.getReturnValue();
                component.set('v.contactList', contactList);
                component.set('v.numberOfContacts', contactList.length);
            }
            component.set('v.loading', false);
        });

        component.set('v.loading', true);
        $A.enqueueAction(action);
    },

    /*
    * handleSelectAllContact : Select all contact
    */
    handleSelectAllContact: function handleSelectAllContact(component) {
        var getIdCheckboxAll = component.find('checkboxAll');
        var isSelectedAll = getIdCheckboxAll.get('v.value');

        // The other checkboxes
        var checkContact = component.find('checkBox');
        if (checkContact != null) {
            if (isSelectedAll) {
                for (let i = 0; i < checkContact.length; i++) {
                    checkContact[i].set('v.value', true);
                }
            } else {
                for (let i = 0; i < checkContact.length; i++) {
                    checkContact[i].set('v.value', false);
                }
            }
        }
    },

    /*
    * addSelectedHelper : Add members on the current campaign
    */
    addSelectedHelper: function addSelectedHelper(component, event, childRecordsIds) {
        var refreshEvent = component.getEvent('RefreshMemberList');
        var action = component.get('c.addContactToCampaignmemberStatus');
        var successMessage = $A.get('$Label.c.cel_campaign_members_status_success_message');
        var successTittle = $A.get('$Label.c.cel_campaign_members_status_success_tittle');

        action.setParams({
            CampaignId: component.get('v.recordId'),
            listAccountId: childRecordsIds
        });

        action.setCallback(this, function actionCallback(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                // display SUCCESS message
                var toastEvent = $A.get('e.force:showToast');
                toastEvent.setParams({
                    title: successTittle,
                    message: successMessage,
                    type: 'success'
                });
                this.fetchcontacts(component, event);
                toastEvent.fire();
                refreshEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    /*
    * gotToReportHelper : open the report window
    */
    gotToReportHelper: function gotToReportHelper(component) {
        var action = component.get('c.gotoReportFolderCampaignAction');

        action.setCallback(this, function actionCallback(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var urlString = response.getReturnValue();
                window.open('/' + urlString);
            }
        });

        $A.enqueueAction(action);
    }
});