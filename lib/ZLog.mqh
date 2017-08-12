//+------------------------------------------------------------------+
//|                                                         ZLog.mqh |
//|                                    Copyright 2017, zuojia & zlbd |
//|                                                                  |
//+------------------------------------------------------------------+
#ifndef ZLog_H
#define ZLog_H
//+------------------------------------------------------------------+
//| Export function declaration                                      |
//+------------------------------------------------------------------+
void ZLog(string strfile, string strfunc, int strline)
{
    printf("----file=%s, func=%s, line=%d----", strfile, strfunc, strline);
}

void ZLog_test()
{
    printf("ZLog_test");
}
//+------------------------------------------------------------------+
//| MACRO define                                                     |
//+------------------------------------------------------------------+
#define ZLOG(_LOGSTR)   ZLog(__FILE__, __FUNCTION__, __LINE__)

#endif// ZLog_H


