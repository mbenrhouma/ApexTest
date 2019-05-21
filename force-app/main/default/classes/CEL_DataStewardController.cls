public class CEL_DataStewardController {
    
    /**
    * getPersonAccount: Account infos for Account Page
    * @return {Account}
    */
    @AuraEnabled
    public static Account getContactDetails(Id accountId) {
        return CEL_AccountMgr.getContactDetails(accountId);
    }
}