//+------------------------------------------------------------------+
//|                                             DivergenceDesign.mq4 |
//|                                              Copyright 2021, TTT |
//|                     ダイバージェンスが発生したときにサインを描写する |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, TTT"
#property description "ダイバージェンスが発生したときにサインを描写する"
#property version   "1.00"

#property strict
#property indicator_chart_window
#property indicator_buffers 2

#property indicator_width1 5
#property indicator_color1 Red
#property indicator_width2 5
#property indicator_color2 Red

// 価格を入れる
double Buffer_0[];
double Buffer_1[];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
 {
//---
  IndicatorBuffers(2);
  SetIndexBuffer(0, Buffer_0);
  SetIndexStyle(0, DRAW_ARROW);
  SetIndexArrow(0, 242);

  SetIndexBuffer(0, Buffer_1);
  SetIndexStyle(0, DRAW_ARROW);
  SetIndexArrow(0, 241);
//---
  return(INIT_SUCCEEDED);
 }
extern int range        = 100;// ブレイク対象範囲
extern double pips        = 1;// サイン表示位置調整
extern bool vline      = true;// 縦線表示
extern int RSIPeriod     = 14;// RSI期間
extern int RSITopline    = 70;// RSI上ライン
extern int RSIBottomline = 30;// RSI下ライン

int NowBars, NowBars2, NowBars3, RealBars, a, b, c, d, e, f, Timeframe = 0;
int indexHigh, indexLow;
double HPrice, LPrice, highrsi, lowrsi, rsi, now, nowopen;
//+------------------------------------------------------------------+
//| tickが動くたびに呼ばれる                                           |
//+------------------------------------------------------------------+
int OnCalculate(
  const int rates_total,
  const int prev_calculated,
  const datetime &time[],
  const double &open[],
  const double &high[],
  const double &low[],
  const double &close[],
  const long &tick_volume[],
  const long &volume[],
  const int &spread[]
)
 {
// Bars: 現在のチャートの中にあるローソク足すべての本数
// IndicatorCounted()確定しているローソク足の本数
// -1はバグ調整
  int limit = Bars - IndicatorCounted() - 1;
  for(int i = limit; i >= 0; i++)
   {
    /*
     * 指定位置(i+2)から100(range）本分の範囲で
     * 一番高い足のindexを取得
     * 最新の足はindex:0
     */
    indexHigh = iHighest(
                  NULL,     // 通貨ペア: NULLは指定なし
                  0,        // 時間足 : 0は時間指定なし
                  MODE_HIGH,// 高値の場所
                  range,    // 範囲(本数)
                  i + 2     // 範囲(始まり)
                );
    indexLow  = iLowest(NULL, 0, MODE_LOW,  range, i + 2);

    //高値の価格を取得
    HPrice = iHigh(
               NULL,    // 通貨ペア: NULLは指定なし
               0,       // 時間足 : 0は時間指定なし
               indexHigh//何番目のローソク足か
             );
    /* iHigh(NULL, 0, 0);最新のローソク足の高値を取得 */
    LPrice = iLow(NULL, 0, indexLow);

    /* iRSIの数値を取得する関数 */
    highrsi = iRSI(
                NULL,     // 通貨ペア
                0,        // 時間軸
                RSIPeriod,// 平均期間
                0,        // 適用価格(0: PRICE_CLOSE(終値), 1: PRICE_OPEN(始値)など)
                indexHigh // 何番目の足か
              );
    lowrsi  = iRSI(NULL, 0, RSIPeriod, 0, indexLow);

    rsi = iRSI(NULL, 0, RSIPeriod, 0, i);//今のRSIを取得

    now     = iClose(NULL, 0, i);// 今の足の終値
    nowopen = iOpen(NULL, 0, i);

    /* 足が確定時の1度だけ通る */
    if(
      i > 1
      || (i == 1 && NowBars < Bars)
    )
     {
      NowBars = Bars;

      // isDivergence : 1
      if(
        HPrice     <  nowopen
        && HPrice  <  now
        && highrsi >  rsi
        && rsi     >= RSITopline
      )
       {
        Buffer_0[i] = iHigh(NULL, 0, i) + pips * 10 * Point;// 下矢印のサインを出す
        if(vline)
         {
          ObjectCreate(
            "kikana" + IntegerToString(a),
            OBJ_VLINE,
            0,
            iTime(NULL, 0, i),
            0
          );
          ObjectSet("kikana" + IntegerToString(a), OBJPROP_COLOR, Red);
          ObjectSet("kikana" + IntegerToString(a), OBJPROP_STYLE, STYLE_DOT);
          a++;

          ObjectCreate("kikanb" + IntegerToString(b), OBJ_VLINE, 0, iTime(NULL, 0, indexHigh), 0);
          ObjectSet("kikanb" + IntegerToString(b), OBJPROP_COLOR, Yellow);
          ObjectSet("kikanb" + IntegerToString(b), OBJPROP_STYLE, STYLE_DOT);
          b++;
         }
       }
      // isDivergence : 2(1の逆)
      if(
        LPrice    > nowopen
        && LPrice > now
        && lowrsi < rsi
        && rsi    <= RSIBottomline
      )
       {
        Buffer_1[i] = iLow(NULL, 0, i) + pips * 10 * Point;// 下矢印のサインを出す
        if(vline)
         {
          ObjectCreate("kikanc" + IntegerToString(c), OBJ_VLINE, 0, iTime(NULL, 0, i), 0);
          ObjectSet("kikanc" + IntegerToString(c), OBJPROP_COLOR, Red);
          ObjectSet("kikanc" + IntegerToString(c), OBJPROP_STYLE, STYLE_DOT);
          c++;

          ObjectCreate("kikand" + IntegerToString(d), OBJ_VLINE, 0, iTime(NULL, 0, indexLow), 0);
          ObjectSet("kikand" + IntegerToString(d), OBJPROP_COLOR, Yellow);
          ObjectSet("kikand" + IntegerToString(d), OBJPROP_STYLE, STYLE_DOT);
          d++;
         }
       }
     }
    if(vline)
     {
      ObjectDelete("kikan");
      /* 常に最新から数えて102本目に赤い縦線を表示 */
      ObjectCreate("kikan", OBJ_VLINE, 0, iTime(NULL, 0, range + 2), 0); //range+2=>102
      ObjectSet("kikan", OBJPROP_COLOR, Red);
     }
   }
  return (rates_total);
 }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
 {
  ObjectDelete("kikan");

  for(int i = ObjectsTotal() - 1; 0 <= i; i--)
   {
    string objName = ObjectName(i);
    if(
      StringFind(objName, "counttotal") >= 0
      || StringFind(objName, "kikan") >= 0
    )
      ObjectDelete(objName);
   }
 }
//+------------------------------------------------------------------+
