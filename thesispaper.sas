options ls=256 ps=30000 nocenter;

*this is printing the data, taking away the clutter in the data and organizing for date/time;
proc print data=d1 (obs=20);run;
data d1;
set d1;
if Date =. then delete;
weekday = weekday(Date);
day = day(Date);
month = month(Date);
year = year(Date);
proc print data=d1 (obs=20);run;

*this is more of organizing the data by only keeping the first day of every month;
proc sort data=d1;by year month;
proc means data=d1 noprint;by year month;var Date;
output out=d2 min=Date;
proc print data=d2 (obs=20);run;

*this is dropping the extra columns and creating a first day column and making it binary;
data d2;
set d2;
drop _TYPE_ _FREQ_;
firstday = 1;
proc print data=d2 (obs=20);run;

*Not sure what this does really;
proc sort data=d2;by Date;
proc sort data=d1;by Date;

*adds in weekday day month and currency pair along with firstday;
data d3;
merge d1 d2;by Date;
if firstday =. then firstday = 0;
proc print data=d3 (obs=20);run;

*I don't know what this is doing;
proc sort data=d3;by Date;
proc print data=d3 (obs=20);run;

*this is setting up the lags to calculate abnormal returns;
data d4;
set d3;
lag1USDJPY = lag1(Price_USDJPY);
lag1EURUSD = lag1(Price_EURUSD);
lag1GBPJPY = lag1(Price_GBPJPY);
USDJPYreturn = (Price_USDJPY - lag1USDJPY)/lag1USDJPY;
EURUSDreturn = (Price_EURUSD - lag1EURUSD)/lag1EURUSD;
GBPJPYreturn = (Price_GBPJPY - lag1GBPJPY)/lag1GBPJPY;
drop lag1USDJPY lag1EURUSD lag1GBPJPY;
if USDJPYreturn =. then delete;
proc print data=d4 (obs=20);run;

*this is saving the data to my flash drive;
proc export data=d4 outfile = '\\Client\E$\end of month abnormal returns.csv';run;

*this is testing everything to see if I am right;
proc ttest data=d4;class firstday;var USDJPYreturn EURUSDreturn GBPJPYreturn;run;

*Here I am making a new dataset in order to make multiple days instead of first day of month, still working on that part;
proc means data=d1 noprint;by year month;var Date;
output out=f1 min=Date;
proc print data=f1 (obs=20);run;

*making the first day binary as we did before;
data f1;
set f1;
drop _TYPE_ _FREQ_;
firstday = 1;
proc print data=f1 (obs=20);run;

*Not sure what this does really;
proc sort data=f1;by Date;
proc sort data=d1;by Date;

*add back in all the previous information so I can compare it to d1;
data f2;
merge d1 f1;by Date;
if firstday =. then firstday = 0;
proc print data=f2 (obs=20);run;


data f3;
set f2;
secondday = lag1(firstday);
thirdday = lag2(firstday);
proc print data=f3 (obs=20);run;

proc sort data=f3;by descending Date;
proc print data=f3 (obs=20);run;
data f4;
set f3;
lastday = lag1(firstday);
if secondday =. then secondday = 0;
if thirdday =. then thirdday = 0;
if lastday =. then lastday=0;
turnofmonth = lastday+firstday+secondday+thirdday;
proc sort data=f4;by Date;
proc print data=f4 (obs=50);run;

*you just took out the following code here and might need to add it back in if turnofmonth = 0 then delete;
data f5;
set f4;
drop secondday thirdday lastday firstday;
proc print data=f5 (obs=50);run;

proc sort data=f5;by Date;
proc print data=f5 (obs=20);run;

data f6;
set f5;
lag1USDJPY = lag1(Price_USDJPY);
lag1EURUSD = lag1(Price_EURUSD);
lag1GBPJPY = lag1(Price_GBPJPY);
USDJPYreturn = (Price_USDJPY - lag1USDJPY)/lag1USDJPY;
EURUSDreturn = (Price_EURUSD - lag1EURUSD)/lag1EURUSD;
GBPJPYreturn = (Price_GBPJPY - lag1GBPJPY)/lag1GBPJPY;
drop lag1USDJPY lag1EURUSD lag1GBPJPY;
if USDJPYreturn =. then delete;
proc print data=f6 (obs=50);run;

proc ttest data=f6;class turnofmonth;var USDJPYreturn EURUSDreturn GBPJPYreturn;run;



/*turn of the week*/

data e1;
set f4;
if weekday = 2 then monday = 1;else monday = 0;
if weekday = 6 then friday = 1;else friday = 0;
drop turnofmonth lastday firstday secondday thirdday;
weekend = monday + friday;
proc print data=e1 (obs=50);run;

data e2;
set e1;
proc print data=e2 (obs=50);run;

proc sort data=e2;by Date;
proc print data=e2 (obs=50);run;

data e3;
set e2;
lag1USDJPY = lag1(Price_USDJPY);
lag1EURUSD = lag1(Price_EURUSD);
lag1GBPJPY = lag1(Price_GBPJPY);
USDJPYreturn = (Price_USDJPY - lag1USDJPY)/lag1USDJPY;
EURUSDreturn = (Price_EURUSD - lag1EURUSD)/lag1EURUSD;
GBPJPYreturn = (Price_GBPJPY - lag1GBPJPY)/lag1GBPJPY;
drop lag1USDJPY lag1EURUSD lag1GBPJPY;
if USDJPYreturn =. then delete;
proc print data=e3 (obs=50);run;

proc ttest data=e3;class friday;var USDJPYreturn EURUSDreturn GBPJPYreturn;run;
proc ttest data=e3;class monday;var USDJPYreturn EURUSDreturn GBPJPYreturn;run;

*setting the christmas vacation days equal to 1 and all else equal to 0;
data c1;
set d3;
drop firstday;
if month = 12 and day = 25 then christmas = 1;else christmas = 0;
if month = 12 and day = 24 then chreve = 1; else chreve = 0;
if month = 12 and day = 26 then ch26 = 1; else ch26 = 0;
if month = 12 and day = 27 then ch27 = 1; else ch27 = 0;
if month = 12 and day = 28 then ch28 = 1; else ch28 = 0;
if month = 12 and day = 29 then ch29 = 1; else ch29 = 0;
if month = 12 and day = 30 then ch30 = 1; else ch30 = 0;
if month = 12 and day = 31 then ch31 = 1; else ch31 = 0;
proc print data=c1 (obs=20);run;

data c2;
set c1;
dec25to31 = christmas + chreve + ch26 + ch27 + ch28 + ch29 + ch30 + ch31;
proc print data=c2 (obs=50); run;

proc sort data=c2;by Date;
proc print data=c2 (obs=50);run;


data c3;
set c2;
lag1USDJPY = lag1(Price_USDJPY);
lag1EURUSD = lag1(Price_EURUSD);
lag1GBPJPY = lag1(Price_GBPJPY);
USDJPYreturn = (Price_USDJPY - lag1USDJPY)/lag1USDJPY;
EURUSDreturn = (Price_EURUSD - lag1EURUSD)/lag1EURUSD;
GBPJPYreturn = (Price_GBPJPY - lag1GBPJPY)/lag1GBPJPY;
drop lag1USDJPY lag1EURUSD lag1GBPJPY;
if USDJPYreturn =. then delete;
proc print data=c3 (obs=50);run;

proc ttest data=c3;class dec25to31;var USDJPYreturn EURUSDreturn GBPJPYreturn;run;

*MLK Day;
data m1;
set d3;
drop firstday;
if month = 1 and weekday = 2 and day > 14 and day < 22 then mlkday = 1; else mlkday = 0;
proc print data = m1 (obs=730);run;

proc sort data=m1;by Date;
proc print data=m1 (obs=50);run;

data m2;
set m1;
lag1USDJPY = lag1(Price_USDJPY);
lag1EURUSD = lag1(Price_EURUSD);
lag1GBPJPY = lag1(Price_GBPJPY);
USDJPYreturn = (Price_USDJPY - lag1USDJPY)/lag1USDJPY;
EURUSDreturn = (Price_EURUSD - lag1EURUSD)/lag1EURUSD;
GBPJPYreturn = (Price_GBPJPY - lag1GBPJPY)/lag1GBPJPY;
drop lag1USDJPY lag1EURUSD lag1GBPJPY;
if USDJPYreturn =. then delete;
proc print data=m1 (obs=50);run;

proc ttest data=m2;class mlkday;var USDJPYreturn EURUSDreturn GBPJPYreturn;run;

*George Washington Day;
data w1;
set d3;
drop firstday;
if month = 2 and weekday = 2 and day > 14 and day < 22 then gwday = 1; else gwday = 0;
proc print data = w1 (obs=50);run;

proc sort data=w1;by Date;
proc print data=w1 (obs=50);run;

data w2;
set w1;
lag1USDJPY = lag1(Price_USDJPY);
lag1EURUSD = lag1(Price_EURUSD);
lag1GBPJPY = lag1(Price_GBPJPY);
USDJPYreturn = (Price_USDJPY - lag1USDJPY)/lag1USDJPY;
EURUSDreturn = (Price_EURUSD - lag1EURUSD)/lag1EURUSD;
GBPJPYreturn = (Price_GBPJPY - lag1GBPJPY)/lag1GBPJPY;
drop lag1USDJPY lag1EURUSD lag1GBPJPY;
if USDJPYreturn =. then delete;
proc print data=w2 (obs=50);run;

proc ttest data=w2;class gwday;var USDJPYreturn EURUSDreturn GBPJPYreturn;run;

*memorial day;
data md1;
set d3;
drop firstday;
if month = 5 and weekday = 2 and day > 24 then memday = 1; else memday = 0;
proc print data=md1 (obs=150);run;

proc sort data=md1; by date;
proc print data=md1 (obs=150);run;

data md2;
set md1;
lag1USDJPY = lag1(Price_USDJPY);
lag1EURUSD = lag1(Price_EURUSD);
lag1GBPJPY = lag1(Price_GBPJPY);
USDJPYreturn = (Price_USDJPY - lag1USDJPY)/lag1USDJPY;
EURUSDreturn = (Price_EURUSD - lag1EURUSD)/lag1EURUSD;
GBPJPYreturn = (Price_GBPJPY - lag1GBPJPY)/lag1GBPJPY;
drop lag1USDJPY lag1EURUSD lag1GBPJPY;
if USDJPYreturn =. then delete;
proc print data=md2 (obs=50);run;

proc ttest data=md2;class memday;var USDJPYreturn EURUSDreturn GBPJPYreturn;run;
