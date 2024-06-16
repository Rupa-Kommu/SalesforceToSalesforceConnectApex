/********************************************
* Description: Script to create 1000 leads
* Added By:Rupa | Created Date: 6/16/2024
********************************************/
public class LeadCreationScript {
    
    //Method to creat leads with source as Web
    public static void createLeads() {
        try {
            // Check if the user has permission to create leads
            if (!Lead.sObjectType.getDescribe().isCreateable()) {
                throw new  AuraHandledException('Insufficient access rights to create leads.');
            }
            
            List<Lead> leads = new List<Lead>();
            
            for (Integer i = 0; i < 1000; i++) {
                Lead l = new Lead(
                    FirstName = 'Test',
                    LastName = 'Lead' + i,
                    Company = 'Test Company' + i,
                    Title = 'Tester'+i,
                    Email = 'test'+i+'@gmail.com',
                    LeadSource = 'Web'
                );
                
                leads.add(l);
            }
            
            // Use Database.insert for better error handling
            List<Database.SaveResult> results = Database.insert(leads, false);
            
            // Check results for errors
            for (Database.SaveResult result : results) {
                if (!result.isSuccess()) {
                    List<String> errorMessages = new List<String>();
                    for (Database.Error error : result.getErrors()) {
                        errorMessages.add(error.getStatusCode() + ' - ' + error.getMessage());
                    }
                }
            }
            
        } catch (Exception e) {
            throw e;
        }
    }
}
