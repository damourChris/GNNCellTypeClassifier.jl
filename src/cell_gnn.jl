# The main struct of the pacakge, 
#  Hold reference to a reference graph onto which he expression should be mapped to 
#  Can be empty at first and then filled with a given set of eset. 
#  The reference graph should be a GraphNeuralNetworks graph generated from the GNNCellTypeReferenceGraph package
#  It also hold onto the neural layers
struct CellGNN
    reference_graph::Graph
    layers::Chain
end

Flux.@layer :expand CellGNN

function CellGNN(hidden_channels; drop_rate=0.5)
    layers = (hidden1=HeteroGraphConv((:gene, :to, :cell) => SAGEConv(1 => hidden_channels,
                                                                      tanh; bias=false),
                                      (:cell, :to, :cell) => SAGEConv(1 => hidden_channels,
                                                                      tanh; bias=false)),
              hidden2=HeteroGraphConv((:cell, :to, :cell) => SAGEConv(hidden_channels => hidden_channels,
                                                                      tanh; bias=false)),
              output=Dense(hidden_channels, 1, relu; bias=false))
    return CellGNN(layers)
end

function (model::CellGNN)(g::GNNHeteroGraph, x_data)
    l = model.layers
    x = x_data

    x = l.hidden1(g, x)
    x = l.hidden2(g, x)
    x = l.output(x)

    return x
end
