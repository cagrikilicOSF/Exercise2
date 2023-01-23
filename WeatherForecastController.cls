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
    public static final String ICON_URL_EXTENSION = '@2x.png';
    public static final String ICON_URL = 'http://openweathermap.org/img/wn/';
    /******************************************************************
  	* @Name         : fetchWeatherInfo 
  	* @Description  : Changes the account's weather information
  	* @Created By   : CagriKilic
  	* @Created Date : Jan 17, 2023
    * @Param city   : String - Shipping city of relevant account
    * @Return       : WrapperData - Weather information of shipping city

  	******************************************************************/
    public static WrapperData fetchWeatherInfo(String city) {
        try {
            WeatherEndpoint__c weatherEndpoint = WeatherEndpoint__c.getInstance(UserInfo.getUserId());
            String endPoint = weatherEndpoint.Endpoint_URL_Part1__c + city + weatherEndpoint.Endpoint_URL_Part2__c;
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
                WrapperData weatherForecastData = new WrapperData(
                    jsonParseData
                );
                return weatherForecastData;
            }
            System.debug(HTTP_RESPONSE_ERROR);
        } catch (Exception e) {
            System.debug('Error: ' + e);
        }
        return null;
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
            this.icon = ICON_URL + we.icon + ICON_URL_EXTENSION;
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
