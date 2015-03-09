/**************************************************************************************
Class 			: TaskComponentController 
Developed by 	: Shailendra Singh(Appirio Offshore)
Created Date 	: 21/08/2012
Related Task	: T-71390
Description		: Display task of logged in User.
*******************************************************************************************/
public with sharing class TaskComponentController {
	
	public Integer filterParam{get;set;}
	
	public List<Task> taskList{get;set;}
	
	public TaskComponentController(){
		taskList = new List<Task>();
		for(Task  task : [Select WhoId,WhatId,Subject,Status,Priority,OwnerId,IsClosed,Id,ActivityDate,AccountId From Task Where Status != 'Completed' AND OwnerId =:Userinfo.getUserId() ORDER BY ActivityDate]){
			taskList.add(task);			
		}
		filterParam = 7;  // default displaing all open task.		
	}
	
	public Pagereference queryTask(){
		String filterCondition = '';
		if(filterParam != null){
			if(filterParam == 0){ // Display Overdue
				filterCondition = ' AND ActivityDate < TODAY';
			}else if(filterParam == 1){// today
				filterCondition = ' AND ActivityDate = TODAY'; 
			}else if(filterParam == 2){ // today + overdue
				filterCondition = ' AND ActivityDate <= TODAY';
			}else if(filterParam == 3){ // Tomorrow
				filterCondition = ' AND ActivityDate = TOMORROW';
			}else if(filterParam == 4){ // Next 7 days
				filterCondition = ' AND ActivityDate = NEXT_WEEK';
			}else if(filterParam == 5){ // Next 7 days + overdue
				filterCondition = ' AND ActivityDate <= NEXT_WEEK';
			}else if(filterParam == 6){ // This month
				filterCondition = ' AND ActivityDate < THIS_MONTH';
			}
		}
		ID ownerID = Userinfo.getUserId();
		taskList = Database.query('Select WhoId,WhatId,Subject,Status,Priority,OwnerId,IsClosed,Id,ActivityDate,AccountId From Task Where Status != \'Completed\' AND OwnerId =:ownerID ' +filterCondition +' ORDER BY ActivityDate');	
		return null;
	}
}