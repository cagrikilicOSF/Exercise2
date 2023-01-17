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
    /**
     * @author Cagri Kilic
     * @date Jan 17, 2023
     * @description  create test data
     */
    @TestSetup
    static void setup() {
        Account account = new Account(name = 'Account ', ShippingCity = 'Lawrence');
        insert account;
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
     * @description InvocableWeatherAction class's positive test function
     */
    @isTest
    static void positiveTest() {
        Test.startTest();
        List<InvocableWeatherAction.Request> liw = new List<InvocableWeatherAction.Request>();
        InvocableWeatherAction.Request iw = new InvocableWeatherAction.Request();
        Id accId = [SELECT Id FROM Account].Id;
        iw.recordId = accId;
        iw.shippingCity = 'London';
        liw.add(iw);
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
                    Id = :iw.recordId
                    AND Temperature__c != NULL
                    AND Humidity__c != NULL
                    AND Description__c != NULL
                    AND Feels_Like__c != NULL
                    AND Icon_Link__c != NULL
                    AND ShippingCity = 'London'
            ]
        );
    }
    /**
     * @author Cagri Kilic
     * @date Jan 17, 2023
     * @description InvocableWeatherAction class's negative test function
     */
    @isTest
    static void negativeTest() {
        Test.startTest();
        List<InvocableWeatherAction.Request> liw = new List<InvocableWeatherAction.Request>();
        InvocableWeatherAction.Request iw = new InvocableWeatherAction.Request();
        Id accId = [SELECT Id FROM Account].Id;
        iw.recordId = accId;
        iw.shippingCity = 'London';
        liw.add(iw);
        Test.setMock(HTTPCalloutMock.class, new WeatherForecastBatchNegativeMock());
        InvocableWeatherAction.updateAccountWeatherForecastInfo(liw);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        System.assertEquals(
            1,
            [
                SELECT COUNT()
                FROM Account
                WHERE
                    Id = :iw.recordId
                    AND Temperature__c = NULL
                    AND Humidity__c = NULL
                    AND Description__c = NULL
                    AND Feels_Like__c = NULL
                    AND Icon_Link__c = NULL
                    AND ShippingCity != 'London'
            ]
        );
    }
}
