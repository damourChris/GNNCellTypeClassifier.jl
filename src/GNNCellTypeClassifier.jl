module GNNCellTypeClassifier

include("setup_env.jl")

using Flux
using Flux: onecold, onehotbatch, logitcrossentropy, jacobian
using GraphNeuralNetworks
using LightXML
using MLUtils
using JLD2
using Random
using Plots
using Statistics
using TSne

using ExpressionData
using OntologyTrees
using GNNCellTypeReferenceGraph

include("./conversion.jl")
include("./utils.jl")

include("cell_gnn.jl")
include("model.jl")
include("main.jl")

end
