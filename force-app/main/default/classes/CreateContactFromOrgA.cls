/********************************************
* Description: Created the class to handle Contact creation using the Org A Leads data
* Added By:Rupa | Created Date: 6/16/2024
********************************************/
@RestResource(urlMapping='/ContactList/*')
global with sharing class CreateContactFromOrgA {
    @HttpPost
    global static string recievedContact(){
        string jsonContacts = RestContext.request.requestBody.toString();
        List<Lead> deserializedContacts =(list<Lead>) Json.deserialize(jsonContacts,List<lead>.class);
        // Collect Lead Ids to query existing contacts
        Set<String> leadIds = new Set<String>();
        //Loop to collect the lead ids to check existing contacts
        for (Lead lead : deserializedContacts) {
            leadIds.add(lead.Id);
        }
        
        // Query existing contacts based on External Id (Lead Id in this case)
        Map<String, Contact> existingContactsMap = new Map<String, Contact>();
        for (Contact existingContact : [SELECT Id, ExternalLeadId__c, FirstName, LastName,Phone, AccountId, Email,LeadSource,Title 
                                        FROM Contact 
                                        WHERE ExternalLeadId__c IN :leadIds]) {
                                            existingContactsMap.put(existingContact.ExternalLeadId__c, existingContact);
                                        }
        
        // Process each lead received from Org A
        List<Contact> contactsToUpdate = new List<Contact>();
        List<Contact> contactsToInsert = new List<Contact>();
        
        for (Lead leadRecord : deserializedContacts) {
            if (existingContactsMap.get(leadRecord.Id) != null) {
                Contact existingContact = existingContactsMap.get(leadRecord.Id);
                // Update existing contact with lead details if necessary
                Boolean isUpdated = false;
                
                if (existingContact.FirstName != leadRecord.FirstName) {
                    existingContact.FirstName = leadRecord.FirstName;
                    isUpdated = true;
                }
                if (existingContact.LastName != leadRecord.LastName) {
                    existingContact.LastName = leadRecord.LastName;
                    isUpdated = true;
                }
                if (existingContact.Title != leadRecord.Title) {
                    existingContact.Title = leadRecord.Title;
                    isUpdated = true;
                }
                if (existingContact.LeadSource != leadRecord.LeadSource) {
                    existingContact.LeadSource = leadRecord.LeadSource;
                    isUpdated = true;
                }
                if (existingContact.Email != leadRecord.Email) {
                    existingContact.Email = leadRecord.Email;
                    isUpdated = true;
                }
                
                // Perform update only if there are changes
                if (isUpdated) {
                    contactsToUpdate.add(existingContact);
                }
            } else {
                // Insert new contact if Contact not found
                Contact newContact = new Contact(
                    ExternalLeadId__c = leadRecord.Id,
                    FirstName = leadRecord.FirstName,
                    LastName = leadRecord.LastName,
                    Title = leadRecord.Title,
                    Email = leadRecord.Email,
                    LeadSource= leadRecord.LeadSource
                );
                contactsToInsert.add(newContact);
            }
        }
        
        // Perform DML operations by check the access of the user
        if (!contactsToUpdate.isEmpty() && Schema.sObjectType.Contact.isCreateable()) {
            update contactsToUpdate;
        }
        if (!contactsToInsert.isEmpty()&& Schema.sObjectType.Contact.isUpdateable()) {
            insert contactsToInsert;
        }
        
        return 'Records processed successfully';
    }
    
}