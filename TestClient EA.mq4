//+------------------------------------------------------------------+
//|                                                Test ClientEA.mq4 |
//|                                                           Emir E |
//+------------------------------------------------------------------+
#property copyright "Emir E"
#property link      ""
#property version   "1.00"
#property strict

// External inputs for optimization

// For MaCD:
extern int Signal_MaCD = 17;
extern int Main_MaCD = 8;

// For Stochastic Oscillator:
extern int KPeriod = 8;
extern int DPeriod = 5;
extern int Slowing = 3;

extern int SL = 35;
extern int TP = 70;
extern double Lots = 0.1;
extern int MagicNumber = 666666;

extern int Slippage = 10;
extern int StopValue = 25;

double Spread = MarketInfo(NULL, MODE_SPREAD);

enum TradeMode{
   Disabled = 1,
   Buy_Only = 2,
   Sell_Only = 3,
   Close_Only = 4,
   Enabled = 5,
};
   
enum BreakEven{
   Yes = 1,
   No = 2,
};

input BreakEven BEOption = 1;

input TradeMode TradeOptions = 5;

static int ticket = 0;
static int modify = 0;

// -------------------------------------------+

void OnTick()
{

   string signal = "";

// MaCD
// MaCD Main
   double CurrentMainMaCD = iMACD(Symbol(), Period(), Signal_MaCD, Main_MaCD, 9, PRICE_CLOSE, MODE_MAIN, 0);
   double PreviousMainMaCD = iMACD(Symbol(), Period(), Signal_MaCD, Main_MaCD, 9, PRICE_CLOSE, MODE_MAIN, 1);
// MaCD Signal   
   double CurrentSignalMaCD = iMACD(Symbol(), Period(), Signal_MaCD, Main_MaCD, 9, PRICE_CLOSE, MODE_SIGNAL, 0);
   double PreviousSignalMaCD = iMACD(Symbol(), Period(), Signal_MaCD, Main_MaCD, 9, PRICE_CLOSE, MODE_SIGNAL, 1);
   
// Stochastic Oscillator
// Stoch Main
   double CurrentMainStoch = iStochastic(Symbol(), Period(), KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_MAIN, 0);
   double PreviousMainStoch = iStochastic(Symbol(), Period(), KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_MAIN, 1);
// Stoch Signal
   double CurrentSignalStoch = iStochastic(Symbol(), Period(), KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_SIGNAL, 0);
   double PreviousSignalStoch = iStochastic(Symbol(), Period(), KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_SIGNAL, 1);
   
   // Prevtime function - To make sure only one position is opened per tick bar
   static datetime prevtime = 0;
   if(prevtime == Time[0])
      return;
   prevtime = Time[0];
   {     
   
   // BUY Conditions
   if((CurrentMainMaCD > 0) && (CurrentSignalMaCD > PreviousSignalMaCD))
   {
      if(PreviousMainStoch <= 25)
      {
         if((PreviousMainStoch < PreviousSignalStoch) && (CurrentMainStoch >= CurrentSignalStoch))
         {
           signal = "BUY";
         }
      }
   }
   // SELL Conditions
   if((CurrentMainMaCD < 0) && (CurrentSignalMaCD < PreviousSignalMaCD))
   {
      if(PreviousMainStoch >= 75)
      {
         if((PreviousMainStoch > PreviousSignalStoch) && (CurrentMainStoch <= CurrentSignalStoch))
         {
            signal = "SELL";
         }
      }
   }
   
   // Place trade order for BUY
   if(signal == "BUY")
   {
      if(TradeOptions == 2 || TradeOptions == 5)
      {
         ticket = OrderSend(Symbol(), OP_BUY, Lots, Ask, Slippage*10, Ask-SL*Point*10, Ask+TP*Point*10, NULL, MagicNumber, 0, Blue);
         if(ticket < 0)
         {
            Alert("Error Sending Order! Error Code: ", GetLastError());
         }
      }
   }
   // Place trade order for SELL
   if(signal == "SELL")
   {
      if(TradeOptions == 3 || TradeOptions == 5)
      {
         ticket = OrderSend(Symbol(), OP_SELL, Lots, Bid, Slippage*10, Bid+SL*Point*10, Bid-TP*Point*10, NULL, MagicNumber, 0, Red);
         if(ticket < 0)
         {
            Alert("Error Sending Order! Error Code: ", GetLastError());
         }
      }
   }
   
// Create a chart output
   Comment("The Signal is: ",signal,"\n");

// For Breakeven function
   if(TradeOptions != 1)
   {
   if(BEOption != 2)
   {
   CheckBEStop();
   }}     
      
   } // End of prevtime
} // End of OnTick()   
//+------------------------------------------------------------------+

void CheckBEStop()
{
   // Go through all open orders
   for (int i=OrdersTotal()-1; i>=0; i--)
   {
      // Check open positions
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         // If order symbol is the chart symbol
         if(OrderSymbol() == Symbol())
         {
            // If it's a SELL position
            if(OrderType() == OP_SELL)
            {
               // If the current SL is above the opening price
               if(OrderStopLoss() > OrderOpenPrice())
               {
                  // If the bid price is below the opening price for a certain input point
                  if(Bid < OrderOpenPrice()-StopValue*_Point)
                  {
                  // Adjust the Stop Loss
                  modify = OrderModify(OrderTicket(), OrderOpenPrice(), (OrderOpenPrice() - Spread*_Point), OrderTakeProfit(), 0, CLR_NONE);
                  if(modify < 0)
                  {
                  Alert("Error Modifying Order! Error Code: ",GetLastError());
                  }
                  }
               }
            }
            // If it's a BUY poistion      
            if(OrderType() == OP_BUY)
            {
               // If the current SL is below the opening price
               if(OrderStopLoss() < OrderOpenPrice())
               {
                  // If the Ask price is above the open price for a certain input point
                  if(Ask > OrderOpenPrice()-StopValue*_Point)
                  {
                  // Adjust the Stop Loss
                  modify = OrderModify(OrderTicket(), OrderOpenPrice(), (OrderOpenPrice() + Spread*_Point), OrderTakeProfit(), 0, CLR_NONE);
                  if(modify < 0)
                  {
                  Alert("Error Modifying Order! Error Code: ",GetLastError());
                  }
                  }
               }
            }
         }
      }
    }
} // End of CheckBEStop function
