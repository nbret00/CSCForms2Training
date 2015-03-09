/****************************************************************************
Name : ItemDivisionTrigger 
Created By : Reena Acharya(Appirio JDC)
Created Date : 21st May , 2013
Description :If Corporate is chosen, no other Division can be added at Item Level. 
            Error message - 'This item is at Corporate level. No Divisions can be added.'
            And if a division is added first, then user tries to add Corporate, 
            give an error message 'To add Corporate, please delete all other divisions from this item.'
****************************************************************************/
trigger ItemDivisionTrigger on Item_Division__c (Before Insert , Before Update , After Insert , Before Delete) {
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
        ItemDivisionHelper.ValidateDivision(Trigger.New , Trigger.OldMap);
    if(Trigger.isAfter && Trigger.isInsert)
        ItemDivisionHelper.populateProgramDivisions(Trigger.New);
    if(trigger.isDelete)
        ItemDivisionHelper.populateProgramDivisions(Trigger.old);
}