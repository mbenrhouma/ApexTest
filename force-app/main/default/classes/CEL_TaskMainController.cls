public class CEL_TaskMainController {
    /**
    * saveTasksByStore: Create Task for each user related to the store
    * @param {Task,Id } taskToCreate,storeId
    * @return {}
    */
    @AuraEnabled
    public static Map<String,String> saveTasksByStore(Task taskToCreate, String storesList){
        Map<String,String> state = new Map<String,String>();
        
        Set<String> porfilesConcerned = new Set<String>();
        
        List<cel_Profile_concerned_by_global_task__mdt> profilesConcernedMetadataRecords = [Select Id,cel_Profile_Id_concerned_global_task__c From cel_Profile_concerned_by_global_task__mdt];
        if(profilesConcernedMetadataRecords.size() > 0){
            for(cel_Profile_concerned_by_global_task__mdt profileConcerned : profilesConcernedMetadataRecords){
               porfilesConcerned.add(profileConcerned.cel_Profile_Id_concerned_global_task__c);
            }
        }
        
        List<Task> tasksList = new List<Task>();
        
        // Get all stores available
        List<String> storesIds = String.isNotBlank(storesList) ? storesList.split(';') : new List<String>();
        List<Account> allStores = CEL_AccountMgr.getStoresByIds(storesIds);
        
        if(allStores != null && !allStores.isEmpty()){
                for(Account store : allStores){
                    List<User> userLists = [Select Id From User Where cel_Code_CGID_of_store__c = :store.cel_store_code_Y2__c AND ProfileId IN :porfilesConcerned AND IsActive = true];
                    if(userLists.size() > 0 && taskToCreate != null){
                        for(User u : userLists){
                            tasksList.add(CEL_TaskMgr.createTaskFromLayout(store.Id,u,taskToCreate.Subject,taskToCreate.ActivityDate,taskToCreate.Description));
                        }
                    }
                }
        }
                
        if(tasksList.size() > 0){
            try{
                insert tasksList;
                state.put('result','true');
                state.put('message',System.Label.cel_task_create_success);
            }
            catch(DmlException e){
                state.put('result','false');
                state.put('message',e.getMessage());
            }
        }
        else{
            state.put('result','false');
            state.put('message',System.Label.cel_task_create_no_users_msg);
        }
        
        return state;
        
    }
    /**
    * getUserAccess: check if the user profile is store manager or no to have access to the create task from store
    * @return {Boolean}
    */
    @AuraEnabled
    public static Boolean getUserAccess(){
       Id profileId = UserInfo.getProfileId();
       List<cel_Create_global_task__mdt> createGlobalTaskMetdata = [Select Id,cel_Profile_Id_global_task__c From cel_Create_global_task__mdt];
       Set<String> listOfProfilesId = new Set<String>();
       
       if(createGlobalTaskMetdata.size() > 0){
           for(cel_Create_global_task__mdt profileMetdata : createGlobalTaskMetdata){
               listOfProfilesId.add(profileMetdata.cel_Profile_Id_global_task__c);
           }
       }
       return listOfProfilesId.contains(profileId);
        
    }
    
    /**
    * getAvailableList: get available List
    * @return {Map<String, List<Map<String, String>>>}
    */
    @AuraEnabled
    public static Map<String, List<Map<String, String>>> getAvailableList(){
       return new Map<String, List<Map<String, String>>> {
            'availableStores' => CEL_AccountMgr.getAvailableStoresList()
        };
        
    }

}