/*
Copyright (c) 2011, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors
    may be used to endorse or promote products derived from this software
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
OF THE POSSIBILITY OF SUCH DAMAGE.

*/
public without sharing class Milestone1_Clone_Project_Controller {

    public Milestone1_Project__c rec {get; set;}
    public Milestone1_Project__c dummyProj {get; set;}
    public boolean isToCreateMilestones  {get; set;}
    public boolean isToCreateTasks  {get; set;}
    public boolean isToCreateStores {get; set;}
    public boolean isToSparkItItems {get; set;}
    private List<Milestone1_Milestone__c> milestones {get; set;}
    private List<Milestone1_Task__c> tasks {get; set;}
    private List<User> statusList{get; set;}
    public Boolean isProjOwnerActive{get;set;}
    public boolean isInactiveUserToBeReplaced{get;set;}

    public Milestone1_Clone_Project_Controller(ApexPages.StandardController stc){
        //query project record
        rec = [SELECT Id, Name, OwnerId FROM Milestone1_Project__c WHERE Id = :stc.getId() LIMIT 1];

        dummyProj = new Milestone1_Project__c();
        dummyProj.Name = 'Copy of ' + rec.Name;
        statusList = [SELECT IsActive from User where id = :rec.OwnerId];
        if(statusList  != null && statusList.size() > 0 )
            isProjOwnerActive = statusList[0].IsActive;
    }

    public PageReference createClone(){
        Savepoint preSave = Database.setSavepoint(); //set savepoint so we can rollback the whole save if there are errors
        PageReference pageReference = null;
        try{
          Milestone1_Project__c projectToClone = retrieveSparkIt(rec.Id);
          if(isProjOwnerActive == false){
                if(dummyProj.OwnerId == null){
                   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,system.label.Milestone1_InactiveUsersError);
                   ApexPages.addMessage(myMsg);
                   isInactiveUserToBeReplaced = true;
                   return pageReference;
                }if(dummyProj.OwnerId != null){
                    projectToClone.ownerId = dummyProj.OwnerId;
                }
            }

            //create new project record
            projectToClone.Name = dummyProj.Name;

            Milestone1_Project__c newProj = projectToClone.clone(false);
            newProj.ImportID__c = rec.Id;
            newProj.Template__c = false; 
            insert newProj;
            
            //query milestone records
            milestones = retrieveMileStones(rec.Id);

		        //query task records
		        tasks = retrieveMileStoneTasks(rec.Id);
            
            //new requirement - milestones and milestone tasks are to be always cloned
            //user won't be able to select them from clone screen
            isToCreateMilestones = true;
            isToCreateTasks = true;
            if(isToCreateMilestones){
                //separate milestone records into parents and subs
                List<Milestone1_Milestone__c> topMilestones = new List<Milestone1_Milestone__c>();
                List<Milestone1_Milestone__c> bottomMilestones = new List<Milestone1_Milestone__c>();
                Map<Id, Id> mapForPredecessorMileston = new Map<Id, Id>();
                for(Milestone1_Milestone__c oldMS : milestones){
                	  if(oldMS.Predecessor_Milestone__c != null && !mapForPredecessorMileston.containsKey(oldMS.Id)) {
                	  	mapForPredecessorMileston.put(oldMS.Id, oldMS.Predecessor_Milestone__c);
                	  }
                    if(oldMS.Parent_Milestone__c == null){
                        topMilestones.add(oldMS);
                    } else {
                        bottomMilestones.add(oldMS);
                    }
                }
                //clone and insert top milestone records
                Map<String, Milestone1_Milestone__c> newTopMilestoneMap = Milestone1_Clone_Utility.cloneMilestonesIntoMap(topMilestones);
                for(Milestone1_Milestone__c newMS : newTopMilestoneMap.values()){
                    newMS.Project__c = newProj.Id;
                    newMS.Alias__c = null;
                    newMS.Predecessor_Milestone__c = null;
                }
                insert newTopMilestoneMap.values();

                //clone and insert sub milestone records
                Map<String, Milestone1_Milestone__c> newBottomMilestoneMap = Milestone1_Clone_Utility.cloneMilestonesIntoMap(bottomMilestones);
                for(Milestone1_Milestone__c newMS : newBottomMilestoneMap.values()){
                    newMS.Project__c = newProj.Id;
                    newMS.Alias__c = null;
                    newMS.Parent_Milestone__c = newTopMilestoneMap.get(newMS.Parent_Milestone__c).Id;
                    newMS.Predecessor_Milestone__c = null;
                }
                insert newBottomMilestoneMap.values();
                
                List<Milestone1_Milestone__c> mileStoneToBeUpdated = new List<Milestone1_Milestone__c>();
                Id predecessorId;
                for(Id oldMsId : newTopMilestoneMap.KeySet()){
                   if(mapForPredecessorMileston.containsKey(oldMsId)) {
                   	 predecessorId = mapForPredecessorMileston.get(oldMsId);
                   	 if(predecessorId != null && newTopMilestoneMap.containsKey(predecessorId)) {
                   	 	 mileStoneToBeUpdated.add(new Milestone1_Milestone__c(Id = newTopMilestoneMap.get(oldMsId).Id, Predecessor_Milestone__c = newTopMilestoneMap.get(predecessorId).Id));
                   	 }
                   }
                }
                
                for(Id oldMsId : newBottomMilestoneMap.KeySet()){
                   if(mapForPredecessorMileston.containsKey(oldMsId)) {
                     predecessorId = mapForPredecessorMileston.get(oldMsId);
                     if(predecessorId != null && newBottomMilestoneMap.containsKey(predecessorId)) {
                       mileStoneToBeUpdated.add(new Milestone1_Milestone__c(Id = newBottomMilestoneMap.get(oldMsId).Id, Predecessor_Milestone__c = newBottomMilestoneMap.get(predecessorId).Id));
                     }
                   }
                }
                update mileStoneToBeUpdated;
                
                system.debug('isToCreateTasks ' + isToCreateTasks);
                if(isToCreateTasks){
                    //collect all milestones into one map
                    Map<String, Milestone1_Milestone__c> allNewMilestoneMap = new Map<String, Milestone1_Milestone__c>();
                    allNewMilestoneMap.putAll(newTopMilestoneMap);
                    allNewMilestoneMap.putAll(newBottomMilestoneMap);

                    //clone and insert task records
                    List<Milestone1_Task__c> newTasks = Milestone1_Clone_Utility.cloneTasksIntoList(tasks);
                    for(Milestone1_Task__c newTask : newTasks){
                        newTask.Project_Milestone__c = allNewMilestoneMap.get(newTask.Project_Milestone__c).Id;
                    }
                    insert newTasks;
                }
            }

            if(isToCreateStores){
                createStoresAndInsertSparkITStore(newProj);
			}
			if(isToSparkItItems){
				createSparkItItems(newProj);
			}
            //direct user to cloned project's detail page
            return new ApexPages.StandardController(newProj).view();

        }catch(Exception e){
            ApexPages.addMessages(e); //show save error(s) on the visualforce page
            Database.rollback(preSave); //rollback any completed saves if the transaction has errors
        }
        return pageReference;
    }

	//this function is used for spark it items
	private void createSparkItItems(Milestone1_Project__c newProj){
		//Spark_It_Item__c
		String masterId = rec.id;
		String query = 'Select ';
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Spark_It_Item__c.fields.getMap();
        for(String fieldApiName : fieldMap.keySet()){
            if(fieldApiName.contains('__c')){
                query += fieldApiName + ', ';
            }
        }
        query += 'Name from Spark_It_Item__c where Spark_It__c =: masterId';
        List<Spark_It_Item__c> listItemsToClone = new List<Spark_It_Item__c>();
        for(Spark_It_Item__c item : Database.query(query)){
        	Spark_It_Item__c tempItem = item.clone(false);
        	tempItem.Spark_It__c = newProj.Id;
            listItemsToClone.add(tempItem);
        }

        insert listItemsToClone;
	}
    //this function is used for inserting stores and then inserting junction object
    private void createStoresAndInsertSparkITStore(Milestone1_Project__c newProj){
        //fetching junction object
        Set<String> storeIds = new Set<String>();
        for(SparkIt_Store__c sStore : [Select Id, Store__c from SparkIt_Store__c where Spark_It__c =: rec.Id and Store__c != null]){
            storeIds.add(sStore.Store__c);
        }
        String query = 'Select ';
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Store__c.fields.getMap();
        for(String fieldApiName : fieldMap.keySet()){
            if(fieldApiName.contains('__c')){
                query += fieldApiName + ', ';
            }
        }
        query += 'Name from Store__c where id =: storeIds';
        //system.assert(false, query);
        List<Store__c> listStoresToClone = new List<Store__c>();
        for(Store__c store : Database.query(query)){
            Store__c tempStore = store.clone(false);
            listStoresToClone.add(tempStore);
        }
        if(listStoresToClone.size() > 0){
            insert listStoresToClone;
        }
        List<SparkIt_Store__c> listJunctionRecords = new List<SparkIt_Store__c>();
        for(Store__c store : listStoresToClone){
            listJunctionRecords.add(new SparkIt_Store__c(Spark_It__c = newProj.Id, Store__c = store.Id));
        }

        insert listJunctionRecords;
    }
    
   private Milestone1_Project__c retrieveSparkIt(Id recordId) {
   	  String query = 'SELECT ';
	    for(String fieldApiName : Schema.SObjectType.Milestone1_Project__c.fields.getMap().keySet()){
        if(fieldApiName.contains('__c')){
            query += fieldApiName + ', ';
        }
	    }
	    query += 'Name FROM Milestone1_Project__c WHERE Id =: recordId';
	    return Database.query(query);
   }
   
   private List<Milestone1_Milestone__c> retrieveMileStones(Id sparkItRecordId) {
      String query = 'SELECT ';
      for(String fieldApiName : Schema.SObjectType.Milestone1_Milestone__c.fields.getMap().keySet()){
        if(fieldApiName.contains('__c')){
            query += fieldApiName + ', ';
        }
      }
      query += 'Name FROM Milestone1_Milestone__c WHERE Project__c =: sparkItRecordId';
      return Database.query(query);
   }
   
   private List<Milestone1_Task__c> retrieveMileStoneTasks(Id sparkItRecordId) {
      String query = 'SELECT ';
      for(String fieldApiName : Schema.SObjectType.Milestone1_Task__c.fields.getMap().keySet()){
        if(fieldApiName.contains('__c')){
            query += fieldApiName + ', ';
        }
      }
      query += 'Name FROM Milestone1_Task__c WHERE Project_Milestone__r.Project__c = :sparkItRecordId';
      return Database.query(query);
   }
   
   

}