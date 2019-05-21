({
    /*
    * getCampaignMemberStatusListHlp : get the campaign members status and currency
    */
    getCampaignMemberStatusListHlp: function getCampaignMemberStatusListHlp(component) {
        var action = component.get('c.getCampaignMemberStatusList');
        var campaignId = component.get('v.recordId');
        var filtName = component.find('filtName').get('v.value');
        var filtCustomerCode = component.find('filtCustomerCode').get('v.value');
        var actionCurrency = component.get('c.getCampaignCurrency');

        actionCurrency.setParams({
            campaignIds: campaignId
        });

        action.setParams({
            campaignIds: campaignId,
            filterName: filtName,
            filtCustomerCode: filtCustomerCode
        });

        action.setCallback(this, function actionCallBack(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var campaignMemberList = response.getReturnValue();
                component.set('v.campaignMemberStatusList', campaignMemberList);
                component.set('v.numberOfCampaignMemberStatus', campaignMemberList.length);
            }
        });

        actionCurrency.setCallback(this, function actionCurrencyCallBack(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var campaign = response.getReturnValue();
                component.set('v.CurrencyLocale', campaign.currencccy);
            }
        });

        $A.enqueueAction(action);
        $A.enqueueAction(actionCurrency);
    },

    /*
    * cancelUpdateAllMemberCtrlHlp : Cancel the modification means reload the page call the init method
    */
    cancelUpdateAllMemberCtrlHlp: function cancelUpdateAllMemberCtrlHlp(component) {
        this.getCampaignMemberStatusListHlp(component);
    },

    /*
    * updateAllmembersHlp : update all members
    */
    updateAllmembersHlp: function updateAllmembersHlp(component, event, tempIDs, inviteds, contacteds, confirmeds, showups, purchasings, reswdeps, reswodeps) {
        var action = component.get('c.updateTheCampaignMembersStatus');
        var successMessage = $A.get('$Label.c.cel_campaign_members_status_success_message');
        var errorMessage = $A.get('$Label.c.cel_campaign_members_status_error_update_message');
        var successTittle = $A.get('$Label.c.cel_campaign_members_status_success_tittle');
        var errortittle = $A.get('$Label.c.cel_campaign_members_status_error_update_tittle');

        action.setParams({
            campaignMembersId: tempIDs,
            inviteds: inviteds,
            contacteds: contacteds,
            confirmeds: confirmeds,
            showups: showups,
            purchasings: purchasings,
            reswdeps: reswdeps,
            reswodeps: reswodeps
        });

        action.setCallback(this, function actionCallBack(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                let toastEvent = $A.get('e.force:showToast');
                toastEvent.setParams({
                    title: successTittle,
                    message: successMessage,
                    type: 'success'
                });
                toastEvent.fire();
                // refresh/reload the page view
                $A.get('e.force:refreshView').fire();
                // call init function again [clear selected checkboxes]
                this.getCampaignMemberStatusListHlp(component, event);
            } else {
                let toastEvent = $A.get('e.force:showToast');
                toastEvent.setParams({
                    title: errortittle,
                    message: errorMessage,
                    type: 'error'
                });
                toastEvent.fire();
                // refresh/reload the page view
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    }
});