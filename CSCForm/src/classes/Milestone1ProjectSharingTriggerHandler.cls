//
// (c) 2014 Appirio, Inc.
//
// Handler Class For Milestone1_Project_Sharing_Trigger
//
// 7 February 2014     Ashish Sharma      Original
//
// 10 June 2014   Sudhir Kumar Jagetiya  T-286148 modified the access level to "Without Sharing"
public without sharing class Milestone1ProjectSharingTriggerHandler {
  /**
  * This method will share Program records with associated requester on insertion of
  * Program records
  */
  public static void handleProjectSharingOnAfterInsert( List<Milestone1_Project__c> projects ){
      List<Milestone1_Project__Share> projectShareList = new List<Milestone1_Project__Share>();

      Milestone1_Project__Share projectShare;
      for(Milestone1_Project__c project : projects){
        if(project.Requestor__c != null && project.Requestor__c != project.OwnerId){
          projectShare = new Milestone1_Project__Share();
          projectShare.ParentId = project.Id;
          projectShare.UserOrGroupId = project.Requestor__c;
          projectShare.AccessLevel  = 'Edit';
          projectShareList.add(projectShare);
        }
      }

      insert projectShareList;
  }

  /**
  * This method will share Program, Item and Milestone records with associated requester
  * on insertion of Program records.
  */
  public static void handleProjectSharingOnAfterUpdate( List<Milestone1_Project__c> newProjects,
                                                       Map<Id, Milestone1_Project__c> oldMap){

      List<Milestone1_Project__Share> newProjectShareList = new List<Milestone1_Project__Share>();
      List<Milestone1_Project__Share> oldProjectShareList;
      List<Spark_It_Item__Share> oldItemShareList;
      List<Spark_It_Item__Share> newItemShareList = new List<Spark_It_Item__Share>();
      List<Milestone1_Milestone__Share> newMilestoneShareList = new List<Milestone1_Milestone__Share>();
      List<Milestone1_Milestone__Share> oldMilestoneShareList;
      Map<String, String> programRequesterIdMap = new Map<String, String>();
      Map<String, String> itemRequesterIdMap = new Map<String, String>();
      Map<String, String> itemOldRequesterIdMap = new Map<String, String>();
      Map<String, String> milestoneRequesterIdMap = new Map<String, String>();
      Map<String, String> milestoneOldRequesterIdMap = new Map<String, String>();

      // Cretae new Program Sharing records
      Milestone1_Project__Share projectShare;
      for(Milestone1_Project__c project : newProjects){
        if(project.Requestor__c != oldMap.get(project.Id).Requestor__c || project.OwnerId != oldMap.get(project.Id).OwnerId){
          programRequesterIdMap.put(project.Id, project.Requestor__c);

          if(project.Requestor__c != null && project.Requestor__c != project.OwnerId){
            projectShare = new Milestone1_Project__Share();
            projectShare.ParentId = project.Id;
            projectShare.UserOrGroupId = project.Requestor__c;
            projectShare.AccessLevel  = 'Edit';
            newProjectShareList.add(projectShare);
          }
        }
      }

      // Delete old Program Sharing records
      if(programRequesterIdMap.size() > 0){
        oldProjectShareList = new List<Milestone1_Project__Share>();
        for(Milestone1_Project__Share projShare : [SELECT ID,UserOrGroupId, ParentId
                                                   FROM Milestone1_Project__Share
                                                   WHERE ParentId IN : programRequesterIdMap.keySet()
                                                   AND RowCause = 'Manual']){
         if(projShare.UserOrGroupId == oldMap.get(projShare.ParentId).Requestor__c){
          oldProjectShareList.add(projShare);
         }
        }

        if(oldProjectShareList.size() > 0){
          delete oldProjectShareList;
        }
      }

      // Insert new Program sharing records
      if(newProjectShareList.size() > 0){
        insert newProjectShareList;
      }


      //Share Item records with parent Program's Requester
      Spark_It_Item__Share itemShare;
      for(Spark_It_Item__c item : [SELECT Id, Spark_It__c,OwnerId FROM Spark_It_Item__c
                                   WHERE Spark_It__c IN : programRequesterIdMap.keySet()]){
        itemRequesterIdMap.put(item.Id, programRequesterIdMap.get(item.Spark_It__c));
        itemOldRequesterIdMap.put(item.Id, oldMap.get(item.Spark_It__c).Requestor__c);

        if(programRequesterIdMap.get(item.Spark_It__c) != null &&
           programRequesterIdMap.get(item.Spark_It__c) != item.OwnerId){
            itemShare = new Spark_It_Item__Share();
            itemShare.ParentId = item.Id;
            itemShare.UserOrGroupId = programRequesterIdMap.get(item.Spark_It__c);
            itemShare.AccessLevel  = 'Edit';
            newItemShareList.add(itemShare);
         }
      }

      //Delete old Item Sharing records
      if(itemRequesterIdMap.size() > 0){
        oldItemShareList = new List<Spark_It_Item__Share>();
        for(Spark_It_Item__Share tempItemShare : [SELECT ID,UserOrGroupId, ParentId
                                                   FROM Spark_It_Item__Share
                                                   WHERE ParentId IN : itemRequesterIdMap.keySet()
                                                   AND RowCause = 'Manual']){
         if(tempItemShare.UserOrGroupId == itemOldRequesterIdMap.get(tempItemShare.ParentId)){
          oldItemShareList.add(tempItemShare);
         }
        }

        if(oldItemShareList.size() > 0){
          delete oldItemShareList;
        }
      }

      // Insert new Item Sharing records
      if(newItemShareList.size() > 0){
        insert newItemShareList;
      }

      /*
      //Share Milestone records with parent Program's Requester
      Milestone1_Milestone__Share milestoneShare;
      for(Milestone1_Milestone__c milestone : [SELECT Id, Project__c,OwnerId FROM Milestone1_Milestone__c
                                   WHERE Project__c IN : programRequesterIdMap.keySet()]){
        milestoneRequesterIdMap.put(milestone.Id, programRequesterIdMap.get(milestone.Project__c));
        milestoneOldRequesterIdMap.put(milestone.Id, oldMap.get(milestone.Project__c).Requestor__c);

        if(programRequesterIdMap.get(milestone.Project__c) != null
             && programRequesterIdMap.get(milestone.Project__c) != milestone.OwnerId){
            milestoneShare = new Milestone1_Milestone__Share();
            milestoneShare.ParentId = milestone.Id;
            milestoneShare.UserOrGroupId = programRequesterIdMap.get(milestone.Project__c);
            milestoneShare.AccessLevel  = 'Edit';
            newMilestoneShareList.add(milestoneShare);
         }
      }

      //Delete old Milestone sharing records
      if(milestoneRequesterIdMap.size() > 0){
        oldMilestoneShareList = new List<Milestone1_Milestone__Share>();
        for(Milestone1_Milestone__Share tempMilestoneShare : [SELECT ID,UserOrGroupId, ParentId
                                                   FROM Milestone1_Milestone__Share
                                                   WHERE ParentId IN : milestoneRequesterIdMap.keySet()
                                                   AND RowCause = 'Manual']){
         if(tempMilestoneShare.UserOrGroupId == milestoneOldRequesterIdMap.get(tempMilestoneShare.ParentId)){
          oldMilestoneShareList.add(tempMilestoneShare);
         }
        }

        if(oldMilestoneShareList.size() > 0){
          delete oldMilestoneShareList;
        }
      }

      // Insert new Item sharing records
      if(newMilestoneShareList.size() > 0){
        insert newMilestoneShareList;
      }*/
  }
}