import { LightningElement, wire, track } from 'lwc';
import getLeads from '@salesforce/apex/LeadController.getLeads';
import syncContacts from '@salesforce/apex/LeadController.syncContacts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LeadListLwc extends LightningElement {
    @track searchKey = '';//To hold the search key
    @track leadSource = ''; // to store the lead source filter value
    @track leads;// To collect the Lead records
    @track error; //to Collect the errors
    @track recordsToDisplay = []; //records to Display

    // Variables for paginator
    @track pageSizeOptions = [5, 10, 25, 50, 75, 100];
    @track totalRecords = 0; // Total number of records
    @track pageSize = 5; // Number of records to be displayed per page
    @track totalPages; // Total number of pages
    @track pageNumber = 1; // Page number

    //Columns to display on the UI
    columns = [
        { label: 'First Name', fieldName: 'FirstName'},
        { label: 'Last Name', fieldName: 'LastName' },
        { label: 'Company', fieldName: 'Company' },
        { label: 'Lead Source', fieldName: 'LeadSource' }
    ];
  //Option to filter the leads
    leadSourceOptions = [
        { label: 'All', value: '' },
        { label: 'Web', value: 'Web' },
        { label: 'Phone Inquiry', value: 'Phone Inquiry' },
        {label:'Partner Referral', value: 'Partner Referral' },
        {label: 'Purchased List', value: 'Purchased List' },
        {label:'Other', value: 'Other'}
    ];
    //Calling the wire method to fetch the lead records
    @wire(getLeads, { searchKey: '$searchKey', leadSource: '$leadSource' })
    wiredLeads(result) {
        if (result.data) {
            this.leads = result.data;
            this.totalRecords = this.leads.length;
            console.log('this.totalRecords'+this.totalRecords);
            this.pageSize = this.pageSizeOptions[0];
            this.updateRecordsToDisplay();
        } else if (result.error) {
            this.error = result.error;
            this.leads = undefined;
            this.recordsToDisplay = [];
        }
    }
    //Logic to handle the search the result by Name(First Name Or Last Name)
    handleSearch(event) {
        this.searchKey = event.target.value;
        this.pageNumber = 1; // Reset page number when search key changes
        this.updateRecordsToDisplay();
    }
    //Logic to Filter the result by Lead source
    handleSourceFilter(event) {
        this.leadSource = event.target.value;
        this.pageNumber = 1; // Reset page number when lead source filter changes
        this.updateRecordsToDisplay();
    }
    //Logic to handle the paginators
    handleRecordsPerPage(event) {
        this.pageSize = event.target.value;
        this.pageNumber = 1; // Reset page number when page size changes
        this.updateRecordsToDisplay();
    }

    previousPage() {
        if (this.pageNumber > 1) {
            this.pageNumber--;
            this.updateRecordsToDisplay();
        }
    }

    nextPage() {
        if (this.pageNumber < this.totalPages) {
            this.pageNumber++;
            this.updateRecordsToDisplay();
        }
    }

    firstPage() {
        this.pageNumber = 1;
        this.updateRecordsToDisplay();
    }

    lastPage() {
        this.pageNumber = this.totalPages;
        this.updateRecordsToDisplay();
    }

    updateRecordsToDisplay() {
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        this.recordsToDisplay = this.leads.slice((this.pageNumber - 1) * this.pageSize, this.pageNumber * this.pageSize);
    }
    //Handling the row changes 
    handleRowSelection(event) {
        this.selectedLeadIds = event.detail.selectedRows.map(row => row.Id);
    }
    //Handle the Sync for creating the records in Org B by calling the syncContacts Method
    handleSync() {
        if (!this.selectedLeadIds || this.selectedLeadIds.length === 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select at least one lead to sync.',
                    variant: 'error'
                })
            );
            return;
        }

        syncContacts({ leadIds: this.selectedLeadIds })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Contacts synchronized successfully',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
}
