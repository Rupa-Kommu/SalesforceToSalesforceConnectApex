/********************************************
* Description: Added the test class to test the fuctionality of the class "CreateContactFromOrgA"
* Added By:Rupa | Created Date: 6/16/2024
********************************************/
@IsTest
public class CreateContactFromOrgA_Test {
    public static String jsonLeads;
    static Set<String> leadIds;
    static Lead lead1;
    static Lead lead2;
    
    //Description: Positive Scenario: Added a method to test the insert fuctionality of contact
    @IsTest
    static void testInsertNewContacts() {
        lead1 = new Lead(FirstName='John', LastName='Doe', Email='john.doe@example.com', Company='Company A');
        insert lead1;
        
        // Collect Lead Ids and serialize leads to JSON
        leadIds = new Set<String>{lead1.Id};
            List<Lead> leads = [SELECT Id, FirstName, LastName, Email, Company FROM Lead WHERE Id IN :leadIds];
        jsonLeads = JSON.serialize(leads);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ContactList/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonLeads);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        String response = CreateContactFromOrgA.recievedContact();
        Test.stopTest();
        List<Contact> contacts = [SELECT ExternalLeadId__c, FirstName, LastName, Email FROM Contact WHERE ExternalLeadId__c IN :leadIds];
        System.assertEquals(1, contacts.size());
        System.assertEquals('John', contacts[0].FirstName);
    }
    //To test the fuctionality of Update Contact
    @IsTest
    static void testUpdateExistingContact() {
        lead1 = new Lead(FirstName='John', LastName='Doe', Email='john.doe@example.com', Company='Company A');
        insert lead1;
        
        lead2 = new Lead(FirstName='Jane', LastName='Smith', Email='jane.smith@example.com', Company='Company B');
        insert lead2;
        
        // Collect Lead Ids and serialize leads to JSON
        leadIds = new Set<String>{lead1.Id, lead2.Id};
            List<Lead> leads = [SELECT Id, FirstName, LastName, Email, Company FROM Lead WHERE Id IN :leadIds];
        jsonLeads = JSON.serialize(leads);
        
        // Insert new contact using test setup data
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ContactList/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonLeads);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        CreateContactFromOrgA.recievedContact();
        
        List<Contact> contacts = [SELECT ExternalLeadId__c, FirstName, LastName, Email FROM Contact WHERE ExternalLeadId__c = :lead1.Id];
        System.assertEquals(1, contacts.size());
        Contact contactToUpdate = contacts[0];
        contactToUpdate.FirstName = 'Johnny';
        contactToUpdate.LastName ='Test';
        contactToUpdate.Title='Test';
        contactToUpdate.Email='test@gmail.com';
        contactToUpdate.LeadSource='Other';
        update contactToUpdate;
        
        // Update lead to reflect changes
        List<Lead> leadRecords = [SELECT Id, FirstName, LastName, Email, Company FROM Lead WHERE Id = :lead1.Id];
        leads[0].FirstName = 'Johnny';
        String updatedJsonLeads = JSON.serialize(leadRecords);
        req.requestBody = Blob.valueOf(updatedJsonLeads);
        String response = CreateContactFromOrgA.recievedContact();
        Test.stopTest();
        
        System.assertEquals('Records processed successfully', response);
        contacts = [SELECT ExternalLeadId__c, FirstName, LastName, Email FROM Contact WHERE ExternalLeadId__c = :lead1.Id];
        System.assertEquals(1, contacts.size());
    }
    
    //Method to test, if not leads are selected
    // Negative Scenario: No leads in the request body
    @IsTest
    static void testNoLeadsInRequest() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ContactList/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('[]'); // Empty JSON array
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        String response = CreateContactFromOrgA.recievedContact();
        Test.stopTest();
        
        System.assertEquals('Records processed successfully', response);
        List<Contact> contacts = [SELECT Id FROM Contact WHERE ExternalLeadId__c IN :leadIds];
        System.assertEquals(0, contacts.size());
    }
    //Method to test the invalid json
    @IsTest
    static void testInvalidJsonFormat() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ContactList/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('Invalid JSON');
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        try {
            CreateContactFromOrgA.recievedContact();
            System.assert(false, 'Expected exception was not thrown');
        } catch (Exception e) {
            System.assert(e instanceof System.JSONException, 'Expected a JSON exception');
        }
        Test.stopTest();
    }
}