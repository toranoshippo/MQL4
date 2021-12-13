//+------------------------------------------------------------------+
//|                                                    Kobanzame.mq4 |
//|                                     Copyright 2021, toranoshippo |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2021, toranoshippo"
#property link        ""
#property version     "1.00"
#property description "RSI値が上限・下限にタッチしたらサインを出す"
#property strict

const int BAR_LIST[] =
  {
   PERIOD_M15
   , PERIOD_H1
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

double rsiPrev, rsiNow;
int symbolSize, barSize;

input const int RSI_TOP_LINE    = 70;// RSIサインの上限値
input const int RSI_BOTTOM_LINE = 30;// RSIサインの下限値


double rsiArray[9];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   Alert("start");
   barSize    = ArraySize(BAR_LIST);
   symbolSize = ArraySize(SYMBOL_LIST);
   
   for(int i = 0; i < symbolSize; i++)
     {
      rsiArray[i] = NormalizeDouble(
                      iRSI(SYMBOL_LIST[i], PERIOD_M15, 14, PRICE_CLOSE, 0)
                      , 2);
     }
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
   for(int i = 0; i < barSize; i++)
    {
      rsiSign(BAR_LIST[i]);
    }
  }
//+------------------------------------------------------------------+
//| RSI値が上限・下限にタッチしたらサインを出す                               |
//+------------------------------------------------------------------+
int rsiSign(const int BAR_TIME)
  {
   for(int i = 0; i < symbolSize; i++)
    {
      rsiPrev = rsiArray[i];
      
      rsiNow = NormalizeDouble(
                 iRSI(SYMBOL_LIST[i], BAR_TIME, 14, PRICE_CLOSE, 0)
                 , 2);
      rsiArray[i] = rsiNow;

      seekDirection(BAR_TIME, SYMBOL_LIST[i]);
    }
   return 0;
  }
//+------------------------------------------------------------------+
//| 上下どちらからRSIラインにタッチしたか探索                                  |
//+------------------------------------------------------------------+
void seekDirection(const int BAR_TIME, const string SYMBOL)
  {
   if(rsiPrev != rsiNow)
    {
      if(rsiPrev < RSI_TOP_LINE && rsiNow >= RSI_TOP_LINE)
       {
         printf(BAR_TIME + "本足" + rsiPrev + " -> : " + rsiNow);//////////////////
         // TODO: push通知
         printf(SYMBOL + "下から70にタッチ：上げ");
       }
      else if(rsiPrev >= RSI_TOP_LINE && rsiNow <= RSI_TOP_LINE)
       {
         printf(BAR_TIME + "本足" + rsiPrev + " -> : " + rsiNow);//////////////////
         // TODO: push通知
         printf(SYMBOL + "上から70にタッチ：下げ");
       }
      else if(rsiPrev >= RSI_BOTTOM_LINE && rsiNow <= RSI_BOTTOM_LINE)
       {
         printf(BAR_TIME + "本足" + rsiPrev + " -> : " + rsiNow);//////////////////
         // TODO: push通知
         printf(SYMBOL + "上から30にタッチ：下げ");
       }
      else if(rsiPrev < RSI_BOTTOM_LINE && rsiNow >= RSI_BOTTOM_LINE)
       {
         printf(BAR_TIME + "本足" + rsiPrev + " -> : " + rsiNow);//////////////////
         // TODO: push通知
         printf(SYMBOL + "下から30にタッチ：上げ");
       }
    }
  }