//+------------------------------------------------------------------+
//|                                                    Kobanzame.mq4 |
//|                                     Copyright 2021, toranoshippo |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2021, toranoshippo"
#property link        ""
#property version     "1.00"
#property indicator_chart_window
#property strict

#property description "RSI値が上限・下限にタッチしたら通知を出す"
#property description "********** 対応通貨 **********"
#property description "EURUSD, GBPUSD, GBPJPY"
#property description "GBPAUD, AUDUSD, USDJPY"
#property description "USDCHF, EURGBP, EURJPY"
#property description "*****************************"

const string SYMBOL_LIST[] =
  {
     "EURUSD"
   , "EURGBP"
   , "EURJPY"
   , "GBPUSD"
   , "GBPJPY"
   , "GBPAUD"
   , "AUDUSD"
   , "USDJPY"
   , "USDCHF"
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

   // EventSetTimer(5);// OnTimerを５秒間隔に呼び出す
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
   rsiSign();
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
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

      string pushMessage = getPushMessage(SYMBOL_LIST[i], rsiPrev, rsiNow);
     
      // TODO : 5分以内に通知があればスルー
      if(pushMessage != "")
       {
         SendNotification(pushMessage);
         // Alert("\n" + pushMessage);
         printf("***********" + pushMessage + "***********");
       }
    }
  }
//+------------------------------------------------------------------+
//| 上下どちらからRSIラインにタッチしたか確認                                  |
//+------------------------------------------------------------------+
string getPushMessage(
    const string symbol
  , const double rsiPrev
  , const double rsiNow
)
  {
   string pushMessage = "";
   if(rsiPrev != 0 && rsiPrev != rsiNow)
    {
      if(rsiPrev < RSI_TOP_LINE && rsiNow >= RSI_TOP_LINE)
       {
         pushMessage = createPushMessage(symbol, rsiPrev, rsiNow, "下", RSI_TOP_LINE, "上げ");
       }
      else if(rsiPrev >= RSI_TOP_LINE && rsiNow <= RSI_TOP_LINE)
       {
         pushMessage = createPushMessage(symbol, rsiPrev, rsiNow, "上", RSI_TOP_LINE, "下げ");
       }
      else if(rsiPrev >= RSI_BOTTOM_LINE && rsiNow <= RSI_BOTTOM_LINE)
       {
         pushMessage = createPushMessage(symbol, rsiPrev, rsiNow, "上", RSI_BOTTOM_LINE, "下げ");
       }
      else if(rsiPrev < RSI_BOTTOM_LINE && rsiNow >= RSI_BOTTOM_LINE)
       {
         pushMessage = createPushMessage(symbol, rsiPrev, rsiNow, "下", RSI_BOTTOM_LINE, "上げ");
       }
    }
    return pushMessage;
  }
//+------------------------------------------------------------------+
//| Example: EURUSD : 15本足29.29->31下から30にタッチ：上げ                |
//+------------------------------------------------------------------+
string createPushMessage(
    const string symbol
  , const double rsiPrev
  , const double rsiNow
  , const string direction
  , const int    line
  , const string status
)
 {
   return symbol + " : " + TIMEFRAME + "本足" + rsiPrev + "->" + rsiNow +  direction + "から" + line + "を交差：" + status;
 }
