//
// (c) 2014 Appirio, Inc.
//
// A trigger that creates sharing record for Milestone Project (Program)
//
// 7 February 2014     Ashish Sharma      Original
//
//
trigger Milestone1_Project_Sharing_Trigger on Milestone1_Project__c (after insert, after update) {
  if(Trigger.isAfter && Trigger.isInsert){
    Milestone1ProjectSharingTriggerHandler.handleProjectSharingOnAfterInsert( trigger.new );
  }

  if(Trigger.isAfter && Trigger.isUpdate){
    Milestone1ProjectSharingTriggerHandler.handleProjectSharingOnAfterUpdate( trigger.new, trigger.oldMap );
  }
}