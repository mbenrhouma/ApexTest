({
    /*
    * getControlCampaignDetails: Called at component initialization
     */
    getControlCampaignDetails: function getControlCampaignDetails(component, event, helper) {
        component.set('v.showLoadingSpinner', true);
        helper.fetchCampaignDetails(component);
    },

    /**
    * showStores : Called at mouse over stores names
    */
    showStores: function showStores(component) {
        var stores = component.find('divStoreHelpText');
        var classColumn = component.get('v.classColumn');
        $A.util.removeClass(stores, 'hide');
        $A.util.addClass(stores, classColumn);
    },

    /**
    * hideStores : Called at mouse leave stores names
    */
    hideStores: function hideStores(component) {
        var stores = component.find('divStoreHelpText');
        var classColumn = component.get('v.classColumn');
        $A.util.addClass(stores, 'hide');
        $A.util.addClass(stores, classColumn);
    },

    /**
    * showCountries : Called at mouse over countries names
    */
    showCountries: function showCountries(component) {
        var countries = component.find('divCountryHelpText');
        $A.util.removeClass(countries, 'hide');
    },

    /**
    * hideCountries : Called at mouse leave countries names
    */
    hideCountries: function hideCountries(component) {
        var countries = component.find('divCountryHelpText');
        $A.util.addClass(countries, 'hide');
    },

    /**
     * getCampaignDetail: Called to refresh the component after save
    */
    getCampaignDetail: function getCampaignDetail(component, event, helper) {
        component.set('v.showLoadingSpinner', true);
        helper.getCampaignDetails(component);
    }
});