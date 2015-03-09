// 
// (c) 2014 Appirio, Inc.
//
// A controller class for CustomSparkItItemDetailPage page that displays  SparkItItems for Partner user
//
// 15 Jan 2014     Sudhir Kr. Jagetiya       Original
//
public with sharing class SparkIt_Charts_GanttController {
  private static final Set<String> excludeRecordTypes = new Set<String>{'Master'};
  private static final String REGEXP_QUOTES    = '(?<!\\\\)"';

  private static final String COLOR_COMPLETE = '#333333';
  private static final String COLOR_LATE = '#ee3322';
  private static final String COLOR_FUTURE = '#666666';
  private static final String COLOR_CURRENT = '#2299bb';
  private static final String STATUS_COMPLETED = 'Completed';
  
  private static final String nameFieldName;
  private static final String completedFieldName;
  private static final String filterFieldName;
  private static final String statusFieldName;
  
  public static String objectType {get; private set;}
  public static String startDateFieldName {get; private set;}
  public static String endDateFieldName {get; private set;}
  public static String idFieldName {get; private set;}
  public static String projectGanttJson {get; private set;}
  
  static {
    startDateFieldName = Milestone1_Project__c.Kickoff__c.getDescribe().getName();
    endDateFieldName = Milestone1_Project__c.Deadline__c.getDescribe().getName();
    statusFieldName = Milestone1_Project__c.Status__c.getDescribe().getName();
    objectType = Schema.SObjectType.Milestone1_Project__c.getName();            
    idFieldName = 'Id';  
    nameFieldName = 'Name';
  }
  
  
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
  
  
  
  private List<Sobject> sobjectList;
  
  public SparkIt_Charts_GanttController() {
    sobjectList = new List<Sobject>();
    
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
    searchSparkIts();
  }

  public PageReference searchSparkIts(){
    sobjectList.clear();
    String selectQuery = '';
    selectQuery = 'SELECT ' + idFieldName+', '+startDateFieldName+', '+endDateFieldName+ ', '+nameFieldName+ ', ' + statusFieldName;
    String tableQuery = ' FROM Milestone1_Project__c ';
    String whereQuery = '';
    String limitQuery = ' LIMIT ' + Limits.getLimitQueryRows();
    String orderQuery = ' ORDER BY Kickoff__c ASC NULLS LAST, Name ASC';
    
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
    String query = selectQuery + tableQuery + whereQuery + orderQuery + limitQuery ;
    
    projectGanttJson = toJSon(Database.query(query));
    return null;
  }

  private String addToWhereQuery(String whereQuery, String condition){
    if(whereQuery == null || whereQuery == ''){
      return 'WHERE ' + condition;
    }else{
      return ' ' + match + ' ' + condition;
    }
  }

  // Get a list of picklist values from an existing Object field.
  public List<Schema.PicklistEntry> fetchPicklistValues(SObject obj,String fld) {
    Schema.DescribeSObjectResult objDescribe = obj.getSObjectType().getDescribe();
    Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
    return fieldMap.get(fld).getDescribe().getPickListValues();
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
  
  /**
    *   Generate the output in json format to be rendered in the jquery gantt.
    */
    private String toJSon(List<Sobject> sobjectList){
        String ret = '[{id: 1, name: "", series: [';
        Boolean addComma=false;
        String completed = '';
        Date startDate,endDate;
        String name,id;
        for (Sobject current : sobjectList){

            if(current.get(startDateFieldName) == null){
                startDate = Date.today();
            }else{
                startDate = Date.valueOf(current.get(startDateFieldName));
            }
            if(current.get(endDateFieldName) == null){
                endDate = startDate;
            }else{
                endDate = Date.valueOf(current.get(endDateFieldName));
            }
            completed = String.valueOf(current.get(statusFieldName));
            name = escapeDoubleQuotes(String.valueOf(current.get(nameFieldName)));
            id = String.valueOf(current.get(idFieldName));
            if (addComma) { ret += ','; }

            String color = COLOR_CURRENT;

            if (completed == STATUS_COMPLETED) {
                color=COLOR_COMPLETE;
            } else if (endDate < Date.today()) {
                color=COLOR_LATE;
            } else if (startDate > Date.today()) {
                color=COLOR_FUTURE;
            }

            ret +=  '{'+
                    'id:"'+id+'",'+
                    'name: "'+name+'",'+                    
                    'start: new Date(' +startDate.year() +',' + (startDate.month()-1) +',' + startDate.day() +'),'+
                    'end: new Date(' +endDate.year() +',' + (endDate.month()-1) + ',' + endDate.day() +'), ' +
                    'color: "' + color + '"'+
                    '}';

            addComma=true;

        }

        ret+=']}];';
        return ret;
    }
    private String escapeDoubleQuotes(String word){
      return word.replaceAll(REGEXP_QUOTES,'\\\\"');
    }
}