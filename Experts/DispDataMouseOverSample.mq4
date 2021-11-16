//+------------------------------------------------------------------+
//|                                      DispDataMouseOverSample.mq4 |
//|                                              Copyright 2021, TTT |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, TTT"
#property version   "1.00"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   ChartSetInteger(ChartID(), CHART_EVENT_MOUSE_MOVE, true);// Required to use OnChartEvent
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHART_EVENT_MOUSE_MOVE)
     {
      int      window;
      datetime time;
      double   price;
      // チャートのX座標とY座標を時間と価格の値に変換
      if(ChartXYToTimePrice(0, lparam, dparam, window, time, price))
        {
         int i = iBarShift(NULL, 0, time);
         Comment(
            TimeToString(time),
            " Open:",      DoubleToStr(Open[i],Digits),
            " High:",      DoubleToStr(High[i],Digits),
            " Low:",       DoubleToStr(Low[i],Digits),
            " Close",      DoubleToStr(Close[i],Digits),
            " Close-Open:",DoubleToStr(Close[i]-Open[i],Digits)
         );
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deinit()
  {
   Comment("");
  }
//+------------------------------------------------------------------+
