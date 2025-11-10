module LCDApproximationJulia

using Printf

const libdirac = Sys.iswindows() ? joinpath(@__DIR__, "..", "lib", "libLCDApproximationJuliaWrapper.dll") :
                 joinpath(@__DIR__, "..", "lib", "libLCDApproximationJuliaWrapper.so")

mutable struct LCDApproximationClassWrapper
    ptr::Ptr{Cvoid}
end

const _dirac_dirac_short_double = Ref{Union{Nothing,LCDApproximationClassWrapper}}(nothing)
const _dirac_dirac_dynamic_weight_double = Ref{Union{Nothing,LCDApproximationClassWrapper}}(nothing)
const _gm_dirac_short_double = Ref{Union{Nothing,LCDApproximationClassWrapper}}(nothing)

function _init_instance()
    _dirac_dirac_short_double[] = LCDApproximationClassWrapper(
        ccall((:create_instance_dirac_short_double, libdirac), Ptr{Cvoid}, ())
    )
    _dirac_dirac_dynamic_weight_double[] = LCDApproximationClassWrapper(
        ccall((:create_instance_dirac_dynamic_weight_double, libdirac), Ptr{Cvoid}, ())
    )
    _gm_dirac_short_double[] = LCDApproximationClassWrapper(
        ccall((:create_instance_gm_short_double, libdirac), Ptr{Cvoid}, ())
    )
    println("LCDApproximationJulia initialized.")
end

function _destroy_instances()
    if _dirac_dirac_short_double[] !== nothing
        ccall((:delete_instance_dirac_short_double, libdirac), Cvoid, (Ptr{Cvoid},), _dirac_dirac_short_double[].ptr)
        _dirac_dirac_short_double[] = nothing
    end
    if _dirac_dirac_dynamic_weight_double[] !== nothing
        ccall((:delete_instance_dirac_dynamic_weight_double, libdirac), Cvoid, (Ptr{Cvoid},), _dirac_dirac_dynamic_weight_double[].ptr)
        _dirac_dirac_dynamic_weight_double[] = nothing
    end
    if _gm_dirac_short_double[] !== nothing
        ccall((:delete_instance_gm_short_double, libdirac), Cvoid, (Ptr{Cvoid},), _gm_dirac_short_double[].ptr)
        _gm_dirac_short_double[] = nothing
    end
    println("LCDApproximationJulia destroyed.")
end

function __init__()
    _init_instance()
    atexit(_destroy_instances)
end

# Result Information
struct CppMinimizerResult
    initalStepSize::Cdouble
    stepTolerance::Cdouble
    lastXtolAbs::Cdouble
    lastXtolRel::Cdouble
    lastFtolAbs::Cdouble
    lastFtolRel::Cdouble
    lastGtol::Cdouble
    xtolAbs::Cdouble
    xtolRel::Cdouble
    ftolAbs::Cdouble
    ftolRel::Cdouble
    gtol::Cdouble
    iterations::Csize_t
    maxIterations::Csize_t
    elapsedTimeMicroseconds::Csize_t
end

function Base.show(io::IO, r::CppMinimizerResult)
    println(io, "GslminimizerResult:")
    @printf(io, "   initialStepSize: %14.6e\n", r.initalStepSize)
    @printf(io, "   stepTolerance:   %14.6e\n\n", r.stepTolerance)

    @printf(io, "   |x - x'|:               %14.6e > %.6e\n", r.lastXtolAbs, r.xtolAbs)
    @printf(io, "   |x - x'|/|x'|:          %14.6e > %.6e\n", r.lastXtolRel, r.xtolRel)
    @printf(io, "   |f(x) - f(x')|:         %14.6e > %.6e\n", r.lastFtolAbs, r.ftolAbs)
    @printf(io, "   |f(x) - f(x')|/|f(x')|: %14.6e < %.6e\n", r.lastFtolRel, r.ftolRel)
    @printf(io, "   |g(x)|:                 %14.6e > %.6e\n\n", r.lastGtol, r.gtol)

    @printf(io, "   iterations: %d of %d\n\n", r.iterations, r.maxIterations)

    if r.elapsedTimeMicroseconds < 1_000
        @printf(io, "   timeTaken: %.3f μs\n", r.elapsedTimeMicroseconds)
    elseif r.elapsedTimeMicroseconds < 1_000_000
        @printf(io, "   timeTaken: %.3f ms\n", r.elapsedTimeMicroseconds / 1_000)
    elseif r.elapsedTimeMicroseconds < 1_000_000_000
        @printf(io, "   timeTaken: %.3f s\n", r.elapsedTimeMicroseconds / 1_000_000)
    else # minutes and seconds
        minutes = div(r.elapsedTimeMicroseconds, 60_000_000)
        seconds = div(r.elapsedTimeMicroseconds - minutes * 60_000_000, 1_000_000)
        @printf(io, "   timeTaken: %d min %.3f s\n", minutes, seconds)
    end
end

# Options
mutable struct ApproximateOptions
    xtolAbs::Cdouble        # double
    xtolRel::Cdouble        # double
    ftolAbs::Cdouble        # double
    ftolRel::Cdouble        # double
    gtol::Cdouble           # double
    initialX::Cuchar        # bool (uchar)
    maxIterations::Csize_t  # size_t
    verbose::Cuchar         # bool (uchar)
end

function createOptions(
    xtolAbs::Union{Cdouble,Nothing}=nothing,
    xtolRel::Union{Cdouble,Nothing}=nothing,
    ftolAbs::Union{Cdouble,Nothing}=nothing,
    ftolRel::Union{Cdouble,Nothing}=nothing,
    gtol::Union{Cdouble,Nothing}=nothing,
    initialX::Union{Any,Nothing}=nothing,
    maxIterations::Union{Csize_t,Nothing}=nothing,
    verbose::Union{Cuchar,Nothing}=nothing
)::Ref{ApproximateOptions}

    opts = Ref(ccall((:defaultApproximateOptions, libdirac), ApproximateOptions, ()))

    xtolAbs !== nothing && (opts[].xtolAbs = xtolAbs)
    xtolRel !== nothing && (opts[].xtolRel = xtolRel)
    ftolAbs !== nothing && (opts[].ftolAbs = ftolAbs)
    ftolRel !== nothing && (opts[].ftolRel = ftolRel)
    gtol !== nothing && (opts[].gtol = gtol)
    initialX !== nothing && (opts[].initialX = true)
    maxIterations !== nothing && (opts[].maxIterations = maxIterations)
    verbose !== nothing && (opts[].verbose = verbose)

    return opts
end

function dirac_short_double_approximate(
    y::Matrix{Float64},
    L::Int;
    bMax::Int=100,
    initialX::Union{Matrix{Float64},Nothing}=nothing,
    wX::Union{Vector{Float64},Nothing}=nothing,
    wY::Union{Vector{Float64},Nothing}=nothing,
    xtolAbs::Union{Cdouble,Nothing}=nothing,
    xtolRel::Union{Cdouble,Nothing}=nothing,
    ftolAbs::Union{Cdouble,Nothing}=nothing,
    ftolRel::Union{Cdouble,Nothing}=nothing,
    gtol::Union{Cdouble,Nothing}=nothing,
    maxIterations::Union{Csize_t,Nothing}=nothing,
    verbose::Union{Cuchar,Nothing}=nothing
)::Tuple{Union{Matrix{Float64},Nothing},CppMinimizerResult}
    M, N = size(y)
    row_major_vec = collect(reshape(transpose(y), :))

    if wX !== nothing
        @assert length(wX) == L "Length of wX must be equal to L"
        @assert isapprox(sum(wX), 1.0, atol=1e-5) "Sum of wX must be 1"
        @assert all(wX .>= 0.0) "All elements of wX must be positive"
        cWx = pointer(wX)
    else
        cWx = C_NULL
    end

    if wY !== nothing
        @assert length(wY) == M "Length of wY must be equal to M"
        @assert isapprox(sum(wY), 1.0, atol=1e-5) "Sum of wY must be 1"
        @assert all(wY .>= 0.0) "All elements of wY must be positive"
        cWy = pointer(wY)
    else
        cWy = C_NULL
    end

    result = Ref(CppMinimizerResult(
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0, 0))

    if initialX !== nothing
        @assert size(initialX) == (L, N) "InitialX must be LxN matrix"
        x = collect(reshape(transpose(initialX), :))
    else
        x = Vector{Float64}(undef, L * N)
    end

    options = createOptions(xtolAbs, xtolRel, ftolAbs, ftolRel, gtol, initialX, maxIterations, verbose)

    success = ccall((:dirac_short_double_approximate, libdirac), Bool,
        (Ptr{Cvoid}, Ptr{Float64}, Csize_t, Csize_t, Csize_t, Csize_t,
            Ptr{Float64}, Ptr{Float64}, Ptr{Float64}, Ref{CppMinimizerResult}, Ref{ApproximateOptions}),
        _dirac_dirac_short_double[].ptr, row_major_vec, M, L, N, bMax,
        x, cWx, cWy, result, options)

    if success
        return permutedims(reshape(x, N, L)), result[]
    else
        return nothing, result[]
    end
end

const _wX_func = Ref{Union{Function,Nothing}}(nothing)
function wX_c(
    x_ptr::Ptr{Cdouble},
    res_ptr::Ptr{Cdouble},
    L::Csize_t,
    N::Csize_t
)::Cvoid
    l = Int(L)
    n = Int(N)
    x_raw = unsafe_wrap(Vector{Float64}, x_ptr, l * n)
    x_matrix = reshape(x_raw, (n, l))          # Reshape row-major as n×l
    x = permutedims(x_matrix)                  # Transpose to L×N for Julia

    result = _wX_func[](x, l, n)
    @assert length(result) == l
    unsafe_copyto!(res_ptr, pointer(result), l)
    return
end

const _wXD_func = Ref{Union{Function,Nothing}}(nothing)
function wXD_c(x_ptr::Ptr{Cdouble}, res_ptr::Ptr{Cdouble}, L::Csize_t, N::Csize_t)
    l = Int(L)
    n = Int(N)
    x_raw = unsafe_wrap(Vector{Float64}, x_ptr, l * n)
    x_matrix = reshape(x_raw, (n, l))          # n×l
    x = permutedims(x_matrix)                  # L×N

    result = _wXD_func[](x, l, n)
    @assert size(result) == (l, n)

    result_row_major = reshape(permutedims(result), :)  # Transpose for C row-major
    unsafe_copyto!(res_ptr, pointer(result_row_major), l * n)
    return
end

function dirac_dynamic_weight_double_approximate(
    y::Matrix{Float64},
    L::Int,
    wX::Function,
    wXD::Function;
    bMax::Int=100,
    initialX::Union{Matrix{Float64},Nothing}=nothing,
    xtolAbs::Union{Cdouble,Nothing}=nothing,
    xtolRel::Union{Cdouble,Nothing}=nothing,
    ftolAbs::Union{Cdouble,Nothing}=nothing,
    ftolRel::Union{Cdouble,Nothing}=nothing,
    gtol::Union{Cdouble,Nothing}=nothing,
    maxIterations::Union{Csize_t,Nothing}=nothing,
    verbose::Union{Cuchar,Nothing}=nothing
)::Tuple{Union{Matrix{Float64},Nothing},CppMinimizerResult}
    M, N = size(y)
    row_major_vec = collect(reshape(transpose(y), :))

    if initialX !== nothing
        @assert size(initialX) == (L, N) "InitialX must be LxN matrix"
        x = collect(reshape(transpose(initialX), :))
    else
        x = Vector{Float64}(undef, L * N)
    end

    _wX_func[] = wX
    _wXD_func[] = wXD

    wX_fPtr = @cfunction(wX_c, Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}, Csize_t, Csize_t))
    wXD_fPtr = @cfunction(wXD_c, Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}, Csize_t, Csize_t))

    result = Ref(CppMinimizerResult(
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0, 0))

    options = createOptions(xtolAbs, xtolRel, ftolAbs, ftolRel, gtol, initialX, maxIterations, verbose)

    success = ccall((:dirac_dynamic_weight_double_approximate, libdirac), Bool,
        (Ptr{Cvoid}, Ptr{Float64}, Int, Int, Int, Int, Ptr{Float64}, Ptr{Cvoid}, Ptr{Cvoid}, Ref{CppMinimizerResult}, Ref{ApproximateOptions}),
        _dirac_dirac_dynamic_weight_double[].ptr, row_major_vec, M, L, N, bMax, x, wX_fPtr, wXD_fPtr, result, options)

    if success
        return permutedims(reshape(x, N, L)), result[]
    else
        return nothing, result[]
    end
end

# L-dimensional approximation of Gaussian Mixture defined by diagonal covariance matrix
function gm_short_double_approximate(
    covDiag::Vector{Float64},
    L::Int;
    bMax::Int=100,
    initialX::Union{Matrix{Float64},Nothing}=nothing,
    wX::Union{Vector{Float64},Nothing}=nothing,
    xtolAbs::Union{Cdouble,Nothing}=nothing,
    xtolRel::Union{Cdouble,Nothing}=nothing,
    ftolAbs::Union{Cdouble,Nothing}=nothing,
    ftolRel::Union{Cdouble,Nothing}=nothing,
    gtol::Union{Cdouble,Nothing}=nothing,
    maxIterations::Union{Csize_t,Nothing}=nothing,
    verbose::Union{Cuchar,Nothing}=nothing
)::Tuple{Union{Matrix{Float64},Nothing},CppMinimizerResult}
    N = length(covDiag)

    if wX !== nothing
        @assert length(wX) == L "Length of wX must be equal to L"
        @assert isapprox(sum(wX), 1.0, atol=1e-5) "Sum of wX must be 1"
        @assert all(wX .>= 0.0) "All elements of wX must be positive"
        cWx = pointer(wX)
    else
        cWx = C_NULL
    end

    result = Ref(CppMinimizerResult(
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0, 0))

    if initialX !== nothing
        @assert size(initialX) == (L, N) "InitialX must be LxN matrix"
        x = collect(reshape(transpose(initialX), :))
    else
        x = Vector{Float64}(undef, L * N)
    end

    options = createOptions(xtolAbs, xtolRel, ftolAbs, ftolRel, gtol, initialX, maxIterations, verbose)

    success = ccall((:gm_short_double_approximate, libdirac), Bool,
        (Ptr{Cvoid}, Ptr{Float64}, Int, Int, Int, Ptr{Float64}, Ptr{Float64}, Ref{CppMinimizerResult}, Ref{ApproximateOptions}),
        _gm_dirac_short_double[].ptr, covDiag, L, N, bMax, x, cWx, result, options)

    if success
        return permutedims(reshape(x, N, L)), result[]
    else
        return nothing, result[]
    end
end

export dirac_short_double_approximate
export dirac_dynamic_weight_double_approximate
export gm_short_double_approximate
export CppMinimizerResult, ApproximateOptions

end # module LCDApproximationJulia
