abstract type AbstractNode end

struct Nil <: AbstractNode
end

mutable struct Node{T <: AbstractNode} <: AbstractNode
    left::T
    right::T
end

Node() = Node(Nil(), Nil())

function grow(node::Node)
    root = Node()
end

using YaoBase.Const

H * S ≈ sqrt(im * Z)

exp(-im * π/4 * Matrix(X + Z))


H ≈ Z * sqrt(im * Y)
S ≈ sqrt(Z)




H * S * H

broadcast(sqrt(-im * X)) do x
    x.re < eps(Float64) ? Complex(0, x.im) :
    x.im < eps(Float64) ? Complex(x.re, 0) :
    x
end



exp(Matrix(I2))
A = im * sqrt(-im * Y)

A[2].re < eps(Float64)

A[2]

H * S

exp(π/4 * X)
