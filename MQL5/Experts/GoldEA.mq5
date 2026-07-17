//+------------------------------------------------------------------+
//| GoldEA v1.0                                                      |
//| Commit 1                                                         |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"

#include <Trade/Trade.mqh>

CTrade trade;

//====================================================
// Inputs
//====================================================

input double EntryTolerance = 5.0;
input double Lots = 0.10;

//====================================================
// Structures
//====================================================

struct SEntry
{
   string name;
   double price;

   string tpName;
   double tpPrice;

   bool hasTP;
};

struct SZone
{
   string name;
   double top;
   double bottom;
};

//====================================================
// Arrays
//====================================================

SEntry BuyEntry[100];
SEntry SellEntry[100];

SZone BuyHTF[100];
SZone SellHTF[100];

SZone BuyOF[100];
SZone SellOF[100];

//====================================================
// Counters
//====================================================

int BuyCount=0;
int SellCount=0;

int BuyHTFCount=0;
int SellHTFCount=0;

int BuyOFCount=0;
int SellOFCount=0;

//====================================================

double MidPrice()
{
   return((Bid+Ask)/2.0);
}

//====================================================

void ResetArrays()
{
   BuyCount=0;
   SellCount=0;

   BuyHTFCount=0;
   SellHTFCount=0;

   BuyOFCount=0;
   SellOFCount=0;
}

//====================================================

void ReadObjects()
{

   ResetArrays();

   int total=ObjectsTotal(0);

   for(int i=0;i<total;i++)
   {

      string obj=ObjectName(0,i);

      ENUM_OBJECT type=(ENUM_OBJECT)ObjectGetInteger(0,obj,OBJPROP_TYPE);

      //------------------------------------------------
      // Horizontal lines
      //------------------------------------------------

      if(type==OBJ_HLINE)
      {

         double price=ObjectGetDouble(0,obj,OBJPROP_PRICE);

         //---------------- BUY -------------------------

         if(StringFind(obj,"BUY_")==0 &&
            StringFind(obj,"BUY_TP_")!=0)
         {

            BuyEntry[BuyCount].name=obj;
            BuyEntry[BuyCount].price=price;
            BuyEntry[BuyCount].hasTP=false;

            BuyCount++;

         }

         //---------------- SELL ------------------------

         if(StringFind(obj,"SELL_")==0 &&
            StringFind(obj,"SELL_TP_")!=0)
         {

            SellEntry[SellCount].name=obj;
            SellEntry[SellCount].price=price;
            SellEntry[SellCount].hasTP=false;

            SellCount++;

         }

      }

      //------------------------------------------------
      // Rectangles
      //------------------------------------------------

      if(type==OBJ_RECTANGLE)
      {

         double p1=ObjectGetDouble(0,obj,OBJPROP_PRICE,0);
         double p2=ObjectGetDouble(0,obj,OBJPROP_PRICE,1);

         double top=MathMax(p1,p2);
         double bottom=MathMin(p1,p2);

         //---------------- HTF BUY ---------------------

         if(StringFind(obj,"HTF_BUY_")==0)
         {

            BuyHTF[BuyHTFCount].name=obj;
            BuyHTF[BuyHTFCount].top=top;
            BuyHTF[BuyHTFCount].bottom=bottom;

            BuyHTFCount++;

         }

         //---------------- HTF SELL --------------------

         if(StringFind(obj,"HTF_SELL_")==0)
         {

            SellHTF[SellHTFCount].name=obj;
            SellHTF[SellHTFCount].top=top;
            SellHTF[SellHTFCount].bottom=bottom;

            SellHTFCount++;

         }

         //---------------- OF BUY ----------------------

         if(StringFind(obj,"OF_BUY_")==0)
         {

            BuyOF[BuyOFCount].name=obj;
            BuyOF[BuyOFCount].top=top;
            BuyOF[BuyOFCount].bottom=bottom;

            BuyOFCount++;

         }

         //---------------- OF SELL ---------------------

         if(StringFind(obj,"OF_SELL_")==0)
         {

            SellOF[SellOFCount].name=obj;
            SellOF[SellOFCount].top=top;
            SellOF[SellOFCount].bottom=bottom;

            SellOFCount++;

         }

      }

   }

   //---------------------------------------------------
   // Pair BUY TP
   //---------------------------------------------------

   for(int i=0;i<BuyCount;i++)
   {

      string tp=BuyEntry[i].name;

      StringReplace(tp,"BUY_","BUY_TP_");

      if(ObjectFind(0,tp)>=0)
      {

         BuyEntry[i].tpName=tp;
         BuyEntry[i].tpPrice=ObjectGetDouble(0,tp,OBJPROP_PRICE);
         BuyEntry[i].hasTP=true;

      }

   }

   //---------------------------------------------------
   // Pair SELL TP
   //---------------------------------------------------

   for(int i=0;i<SellCount;i++)
   {

      string tp=SellEntry[i].name;

      StringReplace(tp,"SELL_","SELL_TP_");

      if(ObjectFind(0,tp)>=0)
      {

         SellEntry[i].tpName=tp;
         SellEntry[i].tpPrice=ObjectGetDouble(0,tp,OBJPROP_PRICE);
         SellEntry[i].hasTP=true;

      }

   }

}

//====================================================

void Dashboard()
{

   string txt;

   txt+="GoldEA\n";
   txt+="-----------------------\n";

   txt+="BUY Lines : "+IntegerToString(BuyCount)+"\n";
   txt+="SELL Lines: "+IntegerToString(SellCount)+"\n\n";

   txt+="BUY HTF : "+IntegerToString(BuyHTFCount)+"\n";
   txt+="SELL HTF: "+IntegerToString(SellHTFCount)+"\n\n";

   txt+="BUY OF : "+IntegerToString(BuyOFCount)+"\n";
   txt+="SELL OF: "+IntegerToString(SellOFCount)+"\n\n";

   txt+="Price : "+DoubleToString(MidPrice(),2);

   Comment(txt);

}

//====================================================

int OnInit()
{

   Print("GoldEA Started");

   return(INIT_SUCCEEDED);

}

//====================================================

void OnTick()
{

   ReadObjects();

   Dashboard();

}

//====================================================

void OnDeinit(const int reason)
{

   Comment("");

}
