global class CEL_BatchMergeAccount implements Database.Batchable<sObject>, Database.Stateful, Schedulable {

    private Map<String, Schema.SObjectField> accountFields;
    protected Id slaveRecordTypeId;
    protected Id masterRecordTypeId;
    
    public CEL_BatchMergeAccount() {
        this.slaveRecordTypeId = CEL_Constants.slavePersonAccountRtID;
        this.masterRecordTypeId = CEL_Constants.peronAccountRtID;
    
    }
    
    /**
     * execute
     * @param {SchedulableContext} sc
     */    
    global void execute(SchedulableContext sc)
    {
        CEL_BatchMergeAccount b = new CEL_BatchMergeAccount();      
        database.executebatch(b);
    }
    
    /**
     * start: Call when the batch begin
     * @param  {BatchableContext} BC
     * @return Database.QueryLocator
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        List<String> idGroupList = new List<String>();
        accountFields = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
        for(CEL_Customer_Duplication__c cd : [SELECT cel_idGroup__c FROM CEL_Customer_Duplication__c WHERE cel_insertionDate__c = TODAY]) {
            idGroupList.add(cd.cel_idGroup__c);
        } 
        
        return Database.getQueryLocator([SELECT ID FROM CEL_Customer_Duplication__c WHERE cel_idGroup__c IN :idGroupList and cel_insertionDate__c = TODAY]);
    }
    
    /**
     * execute: Call when the start method retrieve data
     * @param  {BatchableContext} BC
     * @param [{Account}] accounts
     */
    global void execute(Database.BatchableContext BC, List<CEL_Customer_Duplication__c> recordSets) {
        
        List<CEL_Customer_Duplication__c> recordItems = [SELECT ID, cel_idGroup__c, cel_account__c,cel_is_treated_flag__c FROM CEL_Customer_Duplication__c WHERE ID IN :recordSets and cel_account__c != null];
        
        /*------------------GET ALL ACCOUNTS TO MERGE-------------------*/
        Set<Id> accountIds = new Set<Id>();
                
        //add a list of CEL_Customer_Duplication__c objects with only Id and treatedFlag
        List<CEL_Customer_Duplication__c> recordItemsToUpdateFlag = new List<CEL_Customer_Duplication__c>();
        
        for(CEL_Customer_Duplication__c recordItem : recordItems) {
            accountIds.add(recordItem.cel_account__c);
            
            CEL_Customer_Duplication__c toUpdateItem = new CEL_Customer_Duplication__c(Id = recordItem.Id, cel_is_treated_flag__c = recordItem.cel_is_treated_flag__c);
            recordItemsToUpdateFlag.add(toUpdateItem);
        }
        
        String query = 'SELECT Id, PersonContactId, FirstName, LastName, LastModifiedDate, cel_creation_date__c, RecordTypeId, cel_master_account_id__c, '
                        + 'cel_slave_created_date__c, cel_ext_account_id__c, Type, cel_nb_transactions_12_months__c, '
                        + 'cel_addr_1_line_1__c, cel_addr_1_line_2__c, cel_addr_1_line_3__c, cel_addr_1_zipcode__c, cel_addr_1_city__c, cel_addr_1_region__c, cel_addr_1_country__c, '
                        + 'PersonEmail, PersonMobilePhone, PersonHomePhone, PersonOtherPhone, cel_birthdate_day__c, cel_birthdate_month__c, cel_birthdate_year__c, cel_is_email_contactibiliy__c, cel_is_phone_contactability__c, '
                        + 'PersonBirthDate, cel_is_post_contactability__c, cel_email_mailable__c, cel_mobile_mailable__c, cel_homephone_mailable__c, cel_address_mailable__c, cel_addr_1_validity__c, '
                        + 'cel_mobile_validity__c, cel_homephone_validity__c, cel_PersonEmail__c, cel_email_validity__c, cel_do_not_email__c, cel_optin_postal_mail__c, '
                        + 'cel_optin_sms__c,cel_is_active__pc,cel_desactivation_date__c '
                        + 'FROM Account ' 
                        + 'WHERE Id IN :accountIds '
                        + 'AND (cel_do_not_merge__c = false) '
                        + 'ORDER BY LastModifiedDate DESC';
                        
        Map<Id, Account> allAccounts = new Map<Id, Account> ((List<Account>)Database.query(query));
                
        /*----------------CREATE RECORDSET ACCOUNTS MAP-----------------*/
        Map<String, List<Account>> recordAccounts = new Map<String, List<Account>>();
        
        for(CEL_Customer_Duplication__c recordItem : recordItems) {
            String idGroup = recordItem.cel_idGroup__c;
            List<Account> duplicateAccountsList;
            if(recordAccounts.get(idGroup) != null) {
                duplicateAccountsList = recordAccounts.get(idGroup);
            } else {
                duplicateAccountsList = new List<Account>();
                recordAccounts.put(idGroup, duplicateAccountsList);
            }
            duplicateAccountsList.add(allAccounts.get(recordItem.cel_account__c));
        }
        
        /*---------------DO THE MERGE FROM PREVIOUS MAP-----------------*/
        Schema.DescribeSObjectResult describeResult = Account.SObjectType.getDescribe();
        List<Schema.ChildRelationship> lstchildrelationships = describeResult.getChildRelationships();
        
        Set<Account> toDisableAccounts = new Set<Account>();
        Set<Account> toUpdateAccounts = new Set<Account>();
        Map<String, Map<String, Map<Id, Set<Account>>>> toReassignObjectsMap = new Map<String, Map<String, Map<Id, Set<Account>>>>();
        
        Map<String, List<Account>> toMergeAccountsList = new Map<String, List<Account>>();
        Map<String, List<Account>> toMergeNewsletterAccountsList = new Map<String, List<Account>>();
        Map<String, Map<String, Map<String, Set<Account>>>> objsToUpdate = new Map<String, Map<String, Map<String, Set<Account>>>>();
        
        Map<Id, Account> masterAccounts = new Map<Id, Account>();
        for(List<Account> accountsToMerge : recordAccounts.values()) {
            
            if(accountsToMerge.size() > 1) {  
                List<Account> slaveListToMerge = new List<Account>();
                Map<String, List<Account>> masterAndSlaves;
                
                masterAndSlaves = getMasterAndSlaves(accountsToMerge);
                Account master = masterAndSlaves.get('master').get(0);
                masterAccounts.put(master.Id, master);     
                       
                slaveListToMerge.addAll(masterAndSlaves.get('slaves'));
                if(master != null) {
                    this.mergeAccounts(master, slaveListToMerge);
                    this.addReassignLookupObjects(master, slaveListToMerge, lstchildrelationships, toReassignObjectsMap);
                    
                    toUpdateAccounts.add(master);
                    toDisableAccounts.addAll(slaveListToMerge);
                }
            }
        }
     
        this.reassignLookupObjects(masterAccounts, toReassignObjectsMap);
        
        //update & disable accounts   
        
        if(toDisableAccounts.size()>0){
            Database.SaveResult[] srList = Database.update(new List<Account>(toDisableAccounts),false);
            delete new List<Account>(toDisableAccounts);
        }     
        
        if(toUpdateAccounts.size()>0){
            Database.SaveResult[] srList = Database.update(new List<Account>(toUpdateAccounts),false);
        }
        
        //update cel_customer_duplication__c with the treated flag to true
        if(recordItemsToUpdateFlag.size() > 0){
            for(CEL_Customer_Duplication__c recordItem : recordItemsToUpdateFlag) {
                recordItem.cel_is_treated_flag__c = true;
            }
            update recordItemsToUpdateFlag; 
        }
        
    }
    
    /**
     * mergeAccounts: Merge all newest personAccounts (duplicates) to the latest (master) 
     * @param Account master
     * @param List<Account> duplicates
     * @param Boolean isNewsletterAccount
     */
    private void mergeAccounts(Account master, List<Account> duplicates)
    {
        
        if(duplicates != null) {
            Map<String, List<Account>> mostRecent = getMostRecent(master, duplicates);
            master = mergeAddress(master, mostRecent.get('address'));
            master = mergeEmail(master, mostRecent.get('email'));
            master = mergeMobile(master, mostRecent.get('mobile'));
            master = mergeHomePhone(master, mostRecent.get('homephone'));
            master = mergeBirthDate(master, mostRecent.get('birthdate'));
            master = mergeOptinPhone(master, mostRecent.get('optinPhone'));

            for(Account duplicate : duplicates)
            {
                // Set duplicate account to disabled status and to Slave PersonAccount Record Type
                duplicate.cel_master_account_id__c = master.Id;
                duplicate.RecordTypeId = this.slaveRecordTypeId;
                if(duplicate.cel_slave_created_date__c == null) {
                    duplicate.cel_slave_created_date__c = DateTime.now();
                }
                duplicate.cel_desactivation_date__c = Date.today();
                duplicate.cel_is_active__pc = false;
            }
        }
        
        // Set master account to Master PersonAccount Record Type
        master.cel_master_account_id__c = null;
        master.RecordTypeId = this.masterRecordTypeId;
    }
    
    /**
     * addReassignLookupObjects: add master and duplicated accounts 
     * in a map to build list of objet and update their lookups.
     * @param  Account master
     * @param List<Account> accounts
     * @param List<Schema.ChildRelationship> lstchildrelationships
     * @param Map<String, Map<String, Map<Id, Set<Account>>>> toReassignObjectsMap
     */
    private void addReassignLookupObjects(Account master,
                                        List<Account> duplicates,
                                        List<Schema.ChildRelationship> lstchildrelationships,
                                        Map<String, Map<String, Map<Id, Set<Account>>>> toReassignObjectsMap)
    {
        // Stock to the Map "toReassignObjectsMap" objects which must be update
        for(Schema.ChildRelationship relname: lstchildrelationships)
        {
            Schema.DescribeSObjectResult currentObject = relname.getChildSObject().getDescribe();
            String objectName = currentObject.getName();
            Schema.DescribeFieldResult ff = relname.getField().getDescribe();
            String currentFieldName = ff.getName();
            
            if(currentObject.isSearchable() == true 
            && objectName != 'Contact' 
            && objectName != 'Account'
            && objectName != 'CEL_Customer_Duplication__c' 
            && objectName != 'CEL_Bounces__c' 
            && objectName != 'Individual' 
            && ff.isUpdateable()
            || objectName == 'CampaignMember') 
            {
                if(!toReassignObjectsMap.containsKey(objectName)) {
                    toReassignObjectsMap.put(objectName, new Map<String, Map<Id, Set<Account>>>());
                }
                
                Map<String, Map<Id, Set<Account>>> currentObj = toReassignObjectsMap.get(objectName);
                if(!currentObj.containsKey(currentFieldName)) {
                    currentObj.put(currentFieldName, new Map<Id, Set<Account>>());
                }
                
                Map<Id, Set<Account>> currentField = currentObj.get(currentFieldName);
                Set<Account> currentDuplicateList;
                if(!currentField.containsKey(master.Id)) {
                    currentDuplicateList = new Set<Account>();
                    currentField.put(master.Id, currentDuplicateList);
                } else {
                    currentDuplicateList = currentField.get(master.Id);
                }
                
                currentDuplicateList.addAll(duplicates);
            }
        }
    }
    
    /**
     * reassignLookupObjects: build a list of objets and update their lookups.
     * @param Map<Id, Account> masterAccounts
     * @param Map<String, Map<String, Map<Id, Set<Account>>>> toReassignObjectsMap
     */
    private void reassignLookupObjects(Map<Id, Account> masterAccounts, Map<String, Map<String, Map<Id, Set<Account>>>> toReassignObjectsMap) {
        // Update all objects from the Map "objsToUpdate" 
        List<sObject> toReassignObjects = new List<sObject>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        
        Set<sObject> campaignMemberToCreate = new Set<sObject>();
        Set<sObject> campaignMemberToDelete = new Set<sObject>();

        for(String objectName : toReassignObjectsMap.keySet())
        {
            Map<String, Map<Id, Set<Account>>> fieldsList = toReassignObjectsMap.get(objectName);
            Set<String> objFields = schemaMap.get(objectName).getDescribe().fields.getMap().keySet();

            if(objectName != 'CampaignMember') {
                for(sObject obj: getResultFromObject(objectName, fieldsList, null)) 
                {
                    Boolean toReassign = false;
                    for(String fieldName: fieldsList.keySet()) 
                    {
                        if(objFields.contains(fieldName.toLowerCase()) && fieldsList.containsKey(fieldName))
                        {
                            // Map key = Master Account thant contains a Set of slaves
                            Map<Id, Set<Account>> field = fieldsList.get(fieldName);
                            for(Id masterId : field.keySet()) 
                            {
                                Account master = masterAccounts.get(masterId);
                                for(Account duplicate : field.get(masterId)) 
                                {
                                    Boolean setSlave = false;

                                    // Set master ID instead of duplicate ID to transfer record property
                                    if(obj.get(fieldName) == duplicate.Id) {
                                        obj.put(fieldName, master.Id);
                                        setSlave = true;
                                        toReassign = true;
                                    } 
                                    
                                    if(obj.get(fieldName) == duplicate.PersonContactId) {
                                        obj.put(fieldName, master.PersonContactId);
                                        setSlave = true;
                                        toReassign = true;
                                    }
                                }
                            }
                        }
                    }
                    
                    if(toReassign) {
                        toReassignObjects.add(obj);
                    }
                }
            } else {
                // Specific process for campaignMember because contactId is not updatable
                // Create new campaignMember and remove old
                Map<String, Schema.SObjectField> fMap = schemaMap.get(objectName).getDescribe().fields.getMap();
                Set<String> creatableFields = new set<string>();
                
                if (fMap != null){
                    for (Schema.SObjectField ft : fMap.values()){
                        Schema.DescribeFieldResult fd = ft.getDescribe();
                        if (fd.isCreateable() && !fd.isUnique()){
                            creatableFields.add(fd.getName());
                        }
                    }
                }
                creatableFields.add('LeadOrContactId');
                for(sObject obj: getResultFromObject(objectName, fieldsList, creatableFields)) 
                {
                    Boolean toCreate = false;
                    sObject newObject;
                    for(String fieldName: fieldsList.keySet()) 
                    {
                        if(objFields.contains(fieldName.toLowerCase()) && fieldsList.containsKey(fieldName))
                        {
                            // Map key = Master Account thant contains a Set of slaves
                            Map<Id, Set<Account>> field = fieldsList.get(fieldName);
                            for(Id masterId : field.keySet()) 
                            {
                                Account master = masterAccounts.get(masterId);
                                for(Account duplicate : field.get(masterId)) 
                                {
                                    // Set master ID instead of duplicate ID to transfer record property
                                    if(obj.get(fieldName) == duplicate.Id) {
                                        newObject = obj.clone(false, true);
                                        newObject.put('ContactId', master.Id);
                                        toCreate = true;
                                    } 
                                    
                                    if(obj.get(fieldName) == duplicate.PersonContactId) {
                                        newObject = obj.clone(false, true);
                                        newObject.put('ContactId', master.PersonContactId);
                                        toCreate = true;
                                    }
                                }
                                campaignMemberToDelete.add(obj);
                            }
                        }
                    }
                    if(toCreate) {
                        campaignMemberToCreate.add(newObject);
                    }
                }
            }         
        }
        
        update toReassignObjects;
        delete new List<sObject>(campaignMemberToDelete);
        Database.insert(new List<sObject>(campaignMemberToCreate), false);
    }

    /**
     * getMasterAndSlaves
     * @param List<Account>
     * @return Map<String, List<Account>>
     */
    private Map<String, List<Account>> getMasterAndSlaves(List<Account> accounts) {
        Map<String, List<Account>> masterAndSlaves = new Map<String, List<Account>>();
        List<Account> masters = new List<Account>();
        List<Account> slaveListToMerge = new List<Account>();
        List<Account> multiMasters = new List<Account>();
        
        Account master;
        Integer nbAccount_CLI = 0;
        Integer nbAccount_PRO = 0;
        Double maxNbTransaction = -1;
        
        DateTime maxLastModifiedDate;
        DateTime maxCreatedDate;
        String smallestCustomerCode;
        List<Account> multiMaxLastModifiedDateMasters = new List<Account>();
        List<Account> multiMaxCreatedDateMasters = new List<Account>();
        // Find master account
        for(Account acc: accounts) {
            // Check type
            if(acc.type == 'CLI') {
                nbAccount_CLI++;
            }
            if(acc.type == 'PRO') {
                nbAccount_PRO++;
            }                    
            
            // Check nb transaction
            if(maxNbTransaction == -1) {
                maxNbTransaction = acc.cel_nb_transactions_12_months__c;
                master = acc;
            } else if(maxNbTransaction < acc.cel_nb_transactions_12_months__c) {
                maxNbTransaction = acc.cel_nb_transactions_12_months__c;
                master = acc;
                multiMasters.clear();
            } else if (maxNbTransaction == acc.cel_nb_transactions_12_months__c) {
                if(multiMasters.size() == 0) {
                    multiMasters.add(master);
                }
                multiMasters.add(acc);
            }
        }

        // All accounts are CLI
        if(nbAccount_CLI == accounts.size()) {
            if(multiMasters.size() > 0) {
                // Check lastmodifiedDate in multiMasters
                for(Account am: multiMasters) {
                    if(maxLastModifiedDate == null) {
                        maxLastModifiedDate = am.LastModifiedDate;
                        master = am;
                    } else if(maxLastModifiedDate < am.LastModifiedDate) {
                        master = am;
                    } else if(maxLastModifiedDate == am.LastModifiedDate) {
                        if(multiMaxLastModifiedDateMasters.size() == 0) {
                            multiMaxLastModifiedDateMasters.add(master);
                        }
                        multiMaxLastModifiedDateMasters.add(am);
                    }
                }
                
                //Check created date
                if(multiMaxLastModifiedDateMasters.size() > 1) {
                    for(Account al: multiMaxLastModifiedDateMasters) {
                        if(maxCreatedDate == null) {
                            maxCreatedDate = al.cel_creation_date__c;
                            master = al;
                        } else if(maxCreatedDate < al.cel_creation_date__c) {
                            master = al;
                        } else if(maxCreatedDate == al.cel_creation_date__c) {
                            if(multiMaxCreatedDateMasters.size() == 0) {
                                multiMaxCreatedDateMasters.add(master);
                            }
                            multiMaxCreatedDateMasters.add(al);
                        }
                    }
                }
                
                //Check smallest customer code
                if(multiMaxCreatedDateMasters.size() > 1) {
                    for(Account ac: multiMaxCreatedDateMasters) {
                        if(smallestCustomerCode == null) {
                            smallestCustomerCode = ac.cel_ext_account_id__c;
                            master = ac;
                        } else if(smallestCustomerCode < ac.cel_ext_account_id__c) {
                            master = ac;
                        }
                    }
                }
            }
        } else 
            // All accounts are PRO
            if(nbAccount_PRO == accounts.size()) {
                for(Account ag: accounts) {
                    if(maxLastModifiedDate == null) {
                        maxLastModifiedDate = ag.LastModifiedDate;
                        master = ag;
                    } else if(maxLastModifiedDate < ag.LastModifiedDate) {
                        master = ag;
                    } else if(maxLastModifiedDate == ag.LastModifiedDate) {
                        if(multiMaxLastModifiedDateMasters.size() == 0) {
                            multiMaxLastModifiedDateMasters.add(master);
                        }
                        multiMaxLastModifiedDateMasters.add(ag);
                    }
                }
                
                //Check created date
                if(multiMaxLastModifiedDateMasters.size() > 1) {
                    for(Account alm: multiMaxLastModifiedDateMasters) {
                        if(maxCreatedDate == null) {
                            maxCreatedDate = alm.cel_creation_date__c;
                            master = alm;
                        } else if(maxCreatedDate < alm.cel_creation_date__c) {
                            master = alm;
                        }
                    }
                }
        }

        masters.add(master);
        for(Account acct : accounts) {
            if(acct.Id != master.Id){
                slaveListToMerge.add(acct);
            }
        }
        masterAndSlaves.put('master', masters);
        masterAndSlaves.put('slaves', slaveListToMerge);
        return masterAndSlaves;
    }


    /**
     * getMostRecent: Retrieve most recent value for each fields
     * @param  {Account} master account
     * @param  List<Account> slave account
     * @return Map<String, List<Account>>
     */
    private Map<String, List<Account>> getMostRecent(Account master, List<Account> slavesAccount) {
        Map<String, List<Account>> mostRecent = new Map<String, List<Account>>();
        List<Account> addressMailable = new List<Account>();
        List<Account> emailMailable = new List<Account>();
        List<Account> mobileMailable = new List<Account>();
        List<Account> homephoneMailable = new List<Account>();
        List<Account> personBirthDate = new List<Account>();
        List<Account> optinPhone = new List<Account>();
        DateTime masterLastModifiedDate = master.LastModifiedDate;

        for(Account slave : slavesAccount) {
            if(slave.cel_address_mailable__c == 'Y' && slave.cel_addr_1_validity__c) {
                addressMailable.add(slave);
            }

            if(masterLastModifiedDate < slave.LastModifiedDate) {
                if(slave.PersonBirthDate != null) {
                    personBirthDate.add(slave);
                }
            }
            
            if(slave.cel_email_mailable__c == 'Y'
                && (slave.cel_PersonEmail__c != null || slave.PersonEmail != null)
                && slave.cel_email_validity__c) {
                emailMailable.add(slave);
            }

            if(slave.cel_mobile_mailable__c == 'Y' && slave.cel_mobile_validity__c) {
                mobileMailable.add(slave);
                optinPhone.add(slave);
            }
            
            if(slave.cel_homephone_mailable__c == 'Y' && slave.cel_homephone_validity__c) {
                homephoneMailable.add(slave);
            }
        }

        mostRecent.put('address', addressMailable);
        mostRecent.put('email', emailMailable);
        mostRecent.put('mobile', mobileMailable);
        mostRecent.put('homephone', homephoneMailable);
        mostRecent.put('birthdate', personBirthDate);
        mostRecent.put('optinPhone', optinPhone);

        return mostRecent;
    }


    /**
     * mergeAddress: Merge address fields to master
     * @param  {Account} master account
     * @param  List<Account> slave account with available values
     * @return {Account}
     */
    private Account mergeAddress(Account master, List<Account> slavesAvailable) {
        if(slavesAvailable.size() > 0) {
            Account slave = slavesAvailable.get(0);
            master.cel_addr_1_line_1__c = slave.cel_addr_1_line_1__c;
            master.cel_addr_1_line_2__c = slave.cel_addr_1_line_2__c;
            master.cel_addr_1_line_3__c = slave.cel_addr_1_line_3__c;
            master.cel_addr_1_zipcode__c = slave.cel_addr_1_zipcode__c;
            master.cel_addr_1_city__c = slave.cel_addr_1_city__c;
            master.cel_addr_1_region__c = slave.cel_addr_1_region__c;
            master.cel_addr_1_country__c = slave.cel_addr_1_country__c;
            master.cel_addr_1_validity__c = slave.cel_addr_1_validity__c;
            master.cel_is_post_contactability__c = slave.cel_is_post_contactability__c;
            master.cel_optin_postal_mail__c = slave.cel_optin_postal_mail__c;
        }

        return master;
    }

    /**
     * mergeEmail: Merge email field to master
     * @param  {Account} master account
     * @param  List<Account> slave account with available values
     * @return {Account}
     */
    private Account mergeEmail(Account master, List<Account> slavesAvailable) {
        if(slavesAvailable.size() > 0) {
            Account slave = slavesAvailable.get(0);
            master.PersonEmail = slave.cel_PersonEmail__c;
            master.cel_PersonEmail__c = slave.cel_PersonEmail__c;
            master.cel_do_not_email__c = slave.cel_do_not_email__c;
            master.cel_is_email_contactibiliy__c = slave.cel_is_email_contactibiliy__c;
            master.cel_email_validity__c = slave.cel_email_validity__c;
        }

        return master;
    }

    /**
     * mergeMobile: Merge mobile field to master
     * @param  {Account} master account
     * @param  List<Account> slave account with available values
     * @return {Account}
     */
    private Account mergeMobile(Account master, List<Account> slavesAvailable) {
        if(slavesAvailable.size() > 0) {
            Account slave = slavesAvailable.get(0);
            master.PersonMobilePhone = slave.PersonMobilePhone;
            master.cel_mobile_validity__c = slave.cel_mobile_validity__c;
        }

        return master;
    }

    /**
     * mergeHomePhone: Merge home phone field to master
     * @param  {Account} master account
     * @param  List<Account> slave account with available values
     * @return {Account}
     */
    private Account mergeHomePhone(Account master, List<Account> slavesAvailable) {
        if(slavesAvailable.size() > 0) {
            Account slave = slavesAvailable.get(0);
            master.PersonHomePhone = slave.PersonHomePhone;
            master.cel_homephone_validity__c = slave.cel_homephone_validity__c;
        }

        return master;
    }

    /**
     * mergeBirthDate: Merge birth date field to master
     * @param  {Account} master account
     * @param  List<Account> slave account with available values
     * @return {Account}
     */
    private Account mergeBirthDate(Account master, List<Account> slavesAvailable) {
        if(slavesAvailable.size() > 0) {
            Account slave = slavesAvailable.get(0);
            Date birthDate = slave.PersonBirthDate;
            master.PersonBirthDate = slave.PersonBirthDate;
            master.cel_birthdate_day__c = birthDate.day();
            master.cel_birthdate_month__c = birthDate.month();
            master.cel_birthdate_year__c = birthDate.year();
        }

        return master;
    }

    /**
     * mergeOptinPhone: Merge optin phone field to master
     * @param  {Account} master account
     * @param  List<Account> slave account with available values
     * @return {Account}
     */
    private Account mergeOptinPhone(Account master, List<Account> slavesAvailable) {
        if(slavesAvailable.size() > 0) {
            Account slave = slavesAvailable.get(0);
            master.cel_is_phone_contactability__c = slave.cel_is_phone_contactability__c;
            master.cel_optin_sms__c = slave.cel_optin_sms__c;
        }

        return master;
    }

    /**
     * getResultFromObject: Retrieve fields value from object
     * @param {String} objectName
     * @param {Map<String, Map<Id, Set<Account>>>} fieldsList
     * @return {sObject[]}
     */
    private sObject[] getResultFromObject(String objectName, Map<String, Map<Id, Set<Account>>> fieldsList, Set<String> objFields) {
        List<String> whereClauses = new List<String>();
        sObject[] returnList = new sObject[0];
        
        for(String fieldName : fieldsList.keySet()) 
        {
            Map<Id, Set<Account>> field = fieldsList.get(fieldName);
            List<String> whereFieldNameIdList = new List<String>();
            for(Id masterId : field.keySet())
            {
                Set<Account> al = field.get(masterId);
                for(Account duplicate : al) {
                    whereFieldNameIdList.add('\'' + String.valueOf(duplicate.PersonContactId).substring(0,15) + '\'');
                    whereFieldNameIdList.add('\'' + String.valueOf(duplicate.Id).substring(0,15) + '\'');
                }
            }
            if(whereFieldNameIdList != null && !whereFieldNameIdList.isEmpty()) {
            	whereClauses.add(fieldName + ' IN (' + String.join(whereFieldNameIdList, ',') + ')');
            }
        }
        
        String query = 'SELECT ';
        if(objFields == null) {
            query += String.join(new List<String>(fieldsList.keySet()), ',');
        } else {
            query += String.join(new List<String>(objFields), ',');
        }
        query += ' FROM ' + objectName + ' WHERE ' + String.join(whereClauses, ' OR ');
        if(whereClauses != null && !whereClauses.isEmpty()) {
            returnList = Database.query(query);
        }
        return returnList;
    }


    /**
     * finish: Call at the end of the batch
     * @param  {BatchableContext} BC
     */
    global void finish(Database.BatchableContext BC) {
        System.debug( '================= FINISH ====================' );
    }

}