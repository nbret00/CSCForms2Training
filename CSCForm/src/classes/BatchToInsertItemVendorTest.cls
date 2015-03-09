/*************************************************************************
Name : BatchToInsertItemVendorTest
Author : Reena Acharya (JDC)
Date : 20th May , 2014
Usage : Testclass for coverage of BatchToInsertItemVendor .
**************************************************************************/
@isTest
private class BatchToInsertItemVendorTest{
    @isTest
    private static void testbatch(){
        //Insert Account
        Account acc = new Account( Name = 'test acc');
        insert acc;
        system.assertNotEquals(acc.id , null);
        
        //Insert Items
        Spark_It_Item__c item = new Spark_It_Item__c(Name = 'test' , Partner__c = acc.Id);
        insert item;
        system.assertNotEquals(item.id , null);     
        
        //Execute batch.
        Test.StartTest();
        BatchToInsertItemVendor  batchVendor = new BatchToInsertItemVendor ();
        database.executeBatch(batchVendor , 200);
        Test.StopTest();
        
        //After batch execution item vendor must have inserted for account and item.
        List<Item_Vendor__c> itemvendors = new List<Item_Vendor__c>([Select id from Item_Vendor__c where item__c =: item.id and Account__c =: acc.id]);
        system.assertEquals(itemvendors.size() , 1);
        
    }
}