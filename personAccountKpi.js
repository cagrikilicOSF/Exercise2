/******************************************************************
 * @Name         : getKpiInformations
 * @Description  : KPIs of an Person Account.
 * @Created By   : Cagri Kilic
 * @Created Date : Jan 20, 2023
 * @Modification Log :
 ******************************************************************
 * Version        Developer        Date        Description
 *------------------------------------------------------------
 *
 ******************************************************************/
import { LightningElement, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getTotalOfOrderAmount from "@salesforce/apex/PersonAccountKpiController.getTotalOfOrderAmount";
import getTotalOfOrderAmountLast5Years from "@salesforce/apex/PersonAccountKpiController.getTotalOfOrderAmountLast5Years";
import getAllCases from "@salesforce/apex/PersonAccountKpiController.getAllCases";
import getAllOrders from "@salesforce/apex/PersonAccountKpiController.getAllOrders";
import getAccount from "@salesforce/apex/PersonAccountKpiController.getAccount";
import getAvarageOfOrderAmount from "@salesforce/apex/PersonAccountKpiController.getAvarageOfOrderAmount";
const KPI_ERROR = "An error occurred while retrieving the data of KPI!";
const ERROR_TITLE = "Error!";
const ERROR_VARIANT = "error";
const columns = [
    { label: "YTD", fieldName: "YTD" },
    { label: "YTD - 5", fieldName: "YTD5" },
    { label: "Open Cases", fieldName: "OpenCases" },
    { label: "Total Cases", fieldName: "TotalCases" },
    { label: "Customer Since", fieldName: "CustomerSince", type: "date" },
    { label: "Total Number of Orders", fieldName: "TotalNumberofOrders" },
    { label: "Birthday", fieldName: "Birthday" },
    { label: "Average Order Value", fieldName: "AverageOrderValue" },
];

export default class PersonAccountKpi extends LightningElement {
    @api recordId;
    @track kpiInformations;
    @track isLoading;
    columns = columns;

    /******************************************************************
     * @Name         : connectedCallback
     * @Description  : Runs when the component is opened
     * @Created By   : Cagri Kilic
     * @Created Date : Jan 30, 2023
     
     ******************************************************************/
    connectedCallback() {
        this.handleKpiOfAccount();
    }
    /******************************************************************
	 * @Name         : handleKpiOfAccount
	 * @Description  : Retrieves the Kpi Datas Of Person Account
	 * @Created By   : Cagri Kilic
	 * @Created Date : Jan 30, 2023
     
	 ******************************************************************/
    handleKpiOfAccount() {
        this.isLoading = true;
        this.kpiInformations = [{}];
        getTotalOfOrderAmount({
            accId: this.recordId,
        })
            .then((result) => {
                if (result) {
                    this.kpiInformations[0].YTD = result;
                    return getTotalOfOrderAmountLast5Years({
                        accId: this.recordId,
                    });
                }
                return KPI_ERROR;
            })
            .then((result) => {
                if (result) {
                    this.kpiInformations[0].YTD5 = result;
                    return getAllCases({
                        accId: this.recordId,
                    });
                }
                return KPI_ERROR;
            })
            .then((result) => {
                if (result) {
                    this.kpiInformations[0].TotalCases = result[0];
                    this.kpiInformations[0].OpenCases = result[1];
                    return getAccount({
                        accId: this.recordId,
                    });
                }
                return KPI_ERROR;
            })
            .then((result) => {
                if (result) {
                    this.kpiInformations[0].CustomerSince = result[0];
                    this.kpiInformations[0].Birthday = result[1];
                    return getAllOrders({
                        accId: this.recordId,
                    });
                }
                return KPI_ERROR;
            })
            .then((result) => {
                if (result) {
                    this.kpiInformations[0].TotalNumberofOrders = result;
                    return getAvarageOfOrderAmount({
                        accId: this.recordId,
                    });
                }
                return KPI_ERROR;
            })
            .then((result) => {
                if (result) {
                    this.kpiInformations[0].AverageOrderValue = result;
                }
                return KPI_ERROR;
            })
            .catch((error) => {
                console.log("ERROR : " + JSON.stringify(error));
                this.showToast(ERROR_TITLE, error?.body?.message, ERROR_VARIANT);
            })
            .finally(() => {
                this.isLoading = false;
            });
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
}
