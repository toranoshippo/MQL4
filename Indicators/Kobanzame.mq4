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
#property description "EURUSD, EURGBP, EURJPY"
#property description "GBPUSD, GBPJPY, GBPAUD"
#property description "AUDUSD, USDJPY, USDCHF"
#property description "*****************************"

const int _BAR_LIST[] =
  {
   //PERIOD_M1
   //, PERIOD_M5
   PERIOD_M15
   //, PERIOD_M30
   , PERIOD_H1
   //, PERIOD_H4
   //, PERIOD_D1
  };
const string _SYMBOL_LIST[] =
  {
     "EURUSD", "EURGBP", "EURJPY"
   , "GBPUSD", "GBPJPY", "GBPAUD"
   , "AUDUSD", "USDJPY", "USDCHF"
  };

// TODO: onInitで配列数を宣言することができなかったので他を探す
double _rsiArray[2][9];//[_BAR_LIST.length][_SYMBOL_LIST.length]
int _symbolSize, _barSize;;
//+------------------------------------------------------------------+
//| Parameter selection                                              |
//+------------------------------------------------------------------+
input const int _RSI_TOP_LINE    = 70;        // RSIサインの上限値
input const int _RSI_BOTTOM_LINE = 30;        // RSIサインの下限値
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   _symbolSize = ArraySize(_SYMBOL_LIST);
   _barSize    = ArraySize(_BAR_LIST);
 
  for(int i = 0; i < _barSize; i++)
    {
     for(int j = 0; j < _symbolSize; j++)
       {
        _rsiArray[i][j] = NormalizeDouble(iRSI(_SYMBOL_LIST[j], _BAR_LIST[i], 14, PRICE_CLOSE, 0), 2);
       }
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
void OnTimer(){ rsiSign(); }
//+------------------------------------------------------------------+
//| RSI値が上限・下限にタッチしたらサインを出す                                |
//+------------------------------------------------------------------+
void rsiSign()
  {
   for(int i = 0; i < _barSize; i++)
     {
      for(int j = 0; j < _symbolSize; j++)
        {
         double rsiPrev = _rsiArray[i][j];
         double rsiNow  = NormalizeDouble(iRSI(_SYMBOL_LIST[j], _BAR_LIST[i], 14, PRICE_CLOSE, 0), 2);
         _rsiArray[i][j] = rsiNow;

         string pushMessage = getPushMessage(_SYMBOL_LIST[j], _BAR_LIST[i], rsiPrev, rsiNow);

         if(pushMessage != "")
           {
            SendNotification(pushMessage);
            printf(pushMessage);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| 上下どちらからRSIラインにタッチしたか確認                                  |
//+------------------------------------------------------------------+
string getPushMessage(
    const string symbol
  , const int    TIMEFRAME
  , const double rsiPrev
  , const double rsiNow
)
  {
   if(rsiPrev != 0 && rsiPrev != rsiNow)
     {
      switch(checkDirection(rsiPrev, rsiNow))
        {
         case 0: return createPushMessage(symbol, TIMEFRAME, _RSI_TOP_LINE, "突入");
         case 1: return createPushMessage(symbol, TIMEFRAME, _RSI_TOP_LINE, "抜け☆☆☆");
         case 2: return createPushMessage(symbol, TIMEFRAME, _RSI_BOTTOM_LINE, "突入");
         case 3: return createPushMessage(symbol, TIMEFRAME, _RSI_BOTTOM_LINE, "抜け☆☆☆");
         case 999: return "";
        }
     }
   return "";
  }
//+------------------------------------------------------------------+
//| RSI_LINEへの侵入方向を取得                                          |
//+------------------------------------------------------------------+
int checkDirection(
    const double rsiPrev
  , const double rsiNow
)
  {
   if     (rsiPrev <  _RSI_TOP_LINE    && rsiNow >= _RSI_TOP_LINE)    return 0;// 下からRSI_TOP_LINEに突入
   else if(rsiPrev >= _RSI_TOP_LINE    && rsiNow <= _RSI_TOP_LINE)    return 1;// 上からRSI_TOP_LINEを抜けた
   else if(rsiPrev >= _RSI_BOTTOM_LINE && rsiNow <= _RSI_BOTTOM_LINE) return 2;// 上からRSI_BOTTOM_LINEに突入
   else if(rsiPrev <  _RSI_BOTTOM_LINE && rsiNow >= _RSI_BOTTOM_LINE) return 3;// 下からRSI_BOTTOM_LINEを抜けた
   else return 999;// (0 < RSI値 > _BOTTOM_LINE) OR (_BOTTOM_LINE < RSI値 > _TOP_LINE) OR (TOP_LINE < RSI値 > 100)
  }
//+------------------------------------------------------------------+
//| Example: EURUSD : 15分足29.29->31下から30にタッチ：上げ                |
//+------------------------------------------------------------------+
string createPushMessage(
    const string symbol
  , const int    TIMEFRAME
  , const int    rsiLine
  , const string status
)
  {
   string t = TIMEFRAME >= 60
               ? IntegerToString(TIMEFRAME / 60) + "時間足 : "
               : IntegerToString(TIMEFRAME)      +   "分足 : ";
   return symbol + " : " + t + IntegerToString(rsiLine) + "を交差 : " + status;
  }
