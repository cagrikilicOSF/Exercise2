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
    private static final String CASE_TYPE = 'EmailToCase';
    private static final String BRAND_TYPE_1 = 'Option 1';
    private static final String BRAND_TYPE_2 = 'Option 2';
    private static final String ORIGIN_TYPE_1 = 'Web';
    private static final String ORIGIN_TYPE_2 = 'Email';
    private static final String EMAIL_ADDRESS_EXTENSION = '@gmail.com';
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
            List<EmailServicesAddress> emailAddresses = [
                SELECT LocalPart
                FROM EmailServicesAddress
                WHERE Function.FunctionName = :CASE_TYPE AND IsActive = TRUE
            ];
            Map<String, List<String>> oldCasesMap = new Map<String, List<String>>();
            List<Case> casesWithoutAccount = new List<Case>();
            List<Case> oldCases = [
                SELECT SuppliedEmail, Brand__c, Id, AccountId
                FROM Case
                WHERE SuppliedEmail != NULL
            ];
            for (Case c : oldCases) {
                if (oldCasesMap.containsKey(c.SuppliedEmail)) {
                    oldCasesMap.get(c.SuppliedEmail).add(c.Brand__c);
                    oldCasesMap.get(c.SuppliedEmail).add(c.AccountId);
                } else {
                    oldCasesMap.put(c.SuppliedEmail, new List<String>{ c.Brand__c, c.AccountId });
                }
            }
            for (Case nCase : newCases) {
                if (nCase.Origin == ORIGIN_TYPE_2) {
                    // for the email-to-case
                    if (nCase.SuppliedEmail == emailAddresses.get(0).LocalPart + EMAIL_ADDRESS_EXTENSION) {
                        nCase.Brand__c = BRAND_TYPE_1;
                    } else if (nCase.SuppliedEmail == emailAddresses.get(1).LocalPart + EMAIL_ADDRESS_EXTENSION) {
                        nCase.Brand__c = BRAND_TYPE_2;
                    }
                } else if (nCase.Origin == ORIGIN_TYPE_1) {
                    // for the web-to-case
                    if (!oldCasesMap.containsKey(nCase.SuppliedEmail)) {
                        newAccounts.add(createPersonAccount(nCase));
                        oldCasesMap.put(nCase.SuppliedEmail, new List<String>{ nCase.Brand__c, null });
                        casesWithoutAccount.add(nCase);
                    } else {
                        if (!oldCasesMap.get(nCase.SuppliedEmail).contains(nCase.Brand__c)) {
                            newAccounts.add(createPersonAccount(nCase));
                            oldCasesMap.put(nCase.SuppliedEmail, new List<String>{ nCase.Brand__c, null });
                            casesWithoutAccount.add(nCase);
                        } else {
                            Integer indexOfAccId = oldCasesMap.get(nCase.SuppliedEmail).indexOf(nCase.Brand__c) + 1;
                            if (oldCasesMap.get(nCase.SuppliedEmail).get(indexOfAccId) != null) {
                                nCase.AccountId = oldCasesMap.get(nCase.SuppliedEmail).get(indexOfAccId);
                            } else {
                                casesWithoutAccount.add(nCase);
                            }
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
