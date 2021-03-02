/***********************************************************************************************************************
* Name:    HereTokenScheduler
* Author:  Konrad Russa - konrad.russa@cognizant.com
* Purpose: Class used for scheduling with CRON expression Here token fetching and storing in Custom Setting for 24H
*======================================================================================================================*
* History                                                                                                              *
* -------                                                                                                              *
* VERSION  AUTHOR           DATE              DETAIL                                               RELEASE/CSR         *
*   1.0 -  Konrad Russa     18/12/2020        INITIAL DEVELOPMENT                                         *
************************************************************************************************************************/
/*
Ad-hoc usage:
https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_system.htm
0 0 0 * * ?         Class runs every day at 0 AM (third parameter: Seconds Minutes Hours Day_of_month Month Day_of_week Optional_year).
0 0 1 ? * MON-SAT   Class runs Monday through Saturday at 1 AM.
0 0 * /4 * * ?     Class runs every 4 hours - starts 4h after is submitted !!! there should be no space between * and /4
System.schedule('Here Token Saving Automation','0 0 1 * * ?',new HereTokenScheduler());
*/

global class HereTokenScheduler implements Schedulable {
    
    public interface ISchedule {
        void execute(SchedulableContext sc);
    }

    /*  Description regarding this pattern: http://advancedapex.com/2012/11/14/scheduledapex/
        One of the disadvantages of Scheduled APEX is that a scheduled class can’t be updated. 
        Force.com creates an instance of the APEX class when it is scheduled, preventing it from being updated. 
        You can’t edit a scheduled class, or update it via a ChangeSet, the Force.com IDE or a package update.
        What’s more, Force.com prevents updates to any dependent classes as well. 
        Thus it is quite easy for a scheduled class to “poison” an application – preventing many, 
        if not all of its components, from being updated. As a result, 
        updates to applications that use Scheduled Apex often require any scheduled jobs 
        to be manually aborted before an update can take place.
        It turns out, however, that a recent API update allows use of a design pattern 
        that can help you avoid most of these problems.
        
        Alternative:
        
        Setup -> Deploy -> Deployment Settings -> Deployment Options 
        Allow deployments of components when corresponding Apex jobs are pending or in progress.
        Caution: Enabling this option may cause Apex jobs to fail.
    */

    global void execute(SchedulableContext sc) {
        Type targetType = Type.forName('HereTokenIntegration');
        if(targetType != null) {
            ISchedule tokenFetch = (ISchedule)targetType.newInstance();
            tokenFetch.execute(sc);
        }
    }
}