// 
// (c) 2014 Appirio, Inc.
//
// A controller class for Compaign Brief that display the campaign information
//
// 10 Feb 2014   Sudhir Kr. Jagetiya      Original
//
public with sharing class CampaignBriefController {
  
  private static final String DML_ERROR_MESSAGE = 'Error occured. Please contact your system administrator.';
  
  public Campaign__c projectRecord {get; set;}
    
  public Boolean isEditMode {get; private set;}
        
  public CampaignBriefController(ApexPages.StandardController stc) {
    try {
      
      String isEdit = ApexPages.currentPage().getParameters().get('isEdit');
      
      if(isEdit != null && isEdit.equalsIgnoreCase('true')) {
       isEditMode = true;
      } else {
        isEditMode = false;
      }
        
      projectRecord = [SELECT Id, Name, Background__c, Budget__c, Business_and_marketing_success_measures__c, Communication_Strategy__c,
                              Core_Idea__c, Deliverables__c, GL_Code__c, Hierarchy__c, Objectives__c, Shopper_Barriers_to_Purchase__c,
                              Source_of_Volume__c, Status__c, Target_Audience__c, Requestor__r.Department, Requestor__r.Phone,
                              Requestor__r.ManagerId, Requestor__c, Go_Live_Date__c, KickOff__c, Deadline__c, Size_of_Prize__c, 
                              Mandatories__c, Duration__c, Consumer_and_Shopper_Insights__c
                         FROM Campaign__c
                        WHERE Id = : stc.getId()];
    }
    catch(Exception excep) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, DML_ERROR_MESSAGE));
    }
           
  }
        
  /**
    * @Description: Redirect the user to edit view
    * @return: PageReference of Edit mode
    */
  public PageReference openEditMode() {
    PageReference pageReference = Page.CampaignBrief;
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
    PageReference pageReference = Page.CampaignBrief;
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
      projectRecord.Is_Campaign_Completed__c = true;
      update projectRecord;
      
      PageReference pageReference = Page.CampaignBrief;
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