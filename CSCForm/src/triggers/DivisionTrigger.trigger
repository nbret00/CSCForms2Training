/***********************************************************
Name : DivisionTrigger 
Created Date : 22nd May , 2014
Created By : Reena Acharya(Appiri JDC)
Description : On Delete of division , Item division records should be deleted.
              We are forcefully deleting to fire delete trigger of Item Division
              to pupulate Program's Division field.
***********************************************************/
trigger DivisionTrigger on Division__c (Before Delete) {
    DivisionManagement.deleteItemDivisions(Trigger.old);
}