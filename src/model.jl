struct CellGNN
    chain::Chain
end

Flux.@layer :expand CellGNN

function CellGNN(hidden_channels)
    hidden = HeteroGraphConv((:gene, :to, :term) => GraphConv(1 => hidden_channels))
    chain = Chain(;
                  hidden=hidden,
                  dense=Dense(hidden_channels => 1, relu))
    return CellGNN(chain)
end

function (model::CellGNN)(g::GNNHeteroGraph)
    gene_data_raw = g.ndata[:gene].exprs
    term_data_raw = g.ndata[:term].proportion
    gene_data = Float32.(reshape(gene_data_raw, 1, :))
    term_data = Float32.(reshape(term_data_raw, 1, :))

    l = model.chain.layers
    x = (gene=gene_data, term=term_data)

    x = l.hidden(g, x)
    x = l.dense(x.term)

    return x
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

function eval_loss_accuracy(model, data_loader, device)
    loss = 0.0
    acc = 0.0
    ntot = 0
    for (g, y) in data_loader
        # g, y = device(MLUtils.batch(g)), device(y)
        n = length(y)

        ŷ = model(g)

        loss += Flux.crossentropy(ŷ, y) * n
        acc += mean((ŷ .> 0) .== y) * n
        ntot += n
    end
    return (loss=round(loss / ntot; digits=4),
            acc=round(acc * 100 / ntot; digits=2))
end