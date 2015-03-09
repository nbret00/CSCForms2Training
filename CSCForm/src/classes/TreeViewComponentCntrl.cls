// 
// (c) 2014 Appirio, Inc.
//
// A controller class for TreeViewComponentForProjectCodes comppnent that display the project codes in a tree structure.
//
// 27 Feb 2014     Sudhir Kr. Jagetiya      Original
//
public without sharing class TreeViewComponentCntrl {
  
  private static final Integer RECORD_SIZE_LIMIT;   
  private static JSONGenerator gen {get; set;}
  
  static {
  	try {
  	  RECORD_SIZE_LIMIT = Integer.ValueOf(system.Label.Project_Code_Limit_For_Tree_View);
  	}
  	catch (Exception excep) {
  		RECORD_SIZE_LIMIT = 5000;
  	}
  }
  
  public transient String jsonString {get; set;}
  public String InputText{get;set;}
  public String ProductId{get;set;}  
  public String SelectedCategory{get;set;}
   
  /**
    * @description: It prepares a list of tree nodes
    * @return: List<NodeWrapper> list of nodes
    */  
  private List<NodeWrapper> createNode() {
    try{    
      
      List<NodeWrapper> nodes = new List<NodeWrapper>();
      NodeWrapper nWrap, nodeVP, nodeDirector, nodeGVP, nodeDirectorCode, nodeProjectCode;
      for(Budget_Code__c projectCode : [SELECT Director__c, Director_Code__c, Budget_Code__c, 
                                                Project_Name__c, GVP__c, VP__c 
                                           FROM Budget_Code__c 
                                           WHERE Budget_Code__c != null 
                                           ORDER BY Project_Name__c ASC 
                                           LIMIT :RECORD_SIZE_LIMIT]) {
        nWrap = new NodeWrapper();
        nWrap.prodId = projectCode.Id;
        nWrap.prodName = projectCode.Project_Name__c;
        nWrap.selected = false;
        nWrap.unselectable = false;
        nWrap.hasChildren = true;
        nWrap.isLeafNode  = false;
        nWrap.childNodes = new List<NodeWrapper>();
        if(projectCode.VP__c != null) {
        	nodeVP = prepareNode(projectCode.VP__c, 'VP - ' + projectCode.VP__c, true, false, true);
        	nWrap.childNodes.add(nodeVP);  
        	if(projectCode.Director__c != null) {
        		nodeDirector = prepareNode(projectCode.Director__c, 'Director - ' + projectCode.Director__c, true, false, true);
        		nodeVP.childNodes.add(nodeDirector);
        		if(projectCode.GVP__c != null) {
        			nodeGVP = prepareNode(projectCode.GVP__c, 'GVP - ' + projectCode.GVP__c, true, false, true);
        			nodeDirector.childNodes.add(nodeGVP);
        			if(projectCode.Director_Code__c != null) {
        				nodeDirectorCode = prepareNode(projectCode.Director_Code__c, 'Director Code - ' + projectCode.Director_Code__c, true, false, true);
        				nodeGVP.childNodes.add(nodeDirectorCode);
        				if(projectCode.Budget_Code__c != null) {
        					nodeProjectCode = prepareNode(projectCode.Budget_Code__c, 'Budget Code - ' + projectCode.Budget_Code__c, true, true, false);
        				  nodeDirectorCode.childNodes.add(nodeProjectCode);
        				} else {
        					nodeDirectorCode.isLeafNode  = true;
        				}
        			}	else {
        				nodeGVP.isLeafNode  = true;
        			}                      
        		} else {
	            nodeDirector.isLeafNode  = true;
	          }
        	} else {
        		nodeVP.isLeafNode  = true;
        	}
        } 
        else {
        	nWrap.isLeafNode  = true;
        }
        nodes.add(nWrap);                 
      }
      return nodes; 
    } catch (exception e){
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
      return null;
    } 
  }    
  
  /**
    * @description: It prepares a tree nodes
    * @return: NodeWrapper - tree node
    */  
  public NodeWrapper prepareNode(String prodId, String prodName, Boolean unselectable, Boolean isLeafNode, Boolean hasChildren) {
  	NodeWrapper nWrapper = new NodeWrapper();
  	nWrapper.prodId = prodId;
  	nWrapper.prodName = prodName;
  	nWrapper.unselectable = unselectable;
  	nWrapper.isLeafNode = isLeafNode;
  	nWrapper.hasChildren = hasChildren;
  	nWrapper.childNodes = new List<NodeWrapper>();
  	return nWrapper;
  }
  
  /**
    * @description: It prepares the json string for tree structure
    * @return: String - json string
    */  
  private String getProductTreeJSON() {
    gen = JSON.createGenerator(true);
    gen.writeStartArray();
    for(NodeWrapper node : createNode()) {
      convertNodeToJSON(node);
    }
    gen.writeEndArray();
    return gen.getAsString();
  } 

  /**
    * @description: It converts all the nodes into tree format
    * @return: void
    */ 
  private void convertNodeToJSON(NodeWrapper objNW){
    gen.writeStartObject();
    gen.writeStringField('title', objNW.prodName);
    gen.writeStringField('key', objNW.prodId);
    gen.writeBooleanField('unselectable', objNW.unselectable);
    gen.writeBooleanField('hideCheckbox', objNW.unselectable);
    gen.writeBooleanField('expand', false);
    gen.writeBooleanField('isFolder', false);
    
    if (objNW.hasChildren) {
      gen.writeFieldName('children');
      gen.writeStartArray();
      if (objNW.hasChildren) {
        for (NodeWrapper wr : objNW.childNodes) {
          convertNodeToJSON(wr);
        }
      }
      gen.writeEndArray();
    }
    gen.writeEndObject();
  }

  public class NodeWrapper {
	 public String prodName {get; set;}
	 public String prodId {get; set;}
	 public String parentId {get; set;}
	 public boolean selected{get; set;}
	 public boolean unselectable{get;set;}
	 public string formatClass{get;set;}
	 public Boolean hasChildren {get; set;}
	 public Boolean isLeafNode {get; set;}
	 public List<NodeWrapper> childNodes {get; set;}
	 public NodeWrapper(){
	   this.hasChildren = false;
	 }
  }   
  
  /**
    * @description: Initialize the controller
    * @return: void
    */ 
	public void init(){
	  jsonString = getProductTreeJSON();
	}
}