using YaoBase, YaoArrayRegister, YaoBlocks, LightGraphs
using YaoBase: @interface
export GraphReg, nqubits, nactive, addbits!, add_edge!

struct GraphReg{B, T, Graph <: AbstractGraph} <: AbstractRegister{B, T}
    graphs::NTuple{B, Graph}

    function GraphReg(::Type{T}, graphs::NTuple{B, G}) where {B, T, G <: AbstractGraph}
        # check if each graph has the same number of vertices
        n = first(graphs)
        for k in 2:B
            n == nv(graphs[k]) || error("expect all input graph has the same number of vertices, got $(nv(graphs[k]))")
        end
        new{B, T, G}(graphs)
    end
end

"""
    GraphReg([T=ComplexF64], graphs...)

Create a `GraphReg` with a set of graphs. Graphs should be created as a concrete
type of [`AbstractGraph`](@ref) in [LightGraphs.jl](https://github.com/JuliaGraphs/LightGraphs.jl).
"""
GraphReg(graphs::NTuple{B, G}) where {B, G} = GraphReg(ComplexF64, graphs)

GraphReg(::Type{T}, graphs::AbstractGraph...) where T = GraphReg(T, graphs)
GraphReg(graphs::AbstractGraph...) = GraphReg(ComplexF64, graphs)

# generate a random graph state
"""
    GraphReg{B}([T=ComplexF64], nv[, ne=0])
    GraphReg([T=ComplexF64], nv[, ne=0])

Create a `GraphReg` of random graphs with batch size `B` and number of vertices `nv`
number of edges `ne`.
"""
GraphReg(::Type{T}, nv::Integer, ne::Integer=0) where T = GraphReg{1}(T, nv, ne)
GraphReg(nv::Integer, ne::Integer=0) = GraphReg{1}(nv, ne)

GraphReg{B}(::Type{T}, nv::Integer, ne::Integer=0) where {T, B} = GraphReg(ntuple(k->SimpleGraph(nv, ne), B))
GraphReg{B}(nv::Integer, ne::Integer=0) where B = GraphReg{B}(ComplexF64, nv, ne)


YaoBase.nqubits(r::GraphReg) = nv(r.graphs[1])
YaoBase.nactive(r::GraphReg) = nqubits(r)

function YaoBase.addbits!(r::GraphReg, n::Int)
    for _ in 1:n
        foreach(add_vertex!, r.graphs)
    end
    return r
end

"""
    czcircuit(n, graph)

Return the Control-Z circuit to construct graph state from ``|+⟩^V``
"""
@interface function czcircuit(n, graph::AbstractGraph)
    circuit = chain(n)
    for E in edges(graph)
        # CZ
        push!(circuit, control(E.dst, E.src=>Z))
    end
    return circuit
end

# convert to normal array state
function YaoArrayRegister.ArrayReg(r::GraphReg{1, T}) where T
    # CZ * H |0>
    n = nqubits(r)
    out = zero_state(T, n)
    # H |0> => |+>
    out |> repeat(n, H)
    # CZ |+> => G
    out |> czcircuit(n, r.graphs[1])
    return out
end

function YaoArrayRegister.ArrayReg(r::GraphReg{B, T}) where {B, T}
    n = nqubits(r)
    out = zero_state(T, n; nbatch=B)
    out |> repeat(n, H)

    for k in 1:B
        viewbatch(out, k) |> czcircuit(n, r.graphs[k])
    end
    return out
end

"""
    add_edge!(regsiter, x, y)

Add edge to a `GraphReg` with given vertices `x` and `y`.

!!! note

    For register with batch size > 1, this edge will be added to all the graphs
    stored in the register.
"""
LightGraphs.add_edge!(r::GraphReg{1}, x, y) = add_edge!(r.graphs[1], x, y)

function LightGraphs.add_edge!(r::GraphReg, x, y)
    for each in r.graphs
        add_edge!(each, x, y)
    end
    return r
end
