/***********************************************************************
class Name      : WebserviceForRequestProof_Test
Created By      : Kirti Agarwal
Created Date    : 31st Dec,2013
Purpose         : Test class for WebserviceForRequestProof
Task            : T-226893
************************************************************************/
@isTest
private class WebserviceForRequestProof_Test {
	
	static final String PROGRAM_RECORD_TYPE_D = 'D';
	static Map<String,Schema.RecordTypeInfo> rtMapByNameForProgram = null;

  static testmethod void WebserviceForRequestProof_Test(){

    Milestone1_Project__c project = Milestone1_Test_Utility.sampleProjectActive('Test');
    project.RecordTypeId = getRecordTypeIdForProgram(PROGRAM_RECORD_TYPE_D);
    insert project;

    Milestone1_Milestone__c milestone = Milestone1_Test_Utility.sampleMilestone(project);
    insert milestone;
    
    Spark_It_Item__c item = new Spark_It_Item__c();
    item.Spark_It__c = project.id;
    insert item;

    Test.startTest();
    String milestoneTaskid  = WebserviceForRequestProof.createMilestoneTask(item.id);
    List<Milestone1_Task__c> task = new List<Milestone1_Task__c>([select Id from Milestone1_Task__c where id=:milestoneTaskid and Name = 'Proof Requested']);
    system.assertEquals(task.size(), 0);
    
    Test.StopTest();
    
    milestoneTaskid  = WebserviceForRequestProof.createMilestoneTaskOnProofUploaded(item.id);
    task = new List<Milestone1_Task__c>([SELECT Id FROM Milestone1_Task__c WHERE Id = :milestoneTaskid AND Name = 'Proof Uploaded']);
    system.assertEquals(task.size(), 0);
    
    
  }
  
  /**
    * @Description  method that returns the record Type Id of Task record type.
    * @param String Record Type Name
    * @return Id recordTypeId
    */
  private static Id getRecordTypeIdForProgram(String recordType) {
    if(rtMapByNameForProgram == null) {
      Schema.DescribeSObjectResult describedObject = Schema.SObjectType.Milestone1_Project__c;
      rtMapByNameForProgram = describedObject.getRecordTypeInfosByName();
    }
    Schema.RecordTypeInfo recordTypeDetail = rtMapByNameForProgram.get(recordType);
    if(recordTypeDetail != null) {
      return recordTypeDetail.getRecordTypeId();
    } else {
      return null;
    }
  }
}