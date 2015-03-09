/****************************************************************************
Name : DivisionManagementTest
Created By : Reena Acharya(Appirio JDC)
Created Date : 21st May , 2013
Description :Test class of trigger on Divisions
             For Task : T-280430 , Task: T-280432
****************************************************************************/
@isTest
private class DivisionManagementTest{
    
    /*Task: T-280432 : This field would have a comma separated list of all Divisions added 
      under all items related to this Program.
      
      If any item has Corporate, then show only Corporate in this text area. 
      No other division would be shown then. For example, if a program has two items,
      and one of them has Corporate and other has three divisions, this field at Program record would have only Corporate.
    */
    @isTest
    static void populateProgramDivisions(){
    
        //Insert corportate division
        Division__c corporateDiv = new Division__c(Name = 'Corporate');
        insert corporateDiv ;
        
        //Insert Program
        Milestone1_Project__c program = new Milestone1_Project__c(Name = 'test Prg');
        insert program;
        
        //Insert Item
        Spark_It_Item__c item = new Spark_It_Item__c(Name = 'item' , Spark_It__c = program.id);
        insert item;
        
        //Insert Item Division for corporate division.
        Item_Division__c itemDiv = new Item_Division__c(Item__c = item.Id , Division__c = corporateDiv.id);
        insert itemDiv;
        
        //Record should be inserted without any problem
        system.assertNotEquals(itemDiv.id , null);
        
        //Corporate should be populated in Divisions Name
        System.assertEquals([Select id ,Divisions__c from Milestone1_Project__c where id =: program.Id].Divisions__c , 'Corporate');
        
        
        //Insert Item
        item = new Spark_It_Item__c(Name = 'item2', Spark_It__c = program.id);
        insert item;
        
        //Insert non corporate Division.
        Division__c div = new Division__c(Name = 'Div1');
        insert div;
        
        //Try to insert item division with noncorporate division
        //Record must have inserted without any problem
        Item_Division__c itemDivNonCor = new Item_Division__c(Item__c = item.Id , Division__c = div.id );
        insert itemDivNonCor ;
        
        //Only Corporate should be populated in Divisions Name
        System.assertEquals([Select id ,Divisions__c from Milestone1_Project__c where id =: program.Id].Divisions__c , 'Corporate');
        
        //Delete corporate item division.
        delete corporateDiv ;
        
        //Only non corporate should be populated in Divisions Name
        System.assertEquals([Select id ,Divisions__c from Milestone1_Project__c where id =: program.Id].Divisions__c , 'Div1');
       
    }
}