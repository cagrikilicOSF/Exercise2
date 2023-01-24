/**
 * File:        WeatherForecastNegativeMock.cls
 * Date:        Jan 17, 2023
 * Created By:  Cagri Kilic
 * *************************************************************************
 * Description: WeatherForecastController mock test class
 * *************************************************************************
 * History:
 * Date:            Modified By:           Description:
 */
@isTest
public with sharing class WeatherForecastBatchNegativeMock implements HttpCalloutMock {
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
        response.setBody('{"cod": "404", "message": "city not found"}');
        response.setStatusCode(400);
        return response;
    }
}