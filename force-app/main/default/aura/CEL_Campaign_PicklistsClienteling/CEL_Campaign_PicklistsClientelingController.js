({
    /**
     * doInit: Called at component initialization
     */
    doInit: function doInit(component, event, helper) {
        /** ***********************/
        /* get  available List   */
        /** ***********************/
        helper.getAvailableList(component, event, helper, false);
    },

    /**
    * getCountriesList: Called at region change to return available countries
    */
    getCountriesList: function getCountriesList(component, event, helper) {
        /** *******************************/
        /* get  available Country List   */
        /** ******************************/
        helper.hideMessage(component);
        var regions = component.find('InputSelectMultipleRegion').get('v.value');
        var countryListAction = component.get('c.getCountriesListByRegion');
        countryListAction.setParams({
            regions: regions
        });
        countryListAction.setStorable();
        countryListAction.setCallback(this, function countryListActionCallback(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var countries = response.getReturnValue();
                var allcountries = [];

                for (var key in countries) {
                    if (countries[key]) {
                        allcountries.push({
                            value: countries[key],
                            key: key
                        });
                    }
                }

                component.set('v.campaignCountriesList', allcountries);
            }
        });

        $A.enqueueAction(countryListAction);
    },

    /**
    * getStoreList: Called at region change to return available countries
    */
    getStoreList: function getStoreList(component, event, helper) {
        /** *******************************/
        /* get  available store List   */
        /** ******************************/
        var countries = component.find('InputSelectMultipleCountry').get('v.value');
        var storeListAction = component.get('c.getStoresListByCountry');
        helper.hideMessage(component);

        storeListAction.setParams({
            countries: countries
        });
        storeListAction.setStorable();
        storeListAction.setCallback(this, function storeListActionCallback(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var stores = response.getReturnValue();
                var allstores = [];

                for (var key in stores) {
                    if (stores[key]) {
                        allstores.push({
                            value: stores[key],
                            key: key
                        });
                    }
                }

                component.set('v.campaignStoresList', allstores);
            }
        });

        $A.enqueueAction(storeListAction);
    },

    /**
     * reset : Called at reset component
     */
    reset: function reset(component, event, helper) {
        /** ********************************/
        /* get  available List by parent  */
        /** *******************************/
        helper.getAvailableList(component, event, helper, true);
    },

    /**
    * save : Called at click on save button
    */
    save: function save(component, event, helper) {
        /** *****************/
        /* save List store */
        /** *****************/
        var campaignId = component.get('v.recordId');
        var stores = component.find('InputSelectMultipleStores').get('v.value');
        helper.hideMessage(component);

        if (stores) {
            var saveStoresAction = component.get('c.savePicklistClienteling');
            saveStoresAction.setParams({
                CampaignId: campaignId,
                stores: stores
            });
            saveStoresAction.setStorable();
            saveStoresAction.setCallback(this, function saveStoresActionCallback(response) {
                var state = response.getState();
                if (state === 'SUCCESS' && response.getReturnValue()) {
                    component.set('v.messageType', 'success');
                    component.set('v.message', $A.get('$Label.c.cel_campaign_store_save_success_message'));
                    component.set('v.displayMessage', true);
                } else {
                    component.set('v.messageType', 'error');
                    component.set('v.message', $A.get('$Label.c.cel_campaign_store_save_error_message'));
                    component.set('v.displayMessage', true);
                }
            });

            $A.enqueueAction(saveStoresAction);
        } else {
            component.set('v.messageType', 'error');
            component.set('v.message', $A.get('$Label.c.cel_campaign_members_store_requis_error_message'));
            component.set('v.displayMessage', true);
        }
    },

    /**
    * changeStoreList : Called at click on a store
    */
    changeStoreList: function changeStoreList(component, event, helper) {
        if (component.get('v.messageType') === 'error') {
            helper.hideMessage(component);
        }
    }
});