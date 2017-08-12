//+------------------------------------------------------------------+
//|                                                       ZOrder.mqh |
//|                                    Copyright 2017, zuojia & zlbd |
//|                                                                  |
//+------------------------------------------------------------------+
#ifndef ZORDER_H
#define ZORDER_H
#include "ZLog.mqh"
//+------------------------------------------------------------------+
//| Export function declaration                                      |
//+------------------------------------------------------------------+
input string   ZOrder_bug_input         = "-------------------------------------------- buy --------------------------------------------";//多单参数
input double   ZOrder_bug_lots          = 0.01;        //手数
input int      ZOrder_buy_slippage      = 3;           //滑点
input double   ZOrder_buy_stoploss      = 0;           //止损
input double   ZOrder_buy_takeprofit    = 50;          //止盈
input double   ZOrder_buy_trailingstop  = 0;           //跟踪止损
input string   ZOrder_buy_comment       = "comment";   //注释 
input int      ZOrder_buy_magic         = 12345679;    //EA识别码
input datetime ZOrder_buy_expiration    = 0;           //订单到期时间
input color    ZOrder_buy_arrowcolor    = Green;       //颜色
input string   ZOrder_sell_input        = "-------------------------------------------- sell --------------------------------------------";//空单参数
input double   ZOrder_sell_lots         = 0.01;        //手数
input int      ZOrder_sell_slippage     = 3;           //滑点
input double   ZOrder_sell_stoploss     = 0;           //止损
input double   ZOrder_sell_takeprofit   = 50;          //止盈
input double   ZOrder_sell_trailingstop = 0;           //跟踪止损
input string   ZOrder_sell_comment      = "comment";   //注释 
input int      ZOrder_sell_magic        = 987654321;  //EA识别码
input datetime ZOrder_sell_expiration   = 0;           //订单到期时间
input color    ZOrder_sell_arrowcolor   = Red;         //颜色

//+------------------------------------------------------------------+
//| Export function declaration                                      |
//+------------------------------------------------------------------+
void ZOrder_test()
{
    printf("ZOrder_test");
}


//  获取到指定类型的单子总数
void ZOrder_total(int nOrderType)
{
    int total = OrdersTotal();

}

// 开一多单
bool ZOrder_buyopen(double lot = -1.0)
{
    bool bret = false;
    if( lot <= 0 ) {
        lot = ZOrder_bug_lots;
    }
    int ticket = OrderSend(
            Symbol(),             // symbol       当前货币对
            OP_BUY,               // operation    单子类型
            lot,                  // volume       手数
            Ask,                  // price        价格
            ZOrder_buy_slippage,  // slippage     滑点
            ZOrder_buy_stoploss,  // stoploss     止损
            Ask + ZOrder_sell_takeprofit * Point, // takeprofit  止盈
            ZOrder_buy_comment,   // comment      注释
            ZOrder_buy_magic,     // magic        自定义订单识别码
            ZOrder_buy_expiration,// pending order expiration  订单到期时间
            ZOrder_buy_arrowcolor // color        颜色
            );
    if(ticket > 0) {
        if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)){
            Print("BUY order opened : ", OrderOpenPrice());
            bret = true;
        }
    }
    else{
        Print("Error opening BUY order : ", GetLastError());
    }
    return bret;
}

// 开一空单
bool ZOrder_sellopen(double lot = -1.0)
{    
    bool bret = false;
    if( lot <= 0 ) {
        lot = ZOrder_sell_lots;
    }
    int ticket = OrderSend(
            Symbol(),              // symbol       当前货币对
            OP_SELL,               // operation    单子类型
            lot,                   // volume       手数
            Bid,                   // price        价格
            ZOrder_sell_slippage,  // slippage     滑点
            ZOrder_sell_stoploss,  // stoploss     止损
            Bid - ZOrder_sell_takeprofit * Point, // takeprofit  止盈
            ZOrder_sell_comment,   // comment      注释
            ZOrder_sell_magic,     // magic        自定义订单识别码
            ZOrder_sell_expiration,// pending order expiration  订单到期时间
            ZOrder_sell_arrowcolor // color        颜色
            );
    if(ticket > 0) {
        if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)){
            Print("SELL order opened : ", OrderOpenPrice());
            bret = true;
        }
    }
    else{
        Print("Error opening SELL order : ", GetLastError());
    }
    return bret;
}

// 平掉指定订单号的某一多单
bool ZOrder_buyclose(int nticket, string functionname = "", double lot = -1.0)
{
	int errcount = 0;
	bool bclosed = false;
	bool bselected = false;
    int nspread = (int)(NormalizeDouble(MarketInfo(Symbol(), MODE_SPREAD), Digits)*Point);//fixme
    while (!bclosed) {
		RefreshRates();
		bselected = OrderSelect(nticket, SELECT_BY_TICKET, MODE_TRADES);
		if( !bselected ) {
			Print ("Error! Not possible to select most profitable order . Operation cancelled.");
			return false ;
		}  
		if ((OrderSymbol() == Symbol()) && (OrderMagicNumber() == ZOrder_buy_magic)) {
			if (OrderType() == OP_BUY) {
			    if( lot > 0 ) {
			        bclosed = (OrderClose(OrderTicket(), NormalizeDouble(lot,2), NormalizeDouble(Bid, Digits), nspread, Blue));
			    }
			    else {
			        bclosed = (OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, Digits), nspread, Blue));
			    }
				if (!bclosed) {
					errcount ++;
					if(errcount > 3) {
					    Print ("----buy---- Error closing leading order, Repeat Operation. ", GetLastError(), " line:", __LINE__);
					    break;
					}
				}
			}
		}
	}
    return true;
}

// 平掉指定订单号的某一空单
bool OrderClose_sell(int nticket, string functionname = "", double lot = -1.0)
{
	int errcount = 0;
	bool bclosed = false;
	bool bselected = false;
    int nspread = (int)(NormalizeDouble(MarketInfo(Symbol(), MODE_SPREAD),Digits)*Point);//fixme
    while (!bclosed) {
		RefreshRates();
		bselected = OrderSelect(nticket, SELECT_BY_TICKET, MODE_TRADES);
		if( !bselected ) {
			Print ("Error! Not possible to select most profitable order . Operation cancelled.");
			return false;
		}  
		if ((OrderSymbol() == Symbol()) && (OrderMagicNumber() == ZOrder_sell_magic)) {
			if (OrderType() == OP_SELL) {
			    if( lot > 0 ) {
			        bclosed = (OrderClose(OrderTicket(), NormalizeDouble(lot,2), NormalizeDouble(Ask, Digits), nspread, Blue));
			    }
			    else {
			        bclosed = (OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, Digits), nspread, Blue));
			    }
				if (!bclosed) {
					errcount ++;
					if(errcount > 3) {
					    Print ("----sell---- Error closing leading order, Repeat Operation. ", GetLastError(), " line:", __LINE__);
					    break;
					} 
				}
			}
		} 
	}   
    return true;
}
//+------------------------------------------------------------------+
//| MACRO define                                                     |
//+------------------------------------------------------------------+

#endif// ZORDER_H
