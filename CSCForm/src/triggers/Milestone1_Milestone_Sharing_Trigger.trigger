//
// (c) 2014 Appirio, Inc.
//
// A trigger that creates sharing record for Milestone
//
// 7 February 2014     Ashish Sharma      Original
//
//
trigger Milestone1_Milestone_Sharing_Trigger on Milestone1_Milestone__c (after insert) {

  if(Trigger.isAfter && Trigger.isInsert){
    MilestoneSharingTriggerHandler.handleMilestoneSharingOnAfterInsert(Trigger.new);
  }
}