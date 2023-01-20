/**
 * File:        CaseTrigger_Test.cls
 * Date:        Jan 19, 2023
 * Created By:  Cagri Kilic
 * *************************************************************************
 * Description: CaseTrigger test class
 * *************************************************************************
 * History:
 * Date:            Modified By:           Description:
 */
@isTest
public with sharing class CaseTrigger_Test {
    /**
     * @author Cagri Kilic
     * @date Jan 19, 2023
     * @description  init test data
     */
    private static List<Case> init(String actionToInit) {
        List<Case> caseList = new List<Case>();
        switch on actionToInit {
            when 'webToCase' {
                Case testOldCase = new Case(
                    Brand__c = 'Option 1',
                    Origin = 'Web',
                    Status = 'New',
                    SuppliedEmail = 'example2@gmail.com'
                );
                insert testOldCase;
                for (Integer i = 0; i < 4; i++) {
                    String brand = 'Option 2';
                    String email = 'example@gmail.com';
                    if (i < 2) {
                        brand = 'Option 1';
                    }
                    if (i == 3) {
                        brand = 'Option 2';
                        email = 'example2@gmail.com';
                    }
                    Case testCase = new Case(
                        Brand__c = brand,
                        Origin = 'Web',
                        Status = 'New',
                        SuppliedEmail = email
                    );
                    caseList.add(testCase);
                }
                return caseList;
            }
            when 'emailToCase' {
                for (Integer i = 0; i < 2; i++) {
                    String email = 'cagrisalesforce@gmail.com';
                    if (i > 0) {
                        email = 'cagrisalesforce2@gmail.com';
                    }
                    Case testCase = new Case(
                        Origin = 'Email',
                        Status = 'New',
                        SuppliedEmail = email
                    );
                    caseList.add(testCase);
                }
                return caseList;
            }
        }
        return new List<Case>();
    }
    /**
     * @author Cagri Kilic
     * @date Jan 19, 2023
     * @description Web-to-case test function
     */
    @isTest
    private static void testWebToCase() {
        List<Case> testCases = init('webToCase');
        Test.startTest();
        Database.SaveResult[] saveResults = Database.insert(testCases, false);
        Test.stopTest();
        for (Integer i = 0; i < saveResults.size(); i++) {
            System.assert(saveResults[i].isSuccess());
        }
        System.assertEquals(
            4,
            [
                SELECT COUNT()
                FROM Account
                WHERE PersonEmail != NULL AND RecordTypeId != NULL
            ]
        );
        System.assertEquals(
            saveResults.size() + 1,
            [
                SELECT COUNT()
                FROM Case
            ]
        );
    }
    /**
     * @author Cagri Kilic
     * @date Jan 19, 2023
     * @description Email-to-case test function
     */
    @isTest
    private static void testEmailToCase() {
        List<Case> testCases = init('emailToCase');
        Test.startTest();
        Database.SaveResult[] saveResults = Database.insert(testCases, false);
        Test.stopTest();
        for (Integer i = 0; i < saveResults.size(); i++) {
            System.assert(saveResults[i].isSuccess());
        }
        System.assertEquals(
            saveResults.size(),
            [
                SELECT COUNT()
                FROM Account
                WHERE PersonEmail != NULL AND RecordTypeId != NULL
            ]
        );
        System.assertEquals(
            saveResults.size(),
            [
                SELECT COUNT()
                FROM Case
            ]
        );
    }
}
