/******************************************************************
 * @Name         : CaseForm
 * @Description  : Case Form
 * @Created By   : Cagri Kilic
 * @Created Date : Jan 18, 2023
 * @Modification Log :
 ******************************************************************
 * Version        Developer        Date        Description
 *------------------------------------------------------------
 *
 ******************************************************************/
import { LightningElement, wire, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import ACCOUNT_OBJECT from "@salesforce/schema/Case";
import getCaseMetadatas from "@salesforce/apex/CaseFormController.getCaseMetadatas";
import getCases from "@salesforce/apex/CaseFormController.getCases";
import Id from "@salesforce/user/Id";
const columns = [
    { label: "Created Date", fieldName: "CreatedDate", type: "date" },
    { label: "Case Origin", fieldName: "Origin" },
    { label: "Brand", fieldName: "Brand__c" },
    { label: "Web Email", fieldName: "SuppliedEmail" },
    { label: "AccountId", fieldName: "AccountId" },
    { label: "Description", fieldName: "Description" },
    { label: "Status", fieldName: "Status" },
];
export default class CaseForm extends LightningElement {
    objectApiName = ACCOUNT_OBJECT;
    @track caseMetadatas;
    @track caseDatas;
    @track currentUserId = Id;
    error;
    columns = columns;
    /******************************************************************
     * @Name         : wiredCaseMetadatas
     * @Description  : Retrieves the metadatas
     * @Created By   : Cagri Kilic
     * @Created Date : Jan 18, 2023
     * @Param error  : Keeps the error
     * @Param data   : Keeps the metadatas
     
     ******************************************************************/
    @wire(getCaseMetadatas)
    wiredCaseMetadatas({ error, data }) {
        if (data) {
            this.caseMetadatas = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.caseMetadatas = undefined;
        }
    }
    /******************************************************************
     * @Name         : wiredCaseDatas
     * @Description  : Retrieves the user's cases
     * @Created By   : Cagri Kilic
     * @Created Date : Jan 18, 2023
     * @Param error  : Keeps the error
     * @Param data   : Keeps the user's cases
     * @Param currentUserId   : Keeps the user's id
     
     ******************************************************************/
    @wire(getCases, { userId: "$currentUserId" })
    wiredCaseDatas({ error, data }) {
        if (data) {
            this.caseDatas = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.caseDatas = undefined;
        }
    }
    /******************************************************************
     * @Name         : handleSuccess
     * @Description  : Returns the success status of the event
     * @Created By   : Cagri Kilic
     * @Created Date : Jan 18, 2023
     * @Param event  : Detail of the process
     
     ******************************************************************/
    handleSuccess(event) {
        if (event.detail.id != null) {
            const toastEvent = new ShowToastEvent({
                title: "Case created",
                message: "Record ID: " + event.detail.id,
                variant: "success",
            });
            this.dispatchEvent(toastEvent);
        } else if (event.detail.id == null) {
            const toastEvent = new ShowToastEvent({
                title: "Error!",
                message: "An error occurred while creating the case!",
                variant: "error",
            });
            this.dispatchEvent(toastEvent);
        }
    }
    /******************************************************************
     * @Name         : handleReset
     * @Description  : Resets the case form's datas
     * @Created By   : Cagri Kilic
     * @Created Date : Jan 18, 2023
     
     ******************************************************************/
    handleReset() {
        const inputFields = this.template.querySelectorAll(
            "lightning-input-field"
        );
        if (inputFields) {
            inputFields.forEach((field) => {
                if (field.name !== "origin") {
                    field.reset();
                }
            });
        }
    }
}
