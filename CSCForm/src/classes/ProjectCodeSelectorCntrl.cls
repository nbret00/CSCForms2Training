// 
// (c) 2014 Appirio, Inc.
//
// A controller class for SelectProjectCode page that add the project code to program.
//
// 27 Feb 2014     Sudhir Kr. Jagetiya      Original
//
public without sharing class ProjectCodeSelectorCntrl {
  public String selectedProjectCodeId {get; set;}
  
  private Id programRecordId;
  
  /**
    * @description: Constructor
    * @param: standard controller
    */
  public ProjectCodeSelectorCntrl(ApexPages.StandardController stdController) {
    programRecordId = stdController.getId();
  }
  
  /**
    * @description: A method that creates selected Items 
    * @return: PageReference
    */
  public PageReference updateProgram() {
    try {
      if(programRecordId != null && selectedProjectCodeId != null) {
        Budget_Code__c projectCode = [SELECT GL_String__c FROM Budget_Code__c WHERE Id = :selectedProjectCodeId LIMIT 1];
        update new Milestone1_Project__c(Id = programRecordId, Budget_Code__c = projectCode.GL_String__c);
        return new PageReference('/' + programRecordId);
      }
    }
    catch(Exception excep) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error occured. Please contact your system administrator.'));
    }
    return null;
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
}