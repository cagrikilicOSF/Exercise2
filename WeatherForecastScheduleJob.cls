/******************************************************************
 * @Name         : WeatherForecastScheduleJob
 * @Description  : Schedule Job of Weather Forecast Batch
 * @Created By   : Cagri Kilic
 * @Created Date : Jan 17, 2023
 * @Modification Log :
 ******************************************************************
 * Version        Developer        Date        Description
 *------------------------------------------------------------
 *
 ******************************************************************/
public with sharing class WeatherForecastScheduleJob implements Schedulable {
    public static String sch = '0 0 9 ? * *';
    /******************************************************************
	* @Name         : execute 
	* @Description  : Runs Batch Job
	* @Created By   : CagriKilic
	* @Created Date : Jan 17, 2023
    * @Param ctx     : SchedulableContext - Schedulable Context
   
	  ******************************************************************/
    public void execute(SchedulableContext ctx) {
        WeatherForecastBatch wfBatch = new WeatherForecastBatch();
        ID batchprocessid = Database.executeBatch(wfBatch);
    }
}
