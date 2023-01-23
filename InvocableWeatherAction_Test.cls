/**
 * File:        InvocableWeatherAction_Test.cls
 * Date:        Jan 17, 2023
 * Created By:  Cagri Kilic
 * *************************************************************************
 * Description: InvocableWeatherAction test class
 * *************************************************************************
 * History:
 * Date:            Modified By:           Description:
 */
@isTest
public with sharing class InvocableWeatherAction_Test {
    private static final String ENDPOINT_URL = 'https://api.openweathermap.org/data/2.5/weather?q=';
    private static final String ENDPOINT_URL_EXTENSION = '&units=metric&appid=3e6dc3c440ec8593b831072f36667c5d';
    private static final String TEST_SHIPPING_CITY = 'London';
    private static List<InvocableWeatherAction.Request> liw;
    private static Account acc;
    /**
    /**
     * @author Cagri Kilic
     * @date Jan 17, 2023
     * @description  init test data
     */
    private static void init() {
        acc = new Account(name = 'Account ', ShippingCity = 'Lawrence');
        insert acc;
        WeatherEndpoint__c customSettings = WeatherEndpoint__c.getInstance(UserInfo.getUserId());
        customSettings.Endpoint_URL_Part1__c = ENDPOINT_URL;
        customSettings.Endpoint_URL_Part2__c = ENDPOINT_URL_EXTENSION;
        upsert customSettings;
        liw = new List<InvocableWeatherAction.Request>();
        InvocableWeatherAction.Request iw = new InvocableWeatherAction.Request();
        Id accId = acc.Id;
        iw.recordId = accId;
        iw.shippingCity = TEST_SHIPPING_CITY;
        liw.add(iw);
    }
    /**
     * @author Cagri Kilic
     * @date Jan 17, 2023
     * @description InvocableWeatherAction class's positive test function
     */
    @isTest
    private static void positiveTest() {
        init();
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new WeatherForecastBatchMock());
        InvocableWeatherAction.updateAccountWeatherForecastInfo(liw);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        System.assertEquals(
            1,
            [
                SELECT COUNT()
                FROM Account
                WHERE
                    Id = :acc.Id
                    AND Temperature__c != NULL
                    AND Humidity__c != NULL
                    AND Description__c != NULL
                    AND Feels_Like__c != NULL
                    AND Icon_Link__c != NULL
                    AND ShippingCity = :TEST_SHIPPING_CITY
            ]
        );
    }
    /**
     * @author Cagri Kilic
     * @date Jan 17, 2023
     * @description InvocableWeatherAction class's negative test function
     */
    @isTest
    private static void negativeTest() {
        init();
        Test.startTest();
        Test.setMock(
            HTTPCalloutMock.class,
            new WeatherForecastBatchNegativeMock()
        );
        InvocableWeatherAction.updateAccountWeatherForecastInfo(liw);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        System.assertEquals(
            1,
            [
                SELECT COUNT()
                FROM Account
                WHERE
                    Id = :acc.Id
                    AND Temperature__c = NULL
                    AND Humidity__c = NULL
                    AND Description__c = NULL
                    AND Feels_Like__c = NULL
                    AND Icon_Link__c = NULL
                    AND ShippingCity != :TEST_SHIPPING_CITY
            ]
        );
    }
}
