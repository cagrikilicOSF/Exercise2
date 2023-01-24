/**
 * File:        WeatherForecastBatchMock.cls
 * Date:        Jan 16, 2023
 * Created By:  Cagri Kilic
 * *************************************************************************
 * Description: WeatherForecastController mock test class
 * *************************************************************************
 * History:
 * Date:            Modified By:           Description:
 */
@isTest
public with sharing class WeatherForecastBatchMock implements HttpCalloutMock {
  /******************************************************************
  * @Name         : respond 
  * @Description  : Creates a fake response 
  * @Created By   : CagriKilic
  * @Created Date : Jan 17, 2023
  * @Param json   : HttpRequest - Data of http request
  * @Return       : HttpResponse - Data of http response
  ******************************************************************/
  public static HttpResponse respond(HttpRequest request) {
    System.assertEquals('GET', request.getMethod());

    // Create a fake response
    HttpResponse response = new HttpResponse();
    response.setHeader('Content-Type', 'application/json');
    response.setBody(
      '{"coord":{"lon":-0.1257,"lat":51.5085},"weather":[' +
        '{"id":803,"main":"Clouds","description":"broken clouds","icon":"04d"}],' +
        '"base":"stations","main":{"temp":9.51,"feels_like":7.34,"temp_min":8.12,' +
        '"temp_max":10.61,"pressure":1006,"humidity":91},"visibility":10000,"wind":' +
        '{"speed":4.12,"deg":220},"clouds":{"all":65},"dt":1671618864,"sys":' +
        '{"type":2,"id":2075535,"country":"GB","sunrise":1671609826,"sunset":1671637993},' +
        '"timezone":0,"id":2643743,"name":"London","cod":200}'
    );
    response.setStatusCode(200);
    return response;
  }
}
