public with sharing class CEL_TaskFromStore {
    
    /**
    * saveTasksByStore: Create Task for each user related to the store
    * @param {Task} taskToCreate
    * @param {Id} storeId
    * @return {}
    */
    @AuraEnabled
    public static Map<String,String> saveTasksByStore(Task taskToCreate, Id storeId){
        Set<String> porfilesConcerned = new Set<String>();
        
        List<cel_profile_concerned_by_task_from_store__mdt> profilesConcernedMetadataRecords = [Select Id,cel_concerned_profile_id__c From cel_profile_concerned_by_task_from_store__mdt];
        if(profilesConcernedMetadataRecords != null && !profilesConcernedMetadataRecords.isEmpty()){
            for(cel_profile_concerned_by_task_from_store__mdt profileConcerned : profilesConcernedMetadataRecords){
               porfilesConcerned.add(profileConcerned.cel_concerned_profile_id__c);
            }
        }
        
        
        Map<String,String> state = new Map<String,String>();
        Account store = [Select Id, cel_store_code_Y2__c From Account Where Id =:storeId ];
        List<Task> tasksList = new List<Task>();
        List<User> userLists = [Select Id From User Where cel_Code_CGID_of_store__c = :store.cel_store_code_Y2__c AND ProfileId IN :porfilesConcerned AND IsActive = true];
        
        if(userLists.size() > 0 && taskToCreate != null && storeId !=null){
            for(User u : userLists){
                tasksList.add(CEL_TaskMgr.createTaskFromLayout(storeId,u,taskToCreate.Subject,taskToCreate.ActivityDate,taskToCreate.Description));
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
       List<cel_Create_Task_From_Store__mdt> createTaskFromStoreMetdata = [Select Id,cel_profile_id__c From cel_Create_Task_From_Store__mdt];
       Set<String> listOfProfilesId = new Set<String>();
       
       if(createTaskFromStoreMetdata!= null && !createTaskFromStoreMetdata.isEmpty()){
           for(cel_Create_Task_From_Store__mdt profileMetdata : createTaskFromStoreMetdata){
               listOfProfilesId.add(profileMetdata.cel_profile_id__c);
           }
       }
       return listOfProfilesId.contains(profileId);
        
    }
    

}