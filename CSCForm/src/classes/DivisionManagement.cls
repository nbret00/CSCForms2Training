/***********************************************************
Name : DivisionManagement
Created Date : 22nd May , 2014
Created By : Reena Acharya(Appiri JDC)
Description : Task T-280432 : On Delete of division , Item division records should be deleted.
              We are forcefully deleting to fire delete trigger of Item Division
              to pupulate Program's Division field.
***********************************************************/

public class DivisionManagement{

    //Added by Reena on 22nd May , 2014 for Task T-280432
    //Delete item divisions on deletion of Division
    //To fire trigger of Item divisions Delete event.
    public static void deleteItemDivisions(List<Division__c> divisions){
        List<Item_division__c> itemDivisions = new List<Item_division__c>([Select Id From Item_Division__c where Division__c in : divisions]);
        if(!itemDivisions.isEmpty())
          delete itemDivisions ;
        
    }
}