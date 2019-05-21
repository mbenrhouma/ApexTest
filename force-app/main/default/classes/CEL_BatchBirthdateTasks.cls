global class CEL_BatchBirthdateTasks implements Database.Batchable<sObject>, Database.Stateful, Schedulable{  
    
    protected Id masterRecordTypeId;
    protected Integer daysBeforeBD;
    protected Integer daysAfter;
    protected String taskSubject;
    protected String taskTemplate;
    protected Set<String> openStatus;
    protected Set<String> concernedSegments;
    protected Date todayDate;
    
    protected String emailTaskToBatch;

    public void execute(SchedulableContext context) 
    {
        Database.executeBatch(this);
    }
    
    global CEL_BatchBirthdateTasks(String emailTask) {
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
        this.daysBeforeBD = math.abs(Integer.valueOf(taskCustomMetadata.cel_start_date__c));
        this.daysAfter = Integer.valueOf(taskCustomMetadata.cel_end_date__c);
        this.taskSubject = taskCustomMetadata.cel_task__c;
        
        this.concernedSegments = CEL_CustomMetadataMgr.getConcernedSegmentSet(taskCustomMetadata.Id);

        this.daysAfter = Integer.valueOf(taskCustomMetadata.cel_end_date__c);
        this.taskTemplate = taskCustomMetadata.cel_template__c;
        
        Integer todayMonthValue = todayDate.month();
        Integer next2MonthsValue = todayMonthValue+2;
        return Database.getQueryLocator([SELECT Id,Name,OwnerId,cel_birthdate_day__c,cel_birthdate_month__c,cel_segmentation__c
                                         From Account 
                                         Where cel_birthdate_day__c!= null 
                                         AND cel_birthdate_month__c!= null
                                         AND cel_birthdate_month__c >= :todayMonthValue
                                         AND cel_birthdate_month__c < :next2MonthsValue
                                         AND RecordTypeId =:masterRecordTypeId
                                         AND cel_segmentation__c IN :concernedSegments
                                         AND cel_main_store__r.cel_Is_Seamless_Active__c = true
                                         AND cel_main_store__r.cel_Seamless_Task_Typology__c includes (:taskSubject)]);
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

        List<Task> existingTasks = [Select Id, OwnerId, WhatId, Subject, Status,Description From Task Where (WhatId IN :items) AND (Subject = :taskSubject) AND (Status IN :openStatus)];
        for(Task t :existingTasks){
            mapOfTaskRelatedToAccount.put(t.WhatId,t);
        }
        
        if( items != null && !items.isEmpty()){
            Task taskToAdd;
            for (Account a: items) {
                if(!mapOfTaskRelatedToAccount.containsKey(a.Id)){
                    
                    Date birthdateOfCurrentYear = Date.newInstance(todayDate.Year(), Integer.valueOf(a.cel_birthdate_month__c), Integer.valueOf(a.cel_birthdate_day__c));
                    
                    if(birthdateOfCurrentYear > todayDate){
                        Integer daysDifference = todayDate.daysBetween(birthdateOfCurrentYear);
                        if(daysDifference <= daysBeforeBD){
                            taskToAdd = CEL_TaskMgr.createBirthDateTask(a,birthdateOfCurrentYear,taskSubject,daysAfter,taskTemplate);
                            tasksList.add(taskToAdd);
                        }
                    }
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