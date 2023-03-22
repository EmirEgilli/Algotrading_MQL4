//+------------------------------------------------------------------+
//|                                        Stocks Pivot Telegram.mq4 |
//|                                                           Emir E |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Emir E"
#property link      ""
#property version   "1.3" 
#property strict

#include <Telegram Bot.mqh>
#include <TrendHiLo.mqh>

input int TrendStart = 1;
input int TrendLength = 36;
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
 
  string signalcurrent = "";
  string signalopen = "";
 //Price values for previous day : 
   double high1 = iHigh(_Symbol, PERIOD_D1, 1);
   double low1 = iLow(_Symbol, PERIOD_D1, 1);
   double close1 = iClose(_Symbol, PERIOD_D1, 1);
   
     //Mathematical methods
   double PivotPoint = NormalizeDouble((high1 + low1 + close1)/3,2);
   
   double Resistance = NormalizeDouble(2*PivotPoint - low1, 2);
   double Support = NormalizeDouble(2*PivotPoint - high1, 2);
   
   
  string BuyMessage = StringFormat("%s opened with BULLISH signal! Difference in Price: %.2f \r\n",_Symbol, NormalizeDouble(Close[0]-PivotPoint,2));
  string SellMessage = StringFormat("%s opened with BEARISH signal! Difference in Price: %.2f \r\n",_Symbol, NormalizeDouble(PivotPoint-Close[0],2));
   
   
    //Create Buy and Sell signals for current period
   if(Close[0] > PivotPoint)
   {
      signalcurrent = "BULLISH";
      
      if(Hour() == 16 && Minute() == 32 && Seconds() == 0)
      {         
   // Save a screen shot
   ChartRedraw(); // Make sure the chart is up to date
   ChartScreenShot( ChartID(), "MyScreenshot.png", 1024, 768, ALIGN_CENTER );

   SendTelegramMessage( TelegramApiUrl, TelegramBotToken, ChatId,
                                BuyMessage + TimeToString( TimeLocal() ),
                                "MyScreenshot.png" );
                                return;
      }
   }
   if(Close[0] < PivotPoint)
   {
      signalcurrent = "BEARISH";
      
      if(Hour() == 16 && Minute() == 32 && Seconds() == 0)
      {  
   // Save a screen shot
   ChartRedraw(); // Make sure the chart is up to date
   ChartScreenShot( ChartID(), "MyScreenshot.png", 1024, 768, ALIGN_CENTER );

   SendTelegramMessage( TelegramApiUrl, TelegramBotToken, ChatId,
                                SellMessage + TimeToString( TimeLocal() ),
                                "MyScreenshot.png" );
                                return;
      }
   }
   
      if(iClose(Symbol(),PERIOD_D1,0) > PivotPoint)
      {
      signalopen = "bullish";
      }
      if(iClose(Symbol(),PERIOD_D1,0) < PivotPoint)
      {
      signalopen = "bearish";
      }
   
   if(signalcurrent != "BULLISH" && signalcurrent != "BEARISH")
      {
      signalcurrent = "NEUTRAL";
      }   
      
         Comment("Previous day's highest price: ",high1,"\n",
         "Previous day's lowest price: ",low1,"\n",
         "Previous day's closing price: ",close1,"\n",
         "------------------------------------", "\n",
         "Previous day' Support: ",Support,"\n",
         "Previous day's Resistance: ",Resistance,"\n",
         "------------------------------------", "\n",
         "PIVOT POINT : ",PivotPoint,"\n",
         "OPENING SIGNAL: ",signalopen,"\n",
         "CURRENT SIGNAL: ",signalcurrent,"\n");   
            
  //Now to create a rectangle for S&R       
      string SessionEnd="16:31";      
      string CurrentTime=TimeToStr(TimeLocal(), TIME_SECONDS);      
      int EndPeriod = StringFind(CurrentTime, SessionEnd, 0);
      
      CTrendHiLo *trend = new CTrendHiLo(TrendStart, TrendLength);
   
      trend.Update();
   
     // PrintFormat("Upper at %i is %f", TrendStart+TrendLength, trend.UpperValueAt(TrendStart+TrendLength));
     // PrintFormat("Lower at %i is %f", TrendStart+TrendLength, trend.LowerValueAt(TrendStart+TrendLength));
      
      if(EndPeriod != -1)
      {
         ObjectDelete(0, "Support and Resistance");
         ObjectDelete(0, "UpperTrend");
         ObjectDelete(0, "LowerTrend");
         ObjectDelete(0, "PIVOT POINT");
      }
    
    if (signalcurrent == "BULLISH") {     
      ObjectCreate("Support and Resistance", OBJ_RECTANGLE, 0, iTime(Symbol(), PERIOD_D1, 1) , Resistance, iTime(Symbol(), PERIOD_D1, 0), Support);
      ObjectSetInteger(0, "Support and Resistance", OBJPROP_COLOR, clrDarkGreen);
      ObjectSetInteger(0, "Support and Resistance", OBJPROP_STYLE, STYLE_SOLID);
    }
    
    if (signalcurrent == "BEARISH") {
      ObjectCreate("Support and Resistance", OBJ_RECTANGLE, 0, iTime(Symbol(), PERIOD_D1, 1), Resistance, iTime(Symbol(), PERIOD_D1, 0), Support);
      ObjectSetInteger(0, "Support and Resistance", OBJPROP_COLOR, clrMaroon);
      ObjectSetInteger(0, "Support and Resistance", OBJPROP_STYLE, STYLE_SOLID);
    }  
    
    ObjectCreate(0, "UpperTrend", OBJ_TREND, 0, iTime(Symbol(), Period(), TrendStart+TrendLength), trend.UpperValueAt(TrendStart+TrendLength), iTime(Symbol(), Period(), 0), trend.UpperValueAt(0));
    ObjectSetInteger(0, "UpperTrend", OBJPROP_COLOR, clrChartreuse);
    ObjectSetInteger(0, "UpperTrend", OBJPROP_WIDTH, 2);
   
    ObjectCreate(0, "LowerTrend", OBJ_TREND, 0, iTime(Symbol(), Period(), TrendStart+TrendLength), trend.LowerValueAt(TrendStart+TrendLength), iTime(Symbol(), Period(), 0), trend.LowerValueAt(0));
    ObjectSetInteger(0, "LowerTrend", OBJPROP_COLOR, clrChartreuse);
    ObjectSetInteger(0, "LowerTrend", OBJPROP_WIDTH, 2);
   
    delete trend;
    
    ObjectCreate("PIVOT POINT", OBJ_HLINE, 0, iTime(Symbol(), PERIOD_D1, 0), PivotPoint);
    ObjectSetInteger(0, "PIVOT POINT", OBJPROP_COLOR, clrMediumBlue);
    ObjectSetInteger(0, "PIVOT POINT", OBJPROP_WIDTH, 2);       
   
}
