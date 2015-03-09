// 
// (c) 2014 Appirio, Inc.
//
// A controller class for JobTypeHierarchy page that displays  job types in a hierarchy manner
//
// 15 Jan 2014     Sudhir Kr. Jagetiya       Copied From Asset
//
public without sharing class JobTypeHierarchyController {
  
  public static final String OPERATION_ADD_SIBILING {get; private set;}
  public static final String OPERATION_ADD_CHILD {get; private set;}
  public static final String OPERATION_EDIT {get; private set;}
  
  static {
  	OPERATION_ADD_SIBILING = 'sibling';
    OPERATION_ADD_CHILD = 'child';
    OPERATION_EDIT = 'edit';
  }
  
  public String selectedJobTypeId {get; set;}
  public Job_Type__c sObjectToBind {get;set;}
  public String selectedAction {get; set;}
  
  //Constructor
  public JobTypeHierarchyController() {
    sObjectToBind = new Job_Type__c();
  }
  
  
  public PageReference refreshModalWindow() {
  	try {
  		if(selectedJobTypeId != null) {
  			Job_Type__c selectedJobType;
  			for(Job_Type__c jobType : [SELECT Id, Name, Parent__c, Category__c FROM Job_Type__c WHERE Id = :selectedJobTypeId LIMIT 1]) {
	        selectedJobType = jobType;
	      }
	  		if(OPERATION_ADD_SIBILING.equalsIgnoreCase(selectedAction)) {
	  			sObjectToBind = new Job_Type__c();
	  			sObjectToBind.Parent__c = selectedJobType.Parent__c;
	  		}
	  		else if(OPERATION_ADD_CHILD.equalsIgnoreCase(selectedAction)) {
	  			sObjectToBind = new Job_Type__c();
	  			sObjectToBind.Parent__c = selectedJobType.Id;
	  		} 
	  		else if(OPERATION_EDIT.equalsIgnoreCase(selectedAction)) {
	  			sObjectToBind = selectedJobType;
	  		}
  		}
  	} 
  	catch(Exception excep) {}
  	return null;
  }
  
  public PageReference saveJobType() {
  	try {
  		upsert sObjectToBind;
  		selectedJobTypeId = sObjectToBind.Id;
  	}
  	catch(Exception excep) {
  		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error occured. Please contact your system administrator.'));
  	}
  	return null;
  }
  
  public Pagereference deleteJobType() {
  	try {
  		if(selectedJobTypeId != null) {
  		  delete new Job_Type__c(Id = selectedJobTypeId);
  		}
  	} 
  	catch (Exception excep) {}
  	return null;
  }
}