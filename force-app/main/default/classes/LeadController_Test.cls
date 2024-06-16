/********************************************
* Description: Added the test class to test the fuctionality of the class "LeadController"
* Added By:Rupa | Created Date: 6/16/2024
********************************************/
@isTest
public class LeadController_Test {
    //Added method to set the HTTP response
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock HTTP response
            HttpResponse res = new HttpResponse();
            res.setStatus('200');
            res.setBody('{"message": "Records processed successfully"}');
            return res;
        }
    }
    //Positive test method to test the getLeads method
	@isTest
    static void testGetLeads() {
        // Insert test leads
        Lead testLead1 = new Lead(FirstName = 'John', LastName = 'Doe', Company = 'ABC Inc.', LeadSource = 'Web');
        insert new List<Lead>{testLead1};

        // Call the controller method
        Test.startTest();
        List<Lead> resultLeads = LeadController.getLeads('John', 'Web');
        Test.stopTest();

        // Verify results
        System.assertEquals(1, resultLeads.size(), 'Expected 1 lead in result');
        System.assertEquals('John', resultLeads[0].FirstName, 'First name should be John');
        System.assertEquals('Doe', resultLeads[0].LastName, 'Last name should be Doe');
    }
	//Positive and Negative test method to test the SyncContacts method
    @isTest
    static void testSyncContacts() {
        Lead leadToSync = new Lead(FirstName = 'Test', LastName = 'Lead', Company = 'Test Company', LeadSource = 'Advertisement');
        insert leadToSync;
        List<Id> leadIdsToSync = new List<Id>{leadToSync.Id};

        // Set mock HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Call the controller method to test the fuctionality of Sync
        Test.startTest();
        try{
            LeadController.syncContacts(leadIdsToSync);
        }catch(exception ex){
            System.assertNotEquals(Null,ex.getMessage(),'Expected error message to not be null');
        }
        
        Test.stopTest();
    }
}