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
    private static final String METADATA_QUERY_ERROR = 'An error occurred while retrieving the metadata!';
    private static final String CASE_QUERY_ERROR = 'An error occurred while retrieving the case!';
    private static final Set<String> STATUSES_TO_SKIP = new Set<String>{'Closed'};
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
            throw new AuraHandledException(METADATA_QUERY_ERROR);
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
                WHERE Status != :STATUSES_TO_SKIP AND CreatedById = :userId
            ];
        } catch (Exception e) {
            System.debug('Error: ' + e);
            throw new AuraHandledException(CASE_QUERY_ERROR);
        }
    }
}
