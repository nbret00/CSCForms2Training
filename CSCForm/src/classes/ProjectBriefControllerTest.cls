/*
Class : ProjectBriefControllerTest
Description :  Test Class For ProjectBriefControllerTest
Developed by : 
Created Date : 
Last Modified on Jan 09, 2014 By Sudhir Kumar Jagetiya Task ref. T-234045
*/

@isTest
private class ProjectBriefControllerTest {
    
    static testMethod void SearchSpark_ItControllerTest() {
        
      Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProjectActive('proj');
      insert proj;
    
	    Division__c div = Milestone1_Test_Utility.createDivision(true);
	    
	    Store__c store = Milestone1_Test_Utility.createStore(div.Id, 'TT', true);
	    
	    SparkIt_Store__c sparkstore = Milestone1_Test_Utility.createSparkItStore(proj.Id, store.Id, true);
    
      Test.startTest();
	      ApexPages.currentPage().getParameters().put('id', proj.Id);
	      ApexPages.StandardController stdController = new ApexPages.StandardController(proj);
	      ProjectBriefController pController = new ProjectBriefController(stdController);
	      
	      system.assertEquals(1, pController.tierWithBanners.size());
	      system.assertEquals(1, pController.tierWithDivisions.size());
	      
	      PageReference page = pController.openEditMode();
	      system.assertNotEquals(null, page);
	      system.assert(page.getUrl().contains('isEdit=true'));
	      
	      pController.saveProgram();
	      Milestone1_Project__c program = [SELECT Id, Is_Program_Completed__c FROM Milestone1_Project__c WHERE Id = :proj.Id LIMIT 1];
	      system.assertEquals(true, program.Is_Program_Completed__c);
	      
	      page = pController.cancelEditMode();
        system.assertNotEquals(null, page);
        system.assert(page.getUrl().contains('isEdit=false'));
         
      Test.stopTest();
    }
}