/**
 * File:        CaseFormController_Test.cls
 * Date:        Jan 19, 2023
 * Created By:  Cagri Kilic
 * *************************************************************************
 * Description: CaseFormController test class
 * *************************************************************************
 * History:
 * Date:            Modified By:           Description:
 */
@isTest
public with sharing class CaseFormController_Test {
    /**
     * @author Cagri Kilic
     * @date Jan 19, 2023
     * @description  Create test data
     */
    @TestSetup
    private static void setup() {
        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < 5; i++) {
            Case newCase = new Case(
                Brand__c = 'Option 1',
                Origin = 'Web',
                SuppliedEmail = 'example@gmail.com',
                Description = 'Test Class',
                Status = 'New'
            );
            cases.add(newCase);
        }
        insert cases;
    }
    /**
     * @author Cagri Kilic
     * @date Jan 19, 2023
     * @description CaseFormController class's test function
     */
    @isTest
    private static void caseFormControllerTest() {
        Test.startTest();
        List<Case> testCases = CaseFormController.getCases(
            UserInfo.getUserId()
        );
        List<Case_Metadata__mdt> testMetadatas = CaseFormController.getCaseMetadatas();
        Test.stopTest();

        System.assertEquals(
            testMetadatas.size(),
            [
                SELECT COUNT()
                FROM Case_Metadata__mdt
                WHERE Name__c != NULL AND Default_Value__c != NULL
            ]
        );
        System.assertEquals(
            testCases.size(),
            [
                SELECT COUNT()
                FROM Case
                WHERE
                    Brand__c != NULL
                    AND Origin != NULL
                    AND SuppliedEmail != NULL
                    AND Status != NULL
            ]
        );
    }
}
