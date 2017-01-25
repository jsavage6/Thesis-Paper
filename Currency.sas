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
proc sort data=f1;by Date;

*add back in all the previous information so I can compare it to d1;
data f2;
merge d1 f1;by Date;
if firstday =. then firstday = 0;
proc print data=f2 (obs=20);run;

*experimenting with end of week instead of end of month, EXPERIMENTING;
proc sort data=d1;by year weekday;
proc means data=d1 noprint;by year weekday;var Date;
output out=g1 min=Date;
proc print data=g1 (obs=20);run;

*making the first day binary as we did before;
data g1;
set g1;
drop _TYPE_ _FREQ_;
firstday = 1;
proc print data=g1 (obs=20);run;

*Not sure what this does really;
proc sort data=g1;by Date;
proc sort data=g1;by Date;

*add back in all the previous information so I can compare it to d1;
data g2;
merge d1 g1;by Date;
if firstday =. then firstday = 0;
proc print data=g2 (obs=20);run;
