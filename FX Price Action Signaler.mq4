//+------------------------------------------------------------------+
//|                                     FX Price Action Signaler.mq4 |
//|                                                           Emir E |
//|                                                  xpromarkets.com |
//+------------------------------------------------------------------+
#property copyright "Emir E"
#property link      "xpromarkets.com"
#property version   "1.2"
#property strict


#include <Telegram Bot.mqh>
#include <TrendHiLo.mqh>

input int TrendStart = 1;
input int TrendLength = 50;

      //Current chart, current period, number of candles, no shift, simple, current close price
   double CurrentMainMACD = iMACD(Symbol(), Period(), 24, 50, 9, PRICE_CLOSE, MODE_MAIN, 0);

//Current chart, current period, number of candles, no shift, simple, previous close price
   double PreviousMainMACD = iMACD(Symbol(),  Period(), 24, 50, 9, PRICE_CLOSE, MODE_MAIN, 1);

//Current chart, current period, number of candles, no shift, simple, current close price
   double CurrentSignalMACD = iMACD(Symbol(),  Period(), 24, 50, 9, PRICE_CLOSE, MODE_SIGNAL, 0);

//Current chart, current period, number of candles, no shift, simple, previous close price
   double PreviousSignalMACD = iMACD(Symbol(),  Period(), 24, 50, 9, PRICE_CLOSE, MODE_SIGNAL, 1);
   
   double PrevEMA = iMA(NULL, 0, 200, 0, MODE_EMA, PRICE_CLOSE, 1);
   double CurrEMA = iMA(NULL, 0, 200, 0, MODE_EMA, PRICE_CLOSE, 0);

void OnTick()
  {

   double ATRValue15m = NormalizeDouble(iATR(_Symbol, PERIOD_M15, 14, 0), 4);
   double ATRValue1h = NormalizeDouble(iATR(_Symbol, PERIOD_H1, 14, 0), 4);
   
   double TP15m = NormalizeDouble((ATRValue15m * 100000),0);
   double TP1h = NormalizeDouble((ATRValue1h * 100000),0);
   
//---- Candle4 OHLC
double O4=NormalizeDouble(iOpen(Symbol(),PERIOD_CURRENT,4),4);
double H4=NormalizeDouble(iHigh(Symbol(),PERIOD_CURRENT,4),4);
double L4=NormalizeDouble(iLow(Symbol(),PERIOD_CURRENT,4),4);
double C4=NormalizeDouble(iClose(Symbol(),PERIOD_CURRENT,4),4);

//---- Candle3 OHLC
double O3=NormalizeDouble(iOpen(Symbol(),PERIOD_CURRENT,3),4);
double H3=NormalizeDouble(iHigh(Symbol(),PERIOD_CURRENT,3),4);
double L3=NormalizeDouble(iLow(Symbol(),PERIOD_CURRENT,3),4);
double C3=NormalizeDouble(iClose(Symbol(),PERIOD_CURRENT,3),4);
   
//---- Candle2 OHLC
double O2=NormalizeDouble(iOpen(Symbol(),PERIOD_CURRENT,2),4);
double H2=NormalizeDouble(iHigh(Symbol(),PERIOD_CURRENT,2),4);
double L2=NormalizeDouble(iLow(Symbol(),PERIOD_CURRENT,2),4);
double C2=NormalizeDouble(iClose(Symbol(),PERIOD_CURRENT,2),4);

//---- Candle1 OHLC
double O1=NormalizeDouble(iOpen(Symbol(),PERIOD_CURRENT,1),4);
double H1=NormalizeDouble(iHigh(Symbol(),PERIOD_CURRENT,1),4);
double L1=NormalizeDouble(iLow(Symbol(),PERIOD_CURRENT,1),4);
double C1=NormalizeDouble(iClose(Symbol(),PERIOD_CURRENT,1),4);

   string signal ="";
   string PriceAction = "";
   
    // Old ATR Value
   static double OldValue;
   
     string BuyMessage = StringFormat("%s triggered the EMPTY signal in %d minutes timeframe! Suggested PIP range in TP: %.2f to %.2f \r\n", _Symbol, _Period, TP15m, TP1h);
     string SellMessage = StringFormat("%s triggered the EMPTY signal in %d minutes timeframe! Suggested PIP range in TP: %.2f to %.2f \r\n", _Symbol, _Period, TP15m, TP1h);
   
   //To make sure only one signal is given per candle
   static datetime prevtime = 0;

   if(prevtime == Time[0])
     return;
   prevtime = Time[0];
  {
  
   //Create Buy and Sell signals
      if(ATRValue15m>OldValue)                  //If ATR goes up
         {
   signal = "Looking for Buy";
         }

      if(ATRValue15m<OldValue || OldValue==0)  //If ATR goes down
         {
   signal = "Looking for Sell";
         }
      
      
      if(signal == "Looking for Buy")
   {
      //---- Pattern 1 - bullish 
      if(C2 >= O2 && L2 < O2 && ((O2-L2)>(C2-O2)) && C1 >= O1 && C1 > H2 && L1 > L2)
      { 
              PriceAction = "Bullish Kicking";
              StringReplace(BuyMessage, "EMPTY", PriceAction);
   // Save a screen shot
   ChartRedraw(); // Make sure the chart is up to date
   ChartScreenShot( ChartID(), "MyScreenshot.png", 1024, 768, ALIGN_CENTER );

   SendTelegramMessage( TelegramApiUrl, TelegramBotToken, ChatId,
                                BuyMessage + TimeToString( TimeLocal() ),
                                "MyScreenshot.png" );  
               return;  
      }
      
      //---- Pattern 2 - bullish
      if(C2 < O2 && C1 > O1 && ((O2-C2)>(H2-O2)) && ((O2-C2)>(C2-L2)) && ((C1-O1)>(H1-C1)) && ((C1-O1)>(O1-L1)) && O1 <= C2 && O1 >= L2 && C1 >= O2 && C1 <= H2)
      {
               PriceAction = "Bullish Engulfing";
               StringReplace(BuyMessage, "EMPTY", PriceAction); 
   // Save a screen shot
   ChartRedraw(); // Make sure the chart is up to date
   ChartScreenShot( ChartID(), "MyScreenshot.png", 1024, 768, ALIGN_CENTER );

   SendTelegramMessage( TelegramApiUrl, TelegramBotToken, ChatId,
                                BuyMessage + TimeToString( TimeLocal() ),
                                "MyScreenshot.png" );   
               return;
      }
      
      //---- Pattern 3 - bullish
      if(C2 > O2 && ((C1-O1)>=(H1-C1)) && C1 > O1 && C1 > C2)
      { 
               PriceAction = "Bullish Piercing";
               StringReplace(BuyMessage, "EMPTY", PriceAction); 
   // Save a screen shot
   ChartRedraw(); // Make sure the chart is up to date
   ChartScreenShot( ChartID(), "MyScreenshot.png", 1024, 768, ALIGN_CENTER );

   SendTelegramMessage( TelegramApiUrl, TelegramBotToken, ChatId,
                                BuyMessage + TimeToString( TimeLocal() ),
                                "MyScreenshot.png" );             
               return;
      }  
      //---- Pattern 4 - bullish
      if(C4 < O4 && C3 < O3 && C2 < O2 && C1 > O1 && C4 > C3 && C3 > C2 && C1 >= O4)
      { 
               PriceAction = "Bullish Three-Line Strike";
               StringReplace(BuyMessage, "EMPTY", PriceAction); 
   // Save a screen shot
   ChartRedraw(); // Make sure the chart is up to date
   ChartScreenShot( ChartID(), "MyScreenshot.png", 1024, 768, ALIGN_CENTER );

   SendTelegramMessage( TelegramApiUrl, TelegramBotToken, ChatId,
                                BuyMessage + TimeToString( TimeLocal() ),
                                "MyScreenshot.png" );             
               return;
      }                    
   } //end of BUY signal 
   
   //Open SELL position
   if(signal == "Looking for Sell")
   {
    
     //---- Pattern 1 - bearish
     if(C2 <= O2 && H2 > O2 && ((H2-O2)>(O2-C2)) && C1 <= O1 && C1 < L2 && H1 < H2)
     { 
              PriceAction = "Bearish Kicking";
              StringReplace(SellMessage, "EMPTY", PriceAction);
              
   // Save a screen shot
   ChartRedraw(); // Make sure the chart is up to date
   ChartScreenShot( ChartID(), "MyScreenshot.png", 1024, 768, ALIGN_CENTER );

   SendTelegramMessage( TelegramApiUrl, TelegramBotToken, ChatId,
                                SellMessage + TimeToString( TimeLocal() ),
                                "MyScreenshot.png" );  
               return;
     }
     
     //---- Pattern 2 - bearish
     if(C2 > O2 && C1 < O1 && ((C2-O2)>(H2-C2)) && ((C2-O2)>(O2-L2)) && ((O1-C1)>(H1-O1)) && ((O1-C1)>(C1-L1)) && O1 >= C2 && O1 <= H2 && C1 <= O2 && C1 >= L2)
     { 
             PriceAction = "Bearish Engulfing";
             StringReplace(SellMessage, "EMPTY", PriceAction);
   // Save a screen shot
   ChartRedraw(); // Make sure the chart is up to date
   ChartScreenShot( ChartID(), "MyScreenshot.png", 1024, 768, ALIGN_CENTER );

   SendTelegramMessage( TelegramApiUrl, TelegramBotToken, ChatId,
                                SellMessage + TimeToString( TimeLocal() ),
                                "MyScreenshot.png" ); 
               return;
     }
     
     //---- Pattern 3 - bearish
     if(C2 < O2 && ((O1-C1)>=(C1-L1)) && C1 < O1 && C1 < C2)
     { 
             PriceAction = "Bearish Piercing";
             StringReplace(SellMessage, "EMPTY", PriceAction);            
   // Save a screen shot
   ChartRedraw(); // Make sure the chart is up to date
   ChartScreenShot( ChartID(), "MyScreenshot.png", 1024, 768, ALIGN_CENTER );

   SendTelegramMessage( TelegramApiUrl, TelegramBotToken, ChatId,
                                SellMessage + TimeToString( TimeLocal() ),
                                "MyScreenshot.png" ); 
               return;
     }
     
     //---- Pattern 4 - bearish
     if(C4 > O4 && C3 > O3 && C2 > O2 && C1 < O1 && C4 < C3 && C3 < C2 && C1 <= O4)
     { 
             PriceAction = "Bearish Three-Line Strike";
             StringReplace(SellMessage, "EMPTY", PriceAction);            
   // Save a screen shot
   ChartRedraw(); // Make sure the chart is up to date
   ChartScreenShot( ChartID(), "MyScreenshot.png", 1024, 768, ALIGN_CENTER );

   SendTelegramMessage( TelegramApiUrl, TelegramBotToken, ChatId,
                                SellMessage + TimeToString( TimeLocal() ),
                                "MyScreenshot.png" ); 
               return;
     }               
   } //End of SELL signal 
   
   
 //Assing current value to old value
   OldValue=ATRValue15m;
   
     //Now to create objects       
     // string SessionEnd="23:55";      
     // string CurrentTime=TimeToStr(TimeLocal(), TIME_SECONDS);      
     // int EndPeriod = StringFind(CurrentTime, SessionEnd, 0);
      
      CTrendHiLo *trend = new CTrendHiLo(TrendStart, TrendLength);
   
      trend.Update();
   
      //PrintFormat("Upper at %i is %f", TrendStart+TrendLength, trend.UpperValueAt(TrendStart+TrendLength));
      //PrintFormat("Lower at %i is %f", TrendStart+TrendLength, trend.LowerValueAt(TrendStart+TrendLength));
      
     // if(EndPeriod != -1)
    //  {
         ObjectDelete(0, "UpperTrend");
         ObjectDelete(0, "LowerTrend");
    //  }
    
    
    ObjectCreate(0, "UpperTrend", OBJ_TREND, 0, iTime(Symbol(), Period(), TrendStart+TrendLength), trend.UpperValueAt(TrendStart+TrendLength), iTime(Symbol(), Period(), 0), trend.UpperValueAt(0));
    ObjectSetInteger(0, "UpperTrend", OBJPROP_COLOR, clrChartreuse);
    ObjectSetInteger(0, "UpperTrend", OBJPROP_WIDTH, 2);
   
    ObjectCreate(0, "LowerTrend", OBJ_TREND, 0, iTime(Symbol(), Period(), TrendStart+TrendLength), trend.LowerValueAt(TrendStart+TrendLength), iTime(Symbol(), Period(), 0), trend.LowerValueAt(0));
    ObjectSetInteger(0, "LowerTrend", OBJPROP_COLOR, clrChartreuse);
    ObjectSetInteger(0, "LowerTrend", OBJPROP_WIDTH, 2);
   
    delete trend; 
    
    //Call the MaCD & EMA filter
    MacDFilter();
    //EMAFilter();
     
  } //End of prevtime
}  //End of OnTick


void MacDFilter()
{
      
   string CAM = StringFormat("%s just prompted Bullish Crossover on MaCD in %d minutes timeframe! \r\n", _Symbol, _Period);
   string CBM = StringFormat("%s just prompted Bearish Crossover on MaCD in %d minutes timeframe! \r\n", _Symbol, _Period);
   
   //Bullish Crossover
      if(CurrentMainMACD > CurrentSignalMACD && PreviousMainMACD < PreviousSignalMACD && CurrentMainMACD < 0)
        {
         //Chart output for BUY signal
         // Save a screen shot
   ChartRedraw(); // Make sure the chart is up to date
   ChartScreenShot( ChartID(), "MyScreenshot.png", 1024, 768, ALIGN_CENTER );

   SendTelegramMessage( TelegramApiUrl, TelegramBotToken, ChatId,
                                CAM + TimeToString( TimeLocal() ),
                                "MyScreenshot.png" ); 
               return;  
        }
        
      //Bearish Crossover
      if(CurrentMainMACD < CurrentSignalMACD && PreviousMainMACD > PreviousSignalMACD && CurrentMainMACD > 0)
        {
         //Chart output for SELL signal
         // Save a screen shot
   ChartRedraw(); // Make sure the chart is up to date
   ChartScreenShot( ChartID(), "MyScreenshot.png", 1024, 768, ALIGN_CENTER );

   SendTelegramMessage( TelegramApiUrl, TelegramBotToken, ChatId,
                                CBM + TimeToString( TimeLocal() ),
                                "MyScreenshot.png" ); 
               return;  
        }
}

void EMAFilter()
{

   string CAM = StringFormat("%s price just crossed above 200EMA in %d minutes timeframe! \r\n", _Symbol, _Period);
   string CBM = StringFormat("%s price just crossed below 200EMA in %d minutes timeframe! \r\n", _Symbol, _Period);
   
   double PrevCandle = iClose(_Symbol, _Period, 1);
   double CurrCandle = iClose(_Symbol, _Period, 0);

   if(PrevCandle > PrevEMA && CurrCandle < CurrEMA)
   {
          //Chart output for SELL signal
         // Save a screen shot
   ChartRedraw(); // Make sure the chart is up to date
   ChartScreenShot( ChartID(), "MyScreenshot.png", 1024, 768, ALIGN_CENTER );

   SendTelegramMessage( TelegramApiUrl, TelegramBotToken, ChatId,
                                CBM + TimeToString( TimeLocal() ),
                                "MyScreenshot.png" ); 
               return;  
   }
   
   if(PrevCandle < PrevEMA && CurrCandle > CurrEMA)
   {
          //Chart output for SELL signal
         // Save a screen shot
   ChartRedraw(); // Make sure the chart is up to date
   ChartScreenShot( ChartID(), "MyScreenshot.png", 1024, 768, ALIGN_CENTER );

   SendTelegramMessage( TelegramApiUrl, TelegramBotToken, ChatId,
                                CAM + TimeToString( TimeLocal() ),
                                "MyScreenshot.png" ); 
               return;  
   }
}       