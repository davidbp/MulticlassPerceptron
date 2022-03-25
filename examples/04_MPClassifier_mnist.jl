
using Statistics

# We use flux only to get the MNIST
using Flux, Flux.Data.MNIST
using CategoricalArrays

# Load MulticlassPerceptron
#push!(LOAD_PATH, "../src/") 
using MulticlassPerceptron
using MLJBase

println("\nMNIST Dataset, MulticlassPerceptronClassifier")


function load_MNIST( ;array_eltype::DataType=Float32, verbose::Bool=true)

    if verbose
        time_init = time()
        println("MNIST Dataset Loading...")
    end
    train_imgs = MNIST.images(:train)                             # size(train_imgs) -> (60000,)
    test_imgs  = MNIST.images(:test)                              # size(test_imgs)  -> (10000,)
    train_x    = array_eltype.(hcat(reshape.(train_imgs, :)...))  # size(train_x)    -> (784, 60000)
    test_x     = array_eltype.(hcat(reshape.(test_imgs, :)...))   # size(test_x)     -> (784, 60000)

    ## Prepare data
    train_y = MNIST.labels(:train) .+ 1;
    test_y  = MNIST.labels(:test)  .+ 1;

    ## Encode targets as CategoricalArray objects
    train_y = CategoricalArray(train_y)
    test_y  = CategoricalArray(test_y)

    if verbose
        time_taken = round(time()-time_init; digits=3)
        println("MNIST Dataset Loaded, it took $time_taken seconds")
    end
    return train_x, train_y, test_x, test_y
end

println("\nLoading data")
train_x, train_y, test_x, test_y = load_MNIST( ;array_eltype=Float32, verbose=true)
train_x = train_x' # size(train_x)    -> (60000, 784)
test_x = test_x'   # size(train_x)    -> (60000, 784)

## Define model and train it
n_features = size(train_x, 1);
n_classes  = length(unique(train_y));
perceptron = MulticlassPerceptronClassifier(n_epochs=50; f_average_weights=true)

println("\nTypes and shapes before calling fit(perceptron, 1, train_x, train_y)")
@show typeof(perceptron)
@show typeof(train_x)
@show typeof(train_y)
@show size(train_x)
@show size(train_y)
@show size(test_x)
@show size(test_y)
@show n_features
@show n_classes

## Train the model
println("\nStart Learning")
time_init = time()
fitresult, _ , _  = fit(perceptron, 1, train_x, train_y) #
time_taken = round(time()-time_init; digits=3)
println("")
@show typeof(fitresult)
println("\nLearning took $time_taken seconds\n")

## Make predictions
#y_hat_train = predict(perceptron, fitresult, train_x)
#y_hat_test  = predict(perceptron, fitresult, test_x);
y_hat_train = predict(fitresult, train_x)
y_hat_test  = predict(fitresult, test_x);

## Evaluate the model
println("Results:")
println("Train accuracy:", round(mean(y_hat_train .== train_y), digits=3) )
println("Test accuracy:",  round(mean(y_hat_test  .== test_y), digits=3) ) 
println("\n")
