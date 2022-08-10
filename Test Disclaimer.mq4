//+------------------------------------------------------------------+
//|                                              Test Disclaimer.mq4 |
//|                                                           Emir E |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Emir E"
#property link      ""
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
     int Disclaimer = MessageBox( " Trading non-deliverable OTC instruments is a risky activity and can bring not only profits, but also losses. " +
                  "The amount of possible losses are limited by margin security. " +
                  "Earned profits in the past do not guarantee future profits. " +
                  "Take advantage of company's training services to understand the risks before starting operations. " +
                  "\n" + 
                  "\n" +                
                  "By clicking OK you agree to the terms and conditions, along with the risks mentioned above. ", "RISK WARNING!!", 0x00000001);
   
if(Disclaimer == 1) {
   Alert("Initialization of Expert Advisor is successful.");
   return(INIT_SUCCEEDED);
   }
else{
   Alert("Aborted initialization of Expert Advisor.");
   return(INIT_FAILED);
  }
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
