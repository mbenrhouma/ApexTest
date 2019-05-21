public class CEL_CampaignController {
    
    /**
    * getCampaignDetails : get details of campaign
    * @param {String} campaignId
    * @return {Campaign} c
    */
    @AuraEnabled
    public static Campaign getCampaignDetails(Id CampaignId){
        return CEL_CampaignMgr.getCampaignDetails(CampaignId);
    }
    
    /**
    * getRegionCountryStoresByCampaignId : Get Stores for a list of countries
    * @param {Id} CampaignId
    * @return {Map<String, List<String>>} Region / Country / stores
    */
    @AuraEnabled
    public static Map<String, List<String>> getRegionCountryStoresByCampaignId(Id CampaignId){
        Map<String, List<String>> result = new Map<String, List<String>>();
        
        Campaign c = CEL_CampaignMgr.getCampaign(CampaignId);
        if(c != null){
            
            // Get CEL_Campaign_Store__c for this campaign
            List<CEL_Campaign_RegionCountryStore__c> campaignStores = CEL_CampaignMgr.getCampaignRegionCountryStoreByCampaignId(c.Id);
            
            if(campaignStores != null && !campaignStores.isEmpty()){
                // Get Regions Names
                List<String> allRegionsNames = new List<String>();
                Set<Id> transcoRegionsIds = new Set<Id>();
                for(CEL_Campaign_RegionCountryStore__c cRCS : campaignStores){
                    transcoRegionsIds.add(cRCS.cel_Region__c);
                }
                
                List<cel_transcodification__c> transcoRegions = CEL_TranscodificationMgr.getTranscodificationBySetId(transcoRegionsIds);
                
                if(transcoRegions != null && !transcoRegions.isEmpty()){
                    for(cel_transcodification__c transco : transcoRegions){
                        allRegionsNames.add(transco.Name);
                    }
                }
                
                // Get Countries Names
                List<String> allCountriesNames = new List<String>();
                Set<Id> transcoCountriesIds = new Set<Id>();
                for(CEL_Campaign_RegionCountryStore__c cRCS : campaignStores){
                    transcoCountriesIds.add(cRCS.cel_Country__c);
                }
                
                List<cel_transcodification__c> transcoCountries = CEL_TranscodificationMgr.getTranscodificationBySetId(transcoCountriesIds);
                
                if(transcoCountries != null && !transcoCountries.isEmpty()){
                    for(cel_transcodification__c transco : transcoCountries){
                        allCountriesNames.add(transco.Name);
                    }
                }
                
                // Get Stores Names
                List<String> allStoresNames = new List<String>();
                Set<Id> storesIds = new Set<Id>();
                for(CEL_Campaign_RegionCountryStore__c cRCS : campaignStores){
                    storesIds.add(cRCS.cel_Store__c);
                }
                
                List<Account> allStores = CEL_AccountMgr.getStoresBySetIds(storesIds);
                
                if(allStores != null && !allStores.isEmpty()){
                    for(Account s : allStores){
                        allStoresNames.add(s.cel_long_name__c);
                    }
                }
                
                result.put('Regions', allRegionsNames);
                result.put('Countries', allCountriesNames);
                result.put('Stores', allStoresNames);
            }
        }
        
        return result;
    }
    
    /**
    * getDetailAndMakeCalcul : 
    * If Little Children : Make a fake update on a Members Status to refresh all calculs
    * If Campaign has children : Get details to his children and make sum make a fake update on a MembersStatus for the current campaign
    * @param {String} CampaignId
    */
    @AuraEnabled
    public static void getDetailAndMakeCalcul(String CampaignId){
        //Make map with Conversion rate
        Map<String, decimal> mapCurrentRate = new Map<String, decimal>();
        mapCurrentRate = CEL_DatedConversionRateMgr.getMapCurrentConversionRate();
        
        //Get recordType Campaign
        String recordTypeParent = CEL_Constants.campaignParentRecordType;
        String recordTypeEnfant = CEL_Constants.campaignEnfantRecordType;
        
        Campaign c = CEL_CampaignMgr.getCampaignParentWithChildren(CampaignId);
        if( c != null ){
            
            c = CEL_CampaignMgr.convertAmount(c, mapCurrentRate);
            update c;
            
            // Only if c is Active
            if(c.IsActive){
                // If c Is a Parent get his children to make calcul details Else make a fake update on CampaignMemberStatus
                if(c.ChildCampaigns != null && !c.ChildCampaigns.isEmpty()){
                    //Init campaigns list
                    List<Campaign> parents = new List<Campaign>();
                    List<Campaign> childrens = new List<Campaign>();
                    List<Campaign> littleChildrens = new List<Campaign>();
                    
                    // c is All campaign
                    if(c.ParentId == null && c.RecordTypeId == recordTypeParent && c.cel_region_all__c){
                        //Get all parents
                        List<Campaign> allParents = CEL_CampaignMgr.getAllCampaignParent(c.Id);
                        parents.addAll(allParents);
                        
                        //Get parents Id
                        Set<Id> parentIds = new Set<Id>();
                        for(Campaign cp : parents){
                            parentIds.add(cp.Id);
                        }
                        
                        //Get all childrens
                        List<Campaign> childs = CEL_CampaignMgr.getAllCampaignChildren(parentIds);
                        childrens.addAll(childs);
                        
                        //Get LittleChildren Id
                        Set<Id> childrenIds = new Set<Id>();
                        for(Campaign cc : childrens){
                            childrenIds.add(cc.Id);
                        }
                        List<Campaign> allLittleChildrens = CEL_CampaignMgr.getAllCampaignChildren(childrenIds);
                        
                        //Fake update des Campaign Members Status
                        makeFakeUpdateCampaignMemberStatus(allLittleChildrens);
                        
                        //Calcul child details with little children details
                        for(Campaign cc : childrens){
                            if(allLittleChildrens != null && !allLittleChildrens.isEmpty()){
                                calculAllDetailWithChildren(cc,allLittleChildrens,mapCurrentRate);
                            }
                        }
                        if(childrens != null && !childrens.isEmpty()){
                            update childrens;
                        }
                        
                        //Calcul parent details with children details
                        for(Campaign cp : parents){
                            if(childrens != null && !childrens.isEmpty()){
                                calculAllDetailWithChildren(cp,childrens,mapCurrentRate);
                            }
                        }
                        
                        //Calcul parent details with children details
                        if(parents != null && !parents.isEmpty()){
                            update parents;
                            calculAllDetailWithChildren(c,parents,mapCurrentRate);
                        }
                        update c;
                    }
                    // c is a Parent
                    else if(c.RecordTypeId == recordTypeParent && !c.cel_region_all__c){
                        //Get all childrens
                        List<Campaign> childs = CEL_CampaignMgr.getAllCampaignParent(c.Id);
                        childrens.addAll(childs);
                        
                        //Get LittleChildren Id
                        Set<Id> childrenIds = new Set<Id>();
                        for(Campaign cc : childrens){
                            childrenIds.add(cc.Id);
                        }
                        List<Campaign> allLittleChildrens = CEL_CampaignMgr.getAllCampaignChildren(childrenIds);
                        
                        //Fake update des Campaign Members Status
                        makeFakeUpdateCampaignMemberStatus(allLittleChildrens);
                        
                        //Calcul child details with little children details
                        for(Campaign cc : childrens){
                            if(allLittleChildrens != null && !allLittleChildrens.isEmpty()){
                                calculAllDetailWithChildren(cc,allLittleChildrens,mapCurrentRate);
                            }
                        }
                        if(childrens != null && !childrens.isEmpty()){
                            update childrens;
                        }
                        
                        //Calcul parent details with children details
                        calculAllDetailWithChildren(c,childrens,mapCurrentRate);
                        update c;
                    }
                    // c is Children
                    else if(c.RecordTypeId == recordTypeEnfant){
                        childrens.add(c);
                        littleChildrens.addAll(c.ChildCampaigns);
                        
                        //Fake update des Campaign Members Status
                        makeFakeUpdateCampaignMemberStatus(littleChildrens);
                        //Calcul details with children details
                        calculAllDetailWithChildren(c,c.ChildCampaigns, mapCurrentRate);
                        update c;
                    }
                }
                // If c is a Little Children make a fake update of his first CampaignMemberStatus to refresh calcul
                else{
                    List<Campaign> littleChildrens = new List<Campaign>();
                    littleChildrens.add(c);
                    
                    //Fake update des Campaign Members Status
                    makeFakeUpdateCampaignMemberStatus(littleChildrens);
                    
                    //Calcul details for little children details
                    calculAllDetailForLittleChildren(c,mapCurrentRate);
                    update c;
                }
            }
        }
    }
    
    /**
    * makeFakeUpdateCampaignMemberStatus : udpate the first Campaign Members Status to refrech calculs
    * @param {List<Campaign>} littleChildrens
    */
    public static void makeFakeUpdateCampaignMemberStatus(List<Campaign> littleChildrens){
        List<cel_Campaign_Member_Status__c> allCms = new List<cel_Campaign_Member_Status__c>();
        for(Campaign child : littleChildrens){
            cel_Campaign_Member_Status__c cms = getFirstCampaignMemberStatus(child.Id);
            if(cms != null){
                allCms.add(cms);
            }
        }
        if(allCms != null && !allCms.isEmpty()){
            update allCms;
        }
    }
    
    /**
    * getFirstCampaignMemberStatus : return the first Campaign Members Status
    * @param {String} CampaignId
    * @return {cel_Campaign_Member_Status__c} cms
    */
    public static cel_Campaign_Member_Status__c getFirstCampaignMemberStatus(String CampaignId){
        return CEL_CampaignMgr.getFirstCampaignMemberStatus(CampaignId);
    }
    
    /**
    * calculAllDetailWithChildren : calcul details with children details
    * @param {Campaign} c
    * @param {List<Campaign>} children
    * @param {Map<String, decimal>} mapCurrentRate
    */
    public static void calculAllDetailWithChildren(Campaign c, List<Campaign> children, Map<String, decimal> mapCurrentRate){
        String recordTypeEnfant = CEL_Constants.campaignEnfantRecordType;
        Decimal rateConvertion = (c.cel_local_Currency__c != null && mapCurrentRate.get(c.cel_local_Currency__c) != 0) ? 1/mapCurrentRate.get(c.cel_local_Currency__c) : 1;
        
        //Reset details if c has at least one children
        for(Campaign child : children){
            if(c.Id == child.ParentId){
                c.cel_TotalInvitedParent__c = 0;
                c.cel_TotalContactedParentAction__c = 0;
                c.cel_Confirmed_Parent__c = 0;
                c.cel_TotalShowupParent__c = 0;
                c.cel_TotalPurchasing_Parent__c = 0;
                c.cel_TotalDirectSales__c = 0;
                c.cel_TotalResWDep__c = 0;
                c.cel_TotalResWODep__c = 0;
                c.cel_TotalBudgetedCost__c = 0;
                c.cel_BudgetEuro__c = 0;
                c.cel_SalesTargetResWDepositEuro__c = 0;
                c.cel_SalesTargetResWODepositEuro__c = 0;
                c.cel_SalesTargetDirectSalesEuro__c = 0;
                c.cel_TotalSales__c = 0;
                c.cel_TotalSLG__c = 0;
                c.cel_TotalRTW__c = 0;
                c.cel_TotalShoes__c = 0;
                c.cel_TotalBags__c = 0;
                c.cel_TotalACC__c = 0;
                c.cel_Total__c = 0;
            }
        }
        
        for(Campaign child : children){
            if(c.Id == child.ParentId){
                //Calcul details if child is a enfant
                if(child.RecordTypeId == recordTypeEnfant){
                    c.cel_TotalInvitedParent__c += child.cel_TotalInvited__c != null ? child.cel_TotalInvited__c : 0;
                    c.cel_TotalContactedParentAction__c += child.cel_TotalContacted__c != null ? child.cel_TotalContacted__c : 0;
                    c.cel_Confirmed_Parent__c += child.cel_TotalConfirmed__c != null ? child.cel_TotalConfirmed__c : 0;
                    c.cel_TotalShowupParent__c += child.cel_TotalShowUp__c != null ? child.cel_TotalShowUp__c : 0;
                    c.cel_TotalPurchasing_Parent__c += child.cel_TotalPurchasing__c != null ? child.cel_TotalPurchasing__c : 0;
                }
                //Calcul details if child is a parent
                else{
                    c.cel_TotalInvitedParent__c += child.cel_TotalInvitedParent__c != null ? child.cel_TotalInvitedParent__c : 0;
                    c.cel_TotalContactedParentAction__c += child.cel_TotalContactedParentAction__c != null ? child.cel_TotalContactedParentAction__c : 0;
                    c.cel_Confirmed_Parent__c += child.cel_Confirmed_Parent__c != null ? child.cel_Confirmed_Parent__c : 0;
                    c.cel_TotalShowupParent__c += child.cel_TotalShowupParent__c != null ? child.cel_TotalShowupParent__c : 0;
                    c.cel_TotalPurchasing_Parent__c += child.cel_TotalPurchasing_Parent__c != null ? child.cel_TotalPurchasing_Parent__c : 0;
                }
                c.cel_TotalDirectSales__c += child.cel_TotalDirectSales__c != null ? child.cel_TotalDirectSales__c : 0;
                c.cel_TotalResWDep__c += child.cel_TotalResWDep__c != null ? child.cel_TotalResWDep__c: 0;
                c.cel_TotalResWODep__c += child.cel_TotalResWODep__c != null ? child.cel_TotalResWODep__c : 0;
                c.cel_TotalSLG__c += child.cel_TotalSLG__c != null ? child.cel_TotalSLG__c : 0;
                c.cel_TotalRTW__c += child.cel_TotalRTW__c != null ? child.cel_TotalRTW__c : 0;
                c.cel_TotalShoes__c += child.cel_TotalShoes__c != null ? child.cel_TotalShoes__c : 0;
                c.cel_TotalBags__c += child.cel_TotalBags__c != null ? child.cel_TotalBags__c : 0;
                c.cel_TotalACC__c += child.cel_TotalACC__c != null ? child.cel_TotalACC__c : 0;
                c.cel_Total__c += child.cel_Total__c != null ? child.cel_Total__c : 0;
            }
        }
    }
    
    /**
    * calculAllDetailForLittleChildren : calcul details for little children details
    * @param {Campaign} c
    * @param {Map<String, decimal>} mapCurrentRate
    */
    public static void calculAllDetailForLittleChildren(Campaign c, Map<String, decimal> mapCurrentRate){
        Decimal rateConvertion = (c.cel_local_Currency__c != null && mapCurrentRate.get(c.cel_local_Currency__c) != 0) ? 1/mapCurrentRate.get(c.cel_local_Currency__c) : 1;
        
        List<cel_Campaign_Member_Status__c> allCms = CEL_CampaignMgr.getCampaignMembersStatusByCampaignId(c.id);
        
        c.cel_TotalSLG__c = 0; 
        c.cel_TotalRTW__c = 0;
        c.cel_TotalShoes__c = 0; 
        c.cel_TotalBags__c = 0;
        c.cel_TotalACC__c = 0;
        c.cel_Total__c = 0;
        c.cel_TotalResWDep__c = 0;
        c.cel_TotalResWODep__c = 0;
        c.cel_TotalDirectSales__c = 0;
        
        for(cel_Campaign_Member_Status__c cms : allCms){
            if(c.id == cms.cel_Campaign__c){
                c.cel_TotalResWDep__c += cms.cel_ResWDep_Euro__c != null ? cms.cel_ResWDep_Euro__c : 0; 
                c.cel_TotalResWODep__c += cms.cel_ResWODep_Euro__c != null ? cms.cel_ResWODep_Euro__c : 0;
                c.cel_TotalSLG__c += cms.cel_SLG__c != null ? cms.cel_SLG__c : 0;
                c.cel_TotalRTW__c += cms.cel_RTW__c != null ? cms.cel_RTW__c : 0;
                c.cel_TotalShoes__c += cms.cel_Shoes__c != null ? cms.cel_Shoes__c : 0;
                c.cel_TotalBags__c += cms.cel_Bags__c != null ? cms.cel_Bags__c : 0;
                c.cel_TotalACC__c += cms.cel_ACC__c != null ? cms.cel_ACC__c : 0;
                c.cel_Total__c += cms.cel_total_units__c != null ? cms.cel_total_units__c : 0;
                c.cel_TotalDirectSales__c += cms.cel_Direct_Sales__c != null ? cms.cel_Direct_Sales__c : 0;
            }
        }
    }
    
    /**
    * initPicklistClienteling : init the component picklistClienteling by Campaign Id
    * @param {String} CampaigniId
    * @param {Boolean} isReset
    * @return {Map<String,Map<String, String>>} result
    */
    @AuraEnabled
    public static Map<String,Map<String, String>> initPicklistClienteling(Id CampaignId, Boolean isReset){
        Map<String,Map<String, String>> results = new Map<String,Map<String, String>>();
        Map<String, String> regions = new Map<String, String>();
        Map<String, String> countries = new Map<String, String>();
        Map<String, String> stores = new Map<String, String>();
        Map<String, String> status = new Map<String, String>();
        List<CEL_Campaign_RegionCountryStore__c> campaignStores = new List<CEL_Campaign_RegionCountryStore__c>();
        List<Account> allStores = new List<Account>();
        
        Campaign c = CEL_CampaignMgr.getCampaignDetails(CampaignId);
        if(c != null){
            Campaign cParent = CEL_CampaignMgr.getCampaignDetails(c.ParentId);
            
            // Get status of this campaign
            String isActive = c.IsActive ? 'true' : 'false';
            String isALL = c.cel_level__c == CEL_Constants.levelsCampaign.get('Level_1') ? 'true' : 'false';
            status.put('isActive', isActive);
            status.put('isALL', isALL);
            
            // Get CEL_Campaign_Store__c for this campaign
            campaignStores = CEL_CampaignMgr.getCampaignRegionCountryStoreByCampaignId(c.Id);
            
            if(campaignStores != null && !campaignStores.isEmpty() && !isReset){
                status.put('isNotSave', 'false');
                Set<Id> storesIds = new Set<Id>();
                for(CEL_Campaign_RegionCountryStore__c cRCS : campaignStores){
                    storesIds.add(cRCS.cel_Store__c);
                }
                
                // Get all stores available
                allStores = CEL_AccountMgr.getStoresBySetIds(storesIds);
            }
            else if (cParent !=  null && cParent.Id != null){
                status.put('isNotSave', 'true');
                
                // Get CEL_Campaign_Store__c for the parent campaign
                campaignStores = CEL_CampaignMgr.getCampaignRegionCountryStoreByCampaignId(cParent.Id);
                
                Set<Id> storesIds = new Set<Id>();
                for(CEL_Campaign_RegionCountryStore__c cRCS : campaignStores){
                    storesIds.add(cRCS.cel_Store__c);
                }
                
                if(campaignStores != null && !campaignStores.isEmpty()){
                    // Get all stores available
                    allStores = CEL_AccountMgr.getStoresBySetIds(storesIds);
                }
                else{
                    // Get all stores available
                    allStores = CEL_AccountMgr.getAllStoresOpen();
                }
            }
            else{
                // Get all stores available
                status.put('isNotSave', 'true');
                allStores = CEL_AccountMgr.getAllStoresOpen();
            }
            
            // Get label for store
            if(allStores != null && !allStores.isEmpty()){
                for(Account store : allStores){
                    stores.put(store.Id, store.cel_long_name__c);
                }
            }
            
            // Get label for countries
            for(Account store : allStores){
                countries.put(store.cel_addr_1_country__c, CEL_Utils.getStdPicklistLabelFromValue(Account.cel_addr_1_country__c,store.cel_addr_1_country__c));
            }
            
            // Get label for region by transco object
            Set<Id> regionTranscoIds = new Set<Id>();
            for(Account store : allStores){
                ID idTransco = Id.valueOf(store.cel_store_area__c);
                regionTranscoIds.add(idTransco);
            }
            
            List<cel_transcodification__c> transcoRegions = CEL_TranscodificationMgr.getTranscodificationBySetId(regionTranscoIds);
            
            if(transcoRegions != null && !transcoRegions.isEmpty()){
                for(cel_transcodification__c transco : transcoRegions){
                    regions.put(transco.Id, transco.Name);
                }
            }
        }
        
        // Add lists on result
        results.put('Regions', regions);
        results.put('Countries', countries);
        results.put('Stores', stores);
        results.put('Status', status);
        
        return results;
    }
    
    /**
    * getCountriesListByRegion : Get countries for a list of region
    * @param {String} regions
    * @return {Map<String, String>>} countries
    */
    @AuraEnabled
    public static Map<String, String> getCountriesListByRegion(String regions){
        Map<String, String> countries = new Map<String, String>();
        List<String> codeCountries = new List<String>();
        List<String> allRegions = String.isNotBlank(regions) ? regions.split(';') : new List<String>();
        
        // Get stores by id area
        List<Account> allStores = CEL_AccountMgr.getStoresByAreaId(allRegions);
        
        if(allStores != null && !allStores.isEmpty()){
            for(Account store : allStores){
                countries.put(store.cel_addr_1_country__c, CEL_Utils.getStdPicklistLabelFromValue(Account.cel_addr_1_country__c,store.cel_addr_1_country__c));
            }
        }
         
        return countries;
    }
    
    /**
    * getStoresListByCountry : Get Stores for a list of countries
    * @param {String} countries
    * @return {Map<String, String>>} stores
    */
    @AuraEnabled
    public static Map<String, String> getStoresListByCountry(String countries){
        Map<String, String> stores = new Map<String, String>();
        List<String> allCountries = String.isNotBlank(countries) ? countries.split(';') : new List<String>();
        
        // Get all stores available by id Countries
        List<Account> allStores = CEL_AccountMgr.getStoresByCountry(allCountries);
        
        if(allStores != null && !allStores.isEmpty()){
            for(Account store : allStores){
                stores.put(store.Id, store.cel_long_name__c);
            }
        }
         
        return stores;
    }
    
    /**
    * savePicklistClienteling : reset the component picklistClienteling by Campaign Id with parent information
    * @param {String} CampaigniId
    * @param {String} stores
    * @return {boolean} result
    */
    @AuraEnabled
    public static Boolean savePicklistClienteling(Id CampaignId, String stores){
        Boolean result = false;
        String storeRecordType = CEL_Constants.storeRecordType;
        String storeStatusOpen = CEL_Constants.storeStatus.get('Open');
        List<String> allStoresIds = String.isNotBlank(stores) ? stores.split(';') : new List<String>();
        List<CEL_Campaign_RegionCountryStore__c> campaignStores = new List<CEL_Campaign_RegionCountryStore__c>();
        
        Campaign c = CEL_CampaignMgr.getCampaignDetails(CampaignId);
        
        if(c != null && !c.IsActive){
            List<CEL_Campaign_RegionCountryStore__c> campaignStoresToDelete = CEL_CampaignMgr.getCampaignRegionCountryStoreByCampaignId(c.Id);
            
            // Get all stores available
            List<Account> allStores = CEL_AccountMgr.getStoresByIds(allStoresIds);
            
            //get the transco of the stores countries
            Set<String> setOfCOuntries = CEL_AccountMgr.getStoresCountriesByIds(allStoresIds);
            Map<String,String> mapOfCountryCodeAndTranscoId = new Map<String,String>();
            
            List<cel_transcodification__c> countryTranscoList = [Select Id, cel_transcodification_code__c,RecordTypeId From cel_transcodification__c Where cel_transcodification_code__c IN :setOfCOuntries AND RecordType.Name = 'Country'];
            for(cel_transcodification__c transco : countryTranscoList){
                mapOfCountryCodeAndTranscoId.put(transco.cel_transcodification_code__c,transco.Id);
            }
            
            if(allStores != null && !allStores.isEmpty()){
                for(Account store : allStores){
                    CEL_Campaign_RegionCountryStore__c cRCS = new CEL_Campaign_RegionCountryStore__c();
                    cRCS.cel_Campaign__c = c.Id;
                    cRCS.cel_Region__c = Id.valueOf(store.cel_store_area__c);
                    cRCS.cel_Country__c = mapOfCountryCodeAndTranscoId.get(store.cel_addr_1_country__c);
                    cRCS.cel_Store__c = store.Id;
                    campaignStores.add(cRCS);
                }
                
                if(campaignStores != null && !campaignStores.isEmpty()){
                    delete campaignStoresToDelete;
                    insert campaignStores;
                    result = true;
                }
            }
        }
        
        return result;
    }
}