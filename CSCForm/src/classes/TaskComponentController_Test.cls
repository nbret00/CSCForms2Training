/**************************************************************************************
Class 			: TaskComponentController_Test 
Developed by 	: Shailendra Singh(Appirio Offshore)
Created Date 	: 23/08/2012
Related Task	: T-71390
Description		: Test class for TaskComponentController
*******************************************************************************************/
@isTest
private class TaskComponentController_Test {

    static testMethod void myUnitTest() {
       Task task = new Task(Subject ='Test case',Status = 'Open',OwnerId = Userinfo.getUserId(),ActivityDate = System.today());
       insert task;
       TaskComponentController controller = new TaskComponentController();
       
       System.assert(controller.taskList.size() != 0);
       
       controller.filterParam = 0;
       controller.queryTask();
              
       controller.filterParam = 1;
       controller.queryTask();

       controller.filterParam = 2;
       controller.queryTask();
              
       controller.filterParam = 3;
       controller.queryTask();
       
       controller.filterParam = 4;
       controller.queryTask();
       
       controller.filterParam = 5;
       controller.queryTask();
                                   
       controller.filterParam = 6;
       controller.queryTask();   
                                       
    }
}