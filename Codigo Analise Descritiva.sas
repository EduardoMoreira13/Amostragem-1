/* ################################################### */
/* ** PROGRAMA-SAS – RESULTADOS **** */
/* ################################################### */

OPTIONS LS=80 PS=60 NODATE;

/* LEITURA E DIVISÃO DOS DADOS */

proc import
 datafile="/home/u59041762/Dados categorizados/trabalho_avaria_BCE.xlsx"
 out= pessoal.dados DBMS = xlsx REPLACE;
 sheet="Dados";
 GETNAMES = YES;
run;

/* Variável de identificação 1 a 100 */
DATA ID1 (drop = i);
    id = 0;
    do i = 1 to 100;
    	id + 1;
        output;
	end;
RUN;

DATA pessoal.dados1; 
  set pessoal.dados; 
  set ID1;
RUN; 

/* dados de treinamento */

proc surveyselect data = pessoal.dados1 method = SRS rep = 1 
  sampsize = 50 seed = 14112023 out = pessoal.dados_treinamento;
  id _all_;
run;

proc print data = pessoal.dados_treinamento noobs;
run;


/* dados de validação */
data pessoal.dados_validacao;
  set pessoal.dados1;
      if id not in (01,05,07,08,14,15,17,18,21,22,
                    24,25,26,27,28,31,32,36,38,39,
                    41,46,47,49,50,51,53,54,58,59,
                    60,62,64,66,67,69,71,72,76,77,
                    79,81,82,85,86,87,90,91,93,97) then delete;
run;





/* ------------------------------------------------------------------ */





/* AMOSTRA TREINAMENTO - 50 OBSERVAÇÕES */

/* Regressão Logística - Binária */
proc logistic data = pessoal.dados_treinamento;
 class Fileira /ref=first param=ref;
 model Avaria (event='1') = Idade_Livro Fileira /covb;
run;

/* Estimação - Probabilidade */
proc logistic data= pessoal.dados_treinamento descending;
 class Fileira /ref=first param=ref;
 model Avaria = Idade_Livro;
 output out=estim p=pi_est ;
run;

/* Listando os valores estimados de Pi */
Proc print data=estim;
var Avaria Idade_Livro _level_ pi_est;
run;

proc sort data = estim presorted out=ordem;
by pi_est;
run;

Proc print data=ordem;
var Avaria Idade_Livro pi_est;
run;

/* Solicita o teste de Hosmer e Lameshow */
/* de Adequabilidade de Ajustamento */
proc logistic data = pessoal.dados_treinamento descending;
 class Fileira /ref=first param=ref;
 model Avaria = Idade_Livro /lackfit;
run;


/* Discriminante Linear */
data new_data;
    set pessoal.dados_treinamento;
    keep Avaria Idade_Livro;
run;

proc discrim data = new_data; 
  class Avaria; 
  priors '0' = 0.4 '1'=0.6;
run;





/* ------------------------------------------------------------------ */





/* AMOSTRA VALIDAÇÃO - 50 OBSERVAÇÕES */

/* Regressão Logística - Binária */
proc logistic data = pessoal.dados_validacao;
 class Fileira /ref=first param=ref;
 model Avaria (event='1') = Idade_Livro Fileira /covb;
run;

/* Estimação - Probabilidade */
proc logistic data= pessoal.dados_validacao descending;
 class Fileira /ref=first param=ref;
 model Avaria = Idade_Livro;
 output out=estim p=pi_est ;
run;

/* Listando os valores estimados de Pi */
Proc print data=estim;
var Avaria Idade_Livro _level_ pi_est;
run;

proc sort data = estim presorted out=ordem;
by pi_est;
run;

Proc print data=ordem;
var Avaria Idade_Livro pi_est;
run;

/* Solicita o teste de Hosmer e Lameshow */
/* de Adequabilidade de Ajustamento */
proc logistic data = pessoal.dados_validacao descending;
 class Fileira /ref=first param=ref;
 model Avaria = Idade_Livro /lackfit;
run;


/* Discriminante Linear */
data new_data;
    set pessoal.dados_validacao;
    keep Avaria Idade_Livro;
run;

proc discrim data = new_data; 
  class Avaria; 
  priors '0' = 0.4 '1'=0.6;
run;





/* ------------------------------------------------------------------ */





/* AMOSTRA COMPLETA - 100 OBSERVAÇÕES */


proc import
 datafile="/home/u59041762/Dados categorizados/trabalho_avaria_BCE.xlsx"
 out= pessoal.dados DBMS = xlsx REPLACE;
 sheet="Dados";
 GETNAMES = YES;
run;

/* Vendo conteúdo do arquivo SAS */
proc contents data= pessoal.dados varnum;
run;

/* Análise descritiva e teste do Qui-Quadrado */
proc sort data = pessoal.dados presorted out=ordem;
by Fileira;
run;

proc means data = ordem n mean median 
   std var cv maxdec=2;
   var Avaria;
   class Fileira;
   by Fileira;
run;

proc freq data = pessoal.dados order=data;
 tables Fileira*Avaria /nopercent nocol relrisk chisq;
run;

/* Regressão Logística - Binária */
proc logistic data = pessoal.dados;
 class Fileira /ref=first param=ref;
 model Avaria (event='1') = Idade_Livro Fileira /covb;
run;

/* Estimação - Probabilidade */
proc logistic data= pessoal.dados descending;
 class Fileira /ref=first param=ref;
 model Avaria = Idade_Livro;
 output out=estim p=pi_est ;
run;

/* Listando os valores estimados de Pi */
Proc print data=estim;
var Avaria Idade_Livro _level_ pi_est;
run;

proc sort data = estim presorted out=ordem;
by pi_est;
run;

Proc print data=ordem;
var Avaria Idade_Livro pi_est;
run;

/* Solicita o teste de Hosmer e Lameshow */
/* de Adequabilidade de Ajustamento */
proc logistic data = pessoal.dados descending;
 class Fileira /ref=first param=ref;
 model Avaria = Idade_Livro /lackfit;
run;


/* Discriminante Linear */
data new_data;
    set pessoal.dados;
    keep Avaria Idade_Livro;
run;

proc discrim data = new_data; 
  class Avaria; 
  priors '0' = 0.4 '1'=0.6;
run;

data new_data;
    set pessoal.dados;
    keep Tipo_avaria Idade_Livro;
run;

proc discrim data = new_data; 
  class Tipo_avaria; 
  priors proportional;
run;