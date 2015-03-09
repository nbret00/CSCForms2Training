//
// (c) 2014 Appirio, Inc.
//
// Handler Class For Milestone1_Milestone_Sharing_Trigger
//
// 7 February 2014     Ashish Sharma      Original
//
//
public with sharing class MilestoneSharingTriggerHandler {
  /**
  * This method will share Milestone records with parent Program's requester on insertion of
  * Milestone records
  */
  public static void handleMilestoneSharingOnAfterInsert( List<Milestone1_Milestone__c> milestones ){
      List<Milestone1_Milestone__Share> milestoneShareList = new List<Milestone1_Milestone__Share>();
      Map<String, String> projectRequesterIdMap = new Map<String, String>();
      Set<String> programIDs = new Set<String>();

      for(Milestone1_Milestone__c milestone : milestones){
        programIDs.add(milestone.Project__c);
      }

      //Query all parent Program records and create a map of Program Id
      // and Program Requester Id
      for(Milestone1_Project__c project : [SELECT Requestor__c, Id FROM Milestone1_Project__c
                                           WHERE ID IN : programIDs]){
        projectRequesterIdMap.put(project.Id, project.Requestor__c);
      }

      //Create new milestone Sharing records
      Milestone1_Milestone__Share milestonemShare;
      for(Milestone1_Milestone__c milestone : milestones){
        if(projectRequesterIdMap.get(milestone.Project__c) != null
            && milestone.OwnerId != projectRequesterIdMap.get(milestone.Project__c)){
          milestonemShare = new Milestone1_Milestone__Share();
          milestonemShare.ParentId = milestone.Id;
          milestonemShare.UserOrGroupId = projectRequesterIdMap.get(milestone.Project__c);
          milestonemShare.AccessLevel  = 'Edit';
          milestoneShareList.add(milestonemShare);
        }
      }

      if(milestoneShareList.size() >0){
        insert milestoneShareList;
      }
  }
}