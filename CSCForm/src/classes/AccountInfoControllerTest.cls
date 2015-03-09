/*
Class : AccountInfoControllerTest
Description :  Test class for AccountInfoController
Developed by : Manmeet Manethiya
Created Date : December 31, 2013
*/

@isTest(seeAllData = false)
private class AccountInfoControllerTest {
		static testMethod void testAccountUpdation() {
			Set<String> customerUserTypes = new Set<String> {'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};
			Account acc = new Account (
			Name = 'newAcc1'
			);
			insert acc;
			Contact con = new Contact (
			AccountId = acc.id,
			LastName = 'portalTestUser'
			);
			insert con;
			Profile p;
			for(Profile profile : [select Id,name from Profile where UserType in :customerUserTypes limit 1]){
				p = profile;
			}

			User newUser = new User(
			profileId = p.id,
			username = 'test122234@test1234.com',
			email = 'pb@ff.com',
			emailencodingkey = 'UTF-8',
			localesidkey = 'en_US',
			languagelocalekey = 'en_US',
			timezonesidkey = 'America/Los_Angeles',
			alias='nuser',
			lastname='lastname',
			contactId = con.id,
			CommunityNickname = 'testUser123'
			);
			insert newUser;

			System.runAs(newUser){
				ApexPages.StandardController stc = new ApexPages.StandardController(acc);
				AccountInfoController controller = new AccountInfoController(stc);
				PageReference pg = controller.accountRedirection();
				//assert
				System.assertNotEquals(null, pg);
			}
		}
}