/**
 * Author        :  Shailendra Singh
 * Name          :  RepeatCycleCtrl_Test
 * Related Task  :  T-248629
 * Date 		 :  10/02/2014
 * Description   :  Apex unit test for RepeatCycleCtrl.cls
 */
@isTest
private class RepeatCycleCtrl_Test {

    static testMethod void myUnitTest() {
	    Milestone1_Project__c project = Milestone1_Test_Utility.sampleProjectActive('Test');
	    insert project;
	
	    Milestone1_Milestone__c milestone = Milestone1_Test_Utility.sampleMilestone(project);
	    insert milestone;
	
	    Spark_It_Item__c item = new Spark_It_Item__c();
	    item.Spark_It__c = project.id;
	    insert item;     
	    
	    Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(milestone.id, System.today(), System.today().addDays(7), false, false);
	    task1.Spark_It_Item__c = item.id;
	    Milestone1_Task__c task2 = Milestone1_Test_Utility.sampleTask(milestone.id, System.today(), System.today().addDays(7), false, false);
	    task2.Proof_Cycle__c = 1;
	    task2.Spark_It_Item__c = item.id;
	    List<Milestone1_Task__c> taskList = new List<Milestone1_Task__c>();
	    taskList.add(task1);
	    taskList.add(task2);
	    insert taskList;
	    
	    Test.startTest();
	    
	    ApexPages.StandardController stdController = new  ApexPages.StandardController(item);
		RepeatCycleCtrl ctrl = new RepeatCycleCtrl(stdController);	
		ctrl.cloneTask();
		
		Test.stopTest();
		
		// validate that we have 3 task for item 
		
		List<Milestone1_Task__c> currentTaskList = [Select ID from Milestone1_Task__c Where Spark_It_Item__c =:item.id]; 
		System.assertEquals(currentTaskList.size(), 3);
    }
}