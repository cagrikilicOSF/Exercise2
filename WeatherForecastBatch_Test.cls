/**
 * File:        WeatherForecastBatch_Test.cls
 * Date:        Jan 17, 2023
 * Created By:  Cagri Kilic
 * *************************************************************************
 * Description: WeatherForecastBatch test class
 * *************************************************************************
 * History:
 * Date:            Modified By:           Description:
 */
@isTest
public with sharing class WeatherForecastBatch_Test {
    private static final String ENDPOINT_URL = 'https://api.openweathermap.org/data/2.5/weather?q=';
    private static final String ENDPOINT_URL_EXTENSION = '&units=metric&appid=3e6dc3c440ec8593b831072f36667c5d';
    /**
     * @author Cagri Kilic
     * @date Jan 17, 2023
     * @description  init test data
     */
    private static void init() {
        List<Account> accounts = new List<Account>();
        // insert 10 accounts
        for (Integer i = 0; i < 10; i++) {
            accounts.add(
                new Account(name = 'Account ' + i, ShippingCity = 'London')
            );
        }
        insert accounts;
        WeatherEndpoint__c customSettings = WeatherEndpoint__c.getInstance(
            UserInfo.getUserId()
        );
        customSettings.Endpoint_URL_Part1__c = ENDPOINT_URL;
        customSettings.Endpoint_URL_Part2__c = ENDPOINT_URL_EXTENSION;
        upsert customSettings;
    }
    /**
     * @author Cagri Kilic
     * @date Jan 17, 2023
     * @description WeatherForecastBatch class's positive test function
     */
    @isTest
    private static void positiveTest() {
        init();
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new WeatherForecastBatchMock());
        WeatherForecastBatch wfb = new WeatherForecastBatch();
        Id batchId = Database.executeBatch(wfb);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        System.assertEquals(
            10,
            [
                SELECT COUNT()
                FROM Account
                WHERE
                    Temperature__c != NULL
                    AND Humidity__c != NULL
                    AND Description__c != NULL
                    AND Feels_Like__c != NULL
                    AND Icon_Link__c != NULL
            ]
        );
    }
    /**
     * @author Cagri Kilic
     * @date Jan 17, 2023
     * @description WeatherForecastBatch class's negative test function
     */
    @isTest
    private static void negativeTest() {
        init();
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new WeatherForecastBatchNegativeMock());
        WeatherForecastBatch wfb = new WeatherForecastBatch();
        Id batchId = Database.executeBatch(wfb);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        System.assertEquals(
            10,
            [
                SELECT COUNT()
                FROM Account
                WHERE
                    Temperature__c = NULL
                    AND Humidity__c = NULL
                    AND Description__c = NULL
                    AND Feels_Like__c = NULL
                    AND Icon_Link__c = NULL
            ]
        );
    }
}
