//
// (c) 2014 Appirio, Inc.
//
// Test Class For MilestoneSharingTriggerHandler
//
// 7 February 2014     Ashish Sharma      Original
//
//
@isTest(seeAllData = false)
private class MilestoneSharingTriggerHandlerTest {

    static testMethod void milestoneSharingTest() {
    	// Insert test Data
    	User testUser = Milestone1_Test_Utility.createSFUser();
    	Division__c testDivision = Milestone1_Test_Utility.createDivision(true);

      Milestone1_Project__c project = new Milestone1_Project__c();
      project.Name = 'Test Program';
      project.Requestor__c = UserInfo.getUserId(); //testUser.Id;
      project.Description__c = 'Test';
      project.Go_Live_Date__c = date.today();
      project.Division__c = testDivision.Id;
      insert project;

      Milestone1_Milestone__c testMilestone = new Milestone1_Milestone__c();
      testMilestone.Name = 'Test Milestone';
      testMilestone.Project__c = project.Id;
      insert testMilestone;

	  List<Milestone1_Milestone__Share> milestoneList = new List<Milestone1_Milestone__Share>([SELECT ID FROM Milestone1_Milestone__Share 
	  																							WHERE ParentId =: testMilestone.Id AND UserOrGroupId =: project.Requestor__c]);
      //Assert test if testMilestone record is shared with project's requester or not
      System.assert(milestoneList.size() != 0);
    }
}