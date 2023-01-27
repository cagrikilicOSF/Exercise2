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
import { LightningElement, wire, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getKpiInformations from "@salesforce/apex/PersonAccountKpiController.getPersonAccountKpi";
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
    error;
    columns = columns;

    /******************************************************************
     * @Name         : wiredKpiDatas
     * @Description  : Retrieves the Kpi Datas Of Person Account
     * @Created By   : Cagri Kilic
     * @Created Date : Jan 20, 2023
     * @Param error  : Keeps the error
     * @Param data   : Keeps the kpi datas
     
     ******************************************************************/
    @wire(getKpiInformations, { accId: "$recordId" })
    wiredKpiDatas({ error, data }) {
        console.log(data);
        if (data) {
            this.kpiInformations = [
                {
                    YTD: data[0],
                    YTD5: data[1],
                    OpenCases: data[3],
                    TotalCases: data[2],
                    CustomerSince: data[4],
                    TotalNumberofOrders: data[5],
                    Birthday: data[6],
                    AverageOrderValue: data[7],
                },
            ];
        } else if (error) {
            this.showToast(ERROR_TITLE, error?.body?.message, ERROR_VARIANT);
            this.kpiInformations = undefined;
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
}
