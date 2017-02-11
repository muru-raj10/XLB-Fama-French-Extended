function B=Reg(year,FullData,r_ex) %year = 1999,...,2016
%we input the year from 1999 to 2016. Ignore the output for second half of
%the year of 2016 as the data is not complete.
B=zeros(2,8,2);
    ind=find((FullData(:,11)<=6) & (FullData(:,12)==year));
    SubData=FullData(ind,:);
    Y=r_ex(ind);
%this gives us the intercept and slope coefficient for the first half of
%the year for each of the 8 factors
    for i = 1:5
        X=[ones(length(ind),1) SubData(:,i)];
        B(:,i,1)=X\Y;
    end
    for i=7:9
        X=[ones(length(ind),1) SubData(:,i)];
        B(:,i-1,1)=X\Y;
    end 

    ind2=find((FullData(:,11)>=7) & (FullData(:,12)==year));

    SubData=FullData(ind2,:);
    Y=r_ex(ind2);
%this gives us the intercept and slope coefficient for the second half of
%the year for each of the 8 factors
    for i = 1:5
        X=[ones(length(ind2),1) SubData(:,i)];
        B(:,i,2)=X\Y;
    end
    for i=7:9
        X=[ones(length(ind2),1) SubData(:,i)];
        B(:,i-1,2)=X\Y;
    end
end




