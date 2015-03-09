// 
// (c) 2014 Appirio, Inc.
//
// A Test class for TreeViewComponentCntrl.
//
// 28 Feb 2014     Sudhir Kr. Jagetiya    Original
//
@isTest
private class TreeViewComponentCntrlTest {
  
  static final Integer BULK_RECORD_LIMIT = 10;
	static testMethod void myUnitTest() {
	  
	  List<Budget_Code__c> projectCodeList = new List<Budget_Code__c>();
	  for(Integer index = 0; index < BULK_RECORD_LIMIT; index++) {
	  	projectCodeList.add(Milestone1_Test_Utility.createBudgetCode(false));
	  }
	  insert projectCodeList;
	  
	  Test.startTest();
	    TreeViewComponentCntrl cntrl = new TreeViewComponentCntrl();
	    cntrl.init();
	    system.assertNotEquals(null, cntrl.jsonString);
	  Test.stopTest();
	}
}