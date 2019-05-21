({
    /*
    * getCampaignMemberStatusListCtrl : init
    */
    getCampaignMemberStatusListCtrl: function getCampaignMemberStatusListCtrl(component, event, helper) {
        if (component.get('v.refresh')) {
            helper.getCampaignMemberStatusListHlp(component, event, helper);
        }
    },

    /*
    * handleClick : Manage this here for opening the campaign Member Status
    */
    handleClick: function handleClick(component, event) {
        var navEvt = $A.get('e.force:navigateToSObject');
        // get the recordid from the component
        var salesforceLink = event.target.id;

        navEvt.setParams({
            recordId: salesforceLink
        });
        navEvt.fire();
    },

    /*
    * updateAllmembersCtrl : Update all members
    */
    updateAllmembersCtrl: function updateAllmembersCtrl(component, event, helper) {
        // create array[list] type temp. variable for store child record's id's from selected checkboxes.
        var tempIDs = [];
        var inviteds = [];
        var contacteds = [];
        var confirmeds = [];
        var showups = [];
        var purchasings = [];
        var reswdeps = [];
        var reswodeps = [];

        // get(find) all checkboxes with aura:id "checkBox"
        var getCheckBoxInvited = component.find('checkBoxInvited');
        var getCheckBoxContacted = component.find('checkBoxContacted');
        var getCheckBoxConfirmed = component.find('checkBoxConfirmed');
        var getCheckBoxShowUp = component.find('checkBoxShowUp');
        var getCheckBoxPurchasing = component.find('checkBoxPurchasing');
        // get(find) all amounts with aura:id "checkBox"
        var getReswdepLocale = component.find('ReswdepLocale');
        var getReswodepLocale = component.find('ReswodepLocale');

        // play a for loop and check every checkbox values
        // if value is checked(true) then add those Id (store in Text attribute on checkbox) in tempIDs var.
        if (getCheckBoxInvited != null) {
            for (var i = 0; i < getCheckBoxInvited.length; i++) {
                // select those who checked
                tempIDs.push(getCheckBoxInvited[i].get('v.text'));

                // The Values True or false :) To Updates
                inviteds.push(getCheckBoxInvited[i].get('v.value'));
                contacteds.push(getCheckBoxContacted[i].get('v.value'));

                var confirms = getCheckBoxConfirmed[i].get('v.value');
                if (confirms === null || confirms === '') {
                    confirms = false;
                }
                confirmeds.push(confirms);
                showups.push(getCheckBoxShowUp[i].get('v.value'));
                purchasings.push(getCheckBoxPurchasing[i].get('v.value'));
                // Amounts
                reswdeps.push(getReswdepLocale[i].get('v.value'));
                reswodeps.push(getReswodepLocale[i].get('v.value'));
            }
        }

        console.log('Fabien');
        console.log('tempIDs');
        console.log(tempIDs);


        // call the helper function and pass all selected record id's.
        if (tempIDs != null) {

            console.log('inviteds');
            console.log(inviteds);
            console.log('contacteds');
            console.log(contacteds);
            console.log('confirmeds');
            console.log(confirmeds);
            console.log('showups');
            console.log(showups);
            console.log('purchasings');
            console.log(purchasings);
            console.log('reswdeps');
            console.log(reswdeps);
            console.log('reswodeps');
            console.log(reswodeps);


            helper.updateAllmembersHlp(component, event, tempIDs, inviteds,
                                        contacteds, confirmeds, showups,
                                        purchasings, reswdeps, reswodeps);
        }
    },

    /*
    * cancelUpdateAllMemberCtrl : Cancel the modification means reload the page call the init method
    */
    cancelUpdateAllMemberCtrl: function cancelUpdateAllMemberCtrl(component, event, helper) {
        helper.cancelUpdateAllMemberCtrlHlp(component, event, helper);
    }
});