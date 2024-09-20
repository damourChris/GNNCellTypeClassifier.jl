# the main function of the package
#  Should take a expression set of a mixture of cell expression data and a pretrained model and return a DataFrame with the predicted cell types
#  The model should be a GraphNeuralNetworks model
# The function should return a DataFrame with the predicted cell types
# The DataFrame should have the columns "cell_id" and "cell_type"
# The "cell_id" column should have the same order as the input expression set
# The "cell_type" column should have the predicted cell type for each cell
function cell_type_classifier(eset_to_classify::ExpressionSet, model)::DataFrame

    # Load the model
    model = load_model(model)

    # Load the reference graph
    reference_graph = load_reference_graph()

    # Load the expression set
    eset = load_expression_set(eset_to_classify)

    # Predict the cell types
    cell_types = predict_cell_types(eset, model, reference_graph)

    return cell_types
end

function predict_cell_types(eset, model, reference_graph)
    # Map the expression set to the reference graph
    g = map_expression_to_graph(eset, reference_graph)

    # Get the expression data
    x_data = expression_values(eset)

    # Predict the cell types
    ŷ = model(g, x_data)

    return ŷ
end