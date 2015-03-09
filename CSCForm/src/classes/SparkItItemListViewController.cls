// 
// (c) 2014 Appirio, Inc.
//
// A controller class for SparkItItemListView page that displays all SparkItItems for Partner user
//
// 15 Jan 2014     Sudhir Kr. Jagetiya       Original
//
//
public without sharing class SparkItItemListViewController {
    
  public static final Integer PAGE_SIZE {get; private set;}
  
  static {
    PAGE_SIZE = 10;
  }
  
  public Integer noOfRecords {get; private set;}
  
  private ApexPages.StandardSetController setCon;
  
  public SparkItItemListViewController() {
    noOfRecords = 0;
    initialize();
  }
  
  /**
    * @Description: initialize 
    * @return: void
    */
  private void initialize() {
    try {
        Id currentUserAccountId;
        for(User user : [SELECT Id, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1]) {
            currentUserAccountId = user.Contact.AccountId;
        }
        
        if(currentUserAccountId != null) {
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id,Item__c,Item__r.Name, Item__r.Item_No__c, Item__r.Status__c, Item__r.Deadline__c, Item__r.Spark_It__r.Name, Item__r.Job_Type__r.Name, Item__r.Job_Type__c ,Account__c  FROM Item_Vendor__c WHERE Account__c =: currentUserAccountId]));
            /*SELECT Id, Name, Item_No__c, Status__c, Deadline__c, Spark_It__r.Name, Job_Type__r.Name, Job_Type__c  FROM Spark_It_Item__c WHERE Partner__c = :currentUserAccountId]));*/
            setCon.setPageSize(PAGE_SIZE);
            noOfRecords = setCon.getResultSize();
        }
    }
    catch(Exception excep) {}
  }
  
  /**
    * @Description: it returns the list of Spark It Item record List 
    * @return: List<Spark_It_Item__c>
    */
  public List<Item_Vendor__c> getSparkItItemList() {
    if(setCon != null) {
      return setCon.getRecords();
    }
    return null;
    }
  
  
  public Boolean hasNext {
    get {
        if(setCon != null) {
        return setCon.getHasNext();
        }
        return false;
    }
    set;
    }
    
    public Boolean hasPrevious {
    get {
        if(setCon != null) {
        return setCon.getHasPrevious();
        }
        return false;
    }
    set;
    }
 
    public Integer pageNumber {
    get {
        if(setCon != null) { 
            return setCon.getPageNumber();
        }
      return 0;
    }
    set;
    }
 
    public void first() {
        if(setCon != null) { 
      setCon.first();
        }
    }
 
    public void last() {
        if(setCon != null) { 
      setCon.last();
        }
    }
 
    public void previous() {
        if(setCon != null) { 
      setCon.previous();
        }
    }
 
    public void next() {
        if(setCon != null) { 
      setCon.next();
        }
    }
  
}