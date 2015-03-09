/****************************************************************************
Name : ItemDivisionHelper
Created By : Reena Acharya(Appirio JDC)
Created Date : 21st May , 2013
Description :
            Task : T-280430 : If Corporate is chosen, no other Division can be added at Item Level. 
            Error message - 'This item is at Corporate level. No Divisions can be added.'
            And if a division is added first, then user tries to add Corporate, 
            give an error message 'To add Corporate, please delete all other divisions from this item.'
            
            Task: T-280432 : This field would have a comma separated list of all Divisions added 
            under all items related to this Program.            
            If any item has Corporate, then show only Corporate in this text area. 
            No other division would be shown then. For example, if a program has two items,
            and one of them has Corporate and other has three divisions, this field at Program record would have only Corporate.
    
****************************************************************************/
public class ItemDivisionHelper{
    
    /*Task : T-280430 : If Corporate is chosen, no other Division can be added at Item Level. 
            Error message - 'This item is at Corporate level. No Divisions can be added.'
            And if a division is added first, then user tries to add Corporate, 
            give an error message 'To add Corporate, please delete all other divisions from this item.'
    */
    
    public static void ValidateDivision (List<Item_Division__c> newList , Map<Id , Item_Division__c > oldMap){
        //Create set of items for which Division is changed or new record
        Set<Id> itemIds = new Set<Id>();
        
        for(Item_Division__c  itemDiv : newList ){
            if((Trigger.Isinsert || (Trigger.isUpdate && itemDiv.Division__c != oldMap.get(itemDiv.id).Division__c)))
                itemIds.Add(itemDiv.Item__c);
        }
        
        if(itemIds.size() > 0){
            //Get Id of corporate division 
            Map<Id , Division__c> corporateDivision = new Map<Id , Division__c>([Select id from Division__c where Name = 'Corporate']);
            
            //Get the items and division list for all items.
            Map<Id,Item_Division__c> itemDivisions = new Map<Id,Item_Division__c>([Select id ,item__c,Division__c from Item_Division__c where item__c in : itemIds ]);
            Set<Id> nonCorporateItems = new Set<Id>();
            Set<Id> corporateItems = new Set<Id>();
            //Create sets of corporate and non corporate items.
            for(Item_Division__c itemDiv : itemDivisions.values()){
                if(!corporateDivision.ContainsKey(itemDiv.Division__c) )
                    nonCorporateItems.Add(itemDiv.item__c);
                else
                    corporateItems.Add(itemDiv.Item__c);
            }
                           
            //Add error to the record if corporate division already exits for an item or new division is marked as currency having non corporate division.
            for(Item_Division__c  itemDiv : newList){
              if(Trigger.Isinsert || (Trigger.isUpdate && itemDiv.Division__c != oldMap.get(itemDiv.id).Division__c)){
                    if(corporateDivision.ContainsKey(itemDiv.Division__c) && nonCorporateItems.Contains(itemDiv.item__c)){
                        itemDiv.AddError('To add Corporate, please delete all other divisions from this item.');
                    }
                    else if(corporateItems.Contains(itemDiv.item__c)){
                        itemDiv.AddError('This item is at Corporate level. No Divisions can be added.');
                    }
               }        
            }
    
        }
        
    }
    
    /*Task: T-280432 : This field would have a comma separated list of all Divisions added 
      under all items related to this Program.
      
      If any item has Corporate, then show only Corporate in this text area. 
      No other division would be shown then. For example, if a program has two items,
      and one of them has Corporate and other has three divisions, this field at Program record would have only Corporate.
    */
    public static void populateProgramDivisions(List<Item_Division__c> triggeredRecords){
        
        //Create set of items
        Set<Id> itemIds = new Set<Id>();
        for(Item_Division__c itemDiv : triggeredRecords){
            itemIds.Add(itemDiv.Item__c );
        }
        
        //Create a set of Program Ids
        Set<Id> programIds = new Set<Id>();
        for(Spark_It_Item__c item : [Select id,Spark_It__c from Spark_It_Item__c where id in : itemIds order by Spark_It__c]){
            programIds.Add(item.Spark_It__c);
        }
        
        //Get items with Program , Item Divisions
        Map<Id ,Spark_It_Item__c> items = new Map<Id ,Spark_It_Item__c>();

        //If trigger is delete then query should excluded triggered records else it should include all
        if(Trigger.isDelete){
            items = new Map<Id ,Spark_It_Item__c>([Select id,Spark_It__c , (Select id ,Division__c,Division__r.Name from Item_Divisions__r where id not in : triggeredRecords order by createdDate asc) from Spark_It_Item__c where Spark_It__c  in : programIds order by Spark_It__c]);
        }
        else 
            items = new Map<Id ,Spark_It_Item__c>([Select id,Spark_It__c , (Select id ,Division__c,Division__r.Name from Item_Divisions__r order by createdDate asc) from Spark_It_Item__c where Spark_It__c  in : programIds order by Spark_It__c]);
        
        
        //Create a map having Program Ids and division names
        Map<Id , String> programDivisions = new Map<Id , String>();
       
       
        //Iterate items
        for(Spark_It_Item__c item : items.values()){
            
            //If item contains Program field populated.
            if(item.Spark_It__c  != null){
            
                //create a comma separated names of divisions for a program and store that in a map.
                String divNames = '';
                if(programDivisions.ContainsKey(item.Spark_It__c)){
                    divNames = programDivisions.get(item.Spark_It__c);
                }
                for(Item_Division__c itemDiv  : item.Item_Divisions__r){
                   
                    //One name of division should be shown only once.
                    if(!divNames.Contains(itemDiv.Division__r.Name))
                       divNames  = itemDiv.Division__r.Name + ', ' + divNames ; 
                }
                
                //If any division is corporate then only show Corporate.
                if(divNames.Contains('Corporate')){
                   divNames = 'Corporate' ;
                }
                
                //Remove comma from end.
                if(divNames != '' && divNames.lastIndexof(', ') == divNames.length()-2){
                    divNames = divNames.substring(0,divNames.length()-2);
                }
                
                //Map with program Id and division Names.
                programDivisions.put(item.Spark_It__c , divNames);
            }
        }
        
        //Create a list of program with divisions names.
        List<Milestone1_Project__c> programs = new List<Milestone1_Project__c>();        
        for(Id progId : programDivisions.keyset()){
            String divName = programDivisions.get(progId);
            if(divName.Contains('Corporate'+ ', ')){
                   divName = 'Corporate' ;
            }
            programs.Add(new Milestone1_Project__c(id = progId , Divisions__c = divName)); 
        }
        
        //Update programs with division names.
        if(!programs.isEmpty()){
            update programs;
        }
    }
}