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
            ];
            String city = requestList.get(0).shippingCity;
            update WeatherForecastController.fetchWeatherInfo(city, acc);
        } catch (Exception e) {
            System.debug('Error: ' + e);
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
