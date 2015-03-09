/**
 * Author        :  Shailendra Singh
 * Name          :  RepeatCycleCtrl
 * Related Task  :  T-248629
 * Date 		 :  10/02/2014
 * Description   :  Clone all Milestone1_Task__c for  Spark_It_Item__c where Proof Cycle = 1
 */
public with sharing class RepeatCycleCtrl {

	private final Spark_It_Item__c item; 
	
	public RepeatCycleCtrl(ApexPages.StandardController stdController) {
		item = (Spark_It_Item__c)stdController.getRecord();
	}
	
	// Clone all Milestone1_Task__c for  Spark_It_Item__c where Proof Cycle = 1
	public Pagereference cloneTask() {
		List<Milestone1_Task__c> clonedTaskList = new List<Milestone1_Task__c>();
		for(Milestone1_Task__c task : [Select Total_Hours__c, Total_Expense__c, Task_Stage__c, Task_Number__c, Start_Date__c, Spark_It_Item__c, Short_ID__c, 
										Send_Notificaiton__c, Proof_Cycle__c, Project__c, Project_Milestone__c, ProjectStatus__c, ProjectId__c, Priority__c,
										Predecessor_Task__c, Predecessor_Task_Import_Id__c, OwnerId__c, Overall_Status__c, Name, Milestone_Grandparent__c, 
										Last_Email_Received__c, LastModifiedDate, LastModifiedById, IsDeleted, Index__c, Index_Helper__c, ImportID__c, Id,
										Hours_Balance__c, Expense_Balance__c, Estimated_Hours__c, Estimated_Expense__c, Email_GUID__c, Due_Date__c, Description__c, 
										Days_Late__c, Days_Late_Formula__c, Complete__c, Class__c, Blocked__c, Blocked_Reason__c, OwnerID
										From Milestone1_Task__c Where Spark_It_Item__c = :item.id AND Proof_Cycle__c = 1]) {
			clonedTaskList.add(task.clone());									
		}
		insert clonedTaskList;
		return new Pagereference('/' + item.id);
	}
}