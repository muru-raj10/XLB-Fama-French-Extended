function mdl=Regres(FullData,r_ex,M) 
%M is a row vector indicating the columns to take for the regression
%eg M= (1 1 0 0 0 0 1 1) takes the first and last 2 factors
ParaData = horzcat(FullData(:,1:5),FullData(:,7:9));
for k = 8 : -1 : 1 %k is a value from 1 to 8 to delete the column
    if M(k) == 0
    ParaData(:,k)=[];
    end
end
mdl=fitlm(ParaData,r_ex);
end

%the first row gives us the 2 factor model
%mdl2f=Regres(FullData,r_ex,M(1,:))

%the following gives us the 3 factor models
%mdl3f1=Regres(FullData,r_ex,M(2,:))
%mdl3f2=Regres(FullData,r_ex,M(3,:))
%mdl3f3=Regres(FullData,r_ex,M(4,:))
%mdl3f4=Regres(FullData,r_ex,M(5,:))
%mdl3f5=Regres(FullData,r_ex,M(6,:))
%mdl3f6=Regres(FullData,r_ex,M(7,:))

%the following gives us all the 4 factor models
%mdl4f1=Regres(FullData,r_ex,M(8,:))
% .....
%mdl4f15=Regres(FullData,r_ex,M(22,:))

%... and so on for all 64 rows
% last row gives us the 8 factor model
