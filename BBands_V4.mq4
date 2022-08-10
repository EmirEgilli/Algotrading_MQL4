#property copyright "Copyright 2021, Emir E"
#property version "4.00"
#property strict

extern int SL = 150;
extern int TP = 150;

extern int RSIPeriod = 2;
extern int RSILow = 10;
extern int RSIHigh = 90;
extern double Lots = 0.1;

extern int StopValue = 100;
int CalSPValue;

static int ticket = 0;
static int modify = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {

//Empty string for signal
   string signal="";

 double ATRValue = iATR(_Symbol, _Period, 14, 0); //For ATR Trailing Stop

//Symbol, Period, 20 candles, deviation 2, no shift, close price, candle
   double LowerBB=iBands(_Symbol, _Period, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, 0);
   double UpperBB=iBands(_Symbol, _Period, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, 0);

//Calculate the previous candle
   double PrevLowerBB=iBands(_Symbol, _Period, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, 1);
   double PrevUpperBB=iBands(_Symbol, _Period, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, 1);
   
   // Old ATR Value
   static double OldValue;
   
   //To make sure only one position is opened per bar
   static datetime prevtime = 0;

   if(prevtime == Time[0])
      return;
   prevtime = Time[0];
     {


   if(Close[1]<PrevUpperBB && iRSI(NULL, PERIOD_CURRENT, RSIPeriod, PRICE_CLOSE, 1) < RSILow)
    {
     if(Close[0]>LowerBB)
     {
     if(ATRValue>OldValue)                  //If ATR goes up
      {
      if(iCustom(NULL, PERIOD_CURRENT, "StOsc Reversals Ext", true, 0, 0) != EMPTY_VALUE)
       {
      signal="Buy";
       }
     }
    }
   }    
   if(Close[1]>PrevLowerBB && iRSI(NULL, PERIOD_CURRENT, RSIPeriod, PRICE_CLOSE, 1) > RSIHigh)
     {
     if(Close[0]<UpperBB)
      {
      if(ATRValue<OldValue || OldValue==0)  //If ATR goes down
       {
      if(iCustom(NULL, PERIOD_CURRENT, "StOsc Reversals Ext", true, 1, 0) != EMPTY_VALUE)
       {
      signal="Sell";
       }
      }
    }
   } 
//When there are no open trades


   if(signal=="Buy" && OrdersTotal()==0)
     {
      ticket = OrderSend(_Symbol, OP_BUY, Lots, Ask, 3, Ask-SL*_Point, Ask+TP*_Point, NULL, 0, 0, Blue);
       if(ticket < 0)
           {
            Alert("Error Sending Order!");
           }
     }
   else
      if(signal=="Sell" && OrdersTotal()==0)
        {
         ticket = OrderSend(_Symbol, OP_SELL, Lots, Bid, 3, Bid+SL*_Point, Bid-TP*_Point, NULL, 0, 0, Red);
          if(ticket < 0)
           {
            Alert("Error Sending Order!");
           }
        }

//Check trailing stop
   CalSPValue = CheckATRTrailingStop(ATRValue);

//Create a chart output
   Comment("The signal is: ",signal,"\n",
           "ATR Value is: ",ATRValue,"\n",
           "Calculated Stop Point Value: ",CalSPValue,"\n");

//Assing current value to old value
   OldValue=ATRValue;

  } //End of prevtime function
}  //End of OnTick function
//+------------------------------------------------------------------+

int CheckATRTrailingStop(double ATRValue)
  {

//Calculate stop point value
   CalSPValue = StopValue +(ATRValue* 10);

//Calculate SL price
   double CalSLPriceSELL = Bid + CalSPValue*_Point*10;
   double CalSLPriceBUY  = Ask - CalSPValue*_Point*10;

//Create a for loop to go through all the open orders
   for(int b= OrdersTotal()-1;b>=0;b--)
     {

      //Select an order
      if(OrderSelect(b, SELECT_BY_POS, MODE_TRADES))
         //Check if order symbol equals the chart symbol
         if(OrderSymbol()==Symbol())
           
            //Check if it's a SELL trade
            if(OrderType()==OP_SELL)
              {
               //If the stop loss is below the stop value
               if(OrderStopLoss() > CalSLPriceSELL)

                  //We adjust the stop loss
                  modify = OrderModify(
                              OrderTicket(),       //for the current order
                              OrderOpenPrice(),    //for the open price we had
                              CalSLPriceSELL,          //set the SL
                              OrderTakeProfit(),   //for the unchanged take profit
                              0,                   //no expiration
                              CLR_NONE             //no color
                           );
               if(modify < 0)
                 {
                  Alert("Error Modifying Order!");
                 }

              } //if end for sell

      //Now for the BUY
      if(OrderType()==OP_BUY)
        {
         //If the stop loss is below the stop value
         if(OrderStopLoss() < CalSLPriceBUY)

            //We adjust the stop loss
            modify = OrderModify(
                        OrderTicket(),       //for the current order
                        OrderOpenPrice(),    //for the open price we had
                        CalSLPriceBUY,          //set the SL
                        OrderTakeProfit(),   //for the unchanged take profit
                        0,                   //no expiration
                        CLR_NONE             //no color
                     );

         if(modify < 0)
           {
            Alert("Error Modifying Order!");
           }
        } //if end for buy

     } //end of for loop

   return CalSPValue;

  } //end of CheckATRTrailingStop function
//+------------------------------------------------------------------+