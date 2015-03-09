/*
Class : SparkItStoresSearchControllerTest
Description :  Test class for SparkItStoresSearchController
Developed by : Manmeet Manethiya
Created Date : December 30, 2013
*/

@isTest
private class SparkItStoresSearchControllerTest {
	static testMethod void testSparkItAssociation() {
		Store__C store = new Store__C();
		store.Bakery__c = true;
		insert store;

		Milestone1_Project__c project = Milestone1_Test_Utility.sampleProject('Test');
		insert project;

		Test.setCurrentPage(Page.SparkItStoresSearch);		
		ApexPages.StandardController std = new ApexPages.StandardController(project);
		SparkItStoresSearchController controller = new SparkItStoresSearchController(std);
		controller.dummyStore.Bakery__c = true;
		controller.fetchSelectedFields();
		//controller.selectedFieldApiNames = new List<String>{'Bakery__c'};
		controller.searchStores();
		//controller.listStores.get(0).get(0).isSelected = true;
		controller.associate();
		List<SparkIt_Store__c> sparkItList = new List<SparkIt_Store__c>([Select Id from SparkIt_Store__c where Spark_It__c = : project.Id and Store__c = : store.Id]);
		//system assert
		system.assertEquals(0, sparkItList.size());
	}
}