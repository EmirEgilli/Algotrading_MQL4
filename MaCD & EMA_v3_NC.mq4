//+------------------------------------------------------------------+
//|                                                MACD & EMA v3.mq4 |
//|                                                           Emir E |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Emir E"
#property link      ""
#property version   "3.00"
#property strict

//External inputs for optimization
extern int Fast = 12;
extern int Slow = 26;
extern int SL = 35;
extern int TP = 70;

extern int Slippage = 10;

extern int EMA_Period = 200;
extern double Lots = 0.02;

extern int StopValue = 100;

double Spread = MarketInfo(NULL, MODE_SPREAD);

enum TradeMode{
   Disabled = 1,
   Buy_Only = 2, 
   Sell_Only = 3, 
   Close_Only = 4,
   Advanced = 5, 
};

enum BreakEven{
     Yes = 1,
     No = 2,
}; 

input BreakEven BEOption = 1;    
  
input TradeMode TradeOptions = 1;

static int ticket = 0;
static int modify = 0;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {

   string signal ="";

//Current chart, current period, number of candles, no shift, simple, current close price
   double CurrentMainMACD = iMACD(Symbol(), PERIOD_M5, Fast, Slow, 9, PRICE_CLOSE, MODE_MAIN, 0);

//Current chart, current period, number of candles, no shift, simple, previous close price
   double PreviousMainMACD = iMACD(Symbol(), PERIOD_M5, Fast, Slow, 9, PRICE_CLOSE, MODE_MAIN, 1);
   
   double SlowEMA = iMA(NULL, 0, EMA_Period, 0, MODE_EMA, PRICE_CLOSE, 1);
   

//To make sure only one position is opened per bar
   static datetime prevtime = 0;

   if(prevtime == Time[0])
      return;
   prevtime = Time[0];
     {

   //If fast SMA is above slow SMA
      if((PreviousMainMACD < 0) && (CurrentMainMACD > 0))
        {
          if(Close[1] > SlowEMA)
            {
         //Chart output for BUY signal
         signal="Buy";   
            }
        }
        
      //If fast SMA is below slow SMA
      else if((PreviousMainMACD > 0) && (CurrentMainMACD < 0))
        {
          if(Close[1] < SlowEMA)
            {
         //Chart output for SELL signal
         signal="Sell";   
            }
        }
        
       //Position for BUY    
      if(signal == "Buy")
        {
         if(TradeOptions == 2 || TradeOptions == 5)
         {
         //Here we are assuming that the TakeProfit and StopLoss are entered in Pips
         ticket = OrderSend(Symbol(), OP_BUY, Lots, Ask, Slippage*10, Ask-SL*Point*10, Ask+TP*Point*10, "Long by MaCD & EMA v3", 626262, 0, Blue);
         if(ticket < 0)
           {
            Alert("Error Sending Order! Error Code: ", GetLastError());
           }
         } 
        }

      //Position for SELL
      else if(signal == "Sell")
        {
         if(TradeOptions == 3 || TradeOptions == 5)
         {
         //Here we are assuming that the TakeProfit and StopLoss are entered in Pips
         ticket = OrderSend(Symbol(), OP_SELL, Lots, Bid, Slippage*10, Bid+SL*Point*10, Bid-TP*Point*10, "Short by MaCD & EMA v3", 626262, 0, Red);
         if(ticket < 0)
           {
            Alert("Error Sending Order! Error Code: ", GetLastError());
           }
         }  
        }
     }

//Create a chart output
   Comment("The signal is: ",signal,"\n");

//Call the function
   if(TradeOptions != 1)
   {
   if(BEOption != 2)
   {
    CheckBEStop();
   }
   } 
   
  }
//+------------------------------------------------------------------+

void CheckBEStop()
{
   //Go through all open orders
   for (int b= OrdersTotal()-1; b>=0; b--)
   {
      //Check open positions
      if(OrderSelect(b, SELECT_BY_POS, MODE_TRADES))
      {
      
         //If the order symbol is the chart symbol
         if(OrderSymbol()==Symbol())
         {
            //If it's a SELL trade
            if(OrderType()==OP_SELL)
            {
               //If the current SL is above the open price
               if(OrderStopLoss()>OrderOpenPrice())
               {
                  //If bid price is below the open price for a certain input point
                  if(Bid < OrderOpenPrice()-StopValue*_Point)
                  {
                  
      //Adjust the Stop Loss
     modify = OrderModify(OrderTicket(), OrderOpenPrice(), (OrderOpenPrice()-Spread*_Point), OrderTakeProfit(), 0, CLR_NONE);
          if(modify < 0)
                 {
                  Alert("Error Modifying Order!");
                 }
                  }
               }   
            }
    //If it's a BUY trade
            if(OrderType()==OP_BUY)
            {
               //If the current SL is below the open price
               if(OrderStopLoss()<OrderOpenPrice())
               {
                  //If Ask price is above the open price for a certain input point
                  if(Ask > OrderOpenPrice()-StopValue*_Point)
                  {
                  
      //Adjust the Stop Loss
     modify = OrderModify(OrderTicket(), OrderOpenPrice(), (OrderOpenPrice()+Spread*_Point), OrderTakeProfit(), 0, CLR_NONE);
          if(modify < 0)
                 {
                  Alert("Error Modifying Order!");
                 }
                  }
               }   
            }                                               
         }
      }
    }
}              