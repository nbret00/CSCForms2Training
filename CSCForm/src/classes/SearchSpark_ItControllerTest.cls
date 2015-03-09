@isTest
private class SearchSpark_ItControllerTest {
    static testMethod void SearchSpark_ItControllerTest() {
        List<Milestone1_Project__c> milestoneProjects = new List<Milestone1_Project__c>();
        Milestone1_Project__c proj;
        for(Integer i = 1; i < 6; i++){
            proj = Milestone1_Test_Utility.sampleProjectActive('proj' + i);
            milestoneProjects.add(proj);
        }
        insert milestoneProjects;
        Test.startTest();
        
        SearchSpark_ItController searchController = new SearchSpark_ItController();
        searchController.statusSelected.add('Active');
        searchController.statusSelected.add('Inactive');
        searchController.searchSparkIts();
        
        System.assertEquals(false, searchController.milestoneProjects.isEmpty(), 'Atleast one spark its will be returned.');
        System.assertEquals(5, searchController.milestoneProjects.size(), 'Total 5 Spark its should be returned.');
        
        searchController.plSelected.add('A');
        searchController.milestoneProject.Name = 'proj';
        searchController.milestoneProject.Deadline__c = System.Today();
        searchController.searchSparkIts();
        System.assertEquals(true, searchController.milestoneProjects.isEmpty(), 'No spark its will be returned.');
         
        Test.stopTest();
    }

}