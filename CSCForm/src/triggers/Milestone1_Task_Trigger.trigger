trigger Milestone1_Task_Trigger on Milestone1_Task__c ( before insert, before update,after insert,after update, after delete, after undelete ) {

	if(trigger.isBefore) {
		Milestone1_Task_Trigger_Utility.handleTaskBeforeTrigger(trigger.new);  
	} 
	
	if(trigger.isAfter && (!Trigger.isDelete || !Trigger.isUnDelete)) {
		if(Trigger.isUpdate){
	        //shift Dates of successor Tasks if Task Due Date is shifted
	        Milestone1_Task_Trigger_Utility.checkSuccessorDependencies(trigger.oldMap, trigger.newMap);
		}
		Milestone1_Task_Trigger_Utility.handleTaskAfterTrigger(trigger.new,trigger.old);
	} 
	
	if(Trigger.isAfter) {
		 Milestone1_Task__c[] taskList = null; 
		 if (Trigger.isDelete) {
        	 taskList = Trigger.old; 
    	 } else {
    	 	taskList = Trigger.new;
    	 }
		 Milestone1_Task_Trigger_Utility.calculateMilestonRollUpSummary(taskList);     									 	
	}

}