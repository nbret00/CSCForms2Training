/*
Class : SparkItAfterInsertUpdateDeleteTest
Description :  Test class for SparkItAfterInsertUpdateDelete
Developed by : Manmeet Manethiya
Created Date : December 31, 2013
*/

@isTest
private class SparkItAfterInsertUpdateDeleteTest {
	static testMethod void testSparkItDeletion() {
		Milestone1_Project__c project = Milestone1_Test_Utility.sampleProject('Test');
		project.Template__c = true;
		insert project;

		Test.startTest();
		delete project;
		//assert
		//successfully deleted because user is system admin
		System.assertEquals(0, [Select id from Milestone1_Project__c where id = : project.Id].size());
		Test.stopTest();
	}
}