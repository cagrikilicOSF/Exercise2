/******************************************************************
 * @Name         : InvocableWeatherAction
 * @Description  : Action class of WeatherForecast flow
 * @Created By   : Cagri Kilic
 * @Created Date : Jan 17, 2023
 * @Modification Log :
 ******************************************************************
 * Version        Developer        Date        Description
 *------------------------------------------------------------
 *
 ******************************************************************/
public with sharing class InvocableWeatherAction {
    /******************************************************************
  	* @Name         : updateAccountWeatherForecastInfo 
  	* @Description  : Updates the weather information of the corresponding account
  	* @Created By   : CagriKilic
  	* @Created Date : Jan 17, 2023
    * @Param requestList   : List<Request> - List of invocable variable 

  	******************************************************************/
    @InvocableMethod(
        label='Get Weather Information'
        description='Get Weather Information'
        category='Account'
    )
    public static void updateAccountWeatherForecastInfo(List<Request> requestList) {
        try {
            String accId = requestList.get(0).recordId;
            Account acc = [
                SELECT
                    Id,
                    ShippingCity,
                    Temperature__c,
                    Humidity__c,
                    Feels_Like__c,
                    Icon_Link__c,
                    Description__c
                FROM Account
                WHERE Id = :accId
                LIMIT 1
            ];
            String city = requestList.get(0).shippingCity;
            update setWeatherInfoToAccount(acc, city);
        } catch (Exception e) {
            System.debug('Error: ' + e);
        }
    }
    /******************************************************************
     * @Name         : setWeatherInfoToAccount
     * @Description  : Sets account's weather informations
     * @Created By   : CagriKilic
     * @Created Date : Jan 24, 2023
     * @Param acc    : Account - Relevant account
     * @Param city   : String - Account's shipping city
     * @Return       : Account - Relevant account
     ******************************************************************/
    public static Account setWeatherInfoToAccount(Account acc, String city) {
        try {
            WeatherForecastController.WrapperData weatherForecastData = WeatherForecastController.fetchWeatherInfo(
                city
            );
            if (weatherForecastData != null) {
                acc.Temperature__c = weatherForecastData.temp;
                acc.Humidity__c = weatherForecastData.humidity;
                acc.Feels_Like__c = weatherForecastData.feelsLike;
                acc.Icon_Link__c = weatherForecastData.icon;
                acc.Description__c = weatherForecastData.description;
                acc.ShippingCity = city;
            }
            return acc;
        } catch (Exception e) {
            System.debug('Error: ' + e);
            return new Account();
        }
    }
    /******************************************************************
     * @Name         : Request
     * @Description  : Defines the invocable variable
     * @Created By   : Cagri Kilic
     * @Created Date : Jan 17, 2023
     * @Modification Log :
     ******************************************************************
     * Version        Developer        Date        Description
     *------------------------------------------------------------
     *
     ******************************************************************/
    public class Request {
        @InvocableVariable(
            label='Record Id'
            description='The id of the Account Record'
        )
        public String recordId;
        @InvocableVariable(
            label='Shipping City'
            description='The Shipping City of the Account Record'
        )
        public String shippingCity;
    }
}
