//
// (c) 2013 Appirio, Inc.
//
// A trigger that creates sharing record for Spark It
//
// 10 Jan 2013     Sudhir Kr. Jagetiya       Original
//
//Modified by Reena on 22nd May , 2014 for Task T-280432 Added Delete event.
// 16 Oct 2014     Neeraj Sharma Modified: ref:T-316801 to create history record for deleted spark it items
//
trigger SparkItItemTrigger on Spark_It_Item__c (after insert, after update, before Delete) {

  /*if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
    SparkItItemManagement.afterInsertUpdate(Trigger.newMap, Trigger.oldMap);
  }*/

  if(Trigger.isAfter && Trigger.isInsert){
    SparkItItemManagement.handleItemSharingOnAfterInsert(Trigger.new);
  }
  //Modified by Reena on 22nd May , 2014 for Task T-280432
  if(Trigger.isDelete && trigger.isBefore){
    SparkItItemManagement.deleteItemDivisions(Trigger.old);
    
  //Added by Neeraj Sharma on 16 Oct 2014 for Task T-316801  
  	SparkItItemManagement.createHistoryForDeletedItems(trigger.old);
  }    
}