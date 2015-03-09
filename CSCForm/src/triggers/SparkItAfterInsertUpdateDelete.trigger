/*
Class : SparkItAfterInsertUpdateDelete
Description :
Developed by : Manmeet Manethiya
Created Date : December 26, 2013
*/
trigger SparkItAfterInsertUpdateDelete on Milestone1_Project__c (before delete, after insert, after update) {
	SparkItManagement.afterInsertUpdateDelete(Trigger.newMap, Trigger.oldMap);

}