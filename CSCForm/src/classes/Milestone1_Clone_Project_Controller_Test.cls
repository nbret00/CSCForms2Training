/*
Class : Milestone1_Clone_Project_Controller_Test
Description :  This class is test class for Milestone1_Clone_Project_Controller
Developed by : Manmeet Manethiya
Created Date : December 20, 2013
*/

@isTest
private class Milestone1_Clone_Project_Controller_Test {
	static testMethod void testCloneController() {
		Milestone1_Project__c project = new Milestone1_Project__c();
		project.name = 'Test';
		insert project;

		Milestone1_Milestone__c milestone = new Milestone1_Milestone__c();
		milestone.Project__c = project.id;
		milestone.Name = 'Test';
		insert milestone;

		Milestone1_Task__c task = new Milestone1_Task__c();
		task.Project_Milestone__c = milestone.Id;
		insert task;

		ApexPages.StandardController stc = new ApexPages.StandardController(project);
		Milestone1_Clone_Project_Controller controller = new Milestone1_Clone_Project_Controller(stc);
		controller.isToCreateMilestones = true;
		controller.isToCreateTasks = true;
		controller.createClone();

		//assert
		system.assertEquals(1, [select count(Id) from Milestone1_Milestone__c where name = 'Copy of Test'].size());
	}
}