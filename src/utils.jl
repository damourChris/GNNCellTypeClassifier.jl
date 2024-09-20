function visualize_tsne(out, targets)
    z = tsne(out, 2)
    return scatter(z[:, 1], z[:, 2]; color=Int.(targets[1:size(z, 1)]), leg=false)
end

# A function to find the vertice with more than one edeg
function get_vertices_with_more_than_one_edge(graph::MetaDiGraph)
    vertices = Set{Int}()
    record = Dict{Int,Int}()
    # Make a record of all ocurrence of each vertex in the graph
    for edge in edges(graph)
        (s, d) = src(edge), dst(edge)

        if haskey(record, s)
            record[s] += 1
        else
            record[s] = 1
        end
        if haskey(record, d)
            record[d] += 1
        else
            record[d] = 1
        end
    end

    # Find the vertices with more than one edge
    for (k, v) in record
        if v > 2
            push!(vertices, k)
        end
    end
    return vertices
end

function export_to_graphxml(graph::GNNHeteroGraph, filename::String)
    xdoc = XMLDocument()

    xroot = create_root(xdoc, "graphml")
    set_attribute(xroot, "xmlns", "http://graphml.graphdrawing.org/xmlns")

    xgraph = new_child(xroot, "graph")
    set_attribute(xgraph, "id", "G")
    set_attribute(xgraph, "edgedefault", "directed")

    # Add the nodes
    for (node_type, node_number) in graph.num_nodes
        for node_index in 1:node_number
            xnode = new_child(xgraph, "node")
            set_attribute(xnode, "id", string(node_index))
            set_attribute(xnode, "type", node_type)
        end
    end

    # Add the edges
    src_indices, dst_indices, _ = collect(values(graph.graph))[1]

    for (src, dst) in zip(src_indices, dst_indices)
        xedge = new_child(xgraph, "edge")
        set_attribute(xedge, "source", string(src))
        set_attribute(xedge, "target", string(dst))
    end

    return save_file(xdoc, filename)
end
