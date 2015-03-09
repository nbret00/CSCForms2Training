//
// (c) 2013 Appirio, Inc.
//
// Management Class For SparkItItemTrigger
//
// 10 Jan 2013     Sudhir Kr. Jagetiya       Original
// 22 May 2014     Reena         Modified  for Task ref:T-280432
// 16 Oct 2014     Neeraj Sharma Modified: ref:T-316801 Added method createHistoryForDeletedItems
//                               to create history record for deleted spark it items
public without sharing class SparkItItemManagement {

   /**
  * This method will share Item records with parent Program's requester on insertion of
  * Item records
  */
  public static void handleItemSharingOnAfterInsert( List<Spark_It_Item__c> items ){
      List<Spark_It_Item__Share> itemShareList = new List<Spark_It_Item__Share>();
      Map<String, String> projectRequesterIdMap = new Map<String, String>();
      Set<String> programIDs = new Set<String>();

      for(Spark_It_Item__c item : items){
        programIDs.add(item.Spark_It__c);
      }

      //Query all parent Program records and create a map of Program Id
      // and Program Requester Id
      for(Milestone1_Project__c project : [SELECT Requestor__c, Id FROM Milestone1_Project__c
                                           WHERE ID IN : programIDs]){
        projectRequesterIdMap.put(project.Id, project.Requestor__c);
      }

      //Create new Item Sharing records
      Spark_It_Item__Share itemShare;
      for(Spark_It_Item__c item : items){
        if(projectRequesterIdMap.get(item.Spark_It__c) != null
            && item.OwnerId != projectRequesterIdMap.get(item.Spark_It__c)){
          itemShare = new Spark_It_Item__Share();
          itemShare.ParentId = item.Id;
          itemShare.UserOrGroupId = projectRequesterIdMap.get(item.Spark_It__c);
          itemShare.AccessLevel  = 'Edit';
          itemShareList.add(itemShare);
        }
      }

      if(itemShareList.size() >0){
        insert itemShareList;
      }
  }
  //Added by Reena on 22nd May , 2014 for Task T-280432
  //Delete item divisions on deletion of Item 
  //To fire trigger of Item divisions Delete event.
  public static void deleteItemDivisions(List<Spark_It_Item__c> items){
      List<Item_division__c> itemDivisions = new List<Item_division__c>([Select Id From Item_Division__c where Item__c in : items]);
      if(!itemDivisions.isEmpty())
          delete itemDivisions ;
      
  }
  // @description: It creates history records for deleted Spark It Item records
  // @param: itemList list<Spark_It_Item__c>
  // @return: None
  // 16-10-2014 Neeraj Sharma Original Ref T-316801
  public static void createHistoryForDeletedItems(List<Spark_It_Item__c> items){
  	list<Item_History__c> itemHistoryList = new list<Item_History__c>();
  	Item_History__c itemHistory = null;
  	for(Spark_It_Item__c item: items){
  		itemHistory = new Item_History__c();
  		itemHistory.Item_Id__c = item.Id;
  		itemHistory.Item_Name__c = item.Name;
  		itemHistory.Program_Id__c = item.Spark_It__c;
  		itemHistory.Program_Name__c = item.Program_Name__c;
  		itemHistory.Deleted_By__c = Userinfo.getUserId();
  		itemHistory.Timestamp__c = system.now();
  		itemHistory.Item_No__c = item.Item_No__c;
  		itemHistory.Requestor__c = item.Requestor__c;
  		itemHistoryList.add(itemHistory);
  	}
  	if(itemHistoryList.size() > 0){
  		try{
  		  insert itemHistoryList;
  		}
  		catch(Exception e){}
  	}
  }
}