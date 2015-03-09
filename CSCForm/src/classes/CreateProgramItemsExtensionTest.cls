// 
// (c) 2014 Appirio, Inc.
//
// A Test class for CreateProgramItems page that create Items for program
//
// 31 Jan 2014     Sudhir Kr. Jagetiya      Original
//
@isTest
private class CreateProgramItemsExtensionTest {
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
	  
	  Milestone1_Project__c program = Milestone1_Test_Utility.sampleProjectActive('proj 1');
	  insert program;
	  
	  Test.startTest();
	    
	    CreateProgramItemsExtension cntrlObj = new CreateProgramItemsExtension(new ApexPages.StandardController(program));
	    system.assertEquals('', cntrlObj.selectedJobTypeIds);
	    
	    cntrlObj.selectedJobTypeIds = jobTypeChildToBeInserted.get(0).Id + ',' + jobTypeChildToBeInserted.get(1).Id;
	    cntrlObj.createItems();
	    List<Spark_It_Item__c> sparkItItems = fetchItems(program.Id);
	    system.assertNotEquals(null, sparkItItems);
	    system.assertEquals(2, sparkItItems.size());
	    
	    cntrlObj = new CreateProgramItemsExtension(new ApexPages.StandardController(program));
	    cntrlObj.selectedJobTypeIds = cntrlObj.selectedJobTypeIds.replace(jobTypeChildToBeInserted.get(0).Id+',', '');
      cntrlObj.createItems();
      sparkItItems = fetchItems(program.Id);
      system.assertNotEquals(null, sparkItItems);
      system.assertEquals(1, sparkItItems.size());
	    system.assertEquals(jobTypeChildToBeInserted.get(1).Id, sparkItItems.get(0).Job_Type__c);
	    
	    system.assertNotEquals(null, cntrlObj.backToProgram());
	    
	  Test.stoptest();
	}
	
	private static List<Spark_It_Item__c> fetchItems(Id programId) {
		return [SELECT Id, Job_Type__c FROM Spark_It_Item__c WHERE Spark_It__c = :programId];
	}
}