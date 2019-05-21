public class CEL_TheContactsController {
    
    /**
     * getCampaignCurrency : get the current currency of campaign
     * @param  {String} campaignIds
     * @return {Campaign}
     */
    @AuraEnabled
    public static Campaign getCampaignCurrency(String campaignIds){
        Campaign c = new Campaign();
        List<Campaign> listCamp = [SELECT id, ToLabel(cel_local_Currency__c) currencccy FROM campaign WHERE id = : campaignIds];
        
        if(listCamp != null && !listCamp.isEmpty()){
            c = listCamp.get(0);
        }
        
        return c;
    }
    
    /**
     * getCampaignMemberStatusList : Get list of Campaign members status by campaign Id, filterName and customerCode
     * @param  {String} campaignIds
     * @param  {String} filterName description
     * @param  {String} filtCustomerCode
     * @return  {List<cel_Campaign_Member_Status__c>}
     */
    @AuraEnabled
    public static List<cel_Campaign_Member_Status__c> getCampaignMemberStatusList(String campaignIds, String filterName, String filtCustomerCode){
        List<cel_Campaign_Member_Status__c> listCampaMemberStatus = new List<cel_Campaign_Member_Status__c>();
        
        String filterRequest = '';
        String filterCustomerCode = '';
        if(String.isNotBlank(filterName)){
           filterRequest = '%'+filterName+'%';
        }
        if(String.isNotBlank(filtCustomerCode)){
            filterCustomerCode = '%'+filtCustomerCode+'%';
        }
        
        //Add the id of the campaign
        String contactListQuery = 'select cel_Campaign__c, id, cel_Customer_Code__c, cel_Invited__c, cel_Confirmed__c, cel_Contacted__c, ';
            contactListQuery += 'cel_show_up__c,cel_Res_w_dep__c, cel_Reswodep__c, cel_Purchasing__c,cel_ResWDep_Euro__c, ';
            contactListQuery += 'cel_ResWODep_Euro__c, Name, cel_Contact__r.name  ';
            contactListQuery += ' from cel_Campaign_Member_Status__c where cel_Campaign__c = :campaignIds ';
        
        //Filter Name or lastName
        if(String.isNotBlank(filterRequest) && String.isBlank(filterCustomerCode)){
            contactListQuery += '  and (cel_Contact__r.firstName like : filterRequest or cel_Contact__r.lastName like : filterRequest) ';
        }
        
        //customer Code
        if(String.isNotBlank(filterCustomerCode) && String.isBlank(filterRequest)){
            contactListQuery += '  and cel_Customer_Code__c like : filterCustomerCode ';
        }
        
        //Both criteria are mentionned!
        if(String.isNotBlank(filterRequest) && String.isNotBlank(filterCustomerCode)){
            contactListQuery += '  and (cel_Contact__r.firstName like : filterRequest or cel_Contact__r.lastName like : filterRequest OR cel_Customer_Code__c like : filterCustomerCode) ';
        }
        
        //if no filter, then display the members existing
        contactListQuery += ' order by cel_Contact__r.firstName ';
        listCampaMemberStatus = database.query(contactListQuery);
        
        return listCampaMemberStatus;
    }
    
    /**
     * updateTheCampaignMembersStatus : Update the campaign Members Status
     * @param   {List<String>} campaignMembersId
     * @param   {List<Boolean>} inviteds
     * @param   {List<Boolean>} contacteds
     * @param   {List<Boolean>} confirmeds
     * @param   {List<Boolean>} purchasings
     * @param   {List<Decimal>} reswdeps
     * @param   {List<Decimal>} reswodeps
     * @return  {Boolean}
     */
    @AuraEnabled
    public static Boolean updateTheCampaignMembersStatus(List<String> campaignMembersId, List<Boolean> inviteds, List<Boolean> contacteds, List<Boolean> confirmeds, List<Boolean> showups, List<Boolean> purchasings, List<Decimal> reswdeps, List<Decimal> reswodeps){
        Boolean result = false;
        List<cel_Campaign_Member_Status__c> listCms = new List<cel_Campaign_Member_Status__c>();
        integer i = 0;
        for(String cms : campaignMembersId){
            Decimal reswidep = 0;
            Decimal reswoidep = 0;
            reswidep = ( reswdeps != null && reswdeps.get(i)!= null) ? reswdeps.get(i) : 0;
            reswoidep = ( reswodeps != null && reswodeps.get(i)!= null ) ? reswodeps.get(i) : 0;
            
            cel_Campaign_Member_Status__c cmpcst = new cel_Campaign_Member_Status__c(
                id=cms,
                cel_Invited__c =inviteds.get(i),
                cel_Contacted__c = contacteds.get(i),
                cel_Confirmed__c = confirmeds.get(i) ,
                cel_show_up__c = showups.get(i),
                cel_Purchasing__c = purchasings.get(i),
                cel_Res_w_dep__c = reswidep,
                cel_Reswodep__c =  reswoidep );
            
            listCms.add(cmpcst);
            i++;
        }
        
        if(!listCms.isempty()){
            result = true;
            update listCms;
        }
        
        return result;
    }
    
    /**
     * getContacts : get all contacts by campaignId, filterNmae and customerCode
     * @param  {String} campaignIds
     * @param  {String} filterName
     * @param  {String} filtCustomerCode
     * @return {List<Account>}
     */
    @AuraEnabled
    public static List<Account> getContacts(String campaignIds, String filterName, String customerCode){
        Id personAccountRt = CEL_Constants.peronAccountRtID;
        List<account> listAccounts = new List<Account>();
        String filterRequest = '';
        String filterCustomerCode = '';
        
        if(String.isNotBlank(filterName)){
           filterRequest = '%'+filterName+'%';
        }
        
        if(String.isNotBlank(customerCode)){
            filterCustomerCode = '%'+customerCode+'%';
        }
        
        List<cel_Campaign_Member_Status__c> listCampaignMemberStatus = [select id, cel_contact__c
                                                                        from cel_Campaign_Member_Status__c
                                                                        where cel_Campaign__c =: campaignIds];
        Set<String> setContactsToExclude = new Set<String>();
        for(cel_Campaign_Member_Status__c cs : listCampaignMemberStatus){
            setContactsToExclude.add(cs.cel_contact__c);
        }
        
        String contactListQuery = 'SELECT PersonContactID, Name, lastName, firstName, Id, cel_ext_account_id__c, cel_segment_value_label__c, PersonEmail, cel_PersonEmail__c, PersonHomephone ';
        contactListQuery += 'from Account where Recordtypeid = :personAccountRt ';
        
        // name only
        if(String.isNotBlank(filterRequest) && String.isBlank(filterCustomerCode)){
            contactListQuery += ' and Name like : filterRequest ';
        }
        
        //customer Code only
        if(String.isNotBlank(filterCustomerCode) && string.isBlank(filterRequest)){
            contactListQuery += ' and cel_ext_account_id__c like : filterCustomerCode  ';
        }
        
        //Both criteria are mentionned!
        if(String.isNotBlank(filterRequest) && String.isNotBlank(filterCustomerCode)){
            contactListQuery += ' and (Name like : filterRequest OR cel_ext_account_id__c like : filterCustomerCode) ';
        }
        
        //filter on my segments no need !
        if(!setContactsToExclude.isempty()){
            contactListQuery += '  and PersonContactID not in :setContactsToExclude ';
        }
        
        if(filterRequest == '' && filterCustomerCode == ''){
            listAccounts = new List<Account>();
        }
        else{
            contactListQuery += ' order by Name ASC ';
            listAccounts = database.query(contactListQuery);
        }
        
        return listAccounts;
    }
    
    /**
     * addContactToCampaignmemberStatus : Add the campaign Members Status on the campaign current
     * @param  {String} CampaignId
     * @param  {List<String>} listAccountId
     */
    @AuraEnabled
    public static void addContactToCampaignmemberStatus(String CampaignId, List<String> listAccountId){
        List<cel_Campaign_Member_Status__c> lstCampMemberStatus = new List<cel_Campaign_Member_Status__c>();
        List<Account> listAccounts = new List<Account>();
        listAccounts = [select ID, PersonContactID from Account where id in : listAccountId];
        Map<String, String> map_idContact_idAccount = new Map<string, String>();
        
        for(Account c : listAccounts){
            map_idContact_idAccount.put(c.ID, c.PersonContactID);
        }
        
        if(CampaignId != null){
            for(String accountId : listAccountId){
                //afect members to Campaign member Status
                cel_Campaign_Member_Status__c cmpMemStatus = new cel_Campaign_Member_Status__c(
                                                                                                cel_Member_Name__c = accountId,
                                                                                                cel_Campaign__c = CampaignId,
                                                                                                cel_Contact__c = map_idContact_idAccount.get(accountId)
                                                                                            );
                
                lstCampMemberStatus.add(cmpMemStatus);
            }
        } 
        
        if(!lstCampMemberStatus.isEmpty()){
            try{
                insert lstCampMemberStatus;
            }
            catch(Exception ex){
                system.debug('error on creating Campaignmembers CLASS = CEL_TheContactsController '+ lstCampMemberStatus);
            }
        }
    }
    
    /**
     * gotoReportFolderCampaignAction : return link to the report
     * @return {String}
     */
    @AuraEnabled
    public static String gotoReportFolderCampaignAction(){
        return 'lightning/o/Report/home?queryScope=created';
    }
}