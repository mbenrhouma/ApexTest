({
    /**
     * getAvailableList: get available list
     */
    getAvailableList: function getAvailableList(component, event, helper, isReset) {
        /** ***********************/
        /* get  available List   */
        /** ***********************/
        helper.hideMessage(component);

        var campaignId = component.get('v.recordId');
        var availableListAction = component.get('c.initPicklistClienteling');
        availableListAction.setParams({
            CampaignId: campaignId,
            isReset: isReset
        });
        availableListAction.setStorable();
        availableListAction.setCallback(this, function availableListActionCallback(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var availableList = response.getReturnValue();

                helper.initPicklistValue(component, availableList);
            } else {
                var errors = response.getError();
                component.set('v.messageType', 'error');
                if (errors[0] && errors[0].message) {
                    component.set('v.message', errors[0].message);
                }
            }
        });

        $A.enqueueAction(availableListAction);
    },

    /**
     * hideMessage: hide all message
     */
    hideMessage: function hideMessage(component) {
        component.set('v.displayMessage', false);
    },

    /**
     * InitPicklistValue: inititalize value of pickist
     */
    initPicklistValue: function initPicklistValue(component, availableList) {
        var regions = availableList.Regions;
        var countries = availableList.Countries;
        var stores = availableList.Stores;
        var status = availableList.Status;
        var allregions = [];
        var allcountries = [];
        var allstores = [];

        if (status.isAll === 'true') {
            allregions.push({ value: $A.get('$Label.c.cel_Region_Name_ALL'), key: $A.get('$Label.c.cel_Region_Name_ALL') });
        } else {
            for (let key in regions) {
                if (regions[key]) {
                    allregions.push({
                        value: regions[key],
                        key: key
                    });
                }
            }
        }

        for (let key in countries) {
            if (countries[key]) {
                allcountries.push({
                    value: countries[key],
                    key: key
                });
            }
        }

        for (let key in stores) {
            if (stores[key]) {
                allstores.push({
                    value: stores[key],
                    key: key
                });
            }
        }

        component.set('v.campaignregionsList', allregions);
        component.set('v.campaignCountriesList', allcountries);
        component.set('v.campaignStoresList', allstores);

        if (status.isActive === 'true') {
            // Set message
            component.set('v.messageType', 'info');
            component.set('v.message', $A.get('$Label.c.cel_campaign_store_disabled_message'));
            component.set('v.displayMessage', true);

            component.set('v.ListDisabled', true);
            component.set('v.buttonDisabled', true);
            let header = component.find('divHeader');
            $A.util.addClass(header, 'hide');
        } else {
            component.set('v.ListDisabled', false);
            component.set('v.buttonDisabled', false);
            let header = component.find('divHeader');
            $A.util.removeClass(header, 'hide');
        }

        if (status.isNotSave === 'true') {
            // Set message
            component.set('v.messageType', 'warning');
            component.set('v.message', $A.get('$Label.c.cel_campaign_store_not_save_message'));
            component.set('v.displayMessage', true);
        }
    }
});