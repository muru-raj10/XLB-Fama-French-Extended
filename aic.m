function mdlaic=aic(k,N,RMSE)

mdlaic= exp((2*k)/N)*((RMSE)^2);

end