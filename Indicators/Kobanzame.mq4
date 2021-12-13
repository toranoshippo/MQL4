//+------------------------------------------------------------------+
//|                                                    Kobanzame.mq4 |
//|                                     Copyright 2021, toranoshippo |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2021, toranoshippo"
#property link        ""
#property version     "1.00"
#property strict

#property description "RSI値が上限・下限にタッチしたら通知を出す"
#property description "***** 対応通貨*****"
#property description "EURUSD"
#property description "GBPUSD"
#property description "GBPJPY"
#property description "GBPAUD"
#property description "AUDUSD"
#property description "USDJPY"
#property description "USDCHF"
#property description "EURGBP"
#property description "EURJPY"
#property description "******************"


const string SYMBOL_LIST[] =
  {
     "EURUSD"
   , "GBPUSD"
   , "GBPJPY"
   , "GBPAUD"
   , "AUDUSD"
   , "USDJPY"
   , "USDCHF"
   , "EURGBP"
   , "EURJPY"
  };
  
// TODO: onInitで配列数を宣言することができなかったので他を探す
double rsiArray[9];// 9 -> SYMBOL_LIST length

int symbolSize;

//+------------------------------------------------------------------+
//| Parameter selection                                              |
//+------------------------------------------------------------------+
input ENUM_TIMEFRAMES TIMEFRAME = PERIOD_M15;// 時間軸

input const int RSI_TOP_LINE    = 70;        // RSIサインの上限値
input const int RSI_BOTTOM_LINE = 30;        // RSIサインの下限値
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   symbolSize = ArraySize(SYMBOL_LIST);

   for(int i = 0; i < symbolSize; i++)
     {
      rsiArray[i] = NormalizeDouble(
                      iRSI(SYMBOL_LIST[i], TIMEFRAME, 14, PRICE_CLOSE, 0)
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
    // 動作確認用
    // printf("--------");
    rsiSign();
  }
//+------------------------------------------------------------------+
//| RSI値が上限・下限にタッチしたらサインを出す                               |
//+------------------------------------------------------------------+
void rsiSign()
  {
   for(int i = 0; i < symbolSize; i++)
    {
      double rsiPrev = rsiArray[i];

      double rsiNow  = NormalizeDouble(
                         iRSI(SYMBOL_LIST[i], TIMEFRAME, 14, PRICE_CLOSE, 0)
                         , 2);
      rsiArray[i] = rsiNow;

      seekDirection(rsiPrev, rsiNow, SYMBOL_LIST[i]);
    }
  }
//+------------------------------------------------------------------+
//| 上下どちらからRSIラインにタッチしたか確認                                  |
//+------------------------------------------------------------------+
void seekDirection(
    double rsiPrev
  , double rsiNow
  , string symbol
)
  {
   // 動作確認用
   // printf(symbol+ " : " + TIMEFRAME + "本足" + rsiPrev + " -> : " + rsiNow);//////////////////

   if(rsiPrev != 0 && rsiPrev != rsiNow)
    {
      if(rsiPrev < RSI_TOP_LINE && rsiNow >= RSI_TOP_LINE)
       {
         // TODO: push通知
         printf(symbol + "下から70にタッチ：上げ");
       }
      else if(rsiPrev >= RSI_TOP_LINE && rsiNow <= RSI_TOP_LINE)
       {
         // TODO: push通知
         printf(symbol + "上から70にタッチ：下げ");
       }
      else if(rsiPrev >= RSI_BOTTOM_LINE && rsiNow <= RSI_BOTTOM_LINE)
       {
         // TODO: push通知
         printf(symbol + "上から30にタッチ：下げ");
       }
      else if(rsiPrev < RSI_BOTTOM_LINE && rsiNow >= RSI_BOTTOM_LINE)
       {
         // TODO: push通知
         printf(symbol + "下から30にタッチ：上げ");
       }
    }
  }
