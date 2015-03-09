/*************************************************************************
Name : BatchToInsertItemVendor
Author : Reena Acharya (JDC)
Date : 20th May , 2014
Usage : Batch to insert Item Vendor from Item records.
**************************************************************************/
global class BatchToInsertItemVendor implements Database.Batchable<SObject>{
    
    
    //DataBase.Batchable Start method
    global database.querylocator start(Database.BatchableContext BC){        
        return Database.getQueryLocator('Select id , Partner__c from Spark_It_Item__c where Partner__c != null');
    }
    
    global void execute(Database.BatchableContext BC, LIST<SObject> listData){
        List<Spark_It_Item__c> items = (List<Spark_It_Item__c>)listData;
        List<Item_Vendor__c> itemVendorToInsert = new List<Item_Vendor__c>();
        for(Spark_It_Item__c item : items){
            Item_Vendor__c itemVendor = new Item_Vendor__c();
            itemVendor.Account__c = item.Partner__c;
            itemVendor.Item__c = item.id;
            itemVendorToInsert.Add(itemVendor);
        }
        if(itemVendorToInsert.size() > 0)
            insert itemVendorToInsert;   
    }
    
    global void finish(Database.BatchableContext BC){
         
    }
   }