/******************************************************************
 * @Name         : PersonAccountKpiController
 * @Description  : Controller Of PersonAccountKpi
 * @Created By   : Cagri Kilic
 * @Created Date : Jan 20, 2023
 * @Modification Log :
 ******************************************************************
 * Version        Developer        Date        Description
 *------------------------------------------------------------
 *
 ******************************************************************/
public with sharing class PersonAccountKpiController {
    private static final String KPI_ERROR = 'An error occurred while retrieving the data of KPI!';
    private static final String STATUS = 'Closed';
    private static final String PERSON_BIRTHDATE = 'PersonBirthdate';
    /******************************************************************
	 * @Name         : getOrderData
	 * @Description  : Gets data of order 
	 * @Created By   : Cagri Kilic
	 * @Created Date : Jan 30, 2023
     * @Param accId  : Id - Account Id
     * @Param selectField  : String  - Select field
     * @Param additionalWhereConditions  : String  - Additional conditions
     * @Return       : Object - Query result
     
	 ******************************************************************/
    @AuraEnabled(cacheable=true)
    public static Object getOrderData(String selectField, String additionalWhereConditions, Id accId) {
        try {
            List<Object> orderData = new List<Object>();
            String query = 'SELECT ' + selectField + ' FROM Order WHERE AccountId = :accId ' + additionalWhereConditions;
            AggregateResult[] queryResult = Database.query(query);
            if (queryResult[0].get('expr0') != null && queryResult[0].get('expr0') != 0) {
                return queryResult[0].get('expr0');
            } else {
                return (Object) '0';
            }
        } catch (Exception e) {
            System.debug('Error: ' + e);
            throw new AuraHandledException(KPI_ERROR);
        }
    }
    /******************************************************************
	 * @Name         : getAllCases
	 * @Description  : Gets cases
	 * @Created By   : Cagri Kilic
	 * @Created Date : Jan 30, 2023
     * @Param accId  : Id - Account Id
     * @Return       : List<Object> - All case and total open cases
     
	 ******************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Object> getAllCases(Id accId) {
        try {
            List<Object> caseData = new List<Object>();
            Integer count = 0;
            List<Case> allCases = [
                SELECT Id, Status
                FROM Case
                WHERE AccountId = :accId
            ];
            caseData.add((Object) allCases.size());
            for (Case c : allCases) {
                if (c.Status != STATUS) {
                    count++;
                }
            }
            caseData.add((Object) count);
            return caseData;
        } catch (Exception e) {
            System.debug('Error: ' + e);
            throw new AuraHandledException(KPI_ERROR);
        }
    }
    /**************************************************************************
	 * @Name         : getAccount
	 * @Description  : Gets related account's data
	 * @Created By   : Cagri Kilic
	 * @Created Date : Jan 30, 2023
     * @Param accId  : Id - Account Id
     * @Return       : List<Object> - Account's CreatedData and PersonBirthdate
     
	 **************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Object> getAccount(Id accId) {
        try {
            List<Object> accData = new List<Object>();
            AggregateResult[] accInfos = [
                SELECT DAY_ONLY(CreatedDate), PersonBirthdate
                FROM Account
                WHERE Id = :accId
                GROUP BY DAY_ONLY(CreatedDate), PersonBirthdate
            ];
            accData.add(accInfos[0].get('expr0'));
            if (accInfos[0].get(PERSON_BIRTHDATE) != null) {
                accData.add(accInfos[0].get(PERSON_BIRTHDATE));
            } else if (accInfos[0].get(PERSON_BIRTHDATE) == null) {
                Object message = 'No information';
                accData.add(message);
            }
            return accData;
        } catch (Exception e) {
            System.debug('Error: ' + e);
            throw new AuraHandledException(KPI_ERROR);
        }
    }
}
