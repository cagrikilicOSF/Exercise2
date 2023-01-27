/******************************************************************
 * @Name         : CaseTriggerHandler
 * @Description  : Methods of Contact Trigger
 * @Created By   : Cagri Kilic
 * @Created Date : Jan 18, 2023
 * @Modification Log :
 ******************************************************************
 * Version        Developer        Date        Description
 *------------------------------------------------------------
 *
 ******************************************************************/
public with sharing class CaseTriggerHandler {
    private static final String RECORD_TYPE_LABEL = 'Person Account';
    private static final Map<String, String> ORIGIN_TYPE = new Map<String, String>{ 'Phone' => 'Option 1', 'Email' => 'Option 2' };
    private static String recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RECORD_TYPE_LABEL).getRecordTypeId();
    /******************************************************************************
     * @Name               : addAccountToCase
     * @Description        : Adds Person Account to Case
     * @Created By         : Cagri Kilic
     * @Created Date       : Jan 18, 2023
     * @Param newCases     : List<Case> - Case list
     *****************************************************************************/
    public static void addAccountToCase(List<Case> newCases) {
        try {
            List<Account> newAccounts = new List<Account>();
            Map<String, Map<String, Id>> oldCasesMap = new Map<String, Map<String, Id>>();
            List<Case> casesWithoutAccount = new List<Case>();
            Set<String> newCaseEmails = new Set<String>();
            for (Case nc : newCases) {
                newCaseEmails.add(nc.SuppliedEmail);
            }
            List<Case> oldCases = [
                SELECT SuppliedEmail, Brand__c, Id, AccountId
                FROM Case
                WHERE SuppliedEmail = :newCaseEmails AND Brand__c != NULL
            ];
            for (Case c : oldCases) {
                if (oldCasesMap.containsKey(c.SuppliedEmail)) {
                    oldCasesMap.get(c.SuppliedEmail).put(c.Brand__c, c.AccountId);
                } else {
                    oldCasesMap.put(c.SuppliedEmail, new Map<String, Id>{ c.Brand__c => c.AccountId });
                }
            }
            for (Case nCase : newCases) {
                if (ORIGIN_TYPE.containsKey(nCase.Origin)) {
                    nCase.Brand__c = ORIGIN_TYPE.get(nCase.Origin);
                }
                if (!oldCasesMap.containsKey(nCase.SuppliedEmail)) {
                    newAccounts.add(createPersonAccount(nCase));
                    oldCasesMap.put(nCase.SuppliedEmail, new Map<String, Id>{ nCase.Brand__c => null });
                    casesWithoutAccount.add(nCase);
                } else {
                    if (!oldCasesMap.get(nCase.SuppliedEmail).containsKey(nCase.Brand__c)) {
                        newAccounts.add(createPersonAccount(nCase));
                        oldCasesMap.put(nCase.SuppliedEmail, new Map<String, Id>{ nCase.Brand__c => null });
                        casesWithoutAccount.add(nCase);
                    } else {
                        Id accId = oldCasesMap.get(nCase.SuppliedEmail).get(nCase.Brand__c);
                        if (accId != null) {
                            nCase.AccountId = accId;
                        } else {
                            casesWithoutAccount.add(nCase);
                        }
                    }
                }
            }
            if (newAccounts.size() > 0) {
                insert newAccounts;
                for (Account acc : newAccounts) {
                    for (Case c : casesWithoutAccount) {
                        if (c.AccountId == null && acc.PersonEmail == c.SuppliedEmail && acc.Brand__c == c.Brand__c) {
                            c.AccountId = acc.Id;
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Error: ' + e);
        }
    }
    /******************************************************************
     * @Name          : createPersonAccount
     * @Description   : Retrieves the New Person Account
     * @Created By    : Cagri Kilic
     * @Created Date  : Jan 18, 2023
     * @Param newCase : Case - Related Case
     * @Return        : Account - New Account
     ******************************************************************/
    private static Account createPersonAccount(Case newCase) {
        Account acc = new Account(
            Salutation = 'Mr.',
            FirstName = 'Account' + Integer.valueof((Math.random() * 1000)),
            LastName = 'LastName' + Integer.valueof((Math.random() * 1000)),
            RecordTypeId = recordTypeId,
            SLA__c = 'Gold',
            SLAExpirationDate__c = Date.Today(),
            SLASerialNumber__c = '1234567890',
            ShippingCity = 'Monaco',
            PersonEmail = newCase.SuppliedEmail,
            Brand__c = newCase.Brand__c
        );
        return acc;
    }
}
