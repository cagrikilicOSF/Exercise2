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
const SUCCESS_TITLE = "Case Created";
const SUCCESS_MESSAGE = "Record ID";
const SUCCESS_VARIANT = "success";
const ERROR_TITLE = "Error!";
const ERROR_MESSAGE = "An error occurred while creating the case!";
const ERROR_VARIANT = "error";
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
        } else if (error) {
            this.showToast(ERROR_TITLE, error?.body?.message, ERROR_VARIANT);
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
        } else if (error) {
            this.showToast(ERROR_TITLE, error?.body?.message, ERROR_VARIANT);
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
            this.showToast(SUCCESS_TITLE, SUCCESS_MESSAGE, SUCCESS_VARIANT);
        } else if (event.detail.id == null) {
            this.showToast(ERROR_TITLE, ERROR_MESSAGE, ERROR_VARIANT);
        }
    }
    /******************************************************************
     * @Name              : showToast
     * @Description       : Sets the success status of the event
     * @Created By        : Cagri Kilic
     * @Created Date      : Jan 25, 2023
     * @Param theTitle    : Title of the message
     * @Param theMessage  : Content of the message
     * @Param theVariant  : Variant of the message

     ******************************************************************/
    showToast(theTitle, theMessage, theVariant) {
        const toastEvent = new ShowToastEvent({
            title: theTitle,
            message: theMessage,
            variant: theVariant,
        });
        this.dispatchEvent(toastEvent);
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
