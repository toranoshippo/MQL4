//+------------------------------------------------------------------+
//|                                                  SendPostRsi.mq4 |
//|                                     Copyright 2021, toranoshippo |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, toranoshippo"
#property link      ""
#property version   "1.00"
#property strict

const int BAR_LIST[] =
  {
   PERIOD_M1
   , PERIOD_M5
   , PERIOD_M15
   , PERIOD_M30
   , PERIOD_H1
   , PERIOD_H4
   , PERIOD_D1
  };
const string SYMBOL_LIST[] =
  {
   "EURUSD"

   , "GBPUSD"
   , "GBPJPY"
   , "GBPAUD"

   , "AUDUSD"
//, "AUDJPY"

   , "USDJPY"
//, "USDCAD"
   , "USDCHF"

   , "EURGBP"
   , "EURJPY"
  };
const string DQ = "\"";
int symbol_size, bar_size;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   bar_size    = ArraySize(BAR_LIST);
   symbol_size = ArraySize(SYMBOL_LIST);
   EventSetTimer(5);// OnTimerを５秒間隔に呼び出す
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
   const int      rates_total
   , const int      prev_calculated
   , const datetime &time[]
   , const double   &open[]
   , const double   &high[]
   , const double   &low[]
   , const double   &close[]
   , const long     &tick_volume[]
   , const long     &volume[]
   , const int      &spread[]
)
  {
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   for(int i = 0; i < bar_size; i++)
     {
      string json_data = createJson(BAR_LIST[i]);
      string url = "http://";
      
      int res = sendPost(json_data, url);
     }
  }
//+------------------------------------------------------------------+
//| Calculate the RSI value and create json function                 |
//+------------------------------------------------------------------+
string createJson(int bar_title)
  {
   string json_data = "{" + DQ + bar_title + DQ + ": {";

   for(int i = 0; i < symbol_size; i++)
     {
      double rsiNow = iRSI(SYMBOL_LIST[i], bar_title, 14, PRICE_CLOSE, 0);
      rsiNow = NormalizeDouble(rsiNow, 2);
      json_data += DQ + SYMBOL_LIST[i] + DQ + ":" + DQ + rsiNow + DQ ;//+ ",";
      if(i+1 != symbol_size)
        {
         json_data += ",";
        }
     }

   return json_data += "}}";
  }
//+------------------------------------------------------------------+
//| Send post function                                               |
//+------------------------------------------------------------------+
int sendPost(string createJson, string url)
  {
   char post[],result[];
   string headers = "Content-Type: application/json\r\n";
   ArrayResize(post, StringToCharArray(createJson, post, 0, WHOLE_ARRAY,CP_UTF8) -1);
   return WebRequest("POST", url, headers, 5000, post, result, headers);
  }
//+------------------------------------------------------------------+
