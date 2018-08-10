include("Flare_Prediction.jl");

start_time = DateTime(2013,2,16,1,00,00);
end_time = DateTime(2013,2,16,1,01,00);


N = 10;

X,Y = Load_data(start_time,end_time,N)
