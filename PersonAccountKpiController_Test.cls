/**
 * File:        PersonAccountKpiController_Test.cls
 * Date:        Jan 20, 2023
 * Created By:  Cagri Kilic
 * *************************************************************************
 * Description: PersonAccountKpiController test class
 * *************************************************************************
 * History:
 * Date:            Modified By:           Description:
 */
@isTest
public with sharing class PersonAccountKpiController_Test {
    private static final String RECORD_TYPE_LABEL = 'Person Account';
    private static String recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RECORD_TYPE_LABEL).getRecordTypeId();
    /**
     * @author Cagri Kilic
     * @date Jan 20, 2023
     * @description  init test data
     */
    static void init() {
        Account acc = new Account(
            Salutation = 'Mr.',
            FirstName = 'Account' + Integer.valueof((Math.random() * 1000)),
            LastName = 'LastName' + Integer.valueof((Math.random() * 1000)),
            RecordTypeId = recordTypeId,
            SLA__c = 'Gold',
            SLAExpirationDate__c = Date.Today(),
            SLASerialNumber__c = '1234567890',
            PersonBirthdate = Date.Today().addYears(-15)
        );
        insert acc;

        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = true);
        update standardPricebook;
        standardPricebook = [
            SELECT IsStandard
            FROM Pricebook2
            WHERE Id = :standardPricebook.Id
        ];
        Product2 p = new Product2(Name = 'My Product', IsActive = true);
        insert p;
        PricebookEntry pbe = new PricebookEntry(UnitPrice = 2000, Product2Id = p.Id, Pricebook2Id = standardPricebook.Id, IsActive = true);
        insert pbe;

        Id accId = acc.Id;
        List<Order> orders = new List<Order>();
        List<Case> cases = new List<Case>();
        Date testDate;
        for (Integer i = 0; i < 5; i++) {
            if (Math.mod(i, 2) == 0) {
                testDate = Date.today();
            } else if (Math.mod(i, 2) != 0) {
                testDate = Date.today().addYears(-2);
            }
            Order testOrder = new Order(AccountId = accId, EffectiveDate = testDate, Status = 'Draft', Pricebook2Id = standardPricebook.Id);
            orders.add(testOrder);

            Case testCase = new Case(AccountId = accId, Status = 'New');
            cases.add(testCase);
        }
        insert orders;
        insert cases;

        Id ordId = [SELECT Id FROM Order LIMIT 1].Id;
        OrderItem testItem = new OrderItem(OrderId = ordId, Product2Id = p.Id, Quantity = 2, ListPrice = 2000, UnitPrice = 3000, PricebookEntryId = pbe.id);
        insert testItem;
    }
    /**
     * @author Cagri Kilic
     * @date Jan 20, 2023
     * @description PersonAccountKpiController class's test function
     */
    @isTest
    static void personAccountKpiControllerTest() {
        init();
        List<List<Object>> testDataArr = new List<List<Object>>();
        List<Object> testData = new List<Object>();
        Test.startTest();
        List<Account> acc = [
            SELECT Id
            FROM Account
            ORDER BY CreatedDate ASC
            LIMIT 2
        ];
        for (Account a : acc) {
            List<Object> allCases = PersonAccountKpiController.getAllCases(a.Id);
            Object totalOfOrderAmount = PersonAccountKpiController.getTotalOfOrderAmount(a.Id);
            Object totalOfOrderAmountLast5Years = PersonAccountKpiController.getTotalOfOrderAmountLast5Years(a.Id);
            List<Object> accountData = PersonAccountKpiController.getAccount(a.Id);
            Object allOrders = PersonAccountKpiController.getAllOrders(a.Id);
            Object avarageOfOrderAmount = PersonAccountKpiController.getAvarageOfOrderAmount(a.Id);
            testDataArr.add(accountData);
            testDataArr.add(allCases);
            testData.add(totalOfOrderAmount);
            testData.add(totalOfOrderAmountLast5Years);
            testData.add(allOrders);
            testData.add(avarageOfOrderAmount);
        }
        Test.stopTest();
        for (Integer i = 0; i < testData.size(); i++) {
            if (i < testDataArr.size()) {
                System.assertEquals(2, testDataArr.get(i).size());
            }
            System.assert(testData.get(i) != null);
        }
    }
}
