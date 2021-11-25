//+------------------------------------------------------------------+
//|                                      MACD 2 Colour HISTOGRAM.mq4 |
//|                      Copyright ｩ 2006, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright ｩ 2006, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
#property link      "2 colour Histogram added by cja" 
 
#property  indicator_separate_window
#property  indicator_buffers 4
#property indicator_color1 BlueViolet
#property indicator_color2 SlateBlue
#property  indicator_color3  Orange
#property  indicator_color4  Red
#property indicator_width1 3
#property indicator_width2 3
#property indicator_width3 1
#property indicator_width4 1

//---- indicator parameters
extern int FastEMA=12;
extern int SlowEMA=26;
extern int SignalSMA=9;

//---- indicator buffers
double     ind_Buffer1[];
double     ind_Buffer2[];
double     ind_buffer3a[];
double     ind_buffer3b[];
double     ind_buffer4[];
double     ind_buffer5[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- 2 additional buffers are used for counting.
IndicatorBuffers(6);
//---- drawing settings

SetIndexStyle(0,DRAW_HISTOGRAM);
SetIndexDrawBegin(0,SignalSMA);
SetIndexStyle(1,DRAW_HISTOGRAM);
SetIndexDrawBegin(1,SignalSMA);
SetIndexStyle(4,DRAW_LINE);
SetIndexBuffer(4,ind_Buffer1);
SetIndexStyle(5,DRAW_LINE);
SetIndexBuffer(5,ind_Buffer2);


IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+2);

//---- 5 indicator buffers mapping

SetIndexBuffer(0,ind_buffer3a);
SetIndexBuffer(1,ind_buffer3b);
SetIndexBuffer(2,ind_buffer4); 
SetIndexBuffer(3,ind_buffer5);
SetIndexBuffer(4,ind_Buffer1); 
SetIndexBuffer(5,ind_Buffer2);

//---- name for DataWindow and indicator subwindow label
IndicatorShortName("MACD ("+FastEMA+","+SlowEMA+","+SignalSMA+")");
//---- initialization done
return(0);
}
//+------------------------------------------------------------------+
//| Moving Average of Oscillator                                     |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- macd counted in the 1-st additional buffer
   for(int i=0; i<limit; i++)
      ind_buffer4[i]=iMA(NULL,0,FastEMA,0,MODE_EMA,PRICE_CLOSE,i)
                        -iMA(NULL,0,SlowEMA,0,MODE_EMA,PRICE_CLOSE,i);
//---- signal line counted in the 2-nd additional buffer
   for(i=0; i<limit; i++)
      ind_buffer5[i]=iMAOnArray(ind_buffer4,Bars,SignalSMA,0,MODE_SMA,i);
//---- main loop
   double value=0;
   for(i=0; i<limit; i++)
      {
         ind_buffer3a[i]=0.0;
         ind_buffer3b[i]=0.0;      
         value=ind_buffer4[i]-ind_buffer5[i];
         if (value>0) ind_buffer3a[i]=value;
         if (value<0) ind_buffer3b[i]=value;
      }   
//---- done
   return(0);
  }
//+------------------------------------------------------------------+

