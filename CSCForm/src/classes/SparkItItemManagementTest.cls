//
// (c) 2014 Appirio, Inc.
//
// Test Class For SparkItItemManagement
//
// 7 February 2014     Ashish Sharma      Original
//
// 16 Oct 2014     Neeraj Sharma Modified: ref:T-316801 Added method itemDeleteHistoryTest
//                               to test create history record for deleted spark it items
//
@isTest
private class SparkItItemManagementTest {

    static testMethod void itemSharingTest() {
      // Insert test Data
      User testUser = Milestone1_Test_Utility.createSFUser();
      Division__c testDivision = Milestone1_Test_Utility.createDivision(true);

      Milestone1_Project__c project = new Milestone1_Project__c();
      project.Name = 'Test Program';
      project.Requestor__c = testUser.Id;
      project.Description__c = 'Test';
      project.Go_Live_Date__c = date.today();
      project.Division__c = testDivision.Id;
      insert project;

      Spark_It_Item__c testItem = new Spark_It_Item__c();
      testItem.Name = 'Test Milestone';
      testItem.Spark_It__c = project.Id;
      insert testItem;
      
      delete testItem;
      
    }
    static testMethod void itemDeleteHistoryTest() {
      // Insert test Data
      User testUser = Milestone1_Test_Utility.createSFUser();
      Division__c testDivision = Milestone1_Test_Utility.createDivision(true);

      Milestone1_Project__c project = new Milestone1_Project__c();
      project.Name = 'Test Program';
      project.Requestor__c = testUser.Id;
      project.Description__c = 'Test';
      project.Go_Live_Date__c = date.today();
      project.Division__c = testDivision.Id;
      insert project;

      list<Spark_It_Item__c> itemList = new list<Spark_It_Item__c>();
      
      itemList.add(createItem(project,1));
      itemList.add(createItem(project,2));
      itemList.add(createItem(project,3));
      itemList.add(createItem(project,4));
      itemList.add(createItem(project,5));
      
      insert itemList;
      
      test.startTest();    
      
      delete itemList;
      list<Item_History__c> itemHistoryList = [SELECT Id, Name FROM Item_History__c WHERE Program_Id__c = :project.Id];
      system.debug(itemHistoryList);
      system.assert(itemHistoryList.size() == 5);
      test.stopTest();
      
    }  
    private static Spark_It_Item__c createItem(Milestone1_Project__c project, Integer index){
      Spark_It_Item__c testItem = new Spark_It_Item__c();
      testItem.Name = 'Test Milestone'+index;
      testItem.Spark_It__c = project.Id;
      return testItem;	
    }  
}