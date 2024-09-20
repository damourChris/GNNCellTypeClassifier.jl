
function create_model(nin, nh, nout; dropout=0.5)
    return GNNChain(HeteroGraphConv((:gene, :to, :cell) => GraphConv(nin => 1, relu),
                                    (:cell, :to, :cell) => GraphConv(nin => 1, relu)),
                    GlobalPool(mean),
                    Dropout(dropout),
                    Dense(nh, nout))
end

function prepare_data(gnns::Vector{GNNHeteroGraph})
    # Prepare the data for the model
    y = [Float32.(filter(g.ndata[:cell].proportion) do x
                      return !ismissing(x)
                  end) * 100 for g in gnns]

    y_1_flat = reduce(hcat, y)

    train_data, test_data = getobs(splitobs((gnns, y_1_flat); at=0.8, shuffle=true))

    train_loader = DataLoader(train_data; shuffle=true, collate=true)
    test_loader = DataLoader(test_data; shuffle=false, collate=true)

    return (train_loader, test_loader)
end