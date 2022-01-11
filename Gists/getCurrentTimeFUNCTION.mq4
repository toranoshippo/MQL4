//+------------------------------------------------------------------+
//| getCurrentTime function                                          |
//+------------------------------------------------------------------+
string getCurrentTime()
  {
// MT4の表示時間と日本時間の時差
// 夏時間（3月～11月）：－6時間
// 冬時間（11月～3月）：－7時間
   int hourDiff;
   switch(Month())
     {
      case 3:
      case 4:
      case 5:
      case 6:
      case 7:
      case 8:
      case 9:
      case 10:
      case 11:
         hourDiff = 6;
         break;
      default:
         hourDiff = 7;
         break;
     }
   const int currentHour = Hour() + hourDiff;
   return (
             IntegerToString(Year()) + "." +
             IntegerToString(Month()) + "." +
             IntegerToString(Day()) + " " +
             IntegerToString(currentHour) + ":" +
             IntegerToString(Minute()) + ":" +
             IntegerToString(Seconds())
          );
  }