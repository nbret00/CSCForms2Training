/**
 *	Class : PortalHomeControllerTest
 *	Description :  Evaluate functionality of PortalHomeController class
 *	Developed by : Satyanarayan choudhary
 *	Created Date : Jan 3, 2014
 */
@isTest(seeAllData = false)
private class PortalHomeControllerTest {

    static testMethod void testPortalHomeController() {
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
      
      Integer userNumber  = Milestone1_Test_Utility.USER_COUNTER + 1;
			User newUser = new User(
			profileId = p.id,
			username = 'test89090909'+ userNumber +'@test1234.com',
			email = 'pb@ff.com',
			emailencodingkey = 'UTF-8',
			localesidkey = 'en_US',
			languagelocalekey = 'en_US',
			timezonesidkey = 'America/Los_Angeles',
			alias='nuser',
			lastname='lastname',
			contactId = con.id,
			isActive = true,
			CommunityNickname = 'testUser8909'
			);
			insert newUser;

			System.runAs(newUser){
				
				PortalHomeController controller = new PortalHomeController();
				
				// Verify Account Record
				System.assertEquals(controller.account.Id, acc.Id);
			}
    }
}