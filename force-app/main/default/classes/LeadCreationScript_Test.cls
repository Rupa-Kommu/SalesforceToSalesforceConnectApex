/********************************************
* Description: Test class for LeadCreationScript
* Added By: Rupa | Created Date: 6/16/2024
********************************************/
@isTest
public class LeadCreationScript_Test {
    //Positive Test method to test the lead Creation
    @isTest
    static void testCreateLeadsPositive() {
        // Start a new test context
        Test.startTest();
        
        // Call the method to create leads
        LeadCreationScript.createLeads();
        
        // End the test context
        Test.stopTest();
        
        // Verify 1000 leads were created
        List<Lead> leads = [SELECT Id, FirstName, LastName, Company, Title, Email, LeadSource FROM Lead WHERE LastName LIKE 'Lead%'];
        System.assertEquals(1000, leads.size(), '1000 leads should have been created');
        
        // Verify data integrity for one of the leads
        Lead lead = leads[0];
        System.assertEquals('Test', lead.FirstName, 'FirstName should be Test');
    }
    
    //Negative Scenario to test the creating the leads with Insufficient access
    @isTest
    static void testCreateLeadsInsufficientAccess() {
        // Create a user with "Custom: Support Profile"
        Profile supportProfile = [SELECT Id FROM Profile WHERE Name = 'Custom: Support Profile' LIMIT 1];
        User supportUser = new User(
            Username = 'supportTest@test.com',
            Alias = 'STest1',
            Email = 'supportuser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'SupportUserTest1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = supportProfile.Id
        );
        insert supportUser;
        
        // Use System.runAs to execute as the support user
        System.runAs(supportUser) {
           Test.startTest();
        
        try {
            LeadCreationScript.createLeads();
            System.assert(false, 'Exception should have been thrown due to insufficient access rights');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(),'Insufficient access rights to create leads.');
        }
        
        Test.stopTest(); 
        } 
    }
}