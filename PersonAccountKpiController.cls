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
    private static List<Object> displayDatas;
    /******************************************************************
	 * @Name         : addQueryResultToList
	 * @Description  : Adds query result to list
	 * @Created By   : Cagri Kilic
	 * @Created Date : Jan 20, 2023
     * @Param accId  : Id - Account Id
     * @Param selectField  : String  - Select field
     * @Param additionalWhereConditions  : String  - Additional conditions
     
	 ******************************************************************/
    private static void addQueryResultToList(String selectField, String additionalWhereConditions, Id accId) {
        try {
            String query = 'SELECT ' + selectField + ' FROM Order WHERE AccountId = :accId ' + additionalWhereConditions;
            AggregateResult[] queryResult = Database.query(query);
            if (queryResult[0].get('expr0') != null) {
                displayDatas.add(queryResult[0].get('expr0'));
            } else if (queryResult[0].get('expr0') == null) {
                displayDatas.add((Object) '0');
            }
        } catch (Exception e) {
            System.debug('Error: ' + e);
        }
    }
    /******************************************************************
  	* @Name         : getPersonAccountKpi 
  	* @Description  : Returns list of result of queries
  	* @Created By   : CagriKilic
  	* @Created Date : Jan 20, 2023
    * @Param accId  : Id - Account Id
    * @Return       : List<Object> - Object List
    
  	******************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Object> getPersonAccountKpi(Id accId) {
        try {
            displayDatas = new List<Object>();
            addQueryResultToList('SUM(TotalAmount)', 'AND EffectiveDate = THIS_YEAR', accId);
            addQueryResultToList('SUM(TotalAmount)', 'AND EffectiveDate = LAST_N_YEARS:5', accId);

            Integer count = 0;
            List<Case> allCases = [
                SELECT Id, Status
                FROM Case
                WHERE AccountId = :accId
            ];
            displayDatas.add((Object) allCases.size());
            for (Case c : allCases) {
                if (c.Status != STATUS) {
                    count++;
                }
            }
            displayDatas.add((Object) count);

            AggregateResult[] accInfos = [
                SELECT DAY_ONLY(CreatedDate), PersonBirthdate
                FROM Account
                WHERE Id = :accId
                GROUP BY DAY_ONLY(CreatedDate), PersonBirthdate
            ];
            displayDatas.add(accInfos[0].get('expr0'));

            Integer numberOfOrders = [
                SELECT COUNT()
                FROM Order
                WHERE AccountId = :accId
            ];
            displayDatas.add((Object) numberOfOrders);

            if (accInfos[0].get(PERSON_BIRTHDATE) != null) {
                displayDatas.add(accInfos[0].get(PERSON_BIRTHDATE));
            } else if (accInfos[0].get(PERSON_BIRTHDATE) == null) {
                Object message = 'No information';
                displayDatas.add(message);
            }

            addQueryResultToList('AVG(TotalAmount)', '', accId);
            return displayDatas;
        } catch (Exception e) {
            System.debug('Error: ' + e);
            throw new AuraHandledException(KPI_ERROR);
        }
    }
}
