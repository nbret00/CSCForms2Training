// 
// (c) 2014 Appirio, Inc.
//
// A Test class for JobTypeHierarchyController that create or update the JobTypes
//
// 31 Jan 2014     Sudhir Kr. Jagetiya      Original
//
@isTest
private class JobTypeHierarchyControllerTest {
  static final Integer BULK_RECORD_SIZE = 10;
  
	static testMethod void myUnitTest() {
	  List<Job_Type__c> jobTypeParentToBeInserted = new List<Job_Type__c>();
    for(Integer index = 0; index < BULK_RECORD_SIZE; index++) {
      jobTypeParentToBeInserted.add(new Job_Type__c(Name = 'Test ' + index));
    }
    insert jobTypeParentToBeInserted;
    
    List<Job_Type__c> jobTypeChildToBeInserted = new List<Job_Type__c>();
    for(Job_Type__c parentJobType : jobTypeParentToBeInserted) {
      jobTypeChildToBeInserted.add(new Job_Type__c(Name = 'Test', Parent__c = parentJobType.Id));
    }
    insert jobTypeChildToBeInserted;
    
    Test.startTest();
      JobTypeHierarchyController jobTypeCntrl = new JobTypeHierarchyController();
      jobTypeCntrl.selectedJobTypeId = jobTypeParentToBeInserted.get(0).Id;
      jobTypeCntrl.selectedAction = JobTypeHierarchyController.OPERATION_ADD_SIBILING;
      jobTypeCntrl.refreshModalWindow();
      system.assertEquals(null, jobTypeCntrl.sObjectToBind.Parent__c);
      
      jobTypeCntrl.selectedAction = JobTypeHierarchyController.OPERATION_ADD_CHILD;
      jobTypeCntrl.refreshModalWindow();
      system.assertEquals(jobTypeParentToBeInserted.get(0).Id, jobTypeCntrl.sObjectToBind.Parent__c);
      
      jobTypeCntrl.selectedAction = JobTypeHierarchyController.OPERATION_EDIT;
      jobTypeCntrl.refreshModalWindow();
      system.assertEquals(jobTypeParentToBeInserted.get(0).Id, jobTypeCntrl.sObjectToBind.Id);
      
      jobTypeCntrl.sObjectToBind.Category__c = 'Test';
      jobTypeCntrl.saveJobType();
      List<Job_Type__c> jobTypeList = [SELECT Category__c FROM Job_Type__c WHERE Id = :jobTypeParentToBeInserted.get(0).Id LIMIT 1];
      system.assertNotEquals(null, jobTypeList);
      system.assertEquals(jobTypeCntrl.sObjectToBind.Category__c, jobTypeList.get(0).Category__c);
      
      jobTypeCntrl.deleteJobType();
      jobTypeList = [SELECT Category__c FROM Job_Type__c WHERE Id = :jobTypeParentToBeInserted.get(0).Id LIMIT 1];
      system.assertEquals(0, jobTypeList.size());
    Test.stopTest();
	}
}