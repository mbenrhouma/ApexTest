({
    /*
     * DoInit: Called at component initialization
     */
    fetchCampaignDetails: function fetchCampaignDetails(component) {
        var getCampaignDetailsAction = component.get('c.getCampaignDetails');
        var campaignId = component.get('v.recordId');

        // Get details campaign
        getCampaignDetailsAction.setParams({
            CampaignId: campaignId
        });

        getCampaignDetailsAction.setCallback(this, function getCampaignDetailsActionCallBack(response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                var campaignDetail = response.getReturnValue();
                var getRegionCountryStoreAction = component.get('c.getRegionCountryStoresByCampaignId');
                getRegionCountryStoreAction.setParams({
                    CampaignId: campaignId
                });

                getRegionCountryStoreAction.setCallback(this, function getRegionCountryStoreActionCallBack(responseStore) {
                    var stateStore = responseStore.getState();
                    if (stateStore === 'SUCCESS') {
                        var regionCountryStore = responseStore.getReturnValue();
                        this.fillingValueList(component, regionCountryStore);
                    }
                });

                $A.enqueueAction(getRegionCountryStoreAction);
                component.set('v.campaignDetail', campaignDetail);
            }
        });

        // If Little Children : Make a fake update on a Members Status to refresh all calculs
        // If Campaign has children : Get details to his children and make sum
        var getDetailAndMakeCalculAction = component.get('c.getDetailAndMakeCalcul');
        getDetailAndMakeCalculAction.setParams({
            CampaignId: campaignId
        });

        getDetailAndMakeCalculAction.setCallback(this, function getDetailAndMakeCalculActionCallBack(responseDetail) {
            var stateDetail = responseDetail.getState();
            if (stateDetail === 'SUCCESS') {
                $A.enqueueAction(getCampaignDetailsAction);
                component.set('v.showLoadingSpinner', false);
            }
        });

        $A.enqueueAction(getDetailAndMakeCalculAction);
    },

    /*
     * getCampaignDetails: Called to refresh the component after save
     */
    getCampaignDetails: function getCampaignDetails(component) {
        var getCampaignDetailsAction = component.get('c.getCampaignDetails');
        var campaignId = component.get('v.recordId');

        // Get details campaign
        getCampaignDetailsAction.setParams({
            CampaignId: campaignId
        });

        getCampaignDetailsAction.setCallback(this, function getCampaignDetailsActionCallBack(response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                var campaignDetail = response.getReturnValue();
                var getRegionCountryStoreAction = component.get('c.getRegionCountryStoresByCampaignId');
                getRegionCountryStoreAction.setParams({
                    CampaignId: campaignId
                });

                getRegionCountryStoreAction.setCallback(this, function getRegionCountryStoreActionCallBack(responseStore) {
                    var stateStore = responseStore.getState();
                    if (stateStore === 'SUCCESS') {
                        var regionCountryStore = responseStore.getReturnValue();
                        this.fillingValueList(component, regionCountryStore);
                    }
                });

                $A.enqueueAction(getRegionCountryStoreAction);
                component.set('v.campaignDetail', campaignDetail);
            }
            component.set('v.showLoadingSpinner', false);
        });

        $A.enqueueAction(getCampaignDetailsAction);
    },

    /*
     * fillingValueList: filling value list
     */
    fillingValueList: function fillingValueList(component, regionCountryStore) {
        if (regionCountryStore.Stores) {
            var storeslist = regionCountryStore.Stores;
            var nbStores = storeslist.length;
            var nbColumn = Math.trunc(nbStores / 15);
            var classColumn = 'nbColumn-' + nbColumn;
            component.set('v.Store', storeslist);
            component.set('v.nbStores', nbStores);
            component.set('v.classColumn', classColumn);
        }

        if (regionCountryStore.Countries) {
            var countrieslist = regionCountryStore.Countries;
            var nbCountries = countrieslist.length;
            component.set('v.Country', countrieslist);
            component.set('v.nbCountries', nbCountries);
        }

        if (regionCountryStore.Regions) {
            var regionslist = regionCountryStore.Regions;
            var regions = regionslist.join(', ');
            component.set('v.Region', regions);
        }
    }
});