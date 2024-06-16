/********************************************
* Description: Controller class to the lwc "LeadListLWC"
* Added By:Rupa | Created Date: 6/16/2024
********************************************/
public with Sharing class LeadController {
    
    //Description: Called from LWC to fetch the query selects based on search or filter keys
	@AuraEnabled(cacheable=true)
    public static List<Lead> getLeads(String searchKey, String leadSource) {
        if (!Schema.sObjectType.Lead.isAccessible()) {
            throw new AuraHandledException('Insufficient access rights to read Lead records.');
        }
        String searchKeyPattern = '%' + searchKey + '%';
        String query = 'SELECT Id, FirstName, LastName, Company, LeadSource FROM Lead WHERE (FirstName LIKE :searchKeyPattern OR LastName LIKE :searchKeyPattern) ';
        
        if (leadSource != null && leadSource != '') {
            query += 'AND LeadSource = :leadSource ';
        }
        
        query += 'LIMIT 2000';
        List<Lead> leads = Database.query(query);
        return leads;
    }
    
	// Called from LWC to handle the Syn between the ORG A and Org B
	// Fuctionality: To create the Contact in Org B using Org A lead Data
    @AuraEnabled
    public static void syncContacts(List<Id> leadIds) {
        // Fetch leads by IDs
        List<Lead> leads = [SELECT Id, LastName, FirstName, Title, Company, Phone, Email, LeadSource, Rating, Industry 
                            FROM Lead 
                            WHERE Id IN :leadIds WITH SECURITY_ENFORCED];
        // Converting the leads to String with help of JSON
        string payload= JSON.serialize(leads);
        string targetEndpoint = 'callout:SFDCOrgB/services/apexrest/ContactList';
        // Make HTTP Callout
        HttpRequest request = new HttpRequest();
        request.setEndpoint(targetEndpoint);
        //request.setEndpoint('callout:SFDCOrgB/services/data/v52.0/sobjects/Contact/');
        request.setMethod('POST');
        request.setHeader('Authorization','Bearer'+UserInfo.getSessionId());
        request.setHeader('Content-Type', 'application/json');
        request.setBody(payload);
        Http http = new Http();
        try {
            HttpResponse res = http.send(request);
            // 201 indicates successful creation/Updation
            if (res.getStatusCode() != 200) {
                throw new CalloutException('Failed to sync contacts: ' + res.getBody());
            }
        } catch (Exception e) {
            throw new CalloutException('HTTP Callout failed: ' + e.getMessage());
        }
    }
}