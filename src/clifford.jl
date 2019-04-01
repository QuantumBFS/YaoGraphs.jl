using YaoBase, StaticArrays

const C = Vector{Matrix{ComplexF64}}(undef, 0)

push!(C,  Const.I2)
push!(C,  Const.X)
push!(C,  Const.Y)
push!(C,  Const.Z)

push!(C,  sqrt(im * Const.X))
push!(C,  sqrt(-im * Const.X))
push!(C,  Const.Z*sqrt(im * Const.X))
push!(C,  Const.Z*sqrt(-im * Const.X))

push!(C,  sqrt(im * Const.Y))
push!(C,  sqrt(-im * Const.Y))
push!(C,  Const.Z * C[9])
push!(C,  Const.Z * C[10])

push!(C,  sqrt(im * Const.Z))
push!(C,  sqrt(-im * Const.Z))
push!(C,  Const.X * sqrt(im * Const.Z))
push!(C,  Const.X * sqrt(-im * Const.Z))

push!(C,  sqrt(im * Const.Z) * sqrt(im * Const.X))
push!(C,  sqrt(im * Const.Z) * sqrt(-im * Const.X))
push!(C,  sqrt(-im * Const.Z) * sqrt(im * Const.X))
push!(C,  sqrt(-im * Const.Z) * sqrt(-im * Const.X))

push!(C,  sqrt(im * Const.Z) * sqrt(im * Const.Y))
push!(C,  sqrt(im * Const.Z) * sqrt(-im * Const.Y))
push!(C,  sqrt(-im * Const.Z) * sqrt(im * Const.Y))
push!(C,  sqrt(-im * Const.Z) * sqrt(-im * Const.Y))

function is_equal_clifford(x::AbstractMatrix{T1}, y::AbstractMatrix{T2}) where {T1, T2}
    k = findfirst(a->!isapprox(a, zero(a); atol=1e-5), x)
    phi = x[k] / y[k]
    for (a, b) in zip(x, y)
        if isapprox(abs(a), zero(T1); atol=1e-5) && isapprox(abs(b), zero(T1); atol=1e-5)
            continue
        else
            isapprox(phi, a / b; atol=1e-5) || return false
        end
    end
    return true
end

function find_output(x::Int, y::Int)
    out = findall(σ->is_equal_clifford(C[x] * C[y], σ), C)
    if length(out) < 1
        error("product is not in Clifford{1} group: $x * $y")
    elseif length(out) > 1
        error("product is not unique")
    else
        return out[]
    end
end

const MulTable = SMatrix{24, 24}([find_output(i, j) for i in 1:24, j in 1:24])
