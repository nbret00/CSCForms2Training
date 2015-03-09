/**
 *	Class : PortalHomeController
 *	Description :  This class is specially used in partner community to expose the Task and Spark Items of user.
 *	Developed by : Satyanarayan choudhary
 *	Created Date : Jan 3, 2014
 */
public without sharing class PortalHomeController {
	public Account account {get; set;}
	public PortalHomeController(){
		for(User user : [Select contact.AccountId from User where id =: UserInfo.getUserId()]){
			account = new Account(Id = user.contact.AccountId);
		}	
	}
}