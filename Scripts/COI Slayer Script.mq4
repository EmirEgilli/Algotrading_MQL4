//+------------------------------------------------------------------+
//|                                            COI Slayer Script.mq4 |
//|                                                           Emir E |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Emir E"
#property link      ""
#property version   "1.00"
#property strict
#property script_show_inputs

enum Direction {
   BUY = 1,
   SELL = 2,
   };
   
 input Direction Mode = 1;
extern double Size = 100;
 
 static int ticket = 0;

void OnStart()
  {
      
     if(OrdersTotal() == 0 && Mode == 1)
      {
         ticket = OrderSend(Symbol(), OP_BUY, Size, Ask, 10, 0, Ask+120*Point, NULL, 666666, 0, Blue);
            if(ticket < 0)  { Alert("Error Sending Order! Error Code: ", GetLastError()); } 

         ticket = OrderSend(Symbol(), OP_BUY, Size, Ask, 10, 0, Ask+120*Point, NULL, 666666, 0, Blue);
            if(ticket < 0)  { Alert("Error Sending Order! Error Code: ", GetLastError()); } 

         ticket = OrderSend(Symbol(), OP_BUY, Size, Ask, 10, 0, Ask+110*Point, NULL, 666666, 0, Blue);
            if(ticket < 0)  { Alert("Error Sending Order! Error Code: ", GetLastError()); } 

         ticket = OrderSend(Symbol(), OP_BUY, Size, Ask, 10, 0, Ask+110*Point, NULL, 666666, 0, Blue);
            if(ticket < 0)  { Alert("Error Sending Order! Error Code: ", GetLastError()); } 

         ticket = OrderSend(Symbol(), OP_BUY, Size, Ask, 10, 0, Ask+100*Point, NULL, 666666, 0, Blue);
            if(ticket < 0)  { Alert("Error Sending Order! Error Code: ", GetLastError()); }
            
            return;
      } //End of BUY
      
    if(OrdersTotal() == 0 && Mode == 2)
      {                           
         ticket = OrderSend(Symbol(), OP_SELL, Size, Bid, 10, 0, Bid-120*Point, NULL, 666666, 0, Red);
            if(ticket < 0)  { Alert("Error Sending Order! Error Code: ", GetLastError()); } 
            
         ticket = OrderSend(Symbol(), OP_SELL, Size, Bid, 10, 0, Bid-120*Point, NULL, 666666, 0, Red);
            if(ticket < 0)  { Alert("Error Sending Order! Error Code: ", GetLastError()); }
         
         ticket = OrderSend(Symbol(), OP_SELL, Size, Bid, 10, 0, Bid-110*Point, NULL, 666666, 0, Red);
            if(ticket < 0)  { Alert("Error Sending Order! Error Code: ", GetLastError()); } 
            
         ticket = OrderSend(Symbol(), OP_SELL, Size, Bid, 10, 0, Bid-110*Point, NULL, 666666, 0, Red);
            if(ticket < 0)  { Alert("Error Sending Order! Error Code: ", GetLastError()); }  
            
         ticket = OrderSend(Symbol(), OP_SELL, Size, Bid, 10, 0, Bid-100*Point, NULL, 666666, 0, Red);
            if(ticket < 0)  { Alert("Error Sending Order! Error Code: ", GetLastError()); } 
            
            return;
      } //End of SELL               
   
  } //End of OnStart

