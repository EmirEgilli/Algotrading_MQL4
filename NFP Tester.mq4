//+------------------------------------------------------------------+
//|                                                   NFP Tester.mq4 |
//|                                                           Emir E |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Emir E"
#property link      ""
#property version   "1.00"
#property strict

enum Direction{
  BUY = 1,
  SELL = 2, 
};

input Direction Mode = 1;
extern double Size = 100;

extern int StartHour = 1;
extern int StartMinute = 1;
extern int TPPoint = 100;

static int ticket = 0;

//------------------------------------------------------
void OnTick()
  {
  
  double Highest = iHigh(Symbol(), PERIOD_H1,iHighest(Symbol(),PERIOD_H1,MODE_HIGH,24-StartHour,0));
  double Lowest = iLow(Symbol(), PERIOD_H1,iLowest(Symbol(),PERIOD_H1,MODE_LOW,24-StartHour,0));
  double PipDiffUp;
  double PipDiffDown;
  
 //To make sure only one position is opened per bar
   static datetime prevtime = 0;

   if(prevtime == Time[0])
      return;
   prevtime = Time[0];
 {
   
  if(Hour() == StartHour && Minute() == StartMinute)
  {    
   if(OrdersTotal()==0 && Mode == 1)
   {
      ticket = OrderSend(Symbol(), OP_BUY, Size, Ask, 10*10, 0, Ask+TPPoint*Point,NULL,666666,0,Blue); 
      if(ticket < 0)
           {
            Alert("Error Sending Order! Error Code: ", GetLastError());
           }           
     return;       
     } //End of BUY
   
   if(OrdersTotal()==0 && Mode == 2)
   {
      ticket = OrderSend(Symbol(), OP_SELL, Size, Bid, 10*10, 0, Bid-TPPoint*Point,NULL,666666,0,Red); 
      if(ticket < 0)
           {
            Alert("Error Sending Order! Error Code: ", GetLastError());
           }        
      return;                
    } //End of SELL 
   } // End of Hour and Minute 

         if(ticket > 0)
         {
          if(OrderSelect(ticket, SELECT_BY_TICKET))
          {
            if(OrderType() == OP_BUY)
            {
            PipDiffUp = NormalizeDouble((Highest - OrderOpenPrice())*100000, 0);
            PipDiffDown = NormalizeDouble((OrderOpenPrice() - Lowest)*100000, 0);
            }   
            if(OrderType() == OP_SELL)
            {
            PipDiffUp = NormalizeDouble((OrderOpenPrice() - Lowest)*100000, 0);
            PipDiffDown = NormalizeDouble((Highest - OrderOpenPrice())*100000, 0);
            }
          }
         }
            
   Comment("Highest Price in Session: ",Highest,"\n",
           "Lowest Price in Session: ",Lowest,"\n",
           "Position Opened in Price: ",OrderOpenPrice(),"\n",
           "PIP Point Difference towards Target: ",PipDiffUp,"\n",
           "PIP Point Difference against Target: ",PipDiffDown,"\n");       
                             
  } //End of PrevTime 
    
} //End of OnTick
//+------------------------------------------------------------------+
