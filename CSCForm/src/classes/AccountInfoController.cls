/*
Class : AccountInfoController
Description :  This class is specially used in partner community to expose the account and related contacts
Developed by : Manmeet Manethiya
Created Date : December 30, 2013
*/


//Fields_To_Show_On_Portal
public without sharing class AccountInfoController {
	public Account account {get; set;}
	public boolean isEditMode {get; set;}

	public AccountInfoController(ApexPages.StandardController stc){
		isEditMode = false;
		//fetching realted account
		for(User user : [Select contact.AccountId from User where id =: UserInfo.getUserId()]){
			account = new Account(Id = user.contact.AccountId);
		}
		if(account.Id != null){
			fetchAccountData();
		}
	}

	public void fetchAccountData(){
		String accountId = account.Id;
		String query = 'SELECT ';
		for(Schema.FieldSetMember field : SObjectType.Account.FieldSets.Fields_To_Show_On_Portal.getFields()){
			query += field.getFieldPath() + ', ';
		}
		query += ' Id FROM Account where id =:accountId LIMIT 1';
		account = Database.query(query);
	}

	public Pagereference accountRedirection(){
		if(account == null){
			return new Pagereference('/apex/AccountInfo?id=' + ApexPages.currentPage().getParameters().get('Id'));

		}else{
			return new Pagereference('/apex/AccountInfo?id=' + account.Id +'&param='+account.Id);
		}
	}
}