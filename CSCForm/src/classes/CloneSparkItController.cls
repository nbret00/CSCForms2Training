/*
Class : CloneSparkItController
Description :  This class is used by for Clonning spark It Item
Developed by : Manmeet Manethiya
Created Date : December 18, 2013
*/
public without sharing class CloneSparkItController {

    //public properties getter setters
    public Milestone1_Project__c sparkIt {get; set;}
    public boolean isToCreateMilestones  {get; set;}
    public boolean isToCreateTasks  {get; set;}


    public CloneSparkItController(ApexPages.StandardController controller){
        sparkIt = [SELECT Id,
                      Name,
                      Deadline__c,
                      Description__c,
                      Status__c,
                      Total_Expense_Budget__c,
                      Total_Hours_Budget__c,
                      KickOff__c,
                      OwnerId
               FROM Milestone1_Project__c
               WHERE Id = :controller.getId()
              ];


    }

    public pageReference cloneSparkIt(){
        //fetch Milestones and milestone Tasks
        Milestone1_Project__c clonnedSparkIt = sparkIt.clone();
        insert clonnedSparkIt;
        if(clonnedSparkIt != null){
            // clonning milestones
            Map<Milestone1_Milestone__c, List<Milestone1_Task__c>> mapMilestoneTasks = new Map<Milestone1_Milestone__c, List<Milestone1_Task__c>>();
            for(Milestone1_Milestone__c milestone : [Select Id, Name,  Parent_Milestone__c, Complete__c,  Deadline__c, Description__c,
                                                    Expense_Budget__c,Hours_Budget__c, OwnerId, KickOff__c,
                                                    (Select Id, Name,Project_Milestone__c,OwnerID,
                                                    Complete__c, Description__c,  Start_Date__c,     Due_Date__c,    Priority__c,   Task_Stage__c,
                                                    Class__c,    Blocked__c,   Blocked_Reason__c,   Last_Email_Received__c,  Estimated_Hours__c,
                                                    Estimated_Expense__c From Project_Tasks__r) From Milestone1_Milestone__c
                                                    where Project__c =: sparkIt.Id]){
                    Milestone1_Milestone__c tempMilestone = milestone.clone();
                    List<Milestone1_Task__c> milestoneTasks = new List<Milestone1_Task__c>();
                    for(Milestone1_Task__c mileStoneTask : milestone.Project_Tasks__r){
                        Milestone1_Task__c tempTask = mileStoneTask.clone();
                        milestoneTasks.add(tempTask);
                    }
                    mapMilestoneTasks.put(tempMilestone, milestoneTasks);
            }

            //clonning Milestone Items
            List<Milestone1_Milestone__c> listToInsertMileStones = new List<Milestone1_Milestone__c>();
            for(Milestone1_Milestone__c clonnedItem : mapMilestoneTasks.keySet()){
                listToInsertMileStones.add(clonnedItem);
            }
            insert listToInsertMileStones;

            for(Milestone1_Milestone__c clonnedItem : listToInsertMileStones){
                if(mapMilestoneTasks.containsKey(clonnedItem)){
                    for(Milestone1_Task__c task : mapMilestoneTasks.get(clonnedItem)){
                        task.Project_Milestone__c = clonnedItem.Id;
                    }
                }

            }

            //inserting milestone tasks
            List<Milestone1_Task__c> listToInsertMileStonesTasks = new List<Milestone1_Task__c>();
            for(List<Milestone1_Task__c> tempTasks : mapMilestoneTasks.values()){
                listToInsertMileStonesTasks.addAll(tempTasks);
            }
            insert listToInsertMileStonesTasks;
        }
        return new Pagereference('/' + clonnedSparkIt.Id);
    }
}