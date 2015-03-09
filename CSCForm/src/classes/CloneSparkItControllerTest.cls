/*
Class : CloneSparkItControllerTest
Description :  Test class for CloneSparkItController
Developed by : Ashish Goyal
Created Date : April 21, 2014
*/

@isTest
private class CloneSparkItControllerTest {
	static testMethod void testCloneSparkIt() {
		
		Milestone1_Project__c projectName = Milestone1_Test_Utility.sampleProject('Test App Project');
		insert projectName;
		
		Milestone1_Project__c projectName2 = Milestone1_Test_Utility.sampleProject('Test App Project2');
		insert projectName2;
		
		
		Milestone1_Milestone__c testPredecessorMilestone1 = Milestone1_Test_Utility.testSampleMilestone(projectName2.Id,null,'UNIT_TEST_PREDECESSOR_MILESTONE_NAME_ACB123XYZ_UNIQUE' + System.now());
        insert testPredecessorMilestone1;
        
		Milestone1_Milestone__c testPredecessorMilestone = Milestone1_Test_Utility.testSampleMilestone(projectName.Id,null,'UNIT_TEST_SUCCESSOR_MILESTONE_1_NAME_ACB123XYZ_UNIQUE' + System.now());
        testPredecessorMilestone.Parent_Milestone__c = testPredecessorMilestone1.Id;
        insert testPredecessorMilestone;
        
        
		//Test.setCurrentPage(Page.SparkItStoresSearch);		
		ApexPages.StandardController std = new ApexPages.StandardController(projectName);
		CloneSparkItController controller = new CloneSparkItController(std);
		controller.sparkIt.Name = 'Test Proj';
		controller.cloneSparkIt();
	}

}