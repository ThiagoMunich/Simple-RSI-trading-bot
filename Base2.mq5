//+------------------------------------------------------------------+
//|                                                    Base2.mq5     |
//|                                    Copyright 2021, Thiago Munich |
//|                         https://www.linkedin.com/in/thiagomunich |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Thiago Munich."
#property link      "https://www.linkedin.com/in/thiagomunich"
#property version   "1.0"

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
CTrade trade;

input int tamanhoDoLote = 1; //Número de contratos
input double pontoStop = 150.0;//Pontos para stop loss (a partir do preço de entrada)
input double pontosTake = 150.00;//Pontos para take profit (a partir do preço de entrada)

const uint MagicNumber = 21;

int OnInit(){
   trade.SetExpertMagicNumber(MagicNumber);
   
   return(INIT_SUCCEEDED);
}


int ObterSinal() {
 
   int verificador = 0;
 
   double rsiArray[];
   int rsi = iRSI(Symbol(),Period(),14,PRICE_CLOSE);
   ArraySetAsSeries(rsiArray,true);
   CopyBuffer(rsi,0,0,5,rsiArray);
   double rsi_1 = NormalizeDouble(rsiArray[0],2);
   
   MqlDateTime stm;
   TimeToStruct(TimeCurrent(),stm);
   int horarioAtual = (stm.hour*60) + stm.min;
   int horarioLimite = (9*60) + 10;
   
   if(horarioAtual > horarioLimite) {
   
       // SINAL DE COMPRA
       if(rsi_1 < 30)
          verificador = 1;
             
       // SINAL DE VENDA
       if(rsi_1 > 70)
          verificador = 2;
   }
              
   return (verificador);
   
}// end ObterSinal()

void AbrirOrdem(){
   MqlRates infoDosCandles[];
   ArraySetAsSeries(infoDosCandles,true);
   CopyRates(Symbol(),Period(),0,10,infoDosCandles);
   double precoAtual = infoDosCandles[0].close;
   
   if(ObterSinal()==1 && PositionsTotal()==0){
         double precoEntrada = precoAtual;
         double precoLoss = round(precoEntrada - pontoStop);
         double precoGain = round(precoEntrada + pontosTake);
         
         trade.PositionOpen(Symbol(),ORDER_TYPE_BUY,tamanhoDoLote,precoEntrada,precoLoss,precoGain,"COMPRA ACIONADA.");
   
         Print("*********************");
         Print("** COMPRA ACIONADA **");
         Print("*********************");
      
   } // end ObterSinal == 1 (COMPRA)
   
   if(ObterSinal()==2 && PositionsTotal()==0){
         double precoEntrada = precoAtual;
         double precoLoss = round(precoEntrada + pontoStop);
         double precoGain = round(precoEntrada - pontosTake);

         trade.PositionOpen(Symbol(),ORDER_TYPE_SELL,tamanhoDoLote,precoEntrada,precoLoss,precoGain,"VENDA ACIONADA.");
         
         Print("********************");
         Print("** VENDA ACIONADA **");
         Print("********************");
      
   }// end ObterSinal == 2 (VENDA)
}// end AbrirOrdem()

void OnTick(){

    AbrirOrdem();

   return;
}// end OnTick()