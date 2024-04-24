/* Generated Code (IMPORT) */
/* Source File: Car_sales_final1.xlsx */
/* Source Path: /home/u63650692 */
/* Code generated on: 12/7/23, 3:07 PM */

%web_drop_table(WORK.IMPORT);


FILENAME REFFILE '/home/u63650692/Car_sales_final1.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.IMPORT;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.IMPORT; RUN;


%web_open_table(WORK.IMPORT);

proc means data=WORK.IMPORT;
var Resale_Price_in_Dollars mileage registered_year KMs_Driven;

proc corr data=WORK.IMPORT noprob;
var Resale_Price_in_Dollars mileage registered_year KMs_Driven;

/*VIF, INFLUENCE*/

proc reg data=WORK.IMPORT;
model Resale_Price_in_Dollars = mileage registered_year KMs_Driven / vif influence;
output out=carout predicted=yhat residual=e student=tres h=hii cookd=cookdi dffits=dffitsi;
run;

/* Modified-Levene Test*/
data carmod; set WORK.IMPORT; set carout;
 id = _n_;
 label id = "observation number";
 group = 1;
 if Resale_Price_in_Dollars >4625 then group = 2;
proc sort data = carmod;
 by group;
proc univariate data = carmod noprint;
 by group;
 var e;
 output out = mout median =mede;
proc print data = mout;
 var group mede;
data mtemp;
 merge carmod mout;
 by group;
 d = abs(e - mede);
proc sort data = mtemp;
  by group;
 
 proc means data = mtemp noprint;
  by group;
  var d;
  output out = mout1 mean= meand;
 proc print data = mout1;
 var group meand;
 data mtemp1;
  merge mtemp mout1;
  by group;
  ddif = (d - meand)**2;
 proc sort data =mtemp;
  by group Resale_Price_in_Dollars;
 proc ttest data =mtemp;
 	class group;
	 var d;
 proc print data = mtemp1;
  by group;
  var id Resale_Price_in_Dollars e d ddif;
 run;
/*Log Transformation*/
data car2; set WORK.IMPORT;
logtenY=log10(Resale_Price_in_Dollars);

proc reg data=car2;
model logtenY=mileage registered_year KMs_Driven / vif influence;
output out=carout2 predicted=yhat2 residual=e2 student=tres2 h=hii2 cookd=cookdi2 dffits=dffitsi2;

proc print;
var logtenY mileage registered_year KMs_Driven yhat2 e2 tres2 hii2 cookdi2 dffitsi2;
run;

/*.     */

/* create normal scores for residuals*/
proc rank normal=blom out=enrm data=carout;
var e;
ranks enrm;
run;

data carnew; set carout; set enrm;
label enrm='Normal Scores';
label e='e(Y| x1,x2,x3)';
label yhat = 'Predicted Resale';
proc print;

proc corr data=carnew noprob;
var e enrm;
run;

/* create normal scores for e2 residuals*/
proc rank normal=blom out=enrm2 data=carout2;
var e2;
ranks enrm2;
run;

data carnew2; set carout2; set car2int; set enrm2;
label enrm2='Normal Scores';
label e2='e(logY| x1,x2,x3)';
label yhat2='Predicted log resale';
proc print;

proc corr data=carnew2 noprob;
var e2 enrm2;
run;

/* Standardize predictor variables*/
/* Make copy of variables that will be standardized */

data car2a; set car2;
stdx1 = mileage;
stdx2 = registered_year;
stdx3 = KMs_Driven;

proc standard data=car2a mean=0 std=1 out=car2std;
var stdx1 stdx2 stdx3;
proc print;

/*Interaction terms*/
data car2int; set car2std;
x1x2 = mileage*registered_year;
x1x3 = mileage*KMs_Driven;
x2x3 = registered_year*KMs_Driven;
stdx1x2 = stdx1*stdx2;
stdx1x3 = stdx1*stdx3;
stdx2x3 = stdx2*stdx3;

proc corr data=car2int noprob;
var x1x2 x1x3 x2x3;

proc corr data=car2int noprob;
var stdx1x2 stdx1x3 stdx2x3;
run;

/* Residual Plots Original Y*/


goptions reset = all;
symbol1 v=dot c=black;
axis1 label=(angle = 90);
proc gplot data = carnew;
plot e*yhat/vref = 0 vaxis = axis1;
plot e*enrm/ vaxis = axis1;
plot e*mileage/vref = 0 vaxis = axis1;
plot e*registered_year/vref = 0 vaxis = axis1;
plot e*KMs_Driven / vref = 0 vaxis = axis1;
run;

/* Residual Plots log10 Y*/
goptions reset = all;
symbol1 v=dot c=black;
axis1 label=(angle = 90);
proc gplot data = carnew2;
plot e2*yhat2 /vref = 0 vaxis = axis1;
plot e2*enrm2 / vaxis = axis1;
plot e2*mileage /vref = 0 vaxis = axis1;
plot e2*registered_year /vref = 0 vaxis = axis1;
plot e2*KMs_Driven / vref = 0 vaxis = axis1;
plot logtenY*mileage /vref = 0 vaxis = axis1;
plot logtenY*registered_year /vref = 0 vaxis = axis1;
plot logteny*KMs_Driven/ vref = 0 vaxis = axis1;
run;

/* Plots of residuals vs. interactions */
proc gplot data = carnew2;
plot e2*x1x2 /vref = 0 vaxis = axis1;
plot e2*x1x3 /vref = 0 vaxis = axis1;
plot e2*x2x3 /vref = 0 vaxis = axis1;
run;

/* Plots of residuals vs. standardized interactions */
proc gplot data = carnew2;
plot e2*stdx1x2 /vref = 0 vaxis = axis1;
plot e2*stdx1x3 / vref = 0 vaxis = axis1;
plot e2*stdx2x3 /vref = 0 vaxis = axis1;
run;

/* Partial Regression Plots for Interactions */
proc reg data=car2int;
model x1x2 = mileage registered_year KMs_Driven;
output out=outint residual=ex1x2;
proc reg data=outint;
model x1x3 = mileage registered_year KMs_Driven;
output out=outint residual=ex1x3;
proc reg data=outint;
model x2x3 = mileage registered_year KMs_Driven;
output out=outint residual=ex2x3;
data partreg; set carnew2; set outint;
label ex1x2 = 'e(x1x2 | x1,x2,x3)';
label ex1x3 = 'e(x1x3 | x1,x2,x3)';
label ex2x3 = 'e(x2x3 | x1,x2,x3)';
proc print;

proc gplot data = partreg;
plot e2*ex1x2 /vref = 0 vaxis = axis1;
plot e2*ex1x3 /vref = 0 vaxis = axis1;
plot e2*ex2x3 /vref = 0 vaxis = axis1;
run;

/* Best Subsets */
/* selection = (rsquare adjrsa cp press aic mse sse} *
/*aic = Akaike's information criterion */
/* sbc = Schwarz's Bayesian criterion */
/* start = smallest # of predictors in a model */
/* stop = largest # of predictors in a model */
/* best = maximum # of models to be printed */
proc reg data=car2int;
model logtenY = mileage registered_year KMs_Driven stdx1x2 stdx1x3 stdx2x3 / selection = adjrsq cp aic sbc
start=1 stop=1 best=2;
proc reg data=car2int;
model logtenY = mileage registered_year KMs_Driven stdx1x2 stdx1x3 stdx2x3 / selection = adjrsq cp aic sbc
start=2 stop=2 best=2;
proc reg data=car2int;
model logtenY = mileage registered_year KMs_Driven stdx1x2 stdx1x3 stdx2x3 / selection = adjrsq cp aic sbc
start=3 stop=3 best=2;
proc reg data=car2int;
model logtenY = mileage registered_year KMs_Driven stdx1x2 stdx1x3 stdx2x3 / selection = adjrsq cp aic sbc
start=4 stop=4 best=2;
proc reg data=car2int;
model logtenY = mileage registered_year KMs_Driven stdx1x2 stdx1x3 stdx2x3 / selection = adjrsq cp aic sbc
start=5 stop=5 best=2;
proc reg data=car2int;
model logtenY = mileage registered_year KMs_Driven stdx1x2 stdx1x3 stdx2x3 / selection = adjrsq cp aic sbc
start=6 stop=6 best=2;

/* Stepwise */
/* selection = (backward forward stepwise) */
/*slentry = tail probability for F-in "/
/* slstay = tail probability for F-out */
proc reg data=car2int;
model logtenY = mileage registered_year KMs_Driven stdx1x2 stdx1x3 stdx2x3 / selection = stepwise
slstay=.10;
proc reg data=car2int;
model logtenY = mileage registered_year KMs_Driven stdx1x2 stdx1x3 stdx2x3 / selection = backward
slstay=.10;
run;

proc reg data=car2int;
model logtenY = mileage registered_year KMs_Driven stdx1x2 stdx1x3 stdx2x3 / vif influence;
output out=carout4a predicted=yhat4a residual=e4a student=tres4a h=hii4a cookd=cookdi4a
dffits=dffitsi4a;
proc print;
var logtenY mileage registered_year KMs_Driven stdx1x2 stdx1x3 stdx2x3 cookdi4a;
run;
proc reg data=car2int;
model logtenY = mileage registered_year KMs_Driven stdx1x3 stdx2x3 / vif influence;
output out=carout5a predicted=yhat5a residual=e5a student=tres5a h=hii5a cookd=cookdi5a
dffits=diffitsi5a;
proc print;
var logtenY mileage registered_year KMs_Driven stdx1x3 stdx2x3 cookdi5a;
run;


/* Compute Pearson correlation coefficients */
proc corr data=car2int;
  var logtenY mileage registered_year KMs_Driven stdx1x2 stdx1x3 stdx2x3;
run;

/* Compute Pearson correlation coefficients */
proc corr data=car2int;
  var logtenY mileage registered_year KMs_Driven stdx1x3 stdx2x3;
run;


proc reg data=WORK.IMPORT;
  model Resale_Price_in_Dollars = mileage registered_year KMs_Driven
        / selection = adjrsq cp aic sbc start=1 stop=1 best=1;
