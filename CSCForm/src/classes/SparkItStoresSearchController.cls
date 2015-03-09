/*
Class : SparkItStoresSearchController
Description :  This class is used for associating stores with spark Its
Developed by : Manmeet Manethiya
Created Date : December 27, 2013
*/

public without sharing class SparkItStoresSearchController {

    //getter setter
    public Store__c dummyStore {get; set;}
    public List<List<StoreWrapper>> listStores  {get; set;}
    public Milestone1_Project__c projectRecord {get; set;}

  public List<SelectOption> selectedFields { get; set; }
    public List<SelectOption> allFields { get; set; }
    public boolean isCalledFromSparkItSearch {get; set;}

    //private properties
    Map<String, String> mapApiNameLabels;

    //constructor
    public SparkItStoresSearchController(ApexPages.StandardController stc){
        dummyStore = new Store__c();
        isCalledFromSparkItSearch = false;
        selectedFields = new List<SelectOption>();
        projectRecord = new Milestone1_Project__c(id = stc.getId());
        preparePicklistForFields();
        if(ApexPages.currentPage().getUrl().contains('SearchSpark_It')){
            isCalledFromSparkItSearch = true;
        }
    }

    //preparing picklist of search fields which are refereneced in Search_Fields field set
    public void preparePicklistForFields(){
        List<Schema.FieldSetMember> fields = SObjectType.Store__c.FieldSets.Search_Fields.getFields();
        mapApiNameLabels = new Map<String, String>();
        allFields = new List<SelectOption>();
        for(Schema.FieldSetMember field : fields){
            allFields.add(new SelectOption(field.getFieldPath(), field.getLabel()));
            mapApiNameLabels.put(field.getFieldPath(), field.getLabel());
        }
    }

    //fetching selected fields
    //basically used for rerendering section on page
    public Pagereference fetchSelectedFields(){
        return null;
    }

    //this function returns thype of field
    private String getFieldType(String fieldApi){
        Schema.sObjectType sobject_type = Store__c.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        return String.valueOf(field_map.get(fieldApi).getDescribe().getType());
    }

    //searching stores on the basis of entered criteria
    public Pagereference searchStores(){
        listStores = new List<List<StoreWrapper>>();
        if(selectedFields.size() > 0){
            Integer countRecord = 0;
            for(SelectOption fieldAPiName : selectedFields){
                if(dummyStore.get(fieldAPiName.getValue())  ==  null){
                    countRecord++;
                }
            }
            //if no criteria is entered in any of the search fields
            if(selectedFields.size() == countRecord){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Please fill atleast one criteria to search Stores.');
                ApexPages.addMessage(myMsg);
                return null;
            }
            String query = 'Select Name,Division__c,Banner__c,Street__c,City__c,State__c,Zipcode__c from Store__C where ';
            for(SelectOption fieldAPiNameX : selectedFields){
                String fieldAPiName = fieldAPiNameX.getValue();
                if(getFieldType(fieldAPiName).equalsIgnoreCase('Boolean')){
                    query += fieldAPiName +' = '+ dummyStore.get(fieldAPiName) + ' AND ';
                }else if(getFieldType(fieldAPiName).equalsIgnoreCase('String') ||
                        getFieldType(fieldAPiName).equalsIgnoreCase('Integer') ||
                        getFieldType(fieldAPiName).equalsIgnoreCase('Double') ||
                        getFieldType(fieldAPiName).equalsIgnoreCase('Currency')||
                        getFieldType(fieldAPiName).equalsIgnoreCase('Email') ||
                        getFieldType(fieldAPiName).equalsIgnoreCase('Phone')||
                        getFieldType(fieldAPiName).equalsIgnoreCase('Percent')||
                        getFieldType(fieldAPiName).equalsIgnoreCase('URL')){
                    if(dummyStore.get(fieldAPiName) != null){
                       if(getFieldType(fieldAPiName).equalsIgnoreCase('String')) {
                         dummyStore.put(fieldAPiName, String.escapeSingleQuotes(String.valueOf(dummyStore.get(fieldAPiName))));
                       } 
                       query += fieldAPiName +' Like \'%'+ dummyStore.get(fieldAPiName) + '%\' AND ';                       
                    }
                }else if(getFieldType(fieldAPiName).equalsIgnoreCase('Reference') ||
                        getFieldType(fieldAPiName).equalsIgnoreCase('Picklist')){
                    if(dummyStore.get(fieldAPiName) != null){
                        dummyStore.put(fieldAPiName, String.escapeSingleQuotes(String.valueOf(dummyStore.get(fieldAPiName))));
                        query += fieldAPiName +' = \''+ dummyStore.get(fieldAPiName) + '\' AND ';
                    }
                }
            }
            query = query.subString(0 , query.length() - 4);
            query += ' ORDER BY Name, Division__r.Name, Banner__c, Street__c,City__c,State__c,Zipcode__c ';
            //system.assert(false, query);
            List<StoreWrapper> tempStores = new List<StoreWrapper>();
            for(Store__c store : DataBase.query(query)){
                tempStores.add(new StoreWrapper(false, store));
                if(tempStores.size() > 999){
                    listStores.add(tempStores);
                    tempStores = new List<StoreWrapper>();
                }
            }
            listStores.add(tempStores);
        }
        return null;
    }

    //associating stores to the sparkits
    public Pagereference associate(){
        List<SparkIt_Store__c> sparkItStoresToInsert = new List<SparkIt_Store__c>();
        for(List<StoreWrapper> lstStore : listStores){
            for(StoreWrapper store : lstStore){
                if(store.isSelected){
                    sparkItStoresToInsert.add(new SparkIt_Store__c(Spark_It__c = projectRecord.Id, Store__c = store.store.Id));
                }
            }
        }
        if(sparkItStoresToInsert.size() > 0){
            insert sparkItStoresToInsert;
        }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: No Stores Selected.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        return new Pagereference('/' + projectRecord.Id);
    }

    public Pagereference doBack(){
        return new Pagereference('/' + projectRecord.Id);
    }

    //wrapper class to hold the Stores
    class StoreWrapper{
        public boolean isSelected {get; set;}
        public Store__c store {get; set;}

        public StoreWrapper(boolean isSelected, Store__c store){
            this.isSelected = isSelected;
            this.store = store;
        }
    }
}