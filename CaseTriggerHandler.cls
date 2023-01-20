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
                // for the email-to-case
                if (nCase.SuppliedEmail == 'cagrisalesforce@gmail.com') {
                    nCase.Brand__c = 'Option 1';
                } else if (nCase.SuppliedEmail == 'cagrisalesforce2@gmail.com') {
                    nCase.Brand__c = 'Option 2';
                }

                if (!oldCasesMap.containsKey(nCase.SuppliedEmail)) {
                    newAccounts.add(createPersonAccount(nCase));
                    oldCasesMap.put(nCase.SuppliedEmail, new List<String>{ nCase.Brand__c, 'Empty' });
                    casesWithoutAccount.add(nCase);
                } else {
                    if (!oldCasesMap.get(nCase.SuppliedEmail).contains(nCase.Brand__c)) {
                        newAccounts.add(createPersonAccount(nCase));
                        oldCasesMap.put(nCase.SuppliedEmail, new List<String>{ nCase.Brand__c, 'Empty' });
                        casesWithoutAccount.add(nCase);
                    } else {
                        Integer indexOfAccId = oldCasesMap.get(nCase.SuppliedEmail).indexOf(nCase.Brand__c) + 1;
                        if (oldCasesMap.get(nCase.SuppliedEmail).get(indexOfAccId) != 'Empty') {
                            nCase.AccountId = oldCasesMap.get(nCase.SuppliedEmail).get(indexOfAccId);
                        }
                        else{
                            casesWithoutAccount.add(nCase);
                        }
                    }
                }
            }
            insert newAccounts;
            for (Account acc : newAccounts) {
                for (Case c : casesWithoutAccount) {
                    if (c.AccountId == null && acc.PersonEmail == c.SuppliedEmail && acc.Brand__c == c.Brand__c) {
                        c.AccountId = acc.Id;
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
            RecordTypeId = '0128d0000005iUnAAI',
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
