/***********************************************************************
class Name      : WebserviceForRequestProof
Created By      : Kirti Agarwal
Created Date    : 31st Dec,2013
Purpose         : Create milestone task on click of 'request proof' button
Task            : T-226893
************************************************************************/
global without sharing class WebserviceForRequestProof {
    
    static final String PROGRAM_RECORD_TYPE_D = 'D';
    static final String QUEUE_NAME_PRODUCTION = 'Program_Prodution';
    static final String QUEUE_NAME_TRAFFIC = 'SparkIt_Traffic';

    WebService static String createMilestoneTask(Id spartItemId) {
        List<Spark_It_Item__c> sparItemList = [select id, Spark_It__c, Spark_It__r.RecordType.Name, Proof_Requests__c from Spark_It_Item__c where id = : spartItemId];
        
        if (sparItemList.size() > 0) {
        	  String queueName = sparItemList[0].Spark_It__c != null && PROGRAM_RECORD_TYPE_D.equalsIgnoreCase(sparItemList[0].Spark_It__r.RecordType.Name) ? QUEUE_NAME_PRODUCTION : QUEUE_NAME_TRAFFIC;
        	  sparItemList[0].Proof_Requests__c = sparItemList[0].Proof_Requests__c == null ? 1 : sparItemList[0].Proof_Requests__c + 1;
            update sparItemList;
            
            List<QueueSobject> queueList = [Select SobjectType, QueueId, Id From QueueSobject where Queue.DeveloperName = :queueName limit 1];
            List<Milestone1_Milestone__c> mostRecentMilesStoneList = [select id from Milestone1_Milestone__c Order By CreatedDate desc limit 1];
            if (queueList.size() > 0 && mostRecentMilesStoneList.size() > 0) {
                Milestone1_Task__c Miletask = new Milestone1_Task__c();
                Miletask.Name = 'Proof Requested';
                Miletask.Project_Milestone__c = mostRecentMilesStoneList[0].id;
                Miletask.Due_Date__c = date.today().addDays(7);
                Miletask.Spark_It_Item__c = spartItemId;
                Miletask.OwnerID = queueList[0].QueueId;
                insert Miletask;
                return Miletask.id + '';
            }
        }
        return '';
    }
    
    WebService static String createMilestoneTaskOnProofUploaded(Id spartItemId) {
        List<Spark_It_Item__c> sparItemList = [SELECT Id, Spark_It__c, Spark_It__r.RecordType.Name, 
                                                      Proof_Requests__c 
                                                 FROM Spark_It_Item__c 
                                                WHERE Id = : spartItemId
                                                  AND Spark_It__r.RecordType.Name = :PROGRAM_RECORD_TYPE_D];
        
        if (sparItemList.size() > 0) {
            
	        List<QueueSobject> queueList = [SELECT SobjectType, QueueId, Id FROM QueueSobject WHERE Queue.DeveloperName = :QUEUE_NAME_PRODUCTION LIMIT 1];
	        List<Milestone1_Milestone__c> mostRecentMilesStoneList = [SELECT Id FROM Milestone1_Milestone__c ORDER BY CreatedDate DESC LIMIT 1];
	        if (queueList.size() > 0 && mostRecentMilesStoneList.size() > 0) {
            Milestone1_Task__c Miletask = new Milestone1_Task__c();
            Miletask.Name = 'Proof Uploaded';
            Miletask.Project_Milestone__c = mostRecentMilesStoneList[0].id;
            Miletask.Due_Date__c = date.today().addDays(7);
            Miletask.Spark_It_Item__c = spartItemId;
            Miletask.OwnerID = queueList[0].QueueId;
            insert Miletask;
            return Miletask.id + '';
	        }
        }
        return '';
    }

}