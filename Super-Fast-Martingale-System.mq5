//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#ifdef __MQL5__
#include <mql4compat.mqh>
#include <MT4Orders.mqh>
#endif
#property strict

input string Blank01="=========================================";//================================
input string EASettings="EA Settings:";//交易总体设置
input int Magic=234; //订单识别码
input bool RecordCSV=false;//记录csv
input double CloseAllWhenDD=6000;//亏损砍仓金额 0禁用
input double FloatDDLimit=10000;//最大浮亏限制
input double MaxDDLimit=15000;//最大亏损限制

double MaxFloatLoss=0;//记录最大浮亏
bool InvalidResult=false;//结果作废
input bool UseTrailStop=false;//启动跟踪止损
input int SLStarts=300;//移动起始位置
input int SLPips=80;//移动止损点数
input bool DisableRefreashRegisters=true;//禁止刷新持仓单信息 回测并且完全使用内置函数平仓且模拟滑点禁用请设置为true 可以加速

input string Blank02="=========================================";//================================
input string LabelIS1="Indicators Select:";//指标选择
input int EnterInd1=1;//开仓指标1 编号 0禁用 建议0/1/7
input int EnterInd2=1;//开仓指标2 编号 0禁用 建议0/1/7
input string TFSelectLabel1=""; //0:当前, 1:M1, 2:M5, 3:M15, 4:M30, 5:H1, 6:H4, 7:D1, 8:W1, 9:MN1
input int EnterTFSelect1=8; //开仓指标1图表周期 建议2/1/8
input int EnterTFSelect2=8; //开仓指标2图表周期 建议2/1/8

input string Blank03="=========================================";//================================
input string LabelLS="Lot Size Settings:";//手数设置
input double StartLots=0.1;//起始手数
input double NextStartLots=0.2;//后续手数起点
input double MultiplyFactor=1.75;//翻倍系数 建议1.3/0.1/2
double LotArray[50];//默认最大50层

input string Blank04="=========================================";//================================
input string LabelGS="Grid Settings:";//网格设置
input double MinimumTP=20; //止盈 建议1/0.5/30
input double GridAdjustmentFactor=2.5; //加仓网格调整系数 建议1/0.5/15
double Distance=0;//加仓实际间隔

input string Blank05="=========================================";//================================
input string LabelTS="Trading Settings:";//交易设置
input int MaxTrades=10; //最大持仓单数 建议3/1/10
input int DueDays=28;//最长持仓时间 建议1/1/28

input string Blank06="=========================================";//================================
input string LabelBS="Backtest Settings:";//回测绩效计算
input bool UseZuluTradeP_N=false;//采用ZuluTrade/Myfxbook的累计浮亏算法
input double MinimumSharpeRatioLimit=0;//最低夏普比率限制
double TotalFloatLossOrigin=0;
double TotalFloatLossFixed=0;
double TotalFloatProfitOrigin=0;
double TotalFloatProfitFixed=0;
input double AUD_1LotKickback = 11.00232;//AUD 1手返佣
input double CAD_1LotKickback = 11.28792;//CAD 1手返佣
input double CHF_1LotKickback = 14.31640;//CHF 1手返佣
input double EUR_1LotKickback = 16.75464;//EUR 1手返佣
input double GBP_1LotKickback = 18.98400;//GBP 1手返佣
input double NZD_1LotKickback = 10.06880;//NZD 1手返佣
input double USD_1LotKickback = 14.00000;//USD 1手返佣
double LotKickback=14;//默认1手返佣
double TotalKickback=0;//累计返佣
double TotalLots=0;//累计手数
int TotalTrades= 0;//累计交易次数

input double ExtraCommissionMultiply=3;//手续费扣减倍数 在原始点差上面加点
input double AUD_1LotCommission = 7.82750;//AUD 额外1手手续费
input double CAD_1LotCommission = 7.75750;//CAD 额外1手手续费
input double CHF_1LotCommission = 10.6005;//CHF 额外1手手续费
input double EUR_1LotCommission = 12.4055;//EUR 额外1手手续费
input double GBP_1LotCommission = 13.9020;//GBP 额外1手手续费
input double NZD_1LotCommission = 7.28900;//NZD 额外1手手续费
input double USD_1LotCommission = 10.0000;//USD 额外1手手续费
double ExtraCommission=10;//每手额外手续费

input string Blank07="=========================================";//================================
input string LabelIS2="Indicator Settings:";//指标选择

input string IndUse="";//指标用法
input string FixedGrid_Settings="=== Fixed Grid Settings===";//0号 固定间隔

input string FastMA_Settings="=== Fast Moving Average Settings===";//1号 快速均线 MA走高做多 MA走低做空
input string FastMA_TFSelectLabel=""; //0:当前, 1:M1, 2:M5, 3:M15, 4:M30, 5:H1, 6:H4, 7:D1, 8:W1, 9:MN1
input int FastMAPeriod=20; // 均线周期
input ENUM_MA_METHOD FastMAMethod=MODE_SMA; // 均线模式 0简单 1指数 2平滑 3线性加权
input int FastMAPrice=PRICE_CLOSE; // 应用价格 0收盘 1开盘 2最高 3最低 4中间 5典型 6加权
input int FastMAShift=1;//平移量

input string MediumMA_Settings="=== Medium Moving Average Settings===";//2号 中速均线 MA走高做多 MA走低做空
input int MediumMAPeriod=50; // 均线周期
input ENUM_MA_METHOD MediumMAMethod=MODE_SMA; // 均线模式 0简单 1指数 2平滑 3线性加权
input int MediumMAPrice=PRICE_CLOSE; // 应用价格 0收盘 1开盘 2最高 3最低 4中间 5典型 6加权
input int MediumMAShift=1;//平移量

input string SlowMA_Settings="=== Slow Moving Average Settings===";//3号 慢速均线 MA走高做多 MA走低做空
input int SlowMAPeriod=100; // 均线周期
input ENUM_MA_METHOD SlowMAMethod=MODE_SMA; // 均线模式 0简单 1指数 2平滑 3线性加权
input int SlowMAPrice=PRICE_CLOSE; // 应用价格 0收盘 1开盘 2最高 3最低 4中间 5典型 6加权
input int SlowMAShift=1;//平移量

input string MACD_Settings="=== MACD Settings===";//4号 MACD MACD>=0做多 MACD<0做空
input int MACDFast=12; // MACD 快速周期
input int MACDSlow=26; // MACD 慢速周期
input int MACDSignal=9; // MACD 信号周期
input int MACDPrice=PRICE_CLOSE; // 应用价格 0收盘 1开盘 2最高 3最低 4中间 5典型 6加权
input int MACDShift=1;//平移量

input string ADX_Settings="=== ADX Settings===";//5号 ADX +DI>=-DI做多 +DI<-DI做空 
input int ADXPeriod=14; // ADX动量周期
input int ADXShift=1;//平移量

input string SAR_Settings="=== SAR Settings===";//6号 SAR SAR<=报价做多 SAR>=报价做空
input double SARStep=0.02; // SAR步长
input double SARMaximum=0.2; // SAR最大
input int SARShift=1;//平移量

input string OsMA_Settings="=== OsMA Settings===";//7号 OsMA OsMA>=0做多 OsMA<0做空
input int OsMAFast= 12; // OsMA 快速周期
input int OsMASlow= 26; // OsMA 慢速周期
input int OsMASignal=9; // OsMA 信号周期
input int OsMAPrice=PRICE_CLOSE; // 应用价格 0收盘 1开盘 2最高 3最低 4中间 5典型 6加权
input int OsMAShift=1;//平移量

bool NotInNewsTime=true;

ENUM_TIMEFRAMES IndEnterTF1= 0;
ENUM_TIMEFRAMES IndEnterTF2= 0;
int NextOperateCount=0;

string EnterInd1Name;
string EnterInd2Name;

int handle_FastMAEnter1,handle_FastMAEnter2;
int handle_MediumMAEnter1,handle_MediumMAEnter2;
int handle_SlowMAEnter1,handle_SlowMAEnter2;
int handle_MACDEnter1,handle_MACDEnter2;
int handle_ADXEnter1,handle_ADXEnter2;
int handle_SAREnter1,handle_SAREnter2;
int handle_OsMAEnter1,handle_OsMAEnter2;
int handle_ATR;

datetime OpenTimeFirst=0;

int BuyTicket[50],SellTicket[50];
double BuyLot[50],SellLot[50];
double BuyPrice[50],SellPrice[50];
double BuyMin[50],SellMin[50];
double BuyMax[50],SellMax[50];
double BuyPrice_x_Lot,SellPrice_x_Lot;
double AverageBuyPrice,AverageSellPrice;
double MinimumTargetBuyTP;
double MinimumTargetSellTP;
//********************寄存器***********************************
int OrdersTotalByThisEA=0;//EA持仓单数量计数
datetime Time_Current=0;//当前时间
int BuyOrdersCount=0,SellOrdersCount=0;//订单数量
double LastBuyOrderOpenPrice=0,LastSellOrderOpenPrice=0;//最后的卖出价格
double BuyLots=0,SellLots=0;//总手数
datetime FirstBuyOrderTime=0,FirstSellOrderTime=0;//首次买卖时间
datetime LastBuyTime=0,LastSellTime=0;//最后买卖时间

datetime NextOperateTime=0;//EA下次操作时间点
int StatCloseHandle;//统计文件句柄
int PlaceOrderLimit=900;//下单间隔硬性限制

bool isTesting=false;//测试环境标记
bool isVisualMode=false;//测试环境标记
bool OneTimeInit=true;//一次性初始化
double initBalance=0;//初始余额
string OrderCommentBuy="",OrderCommentSell="";
string StatFile_Close="";//统计文件名
double Point;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   Point=SymbolInfoDouble(Symbol(),SYMBOL_POINT);
   HideTestIndicators(true);//隐藏指标 MT5不可用 忽略

   isTesting=(IsTesting() || IsOptimization() || IsVisualMode());
   isVisualMode=IsVisualMode();
//测试或者优化环境标记 跳过一些不必要步骤
   switch(EnterTFSelect1)
     {
      case 0:IndEnterTF1=PERIOD_CURRENT;break;
      case 1:IndEnterTF1=PERIOD_M1;break;
      case 2:IndEnterTF1=PERIOD_M5;break;
      case 3:IndEnterTF1=PERIOD_M15;break;
      case 4:IndEnterTF1=PERIOD_M30;break;
      case 5:IndEnterTF1=PERIOD_H1;break;
      case 6:IndEnterTF1=PERIOD_H4;break;
      case 7:IndEnterTF1=PERIOD_D1;break;
      case 8:IndEnterTF1=PERIOD_W1;break;
      case 9:IndEnterTF1=PERIOD_MN1;break;
      default:{Print("开仓周期错误");ExpertRemove();}break;
     }
   switch(EnterTFSelect2)
     {
      case 0:IndEnterTF2=PERIOD_CURRENT;break;
      case 1:IndEnterTF2=PERIOD_M1;break;
      case 2:IndEnterTF2=PERIOD_M5;break;
      case 3:IndEnterTF2=PERIOD_M15;break;
      case 4:IndEnterTF2=PERIOD_M30;break;
      case 5:IndEnterTF2=PERIOD_H1;break;
      case 6:IndEnterTF2=PERIOD_H4;break;
      case 7:IndEnterTF2=PERIOD_D1;break;
      case 8:IndEnterTF2=PERIOD_W1;break;
      case 9:IndEnterTF2=PERIOD_MN1;break;
      default:{Print("开仓周期错误");ExpertRemove();}break;
     }

   StatFile_Close=
                  "平仓,"+Symbol()
                  +",翻倍="+DoubleToString(MultiplyFactor,2)
                  +",最大层数="+IntegerToString(MaxTrades)
                  +",止盈="+DoubleToString(MinimumTP,2)
                  +",加仓间隔="+DoubleToString(GridAdjustmentFactor,2)
                  +",开仓指标="+EnterInd1Name
                  +",开仓指标周期="+IntegerToString(IndEnterTF1)
                  +".csv";

//测试环境 手数小数为1 挂机运行为2
   int LotsDigits=2;
   if(isTesting)
      LotsDigits=1;

   Print("手数最低:",MarketInfo(Symbol(),MODE_MINLOT),"手数步进:",MarketInfo(Symbol(),MODE_LOTSTEP));

   LotArray[0]=StartLots;
   for(int i=1;i<=MaxTrades;i++)//后续手数数组 默认0.02手起始
     {
      LotArray[i]=NormalizeDouble(NextStartLots*MathPow(MultiplyFactor,i-1),LotsDigits);
      //后续手数数组
      Print(LotArray[i]);
     }
   if(LotArray[0]<MarketInfo(Symbol(),MODE_MINLOT))
     {
      Alert("起始手数低于平台允许的最小手数");
      ExpertRemove();
     }
   if(StringFind(Symbol(),"AUD")==0) {LotKickback = AUD_1LotKickback;ExtraCommission = AUD_1LotCommission;}
   if(StringFind(Symbol(),"CAD")==0) {LotKickback = CAD_1LotKickback;ExtraCommission = CAD_1LotCommission;}
   if(StringFind(Symbol(),"CHF")==0) {LotKickback = CHF_1LotKickback;ExtraCommission = CHF_1LotCommission;}
   if(StringFind(Symbol(),"EUR")==0) {LotKickback = EUR_1LotKickback;ExtraCommission = EUR_1LotCommission;}
   if(StringFind(Symbol(),"GBP")==0) {LotKickback = GBP_1LotKickback;ExtraCommission = GBP_1LotCommission;}
   if(StringFind(Symbol(),"NZD")==0) {LotKickback = NZD_1LotKickback;ExtraCommission = NZD_1LotCommission;}
   if(StringFind(Symbol(),"USD")==0) {LotKickback = USD_1LotKickback;ExtraCommission = USD_1LotCommission;}
//回测时计算返佣使用

   if(RecordCSV)
     {
      StatCloseHandle=FileOpen(StatFile_Close,FILE_WRITE|FILE_CSV,',');
      //平仓统计文件句柄
      //FileWrite(StatCloseHandle,"编号","开仓时间","平仓时间","货币","类型","手数","止损","止赢","开仓价格","平仓价格","手续费","过夜利息","持仓时长(小时)","点数","持仓盈亏","平仓盈利(含费用)","含返佣盈利(含费用)","返佣","累计返佣","已用保证金","余额","净值","含返佣净值","含返佣余额","最大浮亏","手数","过夜利息","前台盈利","后台盈利","前台+后台盈利");
      FileWrite(StatCloseHandle,"编号","开仓时间","平仓时间","货币","类型","手数","止损","止赢","开仓价格","平仓价格","手续费","过夜利息","持仓时长(小时)","点数","持仓盈亏","平仓盈利(含费用)","含返佣盈利(含费用)","返佣","累计返佣","已用保证金","余额","净值","含返佣净值","含返佣余额","最大浮亏","开仓顺序","最高浮盈","最大浮亏","平仓盈利");
      FileClose(StatCloseHandle);
      //写入统计文件文件头并且关闭句柄
      StatCloseHandle=FileOpen(StatFile_Close,FILE_READ|FILE_WRITE|FILE_CSV,',');
      FileSeek(StatCloseHandle,0,SEEK_END);
      //再次打开平仓统计文件
     }
   OpenTimeFirst=StringToTime(TimeToStr(TimeCurrent(),TIME_DATE));
//当前日期 截断精确时间
   NextOperateTime=OpenTimeFirst;//首次
   Time_Current=TimeCurrent();
   initBalance=AccountBalance();
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#ifdef __MQL5__ 
   switch(EnterInd1)
     {
      case 0:break;
      case 1:handle_FastMAEnter1=iMA(NULL,IndEnterTF1,FastMAPeriod,0,FastMAMethod,FastMAPrice);break;
      case 2:handle_MediumMAEnter1=iMA(NULL,IndEnterTF1,MediumMAPeriod,0,MediumMAMethod,MediumMAPrice);break;
      case 3:handle_SlowMAEnter1=iMA(NULL,IndEnterTF1,SlowMAPeriod,0,SlowMAMethod,SlowMAPrice);break;
      case 4:handle_MACDEnter1=iMACD(NULL,IndEnterTF1,MACDFast,MACDSlow,MACDSignal,MACDPrice);break;
      case 5:handle_ADXEnter1=iADX(NULL,IndEnterTF1,ADXPeriod);break;
      case 6:handle_SAREnter1=iSAR(NULL,IndEnterTF1,SARStep,SARMaximum);break;
      case 7:handle_OsMAEnter1=iOsMA(NULL,IndEnterTF1,OsMAFast,OsMASlow,OsMASignal,OsMAPrice);break;
      default:break;
     }
   switch(EnterInd2)
     {
      case 0:break;
      case 1:handle_FastMAEnter2=iMA(NULL,IndEnterTF2,FastMAPeriod,0,FastMAMethod,FastMAPrice);break;
      case 2:handle_MediumMAEnter2=iMA(NULL,IndEnterTF2,MediumMAPeriod,0,MediumMAMethod,MediumMAPrice);break;
      case 3:handle_SlowMAEnter2=iMA(NULL,IndEnterTF2,SlowMAPeriod,0,SlowMAMethod,SlowMAPrice);break;
      case 4:handle_MACDEnter2=iMACD(NULL,IndEnterTF2,MACDFast,MACDSlow,MACDSignal,MACDPrice);break;
      case 5:handle_ADXEnter2=iADX(NULL,IndEnterTF2,ADXPeriod);break;
      case 6:handle_SAREnter2=iSAR(NULL,IndEnterTF2,SARStep,SARMaximum);break;
      case 7:handle_OsMAEnter2=iOsMA(NULL,IndEnterTF2,OsMAFast,OsMASlow,OsMASignal,OsMAPrice);break;
      default:break;
     }
   handle_ATR=iATR(Symbol(),PERIOD_H1,500);
#endif
   return (INIT_SUCCEEDED);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//ObjectsDeleteAll();
//清空所有图标夹对象
   string FinalStatFile=
                        "最终,"+Symbol()
                        +",翻倍="+DoubleToString(MultiplyFactor,2)
                        +",最大层数="+IntegerToString(MaxTrades)
                        +",止盈="+DoubleToString(MinimumTP,2)
                        +",加仓间隔="+DoubleToString(GridAdjustmentFactor,2)
                        +",开仓指标="+EnterInd1Name
                        +",开仓指标周期="+IntegerToString(IndEnterTF1)
                        +".csv";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(RecordCSV)
     {
      int FinalStatHandle=FileOpen(FinalStatFile,FILE_WRITE|FILE_CSV,',');
      //MT4最终平仓统计 可选功能
      FileWrite(FinalStatHandle,
                "起始资金(STAT_INITIAL_DEPOSIT)",
                "总净盈利(STAT_PROFIT)",
                "毛盈利(STAT_GROSS_PROFIT)",
                "毛亏损(STAT_GROSS_LOSS)",
                "最大单笔盈利(STAT_MAX_PROFITTRADE)",
                "最大单笔亏损(STAT_MAX_LOSSTRADE)",
                "最大连续盈利金额(STAT_CONPROFITMAX)",
                "最大连续盈利次数(STAT_CONPROFITMAX_TRADES)",
                "最多连续盈利金额(STAT_MAX_CONWINS)",
                "最多连续亏损次数(STAT_MAX_CONPROFIT_TRADES)",
                "最大连续亏损金额(STAT_CONLOSSMAX)",
                "最大连续亏损次数(STAT_CONLOSSMAX_TRADES)",
                "最多连续亏损金额(STAT_MAX_CONLOSSES)",
                "最多连续亏损次数(STAT_MAX_CONLOSS_TRADES)",
                "绝对亏损(STAT_BALANCEMIN)",
                "最大余额亏损(STAT_BALANCE_DD)",
                "最大余额亏损比例(STAT_BALANCEDD_PERCENT)",
                "最大余额亏损比例DDREL(STAT_BALANCE_DDREL_PERCENT)",
                "最大余额相对亏损(STAT_BALANCE_DD_RELATIVE)",
                "最低净值(STAT_EQUITYMIN)",
                "净值最大亏损(STAT_EQUITY_DD)",
                "净值最大亏损比例(STAT_EQUITYDD_PERCENT)",
                "净值最大亏损比例DDREL(STAT_EQUITY_DDREL_PERCENT)",
                "净值相对亏损比例(STAT_EQUITY_DD_RELATIVE)",
                "预期盈利(STAT_EXPECTED_PAYOFF)",
                "盈利(STAT_PROFIT_FACTOR)",
                "最低可用预付款(STAT_MIN_MARGINLEVEL)",
                "OnTester数值(STAT_CUSTOM_ONTESTER)",
                "交易次数(STAT_TRADES)",
                "盈利次数(STAT_PROFIT_TRADES)",
                "亏损次数(STAT_LOSS_TRADES)",
                "空单数量(STAT_SHORT_TRADES)",
                "多单数量(STAT_LONG_TRADES)",
                "空单盈利(STAT_PROFIT_SHORTTRADES)",
                "多单盈利(STAT_PROFIT_LONGTRADES)",
                "平均盈利交易(STAT_PROFITTRADES_AVGCON)",
                "平均亏损交易(STAT_LOSSTRADES_AVGCON)"
                );

      FileClose(FinalStatHandle);
      //写入最终平仓统计文件头并且关闭
      FinalStatHandle=FileOpen(FinalStatFile,FILE_READ|FILE_WRITE|FILE_CSV,',');
      FileSeek(FinalStatHandle,0,SEEK_END);
      //再次打开最终统计文件并定位到底部
      FileWrite(FinalStatHandle,
                TesterStatistics(STAT_INITIAL_DEPOSIT),
                TesterStatistics(STAT_PROFIT),
                TesterStatistics(STAT_GROSS_PROFIT),
                TesterStatistics(STAT_GROSS_LOSS),
                TesterStatistics(STAT_MAX_PROFITTRADE),
                TesterStatistics(STAT_MAX_LOSSTRADE),
                TesterStatistics(STAT_CONPROFITMAX),
                TesterStatistics(STAT_CONPROFITMAX_TRADES),
                TesterStatistics(STAT_MAX_CONWINS),
                TesterStatistics(STAT_MAX_CONPROFIT_TRADES),
                TesterStatistics(STAT_CONLOSSMAX),
                TesterStatistics(STAT_CONLOSSMAX_TRADES),
                TesterStatistics(STAT_MAX_CONLOSSES),
                TesterStatistics(STAT_MAX_CONLOSS_TRADES),
                TesterStatistics(STAT_BALANCEMIN),
                TesterStatistics(STAT_BALANCE_DD),
                TesterStatistics(STAT_BALANCEDD_PERCENT),
                TesterStatistics(STAT_BALANCE_DDREL_PERCENT),
                TesterStatistics(STAT_BALANCE_DD_RELATIVE),
                TesterStatistics(STAT_EQUITYMIN),
                TesterStatistics(STAT_EQUITY_DD),
                TesterStatistics(STAT_EQUITYDD_PERCENT),
                TesterStatistics(STAT_EQUITY_DDREL_PERCENT),
                TesterStatistics(STAT_EQUITY_DD_RELATIVE),
                TesterStatistics(STAT_EXPECTED_PAYOFF),
                TesterStatistics(STAT_PROFIT_FACTOR),
                TesterStatistics(STAT_MIN_MARGINLEVEL),
                TesterStatistics(STAT_CUSTOM_ONTESTER),
                TesterStatistics(STAT_TRADES),
                TesterStatistics(STAT_PROFIT_TRADES),
                TesterStatistics(STAT_LOSS_TRADES),
                TesterStatistics(STAT_SHORT_TRADES),
                TesterStatistics(STAT_LONG_TRADES),
                TesterStatistics(STAT_PROFIT_SHORTTRADES),
                TesterStatistics(STAT_PROFIT_LONGTRADES),
                TesterStatistics(STAT_PROFITTRADES_AVGCON),
                TesterStatistics(STAT_LOSSTRADES_AVGCON)
                );
      FileClose(FinalStatHandle);
      //写入对应项目并且关闭
      FileClose(StatCloseHandle);

      string FinalStatLiteFile=
                               "简要,"+Symbol()
                               +",翻倍="+DoubleToString(MultiplyFactor,2)
                               +",最大层数="+IntegerToString(MaxTrades)
                               +",止盈="+DoubleToString(MinimumTP,2)
                               +",加仓间隔="+DoubleToString(GridAdjustmentFactor,2)
                               +",开仓指标="+EnterInd1Name
                               +",开仓指标周期="+IntegerToString(IndEnterTF1)
                               +".csv";
      int FinalStatLiteHandle=FileOpen(FinalStatLiteFile,FILE_READ|FILE_WRITE|FILE_CSV,',');
      FileWrite(FinalStatLiteHandle,
                "货币","最大浮亏","前台盈利","台+后台盈利","累计返佣","总手数","交易次数"
                );
      FileWrite(FinalStatLiteHandle,
                Symbol(),
                NormalizeDouble(MaxFloatLoss,2),
                //浮亏
                NormalizeDouble(AccountEquity()-initBalance,2),
                //前台盈利
                NormalizeDouble(AccountEquity()-initBalance+TotalKickback,2),
                //前台+后台盈利
                NormalizeDouble(TotalKickback,2),
                //累计返佣
                TotalLots,
                TotalTrades
                );
      FileClose(FinalStatLiteHandle);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void SetHLine(color cl,string nm="",double p1=0,int st=0,int wd=1)
  {
   if(ObjectFind(0,nm)<0) ObjectCreate(0,nm,OBJ_HLINE,0,0,0);
   ObjectSetDouble(0,nm,OBJPROP_PRICE,p1);
   ObjectSetInteger(0,nm,OBJPROP_COLOR,cl);
   ObjectSetInteger(0,nm,OBJPROP_STYLE,st);
   ObjectSetInteger(0,nm,OBJPROP_WIDTH,wd);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   static int LastOrdersTotal;
   static double BuySL,SellSL;
   static double accountProfit;
   accountProfit=AccountInfoDouble(ACCOUNT_PROFIT);
   MaxFloatLoss=MathMin(MaxFloatLoss,accountProfit);
#ifdef __MQL5__

#endif
   Time_Current=TimeCurrent();
//获取当前时间 写入变量，避免以后反复调用函数 拖累速度
   if(CloseAllWhenDD>0 && accountProfit<-CloseAllWhenDD)
     {
      CloseAllOrders();
     }
   if(CloseAllWhenDD<=0 && MaxFloatLoss<-FloatDDLimit)
     {
      InvalidResult=true;
      CloseAllOrders();
      ExpertRemove();
     }
   if(UseZuluTradeP_N)ZuluTrade();//ZuluTrade绩效计算法

   if(UseTrailStop)
     {
      Ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
      Bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
      if(Bid-AverageBuyPrice>=Point*SLStarts && BuyOrdersCount>0)
        {
         if(BuySL==0)BuySL=Bid-Point*SLPips;
         BuySL=MathMax(BuySL,Bid-Point*SLPips);
         if(isVisualMode)SetHLine(clrRed,"Buy",BuySL,0,1);
        }
      if(AverageSellPrice-Ask>=Point*SLStarts && SellOrdersCount>0)
        {
         if(SellSL==0)SellSL=Ask+Point*SLPips;
         SellSL=MathMin(SellSL,Ask+Point*SLPips);
         if(isVisualMode)SetHLine(clrRed,"Sell",SellSL,0,1);
        }
      if(BuySL>0 && Bid<BuySL && BuyOrdersCount>0)
        {
         Print("BuySL=",BuySL,",Bid=",Bid,",Point*SLPips=",Point*SLPips);
         BuySL=0;
         CloseBuyOrders();
         if(isVisualMode)SetHLine(clrRed,"Buy",0,0,1);
        }
      if(SellSL>0 && Ask>SellSL && SellOrdersCount>0)
        {
         Print("SellSL=",SellSL,",Ask=",Ask,",Point*SLPips=",Point*SLPips);
         SellSL=0;
         CloseSellOrders();
         if(isVisualMode)SetHLine(clrRed,"Sell",0,0,1);
        }
     }
   if(Time_Current>=NextOperateTime)
      //当前时间 已经到了 下次操作时间点
     {
      if(TesterStatistics(STAT_EQUITY_DD)>MaxDDLimit)
        {
         InvalidResult=true;
         CloseAllOrders();
         ExpertRemove();
        }

      if(OneTimeInit)
         //一次性初始化 日常使用实时刷新
        {
#ifdef __MQL5__
         Distance=IndGet(handle_ATR,0,1); //日常使用 由于不是从0单开始 需要实时刷新间隔数据
#endif
#ifdef __MQL4__
         Distance=iATR(Symbol(),PERIOD_H1,500,1); //日常使用 由于不是从0单开始 需要实时刷新间隔数据
#endif
         OneTimeInit=false;
        }

#ifdef __MQL5__
      Ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
      Bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
#endif

      if(!DisableRefreashRegisters || !isTesting)
         if(OrdersTotal()!=LastOrdersTotal || !isTesting)
           {
            //仅当持仓单数有变化时刷新寄存器
            UpdateRegisters();
            LastOrdersTotal=OrdersTotal();
           }
      //非测试环境实时刷新寄存器
      //EA可以感知各种异常情况 回测环境不需要，以便加快速度

      if(Bid>MinimumTargetBuyTP && BuyOrdersCount>0)
        {
         CloseBuyOrders();
         //平掉多单
        }
      if(Ask<MinimumTargetSellTP && SellOrdersCount>0)
        {
         CloseSellOrders();
         //平掉空单
        }
      isNewsRelease();//数据发布砍仓
      DueCut();//到期砍仓
      if(NotInNewsTime)
         //非平仓时间 非手动过滤行情
        {
         if(BuyOrdersCount>0 && BuyOrdersCount<MaxTrades && Time_Current>=LastBuyTime+PlaceOrderLimit)
            //买单数量>0 并且持仓少于限制 并且满足硬性下单间隔 
           {
            if(Ask<LastBuyOrderOpenPrice-Distance*GridAdjustmentFactor)
              {
               //亏损足够，满足加仓条件
               if(Ind(EnterInd1,"Enter1")>=0)
                  if(Ind(EnterInd2,"Enter2")>=0)
                     SendBuyOrder(LotArray[BuyOrdersCount],Magic);
               //市价买多
              }
           }
         if(BuyOrdersCount==0)
           {
            //买单数量=0
            if(Ind(EnterInd1,"Enter1")>=0)
               if(Ind(EnterInd2,"Enter2")>=0)
                  SendBuyOrder(LotArray[BuyOrdersCount],Magic);
            //市价买多
           }
         if(SellOrdersCount>0 && SellOrdersCount<MaxTrades && Time_Current>=LastSellTime+PlaceOrderLimit)
            //卖单数量>0 并且持仓少于限制 并且满足硬性下单间隔 
           {
            if(Bid>LastSellOrderOpenPrice+Distance*GridAdjustmentFactor)
              {
               //亏损足够，满足加仓条件
               if(Ind(EnterInd1,"Enter1")<=0)
                  if(Ind(EnterInd2,"Enter2")<=0)
                     SendSellOrder(LotArray[SellOrdersCount],Magic);
               //市价卖空
              }
           }
         if(SellOrdersCount==0)
           {
            //卖单数量=0
            if(Ind(EnterInd1,"Enter1")<=0)
               if(Ind(EnterInd2,"Enter2")<=0)
                  SendSellOrder(LotArray[SellOrdersCount],Magic);
            //市价卖空
           }
        }
      NextOperateTime=OpenTimeFirst+300*NextOperateCount;
      //计算出下次操作时间点 300秒处理一次
      NextOperateCount++;
      //操作计数
      //中途不再进行除统计实时浮亏外任何处理 以便提速
      //每次操作有5分钟硬性间隔
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SendBuyOrder(double lots,int magic)
  {
//if(BuyOrdersCount<3){OrderCommentBuy="No";}else{OrderCommentBuy="Yes";}
   OrderCommentBuy=IntegerToString(BuyOrdersCount+1);
   BuyTicket[BuyOrdersCount]=OrderSend(Symbol(),OP_BUY,lots,Ask,9999,0,0,OrderCommentBuy,magic,0,clrNONE);
//订单编号寄存器
//做多 忽略MT4没判断OrderSend和OrderClose的警告，日常使用时实时刷新寄存器 下个Tick任何错误值均会被纠正
   LastBuyTime=Time_Current;//当前时间 数据有点滞后 后面统一刷新 回测时不需要刷新
   BuyLot[BuyOrdersCount]=lots;//手数寄存器 平仓要用
   BuyLots=BuyLots+lots;//总手数寄存器
                        //BuyPrice[BuyOrdersCount]=Ask;//买入价寄存器 可能无用
   BuyPrice_x_Lot=BuyPrice_x_Lot+lots*Ask;//累计买入价寄存器 算均价用
   LastBuyOrderOpenPrice=Ask;//最后买入价寄存器 用于加层
   AverageBuyPrice=BuyPrice_x_Lot/BuyLots;//买入均价 保本位置
   BuyOrdersCount++;//买单数量寄存器
   OrdersTotalByThisEA++;//EA持仓单数寄存器
   TotalLots=TotalLots+lots;
   TotalTrades++;
   if(BuyOrdersCount==1)
      //若是第一单 记录下单时间，此单开仓时间作为判定时间点
      FirstBuyOrderTime=Time_Current;
#ifdef __MQL5__
   Distance=IndGet(handle_ATR,0,1);
#endif
#ifdef __MQL4__
   Distance=iATR(Symbol(),PERIOD_H1,500,1);
#endif
   MinimumTargetBuyTP=AverageBuyPrice==0 ? 0 : NormalizeDouble(AverageBuyPrice+Distance*MinimumTP,Digits);
//多单市价已经高于买入均价+止盈
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SendSellOrder(double lots,int magic)
  {
//if(SellOrdersCount<3){OrderCommentSell="No";}else{OrderCommentSell="Yes";}
   OrderCommentSell=IntegerToString(SellOrdersCount+1);
   SellTicket[SellOrdersCount]=OrderSend(Symbol(),OP_SELL,lots,Bid,9999,0,0,OrderCommentSell,magic,0,clrNONE);
//做空
   LastSellTime=Time_Current;
   SellLot[SellOrdersCount]=lots;//手数寄存器
   SellLots=SellLots+lots;//总手数
                          //SellPrice[SellOrdersCount]=Bid;//买入价寄存器
   SellPrice_x_Lot=SellPrice_x_Lot+lots*Bid;//累计买入价寄存器
   LastSellOrderOpenPrice=Bid;//最后买入价寄存器
   AverageSellPrice=SellPrice_x_Lot/SellLots;
   SellOrdersCount++;
   OrdersTotalByThisEA++;
   TotalLots=TotalLots+lots;
   TotalTrades++;
   if(SellOrdersCount==1)
      //若是第一单 记录下单时间，此单开仓时间作为判定时间点
      FirstSellOrderTime=Time_Current;
#ifdef __MQL5__
   Distance=IndGet(handle_ATR,0,1);
#endif
#ifdef __MQL4__
   Distance=iATR(Symbol(),PERIOD_H1,500,1);
#endif
   MinimumTargetSellTP=AverageSellPrice==0 ? 0 : NormalizeDouble(AverageSellPrice-Distance*MinimumTP,Digits);
//空单市价已经低于卖出均价+止盈
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseBuyOrders()
//平多单
  {
   for(int x=BuyOrdersCount-1;x>=0;x--)
     {
      TotalFloatLossFixed=TotalFloatLossFixed+BuyMin[x]-BuyLot[x]*ExtraCommission*ExtraCommissionMultiply;
      //点差修正后的浮亏
      TotalFloatProfitFixed=TotalFloatProfitFixed+BuyMax[x]-BuyLot[x]*ExtraCommission*ExtraCommissionMultiply;
      //点差修正后的浮盈
      TotalFloatLossOrigin=TotalFloatLossOrigin+BuyMin[x];
      //原始点差浮亏
      TotalFloatProfitOrigin=TotalFloatProfitOrigin+BuyMax[x];
      //原始点差浮盈
      StatsClose(BuyTicket[x],x+1,BuyMax[x],BuyMin[x]);
      //统计平仓
      OrderClose(BuyTicket[x],BuyLot[x],Bid,9999,CLR_NONE);
      //直接根据单号平仓 忽略MT4警告
      BuyMin[x]=0;
      //浮亏寄存器
      BuyMax[x]=0;
      //浮盈寄存器
     }
   OrdersTotalByThisEA=OrdersTotalByThisEA-BuyOrdersCount;
//修正EA下单总数寄存器
   BuyLots=0;
//买入总手数寄存器
   BuyPrice_x_Lot=0;
//清空买单累计价格寄存器
   BuyOrdersCount=0;
//清空卖单数量寄存器
   AverageBuyPrice=0;
//清空空单均价寄存器
   LastBuyOrderOpenPrice=0;
//清空最后的卖单价格
   FirstBuyOrderTime=0;
//首次开仓时间寄存器
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseSellOrders()
//有平空单
  {
   for(int x=SellOrdersCount-1;x>=0;x--)
     {
      TotalFloatLossFixed=TotalFloatLossFixed+SellMin[x]-SellLot[x]*ExtraCommission*ExtraCommissionMultiply;
      //点差修正后的浮亏
      TotalFloatProfitFixed=TotalFloatProfitFixed+SellMax[x]-SellLot[x]*ExtraCommission*ExtraCommissionMultiply;
      //点差修正后的浮盈
      TotalFloatLossOrigin=TotalFloatLossOrigin+SellMin[x];
      //原始点差浮亏
      TotalFloatProfitOrigin=TotalFloatProfitOrigin+SellMax[x];
      //原始点差浮盈
      StatsClose(SellTicket[x],x+1,SellMax[x],SellMin[x]);
      //统计平仓
      OrderClose(SellTicket[x],SellLot[x],Bid,9999,CLR_NONE);
      //直接根据单号平仓 忽略MT4警告
      SellMin[x]=0;
      //浮亏寄存器
      SellMax[x]=0;
      //浮盈寄存器
     }
   OrdersTotalByThisEA=OrdersTotalByThisEA-SellOrdersCount;
//修正EA下单总数寄存器
   SellLots=0;
//卖出总手数寄存器
   SellPrice_x_Lot=0;
//清空卖单累计价格寄存器
   SellOrdersCount=0;
//清空卖单数量寄存器
   AverageSellPrice=0;
//清空空单均价寄存器
   LastSellOrderOpenPrice=0;
//清空最后的卖单价格
   FirstSellOrderTime=0;
//首次开仓时间寄存器
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAllOrders()
//全部平仓
  {
   CloseBuyOrders();
   CloseSellOrders();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
   double OpenAccurate=0,FP_FL_Ratio,CloseAccurate=0,PLNSpeed=0,ProfitMiss=0;
   double result,ZuluTrade_P_L;
   double ExtraCommissionTotal=TotalLots*ExtraCommission*ExtraCommissionMultiply;
   double TotalProfitFixed=AccountInfoDouble(ACCOUNT_EQUITY)-initBalance-ExtraCommissionTotal;
   double TotalProfitOrigin=AccountInfoDouble(ACCOUNT_EQUITY)-initBalance;
   if(TesterStatistics(STAT_EQUITY_DD)>MaxDDLimit)
      InvalidResult=true;
   if(UseZuluTradeP_N)
     {
      OpenAccurate=TotalFloatProfitFixed/(TotalFloatProfitFixed-TotalFloatLossFixed);
      //开仓精度
      FP_FL_Ratio=-TotalFloatProfitFixed/TotalFloatLossFixed;
      //浮盈浮亏比
      CloseAccurate=TotalProfitFixed/TotalFloatProfitFixed;
      //平仓精度
      ProfitMiss=1-CloseAccurate;
      //盈利丢失
      PLNSpeed=-TotalProfitFixed/TotalFloatLossFixed;
      //盈亏速度
      if(PLNSpeed>3)
         InvalidResult=true;
      //ZuluTrade结果异常
     }
   double Performance=TesterStatistics(STAT_SHARPE_RATIO)*OpenAccurate*CloseAccurate;
//综合绩效算法
   if(UseZuluTradeP_N)
      //计算ZuluTrade PLN
     {
      if(InvalidResult || TotalProfitFixed<0 || TesterStatistics(STAT_SHARPE_RATIO)<MinimumSharpeRatioLimit || TotalFloatProfitFixed<0)
        {
         result=MathMax(-0.1,-MathAbs(Performance));
         ZuluTrade_P_L=-MathAbs(PLNSpeed);
        }
      else
        {
         result=MathMax(-0.1,Performance);
         ZuluTrade_P_L=PLNSpeed;
        }
     }
   else
     {
      if(InvalidResult || TotalProfitFixed<0 || TesterStatistics(STAT_SHARPE_RATIO)<MinimumSharpeRatioLimit)
        {
         result=-MathAbs(TotalProfitFixed);
        }
      else
        {
         result=TotalProfitFixed;
        }
     }
   Print("原始点差盈利=",NormalizeDouble(TotalProfitOrigin,0));
   Print("修正后的盈利=",NormalizeDouble(TotalProfitFixed,0));
   Print("原始点差浮亏=",NormalizeDouble(TotalFloatLossOrigin,0));
   Print("修正后的浮亏=",NormalizeDouble(TotalFloatLossFixed,0));
   Print("原始点差浮盈=",NormalizeDouble(TotalFloatProfitOrigin,0));
   Print("修正后的浮盈=",NormalizeDouble(TotalFloatProfitFixed,0));
   Print("平仓精度=",CloseAccurate);
   Print("开仓精度=",OpenAccurate);
   Print("丢失盈利=",ProfitMiss);
   Print("浮盈/浮亏=",FP_FL_Ratio);

   if(UseZuluTradeP_N)
     {
      Print("ZuluTrade 绩效指数=",ZuluTrade_P_L);
     }
   Print("夏普比率=",TesterStatistics(STAT_SHARPE_RATIO));
   Print("综合绩效=",result);
   Print("修正后的盈利=",TotalProfitFixed);
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Ind(int IndNumber,string mode)
  {
   if(mode=="Enter1")
     {
      switch(IndNumber)
        {
         case 0:return 0;break;
         case 1:
           {
#ifdef __MQL4__
            double FastMA1=iMA(NULL,IndEnterTF1,FastMAPeriod,0,FastMAMethod,FastMAPrice,FastMAShift);
            double FastMA2=iMA(NULL,IndEnterTF1,FastMAPeriod,0,FastMAMethod,FastMAPrice,FastMAShift+1);
#endif
#ifdef __MQL5__
            double FastMA1=IndGet(handle_FastMAEnter1,0,FastMAShift);
            double FastMA2=IndGet(handle_FastMAEnter1,0,FastMAShift+1);
#endif
            if(FastMA1>FastMA2)
               return 1;
            else
               return -1;
           }
         break;
         case 2:
           {
#ifdef __MQL4__
            double MediumMA1=iMA(NULL,IndEnterTF1,MediumMAPeriod,0,MediumMAMethod,MediumMAPrice,MediumMAShift);
            double MediumMA2=iMA(NULL,IndEnterTF1,MediumMAPeriod,0,MediumMAMethod,MediumMAPrice,MediumMAShift+1);
#endif
#ifdef __MQL5__
            double MediumMA1=IndGet(handle_MediumMAEnter1,0,MediumMAShift);
            double MediumMA2=IndGet(handle_MediumMAEnter1,0,MediumMAShift+1);
#endif
            if(MediumMA1>MediumMA2)
               return 1;
            else
               return -1;
           }
         break;
         case 3:
           {
#ifdef __MQL4__
            double SlowMA1=iMA(NULL,IndEnterTF1,SlowMAPeriod,0,SlowMAMethod,SlowMAPrice,SlowMAShift);
            double SlowMA2=iMA(NULL,IndEnterTF1,SlowMAPeriod,0,SlowMAMethod,SlowMAPrice,SlowMAShift+1);
#endif
#ifdef __MQL5__
            double SlowMA1=IndGet(handle_SlowMAEnter1,0,SlowMAShift);
            double SlowMA2=IndGet(handle_SlowMAEnter1,0,SlowMAShift+1);
#endif
            if(SlowMA1>SlowMA2)
               return 1;
            else
               return -1;
           }
         break;
         case 4:
           {
#ifdef __MQL4__
            double MACD=iMACD(NULL,IndEnterTF1,MACDFast,MACDSlow,MACDSignal,MACDPrice,MODE_MAIN,MACDShift);
#endif
#ifdef __MQL5__
            double MACD=IndGet(handle_MACDEnter1,0,MACDShift);//Main
#endif
            if(MACD>=0)
               return 1;
            else
               return -1;
           }
         break;
         case 5:
           {
#ifdef __MQL4__
            double ADXPlus=iADX(NULL,IndEnterTF1,ADXPeriod,PRICE_TYPICAL,MODE_PLUSDI,ADXShift);
            double ADXMinus=iADX(NULL,IndEnterTF1,ADXPeriod,PRICE_TYPICAL,MODE_MINUSDI,ADXShift+1);
#endif
#ifdef __MQL5__
            double ADXPlus=IndGet(handle_ADXEnter1,1,ADXShift);
            double ADXMinus=IndGet(handle_ADXEnter1,2,ADXShift+1);
#endif
            if(ADXPlus>=ADXMinus)
               return 1;
            else
               return -1;
           }
         break;
         case 6:
           {
#ifdef __MQL4__
            double SAR=iSAR(NULL,IndEnterTF1,SARStep,SARMaximum,SARShift);
#endif
#ifdef __MQL5__
            double SAR=IndGet(handle_SAREnter1,0,SARShift);
#endif
            if(SAR<=Bid)
               return 1;
            else
               return -1;
           }
         break;
         case 7:
           {
#ifdef __MQL4__
            double OsMA=iOsMA(NULL,IndEnterTF1,OsMAFast,OsMASlow,OsMASignal,OsMAPrice,OsMAShift);
#endif
#ifdef __MQL5__
            double OsMA=IndGet(handle_OsMAEnter1,0,OsMAShift);
#endif
            if(OsMA>=0)
               return 1;
            else
               return -1;
           }
         break;
        }
      if(mode=="Enter2")
        {
         switch(IndNumber)
           {
            case 0:return 0;break;
            case 1:
              {
#ifdef __MQL4__
               double FastMA1=iMA(NULL,IndEnterTF2,FastMAPeriod,0,FastMAMethod,FastMAPrice,FastMAShift);
               double FastMA2=iMA(NULL,IndEnterTF2,FastMAPeriod,0,FastMAMethod,FastMAPrice,FastMAShift+1);
#endif
#ifdef __MQL5__
               double FastMA1=IndGet(handle_FastMAEnter2,0,FastMAShift);
               double FastMA2=IndGet(handle_FastMAEnter2,0,FastMAShift+1);
#endif
               if(FastMA1>FastMA2)
                  return 1;
               else
                  return -1;
              }
            break;
            case 2:
              {
#ifdef __MQL4__
               double MediumMA1=iMA(NULL,IndEnterTF2,MediumMAPeriod,0,MediumMAMethod,MediumMAPrice,MediumMAShift);
               double MediumMA2=iMA(NULL,IndEnterTF2,MediumMAPeriod,0,MediumMAMethod,MediumMAPrice,MediumMAShift+1);
#endif
#ifdef __MQL5__
               double MediumMA1=IndGet(handle_MediumMAEnter2,0,MediumMAShift);
               double MediumMA2=IndGet(handle_MediumMAEnter2,0,MediumMAShift+1);
#endif
               if(MediumMA1>MediumMA2)
                  return 1;
               else
                  return -1;
              }
            break;
            case 3:
              {
#ifdef __MQL4__
               double SlowMA1=iMA(NULL,IndEnterTF2,SlowMAPeriod,0,SlowMAMethod,SlowMAPrice,SlowMAShift);
               double SlowMA2=iMA(NULL,IndEnterTF2,SlowMAPeriod,0,SlowMAMethod,SlowMAPrice,SlowMAShift+1);
#endif
#ifdef __MQL5__
               double SlowMA1=IndGet(handle_SlowMAEnter2,0,SlowMAShift);
               double SlowMA2=IndGet(handle_SlowMAEnter2,0,SlowMAShift+1);
#endif
               if(SlowMA1>SlowMA2)
                  return 1;
               else
                  return -1;
              }
            break;
            case 4:
              {
#ifdef __MQL4__
               double MACD=iMACD(NULL,IndEnterTF2,MACDFast,MACDSlow,MACDSignal,MACDPrice,MODE_MAIN,MACDShift);
#endif
#ifdef __MQL5__
               double MACD=IndGet(handle_MACDEnter2,0,MACDShift);//Main
#endif
               if(MACD>=0)
                  return 1;
               else
                  return -1;
              }
            break;
            case 5:
              {
#ifdef __MQL4__
               double ADXPlus=iADX(NULL,IndEnterTF2,ADXPeriod,PRICE_TYPICAL,MODE_PLUSDI,ADXShift);
               double ADXMinus=iADX(NULL,IndEnterTF2,ADXPeriod,PRICE_TYPICAL,MODE_MINUSDI,ADXShift+1);
#endif
#ifdef __MQL5__
               double ADXPlus=IndGet(handle_ADXEnter2,1,ADXShift);
               double ADXMinus=IndGet(handle_ADXEnter2,2,ADXShift+1);
#endif
               if(ADXPlus>=ADXMinus)
                  return 1;
               else
                  return -1;
              }
            break;
            case 6:
              {
#ifdef __MQL4__
               double SAR=iSAR(NULL,IndEnterTF2,SARStep,SARMaximum,SARShift);
#endif
#ifdef __MQL5__
               double SAR=IndGet(handle_SAREnter2,0,SARShift);
#endif
               if(SAR<=Bid)
                  return 1;
               else
                  return -1;
              }
            break;
            case 7:
              {
#ifdef __MQL4__
               double OsMA=iOsMA(NULL,IndEnterTF2,OsMAFast,OsMASlow,OsMASignal,OsMAPrice,OsMAShift);
#endif
#ifdef __MQL5__
               double OsMA=IndGet(handle_OsMAEnter2,0,OsMAShift);
#endif
               if(OsMA>=0)
                  return 1;
               else
                  return -1;
              }
            break;
           }
        }
     }
   return 0;
  }
//+------------------------------------------------------------------+
void UpdateRegisters()
//强制刷新所有寄存器 用于正常运行 EA可以发觉下单被拒绝或者异常
//仅用于挂机 无需考虑高效执行
  {
   BuyOrdersCount=0;//多单数量寄存器
   SellOrdersCount=0;//空单数量寄存器
   OrdersTotalByThisEA=0;//订单总量寄存器
   TotalLots=0;
   TotalTrades=0;

   LastBuyTime=0;//最后买入时间
   LastBuyOrderOpenPrice=0;//最后买入价格
   BuyLots=0;//总买入手数
   BuyPrice_x_Lot=0;//买入总手数*买入价格
   AverageBuyPrice=0;//买入均价
   FirstBuyOrderTime=0;//首次做多时间 订单过期用

   LastSellTime=0;//最后卖出时间
   LastSellOrderOpenPrice=0;//最后卖出价格
   SellLots=0;//卖出总手数
   SellPrice_x_Lot=0;//卖出总手数*买入价格
   AverageSellPrice=0;//卖出均价
   FirstSellOrderTime=0;//首次做空时间 订单过期用

   for(int i=OrdersTotal()-1; i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(OrderSelect(i,SELECT_BY_POS))
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
           {
            //确认是本EA下单 刷新所有必须刷新的寄存器
            if(OrderType()==OP_BUY)
              {
               datetime orderOpenTime=OrderOpenTime();
               //当前订单开仓时间 存入寄存器 避免反复调用函数
               BuyTicket[BuyOrdersCount]=OrderTicket();
               //订单编号寄存器数组
               BuyLot[BuyOrdersCount]=OrderLots();
               //手数寄存器数组 平仓要用
               BuyLots=BuyLots+OrderLots();
               //总手数寄存器
               BuyPrice_x_Lot=BuyPrice_x_Lot+OrderLots()*OrderOpenPrice();
               //累计买入价寄存器 算均价用
               AverageBuyPrice=BuyPrice_x_Lot/BuyLots;
               //买入均价 计算保本位置
               BuyOrdersCount++;
               //买单数量寄存器
               OrdersTotalByThisEA++;
               //EA持仓单数寄存器
               TotalLots=TotalLots+OrderLots();
               //总手数
               TotalTrades++;
               //总交易次数
               MinimumTargetBuyTP=AverageBuyPrice==0 ? 0 : NormalizeDouble(AverageBuyPrice+Distance*MinimumTP,Digits);
               //止盈目标
               LastBuyTime=MathMax(LastBuyTime,orderOpenTime);
               //最后开仓时间寄存器
               if(LastBuyOrderOpenPrice>0)
                  //最后买入价寄存器 用于加层
                  LastBuyOrderOpenPrice=MathMin(LastBuyOrderOpenPrice,OrderOpenPrice());
               //马丁开仓 多单位置越来越低 最低但高于0的是最后一次下单的位置
               else
                  LastBuyOrderOpenPrice=OrderOpenPrice();
               //若前面没有获取过开仓价 则当前单子即为最后开仓
               if(FirstBuyOrderTime>0)
                  //首次开启多单时间寄存器
                  FirstBuyOrderTime=MathMin(FirstBuyOrderTime,orderOpenTime);
               //寻找第一张多单下单时间
               else
                  FirstBuyOrderTime=orderOpenTime;
               //首次开仓时间
              }
            if(OrderType()==OP_SELL)
              {
               datetime orderOpenTime=OrderOpenTime();
               //当前订单开仓时间 存入寄存器 避免反复调用函数
               SellTicket[SellOrdersCount]=OrderTicket();
               //订单编号寄存器数组
               SellLot[SellOrdersCount]=OrderLots();
               //手数寄存器数组 平仓要用
               SellLots=SellLots+OrderLots();
               //总手数寄存器
               SellPrice_x_Lot=SellPrice_x_Lot+OrderLots()*OrderOpenPrice();
               //累计卖出价寄存器 算均价用
               AverageSellPrice=SellPrice_x_Lot/SellLots;
               //卖出均价 保本位置
               SellOrdersCount++;
               //买单数量寄存器
               OrdersTotalByThisEA++;
               //EA持仓单数寄存器
               TotalLots=TotalLots+OrderLots();
               //总手数
               TotalTrades++;
               //总交易次数
               MinimumTargetSellTP=AverageSellPrice==0 ? 0 : NormalizeDouble(AverageSellPrice-Distance*MinimumTP,Digits);
               //止盈目标
               LastSellTime=MathMax(LastSellTime,orderOpenTime);
               //最后开仓时间寄存器
               if(LastSellOrderOpenPrice>0)
                  //最后卖出价寄存器 用于加层
                  LastSellOrderOpenPrice=MathMax(LastSellOrderOpenPrice,OrderOpenPrice());
               //马丁开仓 空单位置越来越高 最高并且高于0的是最后一次下单的位置
               else
                  LastSellOrderOpenPrice=OrderOpenPrice();
               //若前面没有获取过开仓价 则当前单子即为最后开仓
               if(FirstSellOrderTime>0)
                  //首次开启空单时间寄存器
                  FirstSellOrderTime=MathMin(FirstSellOrderTime,orderOpenTime);
               //寻找第一张空单下单时间
               else
                  FirstSellOrderTime=orderOpenTime;
               //首次开仓时间
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DueCut()
//到期砍仓
  {
   if(OrdersTotalByThisEA>0)
     {
      if(BuyOrdersCount>0)
         if(Time_Current-FirstBuyOrderTime>3600*24*DueDays)
            //多单超时
            CloseBuyOrders();
      if(SellOrdersCount>0)
         if(Time_Current-FirstSellOrderTime>3600*24*DueDays)
            //多单超时
            CloseSellOrders();
     }
   return;
  }
//+------------------------------------------------------------------+
bool isNewsRelease()
  {
   NotInNewsTime=false;
//默认标记为有数据 禁止开仓 仅平仓
   if(
      (Time_Current>=D'2015.01.14' && Time_Current<=D'2015.01.16')//瑞郎黑天鹅 所有货币禁止
      || ((Time_Current>=D'2014.12.30' && Time_Current<=D'2015.02.16') && StringFind(Symbol(),"CHF",0)>-1)//瑞郎黑天鹅瑞郎特别强化过滤
      //|| ((Time_Current>=D'2014.07.20' && Time_Current<=D'2015.03.22') && StringFind(Symbol(),"USD",0)>-1)//美元大牛市
      //|| ((Time_Current>=D'2012.12.09' && Time_Current<=D'2013.04.21') && StringFind(Symbol(),"JPY",0)>-1)//日元大熊市1 日本政府打压日元
      //|| ((Time_Current>=D'2014.10.31' && Time_Current<=D'2014.11.24') && StringFind(Symbol(),"JPY",0)>-1)//日元大熊市2 黑田东彦意外动作
      || (Time_Current>=D'2016.06.22' && Time_Current<=D'2016.06.28')//退欧 
      || ((Time_Current>=D'2016.10.06' && Time_Current<=D'2016.10.10') && StringFind(Symbol(),"GBP",0)>-1)//英镑黑天鹅
      || (Time_Current>=D'2016.11.04' && Time_Current<=D'2016.11.10')//美国大选
      )
      //禁止开仓时间范围内
     {
      CloseBuyOrders();
      CloseSellOrders();
      //强制砍仓
      return true;
     }
   else
     {
      NotInNewsTime=true;
      //不在需要砍仓的时间范围
      return false;
     }
   return false;
  }
//+------------------------------------------------------------------+
void StatsClose(int orderTicket,int Number,double Max,double Min)
  {
   if(RecordCSV)
     {
      if(OrderSelect(orderTicket,SELECT_BY_TICKET,MODE_TRADES))
        {
         TotalKickback=TotalKickback+LotKickback*OrderLots();
         //总佣金=前面的统计+每手佣金*订单手数
         string orderType="NULL";
         //订单类型文字 识别不出就是NULL
         if(OrderType()==OP_BUY) {orderType="多";}
         if(OrderType()==OP_SELL) {orderType="空";}
         //订单类型文字
         FileSeek(StatCloseHandle,0,SEEK_END);
         //调到最后一行 init已经初始化过句柄 不再重新初始化 防止降速
         FileWrite(StatCloseHandle,
                   OrderTicket(),
                   //订单编号
                   TimeToString(OrderOpenTime(),TIME_DATE|TIME_MINUTES),
                   //开仓时间
                   TimeToString(Time_Current),
                   //平仓时间
                   OrderSymbol(),
                   //货币
                   orderType,
                   //多空文字
                   NormalizeDouble(OrderLots(),2),
                   //手数
                   NormalizeDouble(OrderStopLoss(),Digits),
                   //止损价格
                   NormalizeDouble(OrderTakeProfit(),Digits),
                   //止盈价格
                   NormalizeDouble(OrderOpenPrice(),Digits),
                   //开仓价格
                   NormalizeDouble(OrderClosePrice(),Digits),
                   //平仓价格
                   NormalizeDouble(OrderCommission(),Digits),
                   //手续费
                   NormalizeDouble(OrderSwap(),3),
                   //过夜利息
                   NormalizeDouble((Time_Current-OrderOpenTime())/3600,2),
                   //持仓时长
                   NormalizeDouble(OrderProfit()/OrderLots(),2),
                   //考虑点值后的点数
                   NormalizeDouble(AccountProfit(),2),
                   //账户盈亏
                   NormalizeDouble(OrderProfit()+OrderCommission()+OrderSwap()-OrderLots()*ExtraCommission*ExtraCommissionMultiply,2),
                   //平仓盈利(含费用)
                   NormalizeDouble(OrderProfit()+OrderCommission()+OrderSwap()+LotKickback*OrderLots(),2),
                   //含返佣盈利(含费用)
                   NormalizeDouble(LotKickback*OrderLots(),2),
                   //返佣
                   NormalizeDouble(TotalKickback,2),
                   //累计返佣
                   NormalizeDouble(AccountMargin(),2),
                   //已用保证金
                   NormalizeDouble(AccountBalance()-initBalance,2),
                   //余额变化 减去初始余额 下同
                   NormalizeDouble(AccountEquity()-initBalance,2),
                   //净值变化
                   NormalizeDouble(AccountEquity()-initBalance+TotalKickback,2),
                   //含返佣净值
                   NormalizeDouble(AccountBalance()-initBalance+TotalKickback,2),
                   //含返佣余额
                   MaxFloatLoss,
                   //历史最大浮亏
                   Number,Max,Min,
                   NormalizeDouble(OrderProfit()+OrderCommission()+OrderSwap()-OrderLots()*ExtraCommission*ExtraCommissionMultiply,2)
                   //平仓盈利(含费用)
                   //,"=SUM(F:F),=SUM(L:L),=SUM(P:P),=MAX(S:S),=SUM(Q:Q)"
                   //Excel计算用附加
                   );
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#ifdef __MQL5__ 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double IndGet(int handle,const int index,int shift)
  {
   static double Ind[1];
   if(CopyBuffer(handle,index,shift,1,Ind)<0)
     {
      PrintFormat("Failed to copy data from the indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0);
     }
   return(Ind[0]);
  }
#endif
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ZuluTrade()
  {
   for(int i=BuyOrdersCount-1; i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
#ifdef __MQL5__
      if(PositionSelectByTicket(BuyTicket[i]))
        {
         BuyMin[i]=MathMin(BuyMin[i],PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP));
         BuyMax[i]=MathMax(BuyMax[i],PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP));
        }
#endif
#ifdef __MQL4__
      if(OrderSelect(BuyTicket[i],SELECT_BY_TICKET))
        {
         BuyMin[i]=MathMin(BuyMin[i],OrderProfit()+OrderCommission()+OrderSwap());
         BuyMax[i]=MathMax(BuyMax[i],OrderProfit()+OrderCommission()+OrderSwap());
        }
#endif

     }
   for(int i=SellOrdersCount-1; i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
#ifdef __MQL5__
      if(PositionSelectByTicket(SellTicket[i]))
        {
         SellMin[i]=MathMin(SellMin[i],PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP));
         SellMax[i]=MathMax(SellMax[i],PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP));
        }
#endif
#ifdef __MQL4__
      if(OrderSelect(SellTicket[i],SELECT_BY_TICKET))
        {
         SellMin[i]=MathMin(SellMin[i],OrderProfit()+OrderCommission()+OrderSwap());
         SellMax[i]=MathMax(SellMax[i],OrderProfit()+OrderCommission()+OrderSwap());
        }
#endif
     }
  }
//+------------------------------------------------------------------+
