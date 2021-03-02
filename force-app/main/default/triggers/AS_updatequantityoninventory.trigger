/******************************************************************************************
  * File Name   : AS_updatequantityoninventory
  * Created Date: 28th December 2020
  * Description : Calls class AS_updatequantityoninventory on after delete event on Product Required record
  * Story       : https://jira.hyundai-autoever.eu/browse/GD-1606
  * Author      : Neha Aggrawal
*/

trigger AS_updatequantityoninventory on ProductRequired (after delete) {

AS_updatequantityoninventory cl=new AS_updatequantityoninventory();
cl.func();

}