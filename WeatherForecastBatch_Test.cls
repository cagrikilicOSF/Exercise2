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
    /**
     * @author Cagri Kilic
     * @date Jan 17, 2023
     * @description  create test data
     */
    @TestSetup
    private static void setup() {
        List<Account> accounts = new List<Account>();
        // insert 10 accounts
        for (Integer i = 0; i < 10; i++) {
            accounts.add(
                new Account(name = 'Account ' + i, ShippingCity = 'London')
            );
        }
        insert accounts;
        List<openweatherendpoint__c> cSettings = new List<openweatherendpoint__c>();
        for (Integer i = 0; i < 2; i++) {
            openweatherendpoint__c customSetting = new openweatherendpoint__c();
            if (i == 1) {
                customSetting.Name = 'endpointpart1';
                customSetting.Endpoint_URL__c = 'https://api.openweathermap.org/data/2.5/weather?q=';
            } else {
                customSetting.Name = 'endpointpart2';
                customSetting.Endpoint_URL__c = '&units=metric&appid=3e6dc3c440ec8593b831072f36667c5d';
            }
            cSettings.add(customSetting);
        }
        insert cSettings;
    }
    /**
     * @author Cagri Kilic
     * @date Jan 17, 2023
     * @description WeatherForecastBatch class's positive test function
     */
    @isTest
    private static void positiveTest() {
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
