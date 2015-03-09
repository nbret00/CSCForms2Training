/**
 * Test class for RSFUtility
 */
@isTest
private class RSFUtility_Test {

    static testMethod void myUnitTest() {
		// Create a poject
		Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('Chatter Blow');
		insert proj;

		// Create a milestone
		Milestone1_Milestone__c mstone = Milestone1_Test_Utility.sampleMilestone(proj);
		insert mstone;

		List<Milestone1_Task__c> lTask = new List<Milestone1_Task__c>();
		for(Integer i = 0; i < 10; i++){
			lTask.add( Milestone1_Test_Utility.sampleTask(mstone.Id) );
		}
		lTask[0].Blocked__c = true;
		lTask[0].Blocked_Reason__c = 'Test reason';
		lTask[1].Complete__c = true;
		
		Test.startTest();
		
		insert lTask;
		
		Test.stopTest();
		
		mstone = [Select ID, Blocked_Tasks_in_Tasks__c, Complete_Tasks_in_Tasks__c, Open_Tasks_in_Tasks__c from Milestone1_Milestone__c Where ID =:mstone.id];		
		
		System.assertEquals(mstone.Blocked_Tasks_in_Tasks__c, 1);
		System.assertEquals(mstone.Complete_Tasks_in_Tasks__c, 1);
		System.assertEquals(mstone.Open_Tasks_in_Tasks__c, 9);
    }
}