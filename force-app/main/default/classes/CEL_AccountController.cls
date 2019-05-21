public with sharing class CEL_AccountController 
{
    private ApexPages.StandardSetController standardController;

    public CEL_AccountController (ApexPages.StandardSetController standardController)
    {
        this.standardController = standardController;
    }

    public PageReference openFlow()
    {       
        // Get the selected records
        List<Account> selectedAccounts = (List<Account>) standardController.getSelected();
        return null;      
    }

}