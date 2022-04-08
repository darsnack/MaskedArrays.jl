# MaskedArrays

[![Build Status](https://github.com/darsnack/MaskedArrays.jl/workflows/CI/badge.svg)](https://github.com/darsnack/MaskedArrays.jl/actions)

MaskedArrays.jl allows you to associated a bitmask with an array non-destructively. Any elements with a masked value of `false` are zero, while other elements are passed through. The original array is not modified. It provides two types: `MaskedArray` and `MaskedSliceArray`. Nothing is exported.

```julia
julia> x = rand(4, 5)
4×5 Matrix{Float64}:
 0.45442   0.323381  0.245189   0.9963    0.901239
 0.867445  0.358103  0.428182   0.888031  0.800996
 0.116383  0.499893  0.0768902  0.614683  0.23086
 0.840305  0.564109  0.477627   0.104402  0.0891596

julia> m = x .< 0.5
4×5 BitMatrix:
 1  1  1  0  0
 0  1  1  0  0
 1  1  1  0  1
 0  0  1  1  1

julia> mask(x, m)
4×5 MaskedArray{Float64, 2, Matrix{Float64}}:
 0.45442   0.323381  0.245189   0.0       0.0
 0.0       0.358103  0.428182   0.0       0.0
 0.116383  0.499893  0.0768902  0.0       0.23086
 0.0       0.0       0.477627   0.104402  0.0891596
```

You can also pass a `Vector` of indices to mask elements.

```julia
julia> x = ones(3, 2)
3×2 Matrix{Float64}:
 1.0  1.0
 1.0  1.0
 1.0  1.0

julia> mask(x, [1, 5])
3×2 MaskedArray{Float64, 2, Matrix{Float64}}:
 1.0  0.0
 0.0  1.0
 0.0  0.0
```

Even complete slices of dimensions can be masked.

```julia
julia> mask(x, 1:2, :, :)
3×2×2 MaskedSliceArray{Float64, 3, Array{Float64, 3}, Tuple{UnitRange{Int64}, Base.Slice{Base.OneTo{Int64}}, Base.Slice{Base.OneTo{Int64}}}}:
[:, :, 1] =
 0.69798   0.353225
 0.646014  0.20619
 0.0       0.0

[:, :, 2] =
 0.318028  0.276218
 0.508333  0.274718
 0.0       0.0
```

The original array can be obtained with `unmask`, and the masking can be made permanent with `freeze`.
