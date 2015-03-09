public with sharing class SearchSpark_ItController {
	  private static final Set<String> excludeRecordTypes = new Set<String>{'Master'};
    public List<Milestone1_Project__c> milestoneProjects{get;set;}
    public List<SelectOption> statusOptions{get;set;}
    public List<String> statusSelected{get;set;}
    public List<SelectOption> plOptions{get;set;}
    public List<String> plSelected{get;set;}
    public List<SelectOption> matchOptions{get;set;}
    public String match{get;set;}
    public List<SelectOption> dateMatchOptions{get;set;}
    public String dateMatch{get;set;}
    public Milestone1_Project__c milestoneProject{get;set;}
    public boolean isFieldSetExists{get;set;}
    public String selectedOption {get; set;}

    public SearchSpark_ItController(){
	    selectedOption = 'sparkIt';
	    milestoneProjects = new List<Milestone1_Project__c>();
	    milestoneProject = new Milestone1_Project__c();
	    statusOptions = new List<SelectOption>();
	    statusSelected = new List<String>();
	    plSelected = new List<String>();
	    isFieldSetExists = false;
	    for(Schema.PicklistEntry val: fetchPicklistValues(milestoneProject, 'Status__c')) {
	      statusOptions.add(new SelectOption(val.getValue(), val.getLabel()));
	    }
	    plOptions = new List<SelectOption>();
	    Schema.DescribeSObjectResult describedObject = Schema.SObjectType.Milestone1_Project__c;
	    for(String val: describedObject.getRecordTypeInfosByName().keySet()) {
	    	if(!excludeRecordTypes.contains(val))
	        plOptions.add(new SelectOption(val, val));
	    }
	    matchOptions = new List<SelectOption>();
	    match = 'AND';
	    matchOptions.add(new SelectOption('AND', 'Match All Filter'));
	    matchOptions.add(new SelectOption('OR', 'Match Anyone'));

	    dateMatchOptions = new List<SelectOption>();
	    dateMatch = '=';
	    dateMatchOptions.add(new SelectOption('=', 'Equals'));
	    dateMatchOptions.add(new SelectOption('<', 'Less than'));
	    dateMatchOptions.add(new SelectOption('>', 'Greater than'));
	
	        /*String selectQuery = 'SELECT Id, Name, Campaign__c, Division__c, Project_Level__c, Description__c';
	    String tableQuery = ' FROM Milestone1_Project__c ';
	    String whereQuery = '';
	    String limitQuery = ' limit ' + Limits.getLimitQueryRows();
	    String orderQuery = '';
	    isFieldSetExists = true;
	    String query = selectQuery + tableQuery + whereQuery + orderQuery + limitQuery;
	    System.debug(query);
	    milestoneProjects = Database.query(query);*/
    }

    public PageReference searchSparkIts(){
        // get the selected fieldset
        List<Schema.FieldSetMember> fieldSetFieldsList = null;
        Schema.FieldSet fieldSetSelected = getFieldset('SearchSpark_Its', 'Milestone1_Project__c');
        system.debug('fieldSetSelected :' + fieldSetSelected);
        if(fieldSetSelected != null) {
            fieldSetFieldsList = fieldSetSelected.getFields();
        }
        String selectQuery = 'SELECT Id, ';
        if(fieldSetFieldsList == null || fieldSetFieldsList.isEmpty()){
            selectQuery = 'SELECT Id, Name, Campaign__c, Division__c, Project_Level__c, Description__c';
        }else{
            for(Schema.FieldSetMember fieldSetField : fieldSetFieldsList) {
                selectQuery += fieldSetField.getFieldPath() + ', ';
            }
            selectQuery = selectQuery.substring(0, selectQuery.length() - 2);
            isFieldSetExists = true;
        }
        String tableQuery = ' FROM Milestone1_Project__c ';
        String whereQuery = '';
        String limitQuery = ' limit ' + Limits.getLimitQueryRows();
        String orderQuery = '';
        if(milestoneProject.Template__c == true){
        whereQuery += addToWhereQuery(whereQuery, 'Template__c = true');
      }
        if(statusSelected != null && !statusSelected.isEmpty()){
            whereQuery += addToWhereQuery(whereQuery, 'Status__c IN (' + getInString(statusSelected) + ')');
        }
        if(plSelected != null && !plSelected.isEmpty()){
            whereQuery += addToWhereQuery(whereQuery, 'RecordType.Name IN (' + getInString(plSelected) + ')');
        }
        if(milestoneProject.Campaign__c != null){
            whereQuery += addToWhereQuery(whereQuery, 'Campaign__c = \'' + milestoneProject.Campaign__c + '\'');
        }
        if(milestoneProject.Division__c != null){
            whereQuery += addToWhereQuery(whereQuery, 'Division__c = \'' + milestoneProject.Division__c + '\'');
        }
        if(milestoneProject.Requestor__c != null){
            whereQuery += addToWhereQuery(whereQuery, 'Requestor__c = \'' + milestoneProject.Requestor__c + '\'');
        }
        if(milestoneProject.Name != null){
            whereQuery += addToWhereQuery(whereQuery, 'Name like \'%' + milestoneProject.Name + '%\'');
        }
        Date deadline = milestoneProject.Deadline__c;
        if(deadline != null){
            whereQuery += addToWhereQuery(whereQuery, 'Deadline__c ' + dateMatch + ' :deadline');
        }
        String query = selectQuery + tableQuery + whereQuery + orderQuery + limitQuery;
        System.debug(query);
        milestoneProjects = Database.query(query);
        return null;
    }

    private String addToWhereQuery(String whereQuery, String condition){
        if(whereQuery == null || whereQuery == ''){
            return 'WHERE ' + condition;
        }else{
            return ' ' + match + ' ' + condition;
        }
    }

    private Schema.FieldSet getFieldset(String fieldSetName, String objectName){
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.fieldSets.getMap().get(fieldSetName);
        return fieldSetObj;
    }

    // Get a list of picklist values from an existing Object field.
    public List<Schema.PicklistEntry> fetchPicklistValues(SObject obj,String fld) {
        Schema.DescribeSObjectResult objDescribe = obj.getSObjectType().getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        return fieldMap.get(fld).getDescribe().getPickListValues();
    }

    public List<SelectOption> getOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('sparkIt','Program'));
        options.add(new SelectOption('store','Store'));
        return options;
    }

    public Pagereference renderSectionAction(){
        return null;
    }

    //Get a string which can be passed to IN clause
    public String getInString(List<String> input){
        String result = '';
        for(String s : input){
            s = s.trim();
            s = s.replace('\'', '\\\'');
            if(result=='')
                result = result + '\'' + s + '\'';
            else
                result = result + ',\'' + s + '\'';
        }
        return result;
    }
}