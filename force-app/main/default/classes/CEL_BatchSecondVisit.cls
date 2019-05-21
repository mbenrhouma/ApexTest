global class CEL_BatchSecondVisit implements Database.Batchable<sObject>, Database.Stateful, Schedulable{
    protected Id masterRecordTypeId;
    protected Integer daysBefore;
    protected Integer daysAfter;
    protected String taskSubject;
    protected String taskTemplate;
    protected Set<String> openStatus;
    protected Set<String> concernedSegments;
    protected Date todayDate;
    protected Date monthsAgoDate;
    
    protected String emailTaskToBatch;

    public void execute(SchedulableContext context) 
    {
        Database.executeBatch(this);
    }
    
    global CEL_BatchSecondVisit(String emailTask) {
        this.masterRecordTypeId = CEL_Constants.peronAccountRtID;
        this.emailTaskToBatch = emailTask;
        this.openStatus = CEL_Constants.taskOpenStatuses;
        this.todayDate = Date.today();
    }   
    
    /**
    * start: Call when the batch begin
    * @param  {BatchableContext} BC
    * @return Database.QueryLocator
    */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        cel_email_task__mdt taskCustomMetadata = CEL_CustomMetadataMgr.getRelatedTaskCustomMetadata(emailTaskToBatch);
        
        //setting the custom metadata to create the task
        this.daysBefore = math.abs(Integer.valueOf(taskCustomMetadata.cel_start_date__c));
        this.daysAfter = Integer.valueOf(taskCustomMetadata.cel_end_date__c);
        this.taskSubject = taskCustomMetadata.cel_task__c;
        
        this.concernedSegments = CEL_CustomMetadataMgr.getConcernedSegmentSet(taskCustomMetadata.Id);
        
        this.taskTemplate = taskCustomMetadata.cel_template__c;
        this.monthsAgoDate = todayDate.addDays(-daysBefore);
        
        List<User> activeUsersList = [Select Id From User Where IsActive = true];
        
        return Database.getQueryLocator([SELECT Id,Name,OwnerId,cel_birthdate_day__c,cel_birthdate_month__c,cel_segmentation__c
                                         From Account 
                                         Where RecordTypeId =:masterRecordTypeId
                                         AND cel_segmentation__c IN :concernedSegments
                                         AND cel_last_purchase_date__c = :monthsAgoDate
                                         AND (cel_Last_Contact_Date__c <= :monthsAgoDate OR cel_Last_Contact_Date__c = null)
                                         AND cel_main_store__r.cel_Is_Seamless_Active__c = true
                                         AND cel_main_store__r.cel_Seamless_Task_Typology__c includes (:taskSubject)
                                         AND OwnerId IN :activeUsersList]);
    }
    
    /**
    * execute: Call when the start method retrieve data
    * @param  {BatchableContext} BC
    * @param [{LIst<Account>}] items
    */
    global void execute(Database.BatchableContext BC, List<Account> items)
    {
        List<Task> tasksList = new List<Task>();
        
        Map<Id,Task> mapOfTaskRelatedToAccount = new Map<Id,Task>();

        List<Task> existingTasks = [Select Id, OwnerId, WhatId, Subject, Status,Description,cel_Activity_Closure_Reason__c,cel_Activity_Status__c 
                                    From Task 
                                    Where (WhatId IN :items) 
                                    AND (Subject = :taskSubject) 
                                    AND (cel_Activity_Status__c IN :openStatus) 
                                    AND Status = :CEL_Constants.taskStatusMap.get('Open_Status')];
        for(Task t :existingTasks){
            mapOfTaskRelatedToAccount.put(t.WhatId,t);
        }
        
        if( items != null && !items.isEmpty()){
            Task taskToAdd;
            for (Account a: items) {
                if(!mapOfTaskRelatedToAccount.containsKey(a.Id)){
                    taskToAdd = CEL_TaskMgr.createTask(a,taskSubject,daysAfter,taskTemplate);
                    tasksList.add(taskToAdd);  
                }
            }
            
            Database.insert(tasksList);
        }
    }
    
    /**
    * finish: Call at the end of the batch
    * @param  {BatchableContext} BC
    */
    global void finish(Database.BatchableContext BC) {
        System.debug( '================= FINISH ====================' );
    }

}