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
	 * @Name         : getTotalOfOrderAmount
	 * @Description  : Gets total of order amount
	 * @Created By   : Cagri Kilic
	 * @Created Date : Jan 30, 2023
     * @Param accId  : Id - Account Id
     * @Return       : Object - Total of order amount
     
	 ******************************************************************/
    @AuraEnabled(cacheable=true)
    public static Object getTotalOfOrderAmount(Id accId) {
        try {
            AggregateResult[] totalOfOrderAmount = [
                SELECT SUM(TotalAmount)
                FROM Order
                WHERE AccountId = :accId AND EffectiveDate = THIS_YEAR
            ];
            if (totalOfOrderAmount[0].get('expr0') != null) {
                return totalOfOrderAmount[0].get('expr0');
            } else {
                return (Object) '0';
            }
        } catch (Exception e) {
            System.debug('Error: ' + e);
            throw new AuraHandledException(KPI_ERROR);
        }
    }
    /******************************************************************
	 * @Name         : getTotalOfOrderAmountLast5Years
	 * @Description  : Gets total of order amount last 5 years
	 * @Created By   : Cagri Kilic
	 * @Created Date : Jan 30, 2023
     * @Param accId  : Id - Account Id
     * @Return       : Object - Total of order amount last 5 years
     
	 ******************************************************************/
    @AuraEnabled(cacheable=true)
    public static Object getTotalOfOrderAmountLast5Years(Id accId) {
        try {
            AggregateResult[] totalOfOrderAmountLast5Years = [
                SELECT SUM(TotalAmount)
                FROM Order
                WHERE AccountId = :accId AND EffectiveDate = LAST_N_YEARS:5
            ];
            if (totalOfOrderAmountLast5Years[0].get('expr0') != null) {
                return totalOfOrderAmountLast5Years[0].get('expr0');
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
    /******************************************************************
	 * @Name         : getAllOrders
	 * @Description  : Gets orders
	 * @Created By   : Cagri Kilic
	 * @Created Date : Jan 30, 2023
     * @Param accId  : Id - Account Id
     * @Return       : Object - Number of total orders
     
	 ******************************************************************/
    @AuraEnabled(cacheable=true)
    public static Object getAllOrders(Id accId) {
        try {
            Integer numberOfOrders = [
                SELECT COUNT()
                FROM Order
                WHERE AccountId = :accId
            ];
            if (numberOfOrders == 0) {
                return (Object) '0';
            }
            return (Object) numberOfOrders;
        } catch (Exception e) {
            System.debug('Error: ' + e);
            throw new AuraHandledException(KPI_ERROR);
        }
    }
    /******************************************************************
	 * @Name         : getAvarageOfOrderAmount
	 * @Description  : Gets avarage of order amount
	 * @Created By   : Cagri Kilic
	 * @Created Date : Jan 30, 2023
     * @Param accId  : Id - Account Id
     * @Return       : Object - Avarage of order amount
     
	 ******************************************************************/
    @AuraEnabled(cacheable=true)
    public static Object getAvarageOfOrderAmount(Id accId) {
        try {
            AggregateResult[] averageOfOrderAmount = [
                SELECT AVG(TotalAmount)
                FROM Order
                WHERE AccountId = :accId
            ];
            if (averageOfOrderAmount[0].get('expr0') != null) {
                return averageOfOrderAmount[0].get('expr0');
            } else {
                return (Object) '0';
            }
        } catch (Exception e) {
            System.debug('Error: ' + e);
            throw new AuraHandledException(KPI_ERROR);
        }
    }
}
