//+------------------------------------------------------------------+
//|                                                   EA License.mq4 |
//|                                                           Emir E |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Emir E"
#property link      ""
#property version   "1.00"

#property strict

//#define LIC_TRADE_MODES  { ACCOUNT_TRADE_MODE_CONTEST, ACCOUNT_TRADE_MODE_DEMO }  //Add ACCOUNT_TRADE_MODE_REAL or disable alltogether by adding // at the beginning
#define LIC_SYMBOLS { "GBPUSD" , "EURUSD" , "AUDUSD" , "USDCHF" }                   //Limits the usage to predefined symbols
//#define  LIC_EXPIRES_DAYS  30                                                       //Trial version, disable by adding // for full version
//#define  LIC_EXPIRES_START D'2021.12.13'                                          //To add predefined date to expiry of trial version
//#define LIC_PRIVATE_KEY "Inceptial"                                                 //To add password created by KeyGen that only works for account number

input string InpLicense = "Enter License Code here : " ; //License Key

#include <LicenseCheck.mqh>



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

if(!LicenseCheck(InpLicense)) return(INIT_FAILED);
   
//---
   return(INIT_SUCCEEDED);
  }
  
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
