/**
 * File:        WeatherForecastScheduleJob_Test.cls
 * Date:        Jan 17, 2023
 * Created By:  Cagri Kilic
 * *************************************************************************
 * Description: WeatherForecastScheduleJob test class
 * *************************************************************************
 * History:
 * Date:            Modified By:           Description:
 */
@isTest
public with sharing class WeatherForecastScheduleJob_Test {
    /**
     * @author Cagri Kilic
     * @date Jan 17, 2023
     * @description WeatherForecastScheduleJob class's test function
     */
    @isTest
    static void test() {
        Test.startTest();
        String sch = '0 0 9 ? * *';
        Test.setMock(HttpCalloutMock.class, new WeatherForecastBatchMock());
        String jobId = System.schedule('WeatherForecastScheduleJobTest', sch, new WeatherForecastScheduleJob());
        Test.stopTest();
        // Get the information from the CronTrigger API object
        CronTrigger ct = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger
            WHERE NextFireTime > Today
        ];
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals(jobID, ct.Id);
        System.assertEquals(sch, ct.CronExpression);
        System.assert(Date.today() < ct.NextFireTime);
    }
}
