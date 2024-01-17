/* ############################################################### */
/* ######## ANÁLISE DESCRITIVA - TRABALHO AMOSTRAGEM ######## */
/* ############################################################### */


/* Importar banco de dados */

proc import datafile="/home/u59041777/trab_avaria (1).xlsx"
            out=banco
            dbms=xlsx replace;
run;


/* Histograma */

proc sgplot data=banco;
  histogram Idade / 
    binwidth=5       /* Largura dos bins */
    fillattrs=(color="#A11D21") /* Cor das barras do histograma */
    datalabel;       /* Exibir rótulos de dados */

  xaxis label='Idade'; /* Rótulo do eixo X */
  yaxis label='Frequência'; /* Rótulo do eixo Y */
run;

/* Gráfico de Setores Avarias */

data banco1;
  set banco;
  if Avaria = 0 then Avaria_Label = 'Não possui';
  else if Avaria = 1 then Avaria_Label = 'Possui';
run;


proc gchart data=banco1;
  pie Avaria_Label; 
run;

/* Gráfico de Setores Tipos de Avarias */

data banco2;
  set banco;
  if Tipo_avaria = 0 then Tp_Avaria_Label = 'Não possui';
  if Tipo_avaria = 1 then Tp_Avaria_Label = 'Capa';
  if Tipo_avaria = 2 then Tp_Avaria_Label = 'Oxidação das folhas';
  else if Tipo_avaria = 3 then Tp_Avaria_Label = 'Rasuras';
run;


proc gchart data=banco2;
  pie Tp_Avaria_Label; 
run;

/* Ano com tipos de avarias */

proc sgplot data=banco2;
   vbox Idade / category=Tp_Avaria_Label lineattrs=(color=black) fillattrs=(color=blue); /* Defina a cor desejada aqui */
   yaxis label='Idade';
   xaxis label='Tipo de Avaria';
run;


proc print data=banco1;
run;

/* Medidas descritivas Idade */

proc means data=banco mean min max std p25 p75;
   var Idade;
   output out=media_idade mean=media_idade;
run;

/* Calcular a variância chapéu */

data variancia;
p= 0.71;
q = 0.29;
variancia_chapeu = (p*q)/(100-1);
run;

proc print data=variancia;
run;
