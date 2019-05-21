public class CEL_TaskMgr {  
    
    /**
     * createBirthDateTask: create and return the task to add
     * @param  {Account,Date,String,Integer,String}  account,birthdateOfCurrentYear,subject,daysAfter,taskTemplate
     * @return Task
     */
    public static Task createBirthDateTask(Account account, Date birthdateOfCurrentYear, String subject, Integer daysAfter,String taskTemplate) {
        Task taskToAdd = new Task();
        
        taskToAdd.OwnerId = account.OwnerId;
        taskToAdd.ActivityDate = birthdateOfCurrentYear.addDays(daysAfter);
        taskToAdd.Status = CEL_Constants.taskStatusMap.get('Open_Status');
        taskToAdd.cel_Activity_Status__c = 'TODO';
        taskToAdd.Subject = subject;
        taskToAdd.WhatId = account.Id;
        taskToAdd.Description = taskTemplate;
        
        return taskToAdd;
    }
    
    /**
     * createTask: create and return the task to add
     * @param  {Account,Date,String,Integer,String}  account,creationDate,subject,daysAfter,taskTemplate
     * @return Task
     */
    public static Task createTask(Account account, String subject, Integer daysAfter,String taskTemplate) {
        Task taskToAdd = new Task();
        
        taskToAdd.OwnerId = account.OwnerId;
        taskToAdd.ActivityDate = Date.today().addDays(daysAfter);
        taskToAdd.Status = CEL_Constants.taskStatusMap.get('Open_Status');
        taskToAdd.cel_Activity_Status__c = 'TODO';
        taskToAdd.Subject = subject;
        taskToAdd.WhatId = account.Id;
        taskToAdd.Description = taskTemplate;
        
        return taskToAdd;
    }
    
    /**
     * updateTaskToLate: update the task to late
     * @param  {Task}  task
     * @return Task
     */
    public static Task updateTaskToLate(Task task) {
        
        task.cel_Activity_Status__c = 'LATE';
        
        return task;
    }
    
    /**
     * updateTaskToOverdue: update the task to overdue
     * @param  {Task}  task
     * @return Task
     */
    public static Task updateTaskToOverdue(Task task) {
        
        task.Status = CEL_Constants.taskStatusMap.get('Closed_Status');
        task.cel_Activity_Status__c = 'NOTD';
        task.cel_Activity_Closure_Reason__c = 'CLSA';
        
        return task;
    }
    
    /**
     * createTaskFromLayout: create and return the task to add
     * @param  {Id} storeId
     * @param  {User} user
     * @param  {String} Subject
     * @param  {Date} DueDate
     * @param  {String} Description
     * @return Task
     */
    public static Task createTaskFromLayout(Id storeId, User user, String subject, Date dueDate,String description) {
        Task taskToAdd = new Task();
        taskToAdd.OwnerId = user.Id;
        taskToAdd.WhatId = storeId;
        taskToAdd.ActivityDate = dueDate;
        taskToAdd.Subject = subject;
        taskToAdd.Description = description;
        taskToAdd.Status = CEL_Constants.taskStatusMap.get('Open_Status');
        taskToAdd.cel_Activity_Status__c = 'TODO';
        
        return taskToAdd;
    }

}