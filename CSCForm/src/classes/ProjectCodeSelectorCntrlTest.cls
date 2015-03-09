// 
// (c) 2014 Appirio, Inc.
//
// A Test class for ProjectCodeSelectorCntrl.
//
// 28 Feb 2014     Sudhir Kr. Jagetiya    Original
//
@isTest
private class ProjectCodeSelectorCntrlTest {

	static final Integer BULK_RECORD_LIMIT = 10;
  static testMethod void myUnitTest() {
    
    List<Budget_Code__c> projectCodeList = new List<Budget_Code__c>();
    for(Integer index = 0; index < BULK_RECORD_LIMIT; index++) {
      projectCodeList.add(Milestone1_Test_Utility.createBudgetCode(false));
    }
    insert projectCodeList;
    
    Milestone1_Project__c program = Milestone1_Test_Utility.sampleProjectActive('Test');
    insert program;
    
    Test.startTest();
      ProjectCodeSelectorCntrl cntrl = new ProjectCodeSelectorCntrl(new ApexPages.StandardController(program));
      cntrl.selectedProjectCodeId = projectCodeList.get(0).Id;
      cntrl.updateProgram();
      
      program = [SELECT Id, Budget_Code__c FROM Milestone1_Project__c WHERE Id = :program.Id];
      system.assertNotEquals(null, program);
      system.assertNotEquals(projectCodeList.get(0).Budget_Code__c, program.Budget_Code__c);
      
      system.assertNotEquals(null, cntrl.backToProgram());
    Test.stopTest();
  }
}