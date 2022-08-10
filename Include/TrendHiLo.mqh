//+------------------------------------------------------------------+
//|                                                    TrendHiLo.mqh |
//|                                                           Emir E |
//|                                                  xpromarkets.com |
//+------------------------------------------------------------------+
#property copyright "Emir E"
#property link      "xpromarkets.com"
#property version   "1.0"
#property strict

#include <Object.mqh>

struct STrendPoint{
   int bar;
   double price;
   datetime time;
};

struct STrend {
   double slope;
   STrendPoint base;
};

class CTrendHiLo : public CObject {

private:

protected:

   string mSymbol;
   ENUM_TIMEFRAMES mTimeframe;
   
   int mStart;
   int mLength;
   
   STrend mUpperTrend;
   STrend mLowerTrend;
   
   double ValueAt(const int index, const STrend &trend);
   
public:

   CTrendHiLo(const int start=1, const int length=20);
   ~CTrendHiLo();
   
   void Update();
   void UpdateLower();
   void UpdateUpper();
   
   double UpperValueAt(const int index);
   double UpperValueAt(const datetime time);
   double LowerValueAt(const int index);
   double LowerValueAt(const datetime time);
   
   int Start()                { return(mStart); }
   void Start(int value)      { mStart=value; Update(); }
   int Length()               { return(mLength); }
   void Length(int value)     { mLength=value; Update(); }
   
};

CTrendHiLo::CTrendHiLo(const int start=1, const int length=20) {

   mSymbol = Symbol();
   mTimeframe = (ENUM_TIMEFRAMES)Period();
   
   mStart = start;
   mLength = length;
   
   Update();
   
}

CTrendHiLo::~CTrendHiLo() {
}

void CTrendHiLo::Update(){

   UpdateLower();
   UpdateUpper();
}

void CTrendHiLo::UpdateLower(){

   int firstBar = iLowest(mSymbol, mTimeframe, MODE_LOW, mLength, mStart);
   int nextBar = firstBar;
   
   double firstValue = 0;
   int midBar = mStart + (mLength/2);
   double bestSlope = 0;
   
   if(firstBar>=midBar) {  //Up slope
   
      while(nextBar>=midBar) {
         firstBar = nextBar;
         firstValue = iLow(mSymbol, mTimeframe, firstBar);
         bestSlope = 0;
         
         for (int i=firstBar-1; i>=mStart; i--) {  //count left to right
            int pos        = firstBar - i;
            double slope   = (iLow(mSymbol, mTimeframe, i)-firstValue)/pos; //positive slope           
            if (nextBar==firstBar || slope<bestSlope) { //least positive slope
               nextBar = i;
               bestSlope = slope;
            }
         }
       }  
         
     } else { //Down slope
      
         while(nextBar<midBar) {
         
            firstBar = nextBar;
            firstValue = iLow(mSymbol, mTimeframe, firstBar);
            bestSlope = 0;
            
            for(int i=firstBar+1; i<(mStart+mLength); i++){  //count right to left
               int pos = i-firstBar;
               double slope = (firstValue - iLow(mSymbol, mTimeframe, i))/pos; //negative slope
               if(nextBar==firstBar || slope>bestSlope) {      //least negative slope
                  nextBar = i;
                  bestSlope = slope;
               }
            }
         }
     }            

      mLowerTrend.slope       = bestSlope;
      mLowerTrend.base.bar    = firstBar;
      mLowerTrend.base.price  = firstValue;
      mLowerTrend.base.time   = iTime(mSymbol, mTimeframe, firstBar);
      
}
  

void CTrendHiLo::UpdateUpper(){

   int firstBar = iHighest(mSymbol, mTimeframe, MODE_HIGH, mLength, mStart);
   int nextBar = firstBar;
   
   double firstValue = 0;
   int midBar = mStart + (mLength/2);
   double bestSlope = 0;
   
   if(firstBar>=midBar) {  //Up slope
   
      while(nextBar>=midBar) {
         firstBar = nextBar;
         firstValue = iHigh(mSymbol, mTimeframe, firstBar);
         bestSlope = 0;
         
         for (int i=firstBar-1; i>=mStart; i--) {  //count left to right
            int pos        = firstBar - i;
            double slope   = (iHigh(mSymbol, mTimeframe, i)-firstValue)/pos; //negative slope           
            if (nextBar==firstBar || slope>bestSlope) { //least negative slope
               nextBar = i;
               bestSlope = slope;
            }
         }
       }  
         
     } else { //Up slope
      
         while(nextBar<midBar) {
         
            firstBar = nextBar;
            firstValue = iHigh(mSymbol, mTimeframe, firstBar);
            bestSlope = 0;
            
            for(int i=firstBar+1; i<(mStart+mLength); i++){  //count right to left
               int pos = i-firstBar;
               double slope = (firstValue - iHigh(mSymbol, mTimeframe, i))/pos; //negative slope
               if(nextBar==firstBar || slope<bestSlope) {      //least negative slope
                  nextBar = i;
                  bestSlope = slope;
               }
            }
         }
     }            

      mUpperTrend.slope       = bestSlope;
      mUpperTrend.base.bar    = firstBar;
      mUpperTrend.base.price  = firstValue;
      mUpperTrend.base.time   = iTime(mSymbol, mTimeframe, firstBar);
      
}

double CTrendHiLo::UpperValueAt(const int index) {

   return(ValueAt(index, mUpperTrend));
   
}

double CTrendHiLo::UpperValueAt(const datetime time){
   
   int index = iBarShift(mSymbol, mTimeframe, time, false);
   return(ValueAt(index, mUpperTrend));
   
}

double CTrendHiLo::LowerValueAt(const int index) {

   return(ValueAt(index, mLowerTrend));
   
}

double CTrendHiLo::LowerValueAt(const datetime time){
   
   int index = iBarShift(mSymbol, mTimeframe, time, false);
   return(ValueAt(index, mLowerTrend));
   
} 

double CTrendHiLo::ValueAt(const int index, const STrend &trend) {

   int offset = (trend.base.bar-index);
   double value = trend.base.price+(trend.slope*offset);
   return(value);

}


                              