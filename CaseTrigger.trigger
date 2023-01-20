/*********************************************************************************
 *@Name          : CaseTrigger.trigger
 *@Description   : Trigger on Case
 *@Created by    : Cagri Kilic
 *@Created Date  : Jan 18 2023
 *@Modification Log:
 **********************************************************************************
 * Version       Developer           Date                        Description
 *---------------------------------------------------------------------------------
 *
 **********************************************************************************/
trigger CaseTrigger on Case(before insert) {
    if (Trigger.isInsert && Trigger.isBefore) {
        CaseTriggerHandler.addAccountToCase(Trigger.New);
    }
}
