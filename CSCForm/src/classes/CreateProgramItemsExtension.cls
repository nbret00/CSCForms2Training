// 
// (c) 2014 Appirio, Inc.
//
// A controller class for CreateProgramItems page that create Items for program
//
// 31 Jan 2014     Sudhir Kr. Jagetiya      Original
//
public without sharing class CreateProgramItemsExtension {
	
  private static final String ITEM_RECORD_TYPE_STANDARD;
  private static final Map<String, Item_Configuration__c> itemConfigurationSetting;
  private static final Map<String, Id> itemRecordTypeAndJobTypeSettings;
  private static Map<String,Schema.RecordTypeInfo> rtMapByNameForItem = null;
  
  static {
  	ITEM_RECORD_TYPE_STANDARD = 'Standard';
  	itemConfigurationSetting = Item_Configuration__c.getAll();
  	itemRecordTypeAndJobTypeSettings = new Map<String, Id>();
  	Id recordTypeId;
  	for(Item_Configuration__c iConfig : itemConfigurationSetting.values()) {
  		if(iConfig.Item_Record_Type__c != null && iConfig.Job_Type__c != null) {
	  		recordTypeId = getRecordTypeIdForItem(iConfig.Item_Record_Type__c.trim());
	  		if(recordTypeId != null) {
	  		  itemRecordTypeAndJobTypeSettings.put(iConfig.Job_Type__c.trim(), recordTypeId);
	  		}
  		}
  	}
  }
  
  public String selectedJobTypeIds {get; set;}
  
  private Id programRecordId;
  private Map<String, Set<String>> previouslySelectedJobTypes;
  
  
  /**
    * @description: Constructor
    * @param: standard controller
    */
  public CreateProgramItemsExtension(ApexPages.StandardController stdController) {
  	previouslySelectedJobTypes = new Map<String, Set<String>>();
  	programRecordId = stdController.getId();
  	initialize(programRecordId);
  }
  
  /**
    * @description: Initialize the Page 
    * @param: Program Id
    * @return: void
    */
  private void initialize(Id programRecordId) {
  	try {
  		previouslySelectedJobTypes.clear();
	  	selectedJobTypeIds = '';
	  	for(Spark_It_Item__c item : [SELECT Id, Job_Type__c FROM Spark_It_Item__c WHERE Spark_It__c = :programRecordId]) {
	  		if(!previouslySelectedJobTypes.containsKey(item.Job_Type__c)) {
	  			previouslySelectedJobTypes.put(item.Job_Type__c, new Set<String>());
	  		}
	  		previouslySelectedJobTypes.get(item.Job_Type__c).add(item.Id);
	  		selectedJobTypeIds += item.Job_Type__c + ',';
	  	}
	  	selectedJobTypeIds = selectedJobTypeIds != '' ? selectedJobTypeIds.substring(0, selectedJobTypeIds.length() - 1) : '';
  	}
  	catch(Exception excep) {}
  }
  
  /**
    * @description: A method that creates selected Items 
    * @return: PageReference
    */
  public PageReference createItems() {
  	try {
  		if(programRecordId != null) {
	  		//Boolean isNotLeafNode = false;
	  		Set<String> selectedJobs = new Set<String>();
	  		selectedJobs.addAll(selectedJobTypeIds.split(',', -1));
	  		
	  		Set<String> removedParents = new Set<String>();
	  		removedParents.addAll(selectedJobs);
	  		
	  		for(Job_Type__c jobType : [SELECT Id, Name, Parent__c FROM Job_Type__c WHERE Parent__c IN :selectedJobs]) {
	  			if(removedParents.contains(jobType.Parent__c) && removedParents.contains(jobType.Id)) {
	  				if(selectedJobs.contains(jobType.Parent__c)) {
	  					selectedJobs.remove(jobType.Parent__c);
	  				}
	  			} 
	  			/*else {
	  				isNotLeafNode = true;
	  				break;
	  			}*/
	  		}
	  		/*if(isNotLeafNode) {
	  		  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Job Types are only allowed at the lowest level of the child in the tree.'));
	  		  return null;
	  		} 
	  		else {*/
	  			
	  			List<Spark_It_Item__c> itemsToBeDeleted = new List<Spark_It_Item__c>();
          for(String jobTypeId : previouslySelectedJobTypes.keySet()) {
            if(!selectedJobs.contains(jobTypeId)) {
              for(String itemId : previouslySelectedJobTypes.get(jobTypeId)) {
                itemsToBeDeleted.add(new Spark_It_Item__c(Id = itemId));
              }
            }
          }
          delete itemsToBeDeleted;
	  			
	  			List<Spark_It_Item__c> itemsToBeInserted = new List<Spark_It_Item__c>();
	  			selectedJobs.removeAll(previouslySelectedJobTypes.keySet());
	  			Id recordTypeId, defaultRecordTypeId;
	  			defaultRecordTypeId = getRecordTypeIdForItem(ITEM_RECORD_TYPE_STANDARD);
	  			
	  			for(Job_Type__c jobType : [SELECT Id, Parent__c, Name FROM Job_Type__c WHERE Id IN :selectedJobs]) {
	  				recordTypeId = itemRecordTypeAndJobTypeSettings.containsKey(jobType.Name) ? itemRecordTypeAndJobTypeSettings.get(jobType.Name) : defaultRecordTypeId;
	  				itemsToBeInserted.add(createItemInstance(programRecordId, jobType, recordTypeId));
	  			}
	  			insert itemsToBeInserted;
	  			
	  			
	  			
	  			return new PageReference('/' + programRecordId);
	  		//}
  		}
  	}
  	catch(Exception excep) {
  		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error occured. Please contact your system administrator.'));
  	}
  	return null;
  }
  
  /**
    * @description: A method that creates the inctance of Item 
    * @param: program Id
    * @param: jobType
    * @return: Spark_It_Item__c
    */
  private Spark_It_Item__c createItemInstance(Id programRecordId, Job_Type__c jobType, Id recordTypeId) {
  	Spark_It_Item__c item = new Spark_It_Item__c();
  	item.Spark_It__c = programRecordId;
  	item.Name = jobType.Name;
  	item.Job_Type__c = JobType.Id;
  	item.RecordTypeId = recordTypeId;
  	return item;
  }
  
  /**
    * @description: Return the user to Program record
    * @return: PageReference
    */
  public PageReference backToProgram() {
  	if(programRecordId != null) {
  		return new PageReference('/' + programRecordId);
  	}
  	return null;
  }
  
  /**
    * @Description  method that returns the record Type Id of opportunity record type.
    * @param String Record Type Name
    * @return Id recordTypeId
    */
  private static Id getRecordTypeIdForItem(String recordType) {
    if(rtMapByNameForItem == null) {
      Schema.DescribeSObjectResult describedObject = Schema.SObjectType.Spark_It_Item__c;
      rtMapByNameForItem = describedObject.getRecordTypeInfosByName();
    }
    Schema.RecordTypeInfo recordTypeDetail = rtMapByNameForItem.get(recordType);
    if(recordTypeDetail != null) {
      return recordTypeDetail.getRecordTypeId();
    } else {
      return null;
    }
  }
}