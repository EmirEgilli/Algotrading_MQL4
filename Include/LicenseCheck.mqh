#property copyright "Emir E"
#property link      ""

#property strict

bool  LicenseCheck(string license="") {
 
   bool  valid =  false;
 
#ifdef LIC_TRADE_MODES 
      valid = false;
      int validModes[] = LIC_TRADE_MODES;
      long accountTradeMode = AccountInfoInteger(ACCOUNT_TRADE_MODE);
      for (int i=ArraySize(validModes)-1; i>=0; i--) {
      if (accountTradeMode==validModes[i]) {
         valid =  true;
         break;
      }
   }
   if (!valid) {
      Print("This is a limited trial version, it will not work on this type of account");
      return(false);
   }
#endif  

#ifdef LIC_SYMBOLS

valid = false;
      string validSymbols[] = LIC_SYMBOLS;
      long accountTradeMode = AccountInfoInteger(ACCOUNT_TRADE_MODE);
      for (int i=ArraySize(validSymbols)-1; i>=0; i--) {
      if (Symbol()==validSymbols[i]) {
         valid =  true;
         break;
      }
   }
   if (!valid) {
      Print("This is a limited version, it will not work on symbol: " +Symbol());
      return(false);
   }
#endif

#ifdef LIC_EXPIRES_DAYS
   #ifndef LIC_EXPIRES_START
      #define LIC_EXPIRES_START  __DATETIME__
   #endif
    
   datetime expiredDate =  LIC_EXPIRES_START + (LIC_EXPIRES_DAYS*86400);
   PrintFormat("Time limited copy, license to use expires at %s", TimeToString(expiredDate));
   if (TimeCurrent()>expiredDate) {
      Print("License to use has expired, please contact your Senior Account Manager.");
      return(false);
   }
#endif

#ifdef LIC_PRIVATE_KEY
   long account = AccountInfoInteger(ACCOUNT_LOGIN);
   account = 1029678;
   string result = KeyGen(IntegerToString(account), LIC_PRIVATE_KEY);
  
   if(result != license){
   Print("Invalid License!");
   return(false);
   }
#endif
   
     return(true);
    
}

string KeyGen(string account, string privateKey){
   uchar accountChar[];
   StringToCharArray(account, accountChar);
   
   uchar keyChar[];
   StringToCharArray(privateKey, keyChar);
   
   uchar resultChar [];
   CryptEncode(CRYPT_HASH_SHA256, accountChar, keyChar, resultChar);
   CryptEncode(CRYPT_BASE64, resultChar, resultChar, resultChar);
   
   string result = CharArrayToString(resultChar);
   return(result);

}