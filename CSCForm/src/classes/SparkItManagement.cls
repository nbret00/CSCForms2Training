/*
	Class : SparkItManagement
	Description :  Utility class for triggers on Milestone1_Project__c.
	Developed by : Manmeet Manethiya(Appirio)
	Last updated Date : Dec 31 ,2013
*/
public without sharing class SparkItManagement {
	//Method For after events for trigger
	public static void afterInsertUpdateDelete(Map<Id,Milestone1_Project__c> newMap , Map<Id,Milestone1_Project__c> oldMap){
		Boolean isDelete = newMap == null;
		if(isDelete){
			checkValidationOnError(newMap, oldMap);
		}
	}

	private static void checkValidationOnError(Map<Id,Milestone1_Project__c> newMap , Map<Id,Milestone1_Project__c> oldMap){
		//this trigger is created for T-225608
		// Validation -
    	// A.  Create validations rules that will only allow SparkIt Admins, System Admins or the Creator to Edit a Tempalte once it's created.
    	// B.  Create validations rules that will only allow SparkIt Admins or System Admins to Delete a Tempalte once it's created.
		List<String> profileNames = new List<String>();
		profileNames.add(Label.Spark_It_Admin_Profiles);
		profileNames.add('System Administrator');
		Set<String> profileIds = new Set<String>();
		for(Profile pf : [Select Id from Profile where Name In : profileNames]){
			profileIds.add(pf.Id);
		}
		for(Milestone1_Project__c item : oldMap.values()){
			//A.  Create validations rules that will only allow SparkIt Admins, System Admins or the Creator to Edit a Tempalte once it's created.
			if(item.Template__c && !profileIds.contains(UserInfo.getProfileId())){
					item.addError(Label.Spark_It_Template_Delete_Error);
			}
		}

	}
}