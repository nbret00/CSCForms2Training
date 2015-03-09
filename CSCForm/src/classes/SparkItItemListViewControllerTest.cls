// 
// (c) 2014 Appirio, Inc.
//
// A Test Class for SparkItItemListViewController
//
// 20 Jan 2014     Sudhir Kr. Jagetiya       Original
//
//
@isTest
private class SparkItItemListViewControllerTest {

  static final Integer BULK_RECORD_SIZE;
  static final String PARTNER_PROFILE_NAME;
  static final Id PARTNER_PROFILE_ID;
  
  static {
    PARTNER_PROFILE_NAME = 'Partner Community Spark It';
    BULK_RECORD_SIZE = 20;
    for(Profile partnerProfile : [SELECT Id FROM Profile WHERE Name = :PARTNER_PROFILE_NAME LIMIT 1]) {
      PARTNER_PROFILE_ID = partnerProfile.Id;
    }
  }

  static testMethod void myUnitTest() {
     
     Account accountToBeInserted = new Account(Name = 'Test Account ');
     insert accountToBeInserted;
     
     Contact contactToBeInserted = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = accountToBeInserted.Id);
     insert contactToBeInserted;
     
     User userToBeInserted = new User(Email = 'test@test.com', Username = 'testSpark123456' + '@safeway.com', LastName = 'test',
                                     Alias = 'test', ProfileId = PARTNER_PROFILE_ID, LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US',
                                     TimeZoneSidKey = 'America/Chicago', EmailEncodingKey = 'UTF-8', ContactId = contactToBeInserted.Id, CommunityNickname = 'testSpark123456');
     insert userToBeInserted;
     
     Milestone1_Project__c sparkItRecordToBeCreated = Milestone1_Test_Utility.sampleProjectActive('proj1');
     insert sparkItRecordToBeCreated;
     
     Job_Type__c jobType = new Job_Type__c(Name = 'Test');
     insert jobType;
     
     List<Spark_It_Item__c> sparkItItemToBeCreated = new List<Spark_It_Item__c>();
     for(Integer index = 0; index < BULK_RECORD_SIZE; index++) {
        // sparkItItemToBeCreated.add(new Spark_It_Item__c(Name = 'Test', Job_Type__c = jobType.Id, Partner__c = accountToBeInserted.Id, 
       //                                                                  Spark_It__c = sparkItRecordToBeCreated.Id));
       }
       insert sparkItItemToBeCreated;
        
     Test.startTest();
        system.runAs(userToBeInserted) {
            
          SparkItItemListViewController cntrollerObj = new SparkItItemListViewController();
          system.assertEquals(1, cntrollerObj.pageNumber);
          //system.assertEquals(BULK_RECORD_SIZE, cntrollerObj.noOfRecords);
          //system.assertNotEquals(null, cntrollerObj.getSparkItItemList());
          //system.assertEquals(true, cntrollerObj.hasNext);
          //system.assertEquals(false, cntrollerObj.hasPrevious);
          
          cntrollerObj.last();
          //system.assertEquals(false, cntrollerObj.hasNext);
          //system.assertEquals(true, cntrollerObj.hasPrevious);
          
          cntrollerObj.previous();
          //system.assertEquals(true, cntrollerObj.hasNext);
          //system.assertEquals(false, cntrollerObj.hasPrevious);
          
          cntrollerObj.next();
          //system.assertEquals(false, cntrollerObj.hasNext);
          //system.assertEquals(true, cntrollerObj.hasPrevious);
          
          cntrollerObj.first();
          //system.assertEquals(true, cntrollerObj.hasNext);
          //system.assertEquals(false, cntrollerObj.hasPrevious);
        }
     Test.stopTest();
     
  }
}