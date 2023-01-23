/******************************************************************
 * @Name         : WeatherForecastBatch
 * @Description  : Batch Job of Weather Forecast
 * @Created By   : Cagri Kilic
 * @Created Date : Jan 17, 2023
 * @Modification Log :
 ******************************************************************
 * Version        Developer        Date        Description
 *------------------------------------------------------------
 *
 ******************************************************************/
public with sharing class WeatherForecastBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public static final String SHIPPING_CITY_ERROR = 'Error : Shipping City is null!';
    /******************************************************************
     * @Name         : start
     * @Description  : Returns the result of the sent query
     * @Created By   : CagriKilic
     * @Created Date : Jan 17, 2023
     * @Param bc     : Database.BatchableContext - Batchable Context
     * @Return       : Database.QueryLocator - Query Locator
     ******************************************************************/
    public Database.QueryLocator start(Database.BatchableContext bc) {
        try {
            String query = 'SELECT Id, ShippingCity, Temperature__c, Humidity__c, Feels_Like__c, Icon_Link__c, Description__c FROM Account';
            return Database.getQueryLocator(query);
        } catch (QueryException e) {
            System.debug('An error occurred: ' + e.getMessage());
            return null;
        }
    }
    /******************************************************************
  	* @Name         : execute 
  	* @Description  : Updates the weather information of the accounts
  	* @Created By   : CagriKilic
  	* @Created Date : Jan 17, 2023
    * @Param bc     : Database.BatchableContext - Batchable Context
    * @Param account    : List<Account> - List of Accounts 
    
  	******************************************************************/
    public void execute(Database.BatchableContext bc, List<Account> account) {
        List<Account> updateAccounts = new List<Account>();
        for (Account acc : account) {
            String city = acc.ShippingCity;
            if (city != null && city != '') {
                WeatherForecastController.WrapperData weatherForecastData = WeatherForecastController.fetchWeatherInfo(city);
                if (weatherForecastData != null) {
                    acc.Temperature__c = weatherForecastData.temp;
                    acc.Humidity__c = weatherForecastData.humidity;
                    acc.Feels_Like__c = weatherForecastData.feelsLike;
                    acc.Icon_Link__c = weatherForecastData.icon;
                    acc.Description__c = weatherForecastData.description;
                    updateAccounts.add(acc);
                }
            } else {
                System.debug(SHIPPING_CITY_ERROR);
            }
        }
        if (updateAccounts.size() > 0) {
            update updateAccounts;
        }
    }
    /******************************************************************
  	* @Name         : finish 
  	* @Description  : Retrieves job result
  	* @Created By   : CagriKilic
  	* @Created Date : Jan 17, 2023
    * @Param bc     : Database.BatchableContext - Batchable Context 
    
  	******************************************************************/
    public void finish(Database.BatchableContext bc) {
        AsyncApexJob job = [
            SELECT
                Id,
                Status,
                NumberOfErrors,
                JobItemsProcessed,
                TotalJobItems,
                CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()
        ];
        System.debug('Job: ' + job);
    }
}
