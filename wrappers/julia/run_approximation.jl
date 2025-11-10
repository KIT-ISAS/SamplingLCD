# Pkg.activate("C:/Users/rabCrypt/Documents/BA25_Preus/wrappers/julia/LCDApproximationJulia")  # optional if not already active
# Pkg.develop(path="C:/Users/rabCrypt/Documents/BA25_Preus/wrappers/julia/LCDApproximationJulia")  # only once
using LCDApproximationJulia
using Random
using Distributions

function generate_ellipse_points(N, a, b, center=(0.0, 0.0))
    cx, cy = center
    points = zeros(N, 2)

    for i in 1:N
        r = sqrt(rand())
        theta = rand() * 2π
        x = cx + a * r * cos(theta)
        y = cy + b * r * sin(theta)
        points[i, :] = [x, y]
    end

    return points  # Nx2 matrix (each row is a point)
end

function weightX(x::Matrix{Float64}, L::Int64, N::Int64)::Vector{Float64}
    res = zeros(L)
    for i in 1:L
        sed = sum(x[i, 1:N] .^ 2)
        res[i] = exp(0.5 * sed)
    end
    return res
end

function weightXDeriv(x::Matrix{Float64}, L::Int64, N::Int64)::Matrix{Float64}
    grad = zeros(L, N)
    for i in 1:L
        sed = sum(x[i, 1:N] .^ 2)
        exp_sed = exp(0.5 * sed)
        for k in 1:N
            grad[i, k] = x[i, k] * exp_sed
        end
    end
    return grad
end

println("Starting approximation...")

N = 2
L = 5
M = 300
bMax = 100

y = rand(Normal(0, 1), M, N)
covDiag = ones(N)

result, info = LCDApproximationJulia.dirac_short_double_approximate(y, L)
if result !== nothing
    println("Approximation result dirac to dirac: \n", result)
    println("Approximation info dirac to dirac: \n", info)
else
    println("Approximation failed!")
    println("Dirac-To-Dirac Approximation info dirac to dirac: \n", info)
end

resultDyn, infoDyn = LCDApproximationJulia.dirac_dynamic_weight_double_approximate(y, L, weightX, weightXDeriv)
if resultDyn !== nothing
    println("Approximation result dirac to dirac dynamic weight: \n", resultDyn)
    println("Approximation info dirac to dirac dynamic weight: \n", infoDyn)
else
    println("Approximation failed!")
    println("Dirac-To-Dirac Dynamic-Weight Approximation info dirac to dirac dynamic weight: \n", infoDyn)
end

resultGM, infoGM = LCDApproximationJulia.gm_short_double_approximate(covDiag, L)
if resultGM !== nothing
    println("Approximation result GM: \n", resultGM)
    println("Approximation info GM: \n", infoGM)
else
    println("Guassian-To-Dirac Approximation failed!")
    println("Approximation info GM: \n", infoGM)
end