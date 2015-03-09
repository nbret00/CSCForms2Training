/*
Class : ProjectBriefController
Description :  This class is used by for showing Project briefs, this is used by Project Brief button on SparkIt object
Developed by : Manmeet Manethiya
Created Date : December 20, 2013
Last Modified on Jan 09, 2014 By Sudhir Kumar Jagetiya Task ref. T-234045
*/

public without sharing class ProjectBriefController {
	private static final String DML_ERROR_MESSAGE = 'Error occured. Please contact your system administrator.';
	private static final Set<String> excludeRecordTypes = new Set<String>{'Master', 'D', 'Quick Form'};
	public Milestone1_Project__c projectRecord {get; set;}
	public Map<String, Set<String>> tierWithBanners {get; private set;}
	public Map<String, set<String>> tierWithDivisions {get; private set;}
	public Boolean isCorporate {get; private set;}   
	public List<SelectOption> divisionSelectOptions {get;set;}
	public List<String> selectedDivisionsValues {get;set;}
    
  public List<SelectOption> projectLevel {get;set;}
  public Boolean isEditMode {get; private set;}
        
  public ProjectBriefController(ApexPages.StandardController stc) {
    try {
        tierWithBanners = new Map<String, Set<String>>();
        tierWithDivisions = new Map<String, Set<String>>();
        
        String isEdit = ApexPages.currentPage().getParameters().get('isEdit');
          
      if(isEdit != null && isEdit.equalsIgnoreCase('true')) {
        isEditMode = true;
      } else {
        isEditMode = false;
      }
          
      projectRecord = [SELECT Id, Campaign__c, Campaign__r.Name, owner.Name, Kickoff__c, Background__c,
                                Division__c, Division__r.Name, Date__c, Name,  Core_Idea__c, Hierarchy__c, Duration__c,
                                Source_of_Volume__c, Shopper_Barriers_to_Purchase__c, Communication_Strategy__c, Budget__c, Business_and_marketing_success_measures__c, 
                                Tier_I__c, Tier_II__c, Tier_III__c,  Spark_It__c, Divisions__c,
                                Target_Audience__c, Objectives__c, Deliverables__c , Deadline__c, Go_Live_Date__c, Requestor__c, Hands_Off_Date__c,
                                Consumer_and_Shopper_Insights__c, Mandatories__c, Size_of_Prize__c , Full_Company__c, 
                                Requestor__r.ManagerId, Requestor__r.Phone, Requestor__r.Department, recordType.Name,
                                Customer_Segments_or_Media_DMAs__c, Assets_Content__c, Other_Properties__c
                           FROM Milestone1_Project__c
                          WHERE Id = : stc.getId()];
        
                
        //Added By Sudhir           
        for(SparkIt_Store__c sparkItStore : [SELECT Store__r.Three_Tier__c, Store__r.Division__c, Store__r.Division__r.Name,
                                                    Store__r.Banner__c, Store__c, Spark_It__c 
                                               FROM SparkIt_Store__c 
                                               WHERE Spark_It__c = :projectRecord.Id]) {
           if(sparkItStore.Store__c != null && sparkItStore.Store__r.Three_Tier__c != null) {
             if(sparkItStore.Store__r.Banner__c != null) {
             if(!tierWithBanners.containsKey(sparkItStore.Store__r.Three_Tier__c)) {
               tierWithBanners.put(sparkItStore.Store__r.Three_Tier__c, new Set<String>());
             }
             tierWithBanners.get(sparkItStore.Store__r.Three_Tier__c).add(sparkItStore.Store__r.Banner__c);
             }
               if(sparkItStore.Store__r.Division__c != null) {
                 if(!tierWithDivisions.containsKey(sparkItStore.Store__r.Three_Tier__c)) {
                   tierWithDivisions.put(sparkItStore.Store__r.Three_Tier__c, new Set<String>());
                 }
                 tierWithDivisions.get(sparkItStore.Store__r.Three_Tier__c).add(sparkItStore.Store__r.Division__r.Name);
               }
           }                            
        }
         /*Changes for Division T-280433  - Reetesh Makkar*/
         divisionSelectOptions = new List<SelectOption>();
         if(projectRecord.Divisions__c!= null){
         	
         
         selectedDivisionsValues = new List<String>();
         for(String division : projectRecord.Divisions__c.split(',')) {
            divisionSelectOptions.add(new SelectOption(division.trim(), division.trim()));
            selectedDivisionsValues.add(division.trim());
         }
         }
         /*end changes for multiple divisions*/

         projectLevel = new List<SelectOption>();
         Schema.DescribeSObjectResult describedObject = Schema.SObjectType.Milestone1_Project__c;
         for(String val: describedObject.getRecordTypeInfosByName().keySet()) {
             if(!excludeRecordTypes.contains(val)) 
             projectLevel.add(new SelectOption(val, val));
         }
         
         /*for(String  recordType : Schema.SObjectType.Milestone1_Project__c.getRecordTypeInfosByName().keySet()) {
         projectLevel.add(new SelectOption(recordType, recordType));
       }*/
        
    }
    catch(Exception excep) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, DML_ERROR_MESSAGE));
    }
           
  }
        
  // Get a list of picklist values from an existing Object field.
  public List<Schema.PicklistEntry> fetchPicklistValues(SObject obj, String fld) {
    Schema.DescribeSObjectResult objDescribe = obj.getSObjectType().getDescribe();
    Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
    return fieldMap.get(fld).getDescribe().getPickListValues();
  }
    
    /**
    * @Description: Redirect the user to edit view
    * @return: PageReference of Printview
    */
    public PageReference openEditMode() {
      PageReference pageReference = Page.ProjectBrief;
      pageReference.getParameters().put('id', projectRecord.Id);
      pageReference.getParameters().put('isEdit', 'true');
      pageReference.setRedirect(true);
      return pageReference;
    }
    
    /**
    * @Description: Redirect the user to print view
    * @return: PageReference of Printview
    */
    public PageReference cancelEditMode() {
    PageReference pageReference = Page.ProjectBrief;
    pageReference.getParameters().put('id', projectRecord.Id);
    pageReference.getParameters().put('isEdit', 'false');
    pageReference.setRedirect(true);
    return pageReference;
  }
  
  /**
    * @Description: Save the Program record
    * @return: PageReference of Printview
    */
  public PageReference saveProgram() {
    try {
	    projectRecord.Is_Program_Completed__c = true;
	    update projectRecord;
	    
	    PageReference pageReference = Page.ProjectBrief;
	    pageReference.getParameters().put('id', projectRecord.Id);
	    pageReference.getParameters().put('isEdit', 'false');
	    pageReference.setRedirect(true);
	    return pageReference;
    }
    catch (Exception excep) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, DML_ERROR_MESSAGE));
    }
      return null;
  }
}