/* 
    // (c) 2012 Appirio, Inc.
    //
    // Test sparkIt chart controller
    //
    // 23 Jan 2014    Dheeraj Kumar (JDC)      Original
    //
*/ 

@isTest
private class SparkIt_Charts_GanttController_Test {
    
        public static final String COLOR_COMPLETE = '#333333';
        
        // To test SparkIt JSon
    static testMethod void TestProjectJson() {
                
        Campaign__c campaign = Milestone1_Test_Utility.createCampaign('testCampaign', true);
        Division__c divisionObj = Milestone1_Test_Utility.createDivision('testCampaign', true);             
                
        Milestone1_Project__c sparkIt = Milestone1_Test_Utility.sampleProjectActive('Json1');
        sparkIt.Campaign__c = campaign.Id;
        sparkIt.Division__c = divisionObj.Id;
        sparkIt.Status__c = 'Completed';
        insert sparkIt;      
        
       
        Date dt = Date.today();
        
        SparkIt_Charts_GanttController cls = new SparkIt_Charts_GanttController();
        //cls.mytarget = 'sparks';

        //String ret = cls.getProjectGanttJson();
        
        //System.assert(ret.indexOf('ganttData') > -1);
        //System.assert(ret.indexOf(sparkIt.Name) > -1);        
        String testDateString = 'new Date(' + dt.year() + ',' + (dt.month()-1) + ',' + dt.day() +')';
            //System.assert(ret.indexOf(testDateString) > -1, 'expected: ' + testDateString + ': in: ' + ret);

        Milestone1_Project__c sparkIt2 = Milestone1_Test_Utility.sampleProjectActive('Json2');
        sparkIt2.Deadline__c = Date.today()-1;
        sparkIt2.Campaign__c = campaign.Id;
        sparkIt2.Division__c = divisionObj.Id;
        sparkIt2.Status__c = 'Completed';
        insert sparkIt2;

        //ret = cls.getProjectGanttJson();
       // System.assert(ret.indexOf(COLOR_COMPLETE) > -1);        
    }
    
}