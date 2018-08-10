include("LogisticRegression.jl")
using CSV,DataFrames

test()
X_data = CSV.read("C:/Users/Ratan Priya/Desktop/JAGS/Project/X.csv")
Y_data = CSV.read("C:/Users/Ratan Priya/Desktop/JAGS/Project/Y.csv")

X_train_data,X_test_data = split_data(X_data,0.7)
Y_train_data,Y_test_data = split_data(Y_data,0.7)

function split_data(data,ratio)
    total_length = size(data)[1]
    training_len = floor(total_length*ratio)
    training_len = convert(Int64,training_len)

    training_data = head(data,training_len)
    remaining_len = total_length-training_len
    test_data = tail(data,remaining_len)

    return training_data,test_data
end

params_dict = Dict("aplha"=> 0.01, "eps"=> 0.001, "max_iter"=> 100)
X_train_data = convert(DataFrame,X_train_data)
Y_train_data = convert(DataFrame,Y_train_data)
print(typeof(params_dict))
print(typeof(X_train_data))
print(typeof(Y_train_data))

model_params, J_values = logistic_regression_learn(X_train_data,Y_train_data,params_dict)
