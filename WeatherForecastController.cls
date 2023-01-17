/******************************************************************
 * @Name         : WeatherForecastController
 * @Description  : Controller of WeatherForecast class
 * @Created By   : Cagri Kilic
 * @Created Date : Jan 17, 2023
 * @Modification Log :
 ******************************************************************
 * Version        Developer        Date        Description
 *------------------------------------------------------------
 *
 ******************************************************************/
public with sharing class WeatherForecastController {
    public static final String HTTP_RESPONSE_ERROR = 'Error : An error occurred while retrieving weather information!';
    /******************************************************************
  	* @Name         : fetchWeatherInfo 
  	* @Description  : Changes the account's weather information
  	* @Created By   : CagriKilic
  	* @Created Date : Jan 17, 2023
    * @Param city   : String - Shipping city of relevant account
    * @Param acc    : Account - Account to be updated weather information
    * @Return       : Account - Weather information updated account

  	******************************************************************/
    public static Account fetchWeatherInfo(String city, Account acc) {
        try {
            List<openweatherendpoint__c> endPointDatas = openweatherendpoint__c.getAll().values();
            String endPoint = endPointDatas.get(1).Endpoint_URL__c + city + endPointDatas.get(0).Endpoint_URL__c;
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http = new Http();
            request.setEndpoint(endPoint);
            request.setMethod('GET');
            request.setTimeout(120000);
            response = http.send(request);
            if (response.getStatusCode() == 200) {
                String jsonResponse = response.getBody();
                FromJSON jsonParseData = (FromJSON) parse(jsonResponse);
                WrapperData wrpData = new WrapperData(jsonParseData);
                acc.Temperature__c = wrpData.temp;
                acc.Humidity__c = wrpData.humidity;
                acc.Feels_Like__c = wrpData.feelsLike;
                acc.Icon_Link__c = wrpData.icon;
                acc.Description__c = wrpData.description;
                acc.ShippingCity = city;
                return acc;
            } else {
                System.debug(HTTP_RESPONSE_ERROR);
                return new Account();
            }
        } catch (Exception e) {
            System.debug('Error: ' + e);
            return new Account();
        }
    }
    /******************************************************************
     * @Name         : WrapperData
     * @Description  : Assigns weather information to variables
     * @Created By   : Cagri Kilic
     * @Created Date : Jan 17, 2023
     * @Modification Log :
     ******************************************************************
     * Version        Developer        Date        Description
     *------------------------------------------------------------
     *
     ******************************************************************/
    public class WrapperData {
        public Double temp;
        public Integer humidity;
        public Double feelsLike;
        public String description;
        public String icon;
        public WrapperData(FromJSON parseData) {
            Main te = parseData.main;
            Weather we = parseData.weather[0];
            this.temp = te.temp;
            this.humidity = te.humidity;
            this.feelsLike = te.feels_like;
            this.description = we.description;
            this.icon ='http://openweathermap.org/img/wn/' + we.icon + '@2x.png';
        }
    }
    /******************************************************************
     * @Name         : FromJSON
     * @Description  : Contains objects of weather data
     * @Created By   : Cagri Kilic
     * @Created Date : Jan 17, 2023
     * @Modification Log :
     ******************************************************************
     * Version        Developer        Date        Description
     *------------------------------------------------------------
     *
     ******************************************************************/
    public class FromJSON {
        public Weather[] weather;
        public Main main;
    }
    /******************************************************************
     * @Name         : Weather
     * @Description  : Contains variables of json data of weather
     * @Created By   : Cagri Kilic
     * @Created Date : Jan 17, 2023
     * @Modification Log :
     ******************************************************************
     * Version        Developer        Date        Description
     *------------------------------------------------------------
     *
     ******************************************************************/
    public class Weather {
        public String description;
        public String icon;
    }
    /******************************************************************
     * @Name         : Main
     * @Description  : Contains variables of json data of main
     * @Created By   : Cagri Kilic
     * @Created Date : Jan 17, 2023
     * @Modification Log :
     ******************************************************************
     * Version        Developer        Date        Description
     *------------------------------------------------------------
     *
     ******************************************************************/
    public class Main {
        public Double temp;
        public Double feels_like;
        public Integer humidity;
    }
    /******************************************************************
  	* @Name         : parse 
  	* @Description  : Parses json data
  	* @Created By   : CagriKilic
  	* @Created Date : Jan 17, 2023
    * @Param json   : String - Data of Http response
    * @Return       : FromJSON - Weather datas
  	******************************************************************/
    private static FromJSON parse(String json) {
        return (FromJSON) System.JSON.deserialize(json, FromJSON.class);
    }
}