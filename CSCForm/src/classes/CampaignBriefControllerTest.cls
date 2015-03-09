// 
// (c) 2014 Appirio, Inc.
//
// A Test class for CampaignBriefController
//
// 10 Feb 2014   Sudhir Kr. Jagetiya      Original
//
@isTest
private class CampaignBriefControllerTest {

	static testMethod void myUnitTest() {
	  
	  Campaign__c campaign = new Campaign__c(Name = 'test');
	  insert campaign;
	
	  Test.startTest();
	    ApexPages.currentPage().getParameters().put('id', campaign.Id);
	    ApexPages.StandardController stdController = new ApexPages.StandardController(campaign);
	    CampaignBriefController pController = new CampaignBriefController(stdController);
	    
	    
	    PageReference page = pController.openEditMode();
	    system.assertNotEquals(null, page);
	    system.assert(page.getUrl().contains('isEdit=true'));
	    
	    pController.saveProgram();
	    Campaign__c program = [SELECT Id, Is_Campaign_Completed__c FROM Campaign__c WHERE Id = :campaign.Id LIMIT 1];
	    system.assertEquals(true, program.Is_Campaign_Completed__c);
	    
	    page = pController.cancelEditMode();
	    system.assertNotEquals(null, page);
	    system.assert(page.getUrl().contains('isEdit=false'));
         
      Test.stopTest(); 
	}
}