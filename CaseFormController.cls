/******************************************************************
 * @Name         : CaseFormController
 * @Description  : Controller Of CaseForm
 * @Created By   : Cagri Kilic
 * @Created Date : Jan 18, 2023
 * @Modification Log :
 ******************************************************************
 * Version        Developer        Date        Description
 *------------------------------------------------------------
 *
 ******************************************************************/
public with sharing class CaseFormController {
    /******************************************************************
	 * @Name         : getCaseMetadatas
	 * @Description  : Retrieves the metadatas
	 * @Created By   : Cagri Kilic
	 * @Created Date : Jan 18, 2023
	 * @Return       : List<Case_Metadata__mdt> - Metadata List

	 ******************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Case_Metadata__mdt> getCaseMetadatas() {
        try {
            return [
                SELECT Name__c, Default_Value__c
                FROM Case_Metadata__mdt
            ];
        } catch (Exception e) {
            System.debug('Error: ' + e);
            return new List<Case_Metadata__mdt>();
        }
    }
    /******************************************************************
	 * @Name         : getCases
	 * @Description  : Constructor of the class
	 * @Created By   : CagriKilic
	 * @Created Date : Jan 18, 2023
	 * @Param userId : Id - User id
	 * @Return       : List<Case> - Related Case List
	 
	 ******************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Case> getCases(Id userId) {
        try {
            return [
                SELECT
                    Brand__c,
                    Origin,
                    SuppliedEmail,
                    CreatedDate,
                    AccountId,
                    Description,
                    Status
                FROM Case
                WHERE Status != 'Closed' AND CreatedById = :userId
            ];
        } catch (Exception e) {
            System.debug('Error: ' + e);
            return new List<Case>();
        }
    }
}
