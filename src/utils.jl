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
