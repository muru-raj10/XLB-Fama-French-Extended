clear;
clc;
format compact

%read the dates and factors from each file
filename1 = 'F-F_ST_Reversal_Factor_daily.CSV';
SRev = xlsread(filename1,'A15:B23990');
SRevDateNum=datenum(num2str(SRev(:,1)),'yyyymmdd'); %find the date number
SRevDate=datestr(SRevDateNum,'dd/mm/yyyy');  %rewrite the date into dd/mm/yyyy format
SRev(:,2)=log(1+(SRev(:,2)/100));          %Take log(1+R)and put into a table format
S_Rev = table(SRevDateNum,SRevDate,SRev(:,2),'VariableNames',{'DateNum','Date','ST_Rev'});

filename2 = 'F-F_Momentum_Factor_daily.CSV';
Momf = xlsread(filename2,'A15:B23760');
MomNum=datenum(num2str(Momf(:,1)),'yyyymmdd');
MomDate=datestr(MomNum,'dd/mm/yyyy');
Momf(:,2)=log(1+(Momf(:,2)/100)); 
Mom = table(MomNum,MomDate,Momf(:,2),'VariableNames',{'DateNum','Date','Mom'});

filename3 = 'F-F_LT_Reversal_Factor_daily.CSV';
LRev = xlsread(filename3,'A15:B22760');
LRevDateNum=datenum(num2str(LRev(:,1)),'yyyymmdd');
LRevDate=datestr(LRevDateNum,'dd/mm/yyyy');
LRev(:,2)=log(1+(LRev(:,2)/100));
L_Rev = table(LRevDateNum,LRevDate,LRev(:,2),'VariableNames',{'DateNum','Date','LT_Rev'});

filename4 = 'F-F_Research_Data_5_Factors_2x3_daily.CSV';
FF5 = xlsread(filename4,'A5:G13431');
FF5Num=datenum(num2str(FF5(:,1)),'yyyymmdd');
FF5Date=datestr(FF5Num,'dd/mm/yyyy');
FF5(:,2)=log(1+(FF5(:,2)/100));
Fama5 = table(FF5Num,FF5Date,FF5(:,2),FF5(:,3),FF5(:,4),FF5(:,5),FF5(:,6),FF5(:,7), ...
    'VariableNames',{'DateNum','Date','MktRiskPrem','SMB','HML','RMW','CMA','Rf'});

filename5 = 'XLB-US-Equity.csv';   %in the excel file, the date format was modified to be readable
[XlbDate, Xlb] = textread(filename5, '%s %f','delimiter', ',', 'headerlines', 1);
XlbDateNum=datenum(XlbDate,'dd/mm/yyyy');
XlbDate=datestr(XlbDateNum,'dd/mm/yyyy');
Xlbl=log(Xlb);
dXlbl=diff(Xlbl);
XLB = table(XlbDateNum(2:end,:),XlbDate(2:end,:),dXlbl,'VariableNames',{'DateNum','Date','XLB'});

%sort out the data to the respective dates
Data8F=innerjoin(innerjoin(innerjoin(innerjoin(Fama5,Mom),S_Rev),L_Rev),XLB);

r_ex = Data8F.XLB-Data8F.Rf; %excess returns, column vector

%From 22/12/1998 to 31/10/2016, we shall take sample periods starting from
%Jan 1999 till jun 2016, giving us a total of 33 half years.

[MthNbr]=month(Data8F.DateNum);  %add in the year and month number into our table
[Year]=year(Data8F.DateNum);
MthYrTbl=table(MthNbr, Year,'VariableNames', {'MonthNbr', 'Year'});
Data8F=[Data8F MthYrTbl];

FullData=table2array(Data8F(:,3:14)); 
%Takes the 8 factors, the risk free rate, month and year number. Easier to
%work with array than a table

%Chow test
PredFac=cat(2,FullData(:,1:5),FullData(:,7:9));
PredFacTable=table(PredFac(:,1),PredFac(:,2),PredFac(:,3),PredFac(:,4),PredFac(:,5),...
    PredFac(:,6),PredFac(:,7),PredFac(:,8),r_ex, 'VariableNames',...
    {'MktRiskPrem','SMB','HML','RMW','CMA','Mom','ST_Rev','LT_Rev','r_ex'});


BP=[130 258 384 510 635 758 882 1010 1134 1262 1386 1514 1618 1766 1891 2017 2141 2268 ...
    2393 2521 2645 2773 2897 3025 3150 3277 3402 3527 3651 3779 3903 4031 4155 4283 4408];
stability1 = zeros(8,35);

for i = 1 : 8
    for j = 1 : 33
        stability1(i,j)= chowtest(PredFac(BP(j):BP(j+2),i),r_ex(BP(j):BP(j+2)),floor(size(PredFac(BP(j):BP(j+2),i),1)/2));
    end
end
stability = chowtest(PredFac,r_ex,BP);

    
Coeff=zeros(17,1);
%run the following functions for part 2
%B1999=Reg(1999,FullData,r_ex);
%B2000=Reg(2000,FullData,r_ex);
%B2001=Reg(2001,FullData,r_ex);
%...
%B2016=Reg(2016,FullData,r_ex);

%we extract the data for the 8 factors only
ParaData = horzcat(FullData(:,1:5),FullData(:,7:9)); 
mdl8f=fitlm(ParaData,r_ex); %8-factor model

%Do a binary matrix that is ordered in terms 
%of number of 1s in each row.
S = dec2bin((1:64).'); %returns string of binaries
N = S - '0';  % to make the binaries into values
N=N(:,2:7);
Sum=sum(N,2);
N= horzcat(Sum,N);
[values, order] = sort(N(:,1));
sortedN = N(order,:);
M=ones(64,8);
M(:,3:8)=sortedN(:,2:7); 
%M is a 64 x 8 matrix. We will input each row M(i,:) into the function
%Regres(FullData,r_ex,M(i,:)); 

%run the following functions for part 3

%the first row gives us the 2 factor model
mdl2f=Regres(FullData,r_ex,M(1,:));

%the following gives us the 3 factor models
mdl3f1=Regres(FullData,r_ex,M(2,:));
mdl3f2=Regres(FullData,r_ex,M(3,:));
mdl3f3=Regres(FullData,r_ex,M(4,:));
mdl3f4=Regres(FullData,r_ex,M(5,:));
mdl3f5=Regres(FullData,r_ex,M(6,:));
mdl3f6=Regres(FullData,r_ex,M(7,:));

%the following gives us all the 4 factor models
mdl4f1=Regres(FullData,r_ex,M(8,:));
mdl4f2=Regres(FullData,r_ex,M(9,:));
mdl4f3=Regres(FullData,r_ex,M(10,:));
mdl4f4=Regres(FullData,r_ex,M(11,:));
mdl4f5=Regres(FullData,r_ex,M(12,:));
mdl4f6=Regres(FullData,r_ex,M(13,:));
mdl4f7=Regres(FullData,r_ex,M(14,:));
mdl4f8=Regres(FullData,r_ex,M(15,:));
mdl4f9=Regres(FullData,r_ex,M(16,:));
mdl4f10=Regres(FullData,r_ex,M(17,:));
mdl4f11=Regres(FullData,r_ex,M(18,:));
mdl4f12=Regres(FullData,r_ex,M(19,:));
mdl4f13=Regres(FullData,r_ex,M(20,:));
mdl4f14=Regres(FullData,r_ex,M(21,:));
mdl4f15=Regres(FullData,r_ex,M(22,:));

mdl5f1=Regres(FullData,r_ex,M(23,:));
mdl5f2=Regres(FullData,r_ex,M(24,:));
mdl5f3=Regres(FullData,r_ex,M(25,:));
mdl5f4=Regres(FullData,r_ex,M(26,:));
mdl5f5=Regres(FullData,r_ex,M(27,:));
mdl5f6=Regres(FullData,r_ex,M(28,:));
mdl5f7=Regres(FullData,r_ex,M(29,:));
mdl5f8=Regres(FullData,r_ex,M(30,:));
mdl5f9=Regres(FullData,r_ex,M(31,:));
mdl5f10=Regres(FullData,r_ex,M(32,:));
mdl5f11=Regres(FullData,r_ex,M(33,:));
mdl5f12=Regres(FullData,r_ex,M(34,:));
mdl5f13=Regres(FullData,r_ex,M(35,:));
mdl5f14=Regres(FullData,r_ex,M(36,:));
mdl5f15=Regres(FullData,r_ex,M(37,:));
mdl5f16=Regres(FullData,r_ex,M(38,:));
mdl5f17=Regres(FullData,r_ex,M(39,:));
mdl5f18=Regres(FullData,r_ex,M(40,:));
mdl5f19=Regres(FullData,r_ex,M(41,:));
mdl5f20=Regres(FullData,r_ex,M(42,:));

mdl6f1=Regres(FullData,r_ex,M(43,:));
mdl6f2=Regres(FullData,r_ex,M(44,:));
mdl6f3=Regres(FullData,r_ex,M(45,:));
mdl6f4=Regres(FullData,r_ex,M(46,:));
mdl6f5=Regres(FullData,r_ex,M(47,:));
mdl6f6=Regres(FullData,r_ex,M(48,:));
mdl6f7=Regres(FullData,r_ex,M(49,:));
mdl6f8=Regres(FullData,r_ex,M(50,:));
mdl6f9=Regres(FullData,r_ex,M(51,:));
mdl6f10=Regres(FullData,r_ex,M(52,:));
mdl6f11=Regres(FullData,r_ex,M(53,:));
mdl6f12=Regres(FullData,r_ex,M(54,:));
mdl6f13=Regres(FullData,r_ex,M(55,:));
mdl6f14=Regres(FullData,r_ex,M(56,:));
mdl6f15=Regres(FullData,r_ex,M(57,:));

mdl7f1=Regres(FullData,r_ex,M(58,:));
mdl7f2=Regres(FullData,r_ex,M(59,:));
mdl7f3=Regres(FullData,r_ex,M(60,:));
mdl7f4=Regres(FullData,r_ex,M(61,:));
mdl7f5=Regres(FullData,r_ex,M(62,:));
mdl7f6=Regres(FullData,r_ex,M(63,:));

mdl8f1=Regres(FullData,r_ex,M(64,:));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%to calculate the aic for each function
AIC=zeros(64,1);

AIC(1)=aic(3,4494,mdl2f.RMSE);

AIC(2)=aic(4,4494,mdl3f1.RMSE);
AIC(3)=aic(4,4494,mdl3f2.RMSE);
AIC(4)=aic(4,4494,mdl3f3.RMSE);
AIC(5)=aic(4,4494,mdl3f4.RMSE);
AIC(6)=aic(4,4494,mdl3f5.RMSE);
AIC(7)=aic(4,4494,mdl3f6.RMSE);

AIC(8)=aic(5,4494,mdl4f1.RMSE);
AIC(9)=aic(5,4494,mdl4f2.RMSE);
AIC(10)=aic(5,4494,mdl4f3.RMSE);
AIC(11)=aic(5,4494,mdl4f4.RMSE);
AIC(12)=aic(5,4494,mdl4f5.RMSE);
AIC(13)=aic(5,4494,mdl4f6.RMSE);
AIC(14)=aic(5,4494,mdl4f7.RMSE);
AIC(15)=aic(5,4494,mdl4f8.RMSE);
AIC(16)=aic(5,4494,mdl4f9.RMSE);
AIC(17)=aic(5,4494,mdl4f10.RMSE);
AIC(18)=aic(5,4494,mdl4f11.RMSE);
AIC(19)=aic(5,4494,mdl4f12.RMSE);
AIC(20)=aic(5,4494,mdl4f13.RMSE);
AIC(21)=aic(5,4494,mdl4f14.RMSE);
AIC(22)=aic(5,4494,mdl4f15.RMSE);

AIC(23)=aic(6,4494,mdl5f1.RMSE);
AIC(24)=aic(6,4494,mdl5f2.RMSE);
AIC(25)=aic(6,4494,mdl5f3.RMSE);
AIC(26)=aic(6,4494,mdl5f4.RMSE);
AIC(27)=aic(6,4494,mdl5f5.RMSE);
AIC(28)=aic(6,4494,mdl5f6.RMSE);
AIC(29)=aic(6,4494,mdl5f7.RMSE);
AIC(30)=aic(6,4494,mdl5f8.RMSE);
AIC(31)=aic(6,4494,mdl5f9.RMSE);
AIC(32)=aic(6,4494,mdl5f10.RMSE);
AIC(33)=aic(6,4494,mdl5f11.RMSE);
AIC(34)=aic(6,4494,mdl5f12.RMSE);
AIC(35)=aic(6,4494,mdl5f13.RMSE);
AIC(36)=aic(6,4494,mdl5f14.RMSE);
AIC(37)=aic(6,4494,mdl5f15.RMSE);
AIC(38)=aic(6,4494,mdl5f16.RMSE);
AIC(39)=aic(6,4494,mdl5f17.RMSE);
AIC(40)=aic(6,4494,mdl5f18.RMSE);
AIC(41)=aic(6,4494,mdl5f19.RMSE);
AIC(42)=aic(6,4494,mdl5f20.RMSE);

AIC(43)=aic(7,4494,mdl6f1.RMSE);
AIC(44)=aic(7,4494,mdl6f2.RMSE);
AIC(45)=aic(7,4494,mdl6f3.RMSE);
AIC(46)=aic(7,4494,mdl6f4.RMSE);
AIC(47)=aic(7,4494,mdl6f5.RMSE);
AIC(48)=aic(7,4494,mdl6f6.RMSE);
AIC(49)=aic(7,4494,mdl6f7.RMSE);
AIC(50)=aic(7,4494,mdl6f8.RMSE);
AIC(51)=aic(7,4494,mdl6f9.RMSE);
AIC(52)=aic(7,4494,mdl6f10.RMSE);
AIC(53)=aic(7,4494,mdl6f11.RMSE);
AIC(54)=aic(7,4494,mdl6f12.RMSE);
AIC(55)=aic(7,4494,mdl6f13.RMSE);
AIC(56)=aic(7,4494,mdl6f14.RMSE);
AIC(57)=aic(7,4494,mdl6f15.RMSE);

AIC(58)=aic(8,4494,mdl7f1.RMSE);
AIC(59)=aic(8,4494,mdl7f2.RMSE);
AIC(60)=aic(8,4494,mdl7f3.RMSE);
AIC(61)=aic(8,4494,mdl7f4.RMSE);
AIC(62)=aic(8,4494,mdl7f5.RMSE);
AIC(63)=aic(8,4494,mdl7f6.RMSE);

AIC(64)=aic(9,4494,mdl8f1.RMSE);

indMinAIC=find(AIC==min(AIC));
M(indMinAIC,:)


adrs=zeros(64,1);

adrs(1)=(mdl2f.Rsquared.Adjusted);

adrs(2)=(mdl3f1.Rsquared.Adjusted);
adrs(3)=mdl3f2.Rsquared.Adjusted;
adrs(4)=mdl3f3.Rsquared.Adjusted;
adrs(5)=mdl3f4.Rsquared.Adjusted;
adrs(6)=mdl3f5.Rsquared.Adjusted;
adrs(7)=mdl3f6.Rsquared.Adjusted;

adrs(8)=mdl4f1.Rsquared.Adjusted;
adrs(9)=mdl4f2.Rsquared.Adjusted;
adrs(10)=mdl4f3.Rsquared.Adjusted;
adrs(11)=mdl4f4.Rsquared.Adjusted;
adrs(12)=mdl4f5.Rsquared.Adjusted;
adrs(13)=mdl4f6.Rsquared.Adjusted;
adrs(14)=mdl4f7.Rsquared.Adjusted;
adrs(15)=mdl4f8.Rsquared.Adjusted;
adrs(16)=mdl4f9.Rsquared.Adjusted;
adrs(17)=mdl4f10.Rsquared.Adjusted;
adrs(18)=mdl4f11.Rsquared.Adjusted;
adrs(19)=mdl4f12.Rsquared.Adjusted;
adrs(20)=mdl4f13.Rsquared.Adjusted;
adrs(21)=mdl4f14.Rsquared.Adjusted;
adrs(22)=mdl4f15.Rsquared.Adjusted;

adrs(23)=mdl5f1.Rsquared.Adjusted;
adrs(24)=mdl5f2.Rsquared.Adjusted;
adrs(25)=mdl5f3.Rsquared.Adjusted;
adrs(26)=mdl5f4.Rsquared.Adjusted;
adrs(27)=mdl5f5.Rsquared.Adjusted;
adrs(28)=mdl5f6.Rsquared.Adjusted;
adrs(29)=mdl5f7.Rsquared.Adjusted;
adrs(30)=mdl5f8.Rsquared.Adjusted;
adrs(31)=mdl5f9.Rsquared.Adjusted;
adrs(32)=mdl5f10.Rsquared.Adjusted;
adrs(33)=mdl5f11.Rsquared.Adjusted;
adrs(34)=mdl5f12.Rsquared.Adjusted;
adrs(35)=mdl5f13.Rsquared.Adjusted;
adrs(36)=mdl5f14.Rsquared.Adjusted;
adrs(37)=mdl5f15.Rsquared.Adjusted;
adrs(38)=mdl5f16.Rsquared.Adjusted;
adrs(39)=mdl5f17.Rsquared.Adjusted;
adrs(40)=mdl5f18.Rsquared.Adjusted;
adrs(41)=mdl5f19.Rsquared.Adjusted;
adrs(42)=mdl5f20.Rsquared.Adjusted;
adrs(43)=mdl6f1.Rsquared.Adjusted;
adrs(44)=mdl6f2.Rsquared.Adjusted;
adrs(45)=mdl6f3.Rsquared.Adjusted;
adrs(46)=mdl6f4.Rsquared.Adjusted;
adrs(47)=mdl6f5.Rsquared.Adjusted;
adrs(48)=mdl6f6.Rsquared.Adjusted;
adrs(49)=mdl6f7.Rsquared.Adjusted;
adrs(50)=mdl6f8.Rsquared.Adjusted;
adrs(51)=mdl6f9.Rsquared.Adjusted;
adrs(52)=mdl6f10.Rsquared.Adjusted;
adrs(53)=mdl6f11.Rsquared.Adjusted;
adrs(54)=mdl6f12.Rsquared.Adjusted;
adrs(55)=mdl6f13.Rsquared.Adjusted;
adrs(56)=mdl6f14.Rsquared.Adjusted;
adrs(57)=mdl6f15.Rsquared.Adjusted;

adrs(58)=mdl7f1.Rsquared.Adjusted;
adrs(59)=mdl7f2.Rsquared.Adjusted;
adrs(60)=mdl7f3.Rsquared.Adjusted;
adrs(61)=mdl7f4.Rsquared.Adjusted;
adrs(62)=mdl7f5.Rsquared.Adjusted;
adrs(63)=mdl7f6.Rsquared.Adjusted;

adrs(64)=mdl8f1.Rsquared.Adjusted;