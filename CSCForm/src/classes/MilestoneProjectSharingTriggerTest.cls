//
// (c) 2014 Appirio, Inc.
//
// Test Class For Milestone1ProjectSharingTriggerHandler
//
// 7 February 2014     Ashish Sharma      Original
//
//
@isTest
private class MilestoneProjectSharingTriggerTest {

    static testMethod void programSharingTest() {
      // Insert test Data
      User testUser1 = Milestone1_Test_Utility.createSFUser();
      Division__c testDivision = Milestone1_Test_Utility.createDivision(true);

      Milestone1_Project__c project = new Milestone1_Project__c();
      project.Name = 'Test Program';
      project.Requestor__c = testUser1.Id;
      project.Description__c = 'Test';
      project.Go_Live_Date__c = date.today();
      project.Division__c = testDivision.Id;
      insert project;

      //Assert test if project record is shared with requester or not
      System.assert([SELECT ID FROM Milestone1_Project__Share WHERE ParentId =: project.Id
                         AND UserOrGroupId =: testUser1.Id].Id <> null);

      Milestone1_Milestone__c testMilestone = new Milestone1_Milestone__c();
      testMilestone.Name = 'Test Milestone';
      testMilestone.Project__c = project.Id;
      insert testMilestone;

      Spark_It_Item__c testItem = new Spark_It_Item__c();
      testItem.Name = 'Test Milestone';
      testItem.Spark_It__c = project.Id;
      insert testItem;

      // Update Program's requester
      User testUser2 = Milestone1_Test_Utility.createSFUser();
      project.Requestor__c = testUser2.Id;
      update project;

      //Assert test if project record is shared with new requester or not
      System.assert([SELECT ID FROM Milestone1_Project__Share WHERE ParentId =: project.Id
                         AND UserOrGroupId =: testUser2.Id].Id <> null);
      
      //Assert test if testItem record is shared with project's requester or not
      /*System.assert([SELECT ID FROM Spark_It_Item__Share WHERE ParentId =: testItem.Id
                         AND UserOrGroupId =: project.Requestor__c].Id <> null);*/

      //Assert test if testMilestone record is shared with project's requester or not
      List<Milestone1_Milestone__Share> mileStoneList = new List<Milestone1_Milestone__Share>([SELECT ID FROM Milestone1_Milestone__Share WHERE ParentId =: testMilestone.Id
                         																			AND UserOrGroupId =: project.Requestor__c]);
      System.assert(mileStoneList.size() == 0);
    }
}