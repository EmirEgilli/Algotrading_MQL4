//+------------------------------------------------------------------+
//|                                                    TrendHiLo.mq4 |
//|                                                           Emir E |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Emir E"
#property link      ""
#property version   "1.00"
#property script_show_inputs
#property strict


#include <TrendHiLo.mqh>

input int TrendStart = 1;
input int TrendLength = 50;

void OnStart()
  {

   CTrendHiLo *trend = new CTrendHiLo(TrendStart, TrendLength);
   
   trend.Update();
   
   PrintFormat("Upper at %i is %f", TrendStart+TrendLength, trend.UpperValueAt(TrendStart+TrendLength));
   PrintFormat("Lower at %i is %f", TrendStart+TrendLength, trend.LowerValueAt(TrendStart+TrendLength));
   
   ObjectDelete(0, "UpperTrend");
   ObjectDelete(0, "LowerTrend");
   
   ObjectCreate(0, "UpperTrend", OBJ_TREND, 0, iTime(Symbol(), Period(), TrendStart+TrendLength), trend.UpperValueAt(TrendStart+TrendLength), iTime(Symbol(), Period(), 0), trend.UpperValueAt(0));
   ObjectSetInteger(0, "UpperTrend", OBJPROP_COLOR, clrChartreuse);
   ObjectSetInteger(0, "UpperTrend", OBJPROP_WIDTH, 2);
   
   ObjectCreate(0, "LowerTrend", OBJ_TREND, 0, iTime(Symbol(), Period(), TrendStart+TrendLength), trend.LowerValueAt(TrendStart+TrendLength), iTime(Symbol(), Period(), 0), trend.LowerValueAt(0));
   ObjectSetInteger(0, "LowerTrend", OBJPROP_COLOR, clrChartreuse);
   ObjectSetInteger(0, "LowerTrend", OBJPROP_WIDTH, 2);
   
   delete trend;
   
  }
