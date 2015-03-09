// 
// (c) 2014 Appirio, Inc.
//
// A Test class for TreeViewComponent that display the JobTypes in tree view
//
// 31 Jan 2014     Sudhir Kr. Jagetiya      Original
//
@isTest
private class TreeStructureUtilsTest {
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
      TreeStructureUtils cntrl = new TreeStructureUtils();
      cntrl.ObjectName = 'Job_Type__c';
      cntrl.ProductId = jobTypeParentToBeInserted.get(0).Id;
      cntrl.init();
      system.assert(cntrl.LstOfProductNodes.size() > 0);
    Test.stopTest();
	}
}