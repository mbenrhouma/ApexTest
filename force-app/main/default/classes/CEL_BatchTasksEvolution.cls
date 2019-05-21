global class CEL_BatchTasksEvolution implements Database.Batchable<sObject>, Database.Stateful, Schedulable{
    
    /**
    * execute
    * @param {SchedulableContext} sc
    */    
    global void execute(SchedulableContext sc)
    {
        CEL_BatchTasksEvolution b = new CEL_BatchTasksEvolution();      
        database.executebatch(b);
    }
    
    /**
    * start: Call when the batch begin
    * @param  {BatchableContext} BC
    * @return Database.QueryLocator
    */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        Set<String> openStatus = CEL_Constants.taskOpenStatuses;
        return Database.getQueryLocator([SELECT Id, Status, CreatedDate,OwnerId, WhatId,Subject, ActivityDate,Type, WhoId
                                         From Task 
                                         Where Status IN :openStatus]);
    }
    
    /**
    * execute: Call when the start method retrieve data
    * @param  {BatchableContext} BC
    * @param [{List<Task>}] items
    */
    global void execute(Database.BatchableContext BC, List<Task> items)
    {
        List<Task> tasksToUpdateList = new List<Task>();
        Date todayDate = Date.today();
        
        if(items != null && !items.isEmpty()){
            Task taskToUpdate;
            for(Task t : items){
                if(t.CreatedDate.addDays(1) <= todayDate && todayDate <= t.ActivityDate){
                    taskToUpdate = CEL_TaskMgr.updateTaskToLate(t);
                    tasksToUpdateList.add(taskToUpdate);
                }
                
                if(todayDate > t.ActivityDate){
                    taskToUpdate = CEL_TaskMgr.updateTaskToOverdue(t);
                    tasksToUpdateList.add(taskToUpdate);
                }
            }
        }
        
        if(tasksToUpdateList != null && !tasksToUpdateList.isEmpty()){
            update tasksToUpdateList; 
        }
        
    }
    
    /**
    * finish: Call at the end of the batch
    */
    global void finish(Database.BatchableContext BC) {
        System.debug( '================= FINISH ====================' );
    }

}