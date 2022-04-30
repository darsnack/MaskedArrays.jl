function _indextomask(A, is)
    bitmask = fill!(similar(A, Bool), false)
    bitmask[is] .= 1

    return bitmask
end
function _slicetomask(A, slices::Tuple)
    slicemask = fill!(similar(A, Bool), false)
    if all(!isempty, slices)
        slicemask[slices...] .= 1
    end

    return slicemask
end

"""
    mask(A::AbstractArray, bitmask::AbstractArray{Bool})

Mask `A` by zeroing out the elements corresponding to false in `bitmask`.

# Examples

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
"""
mask(A::AbstractArray, bitmask::AbstractArray{Bool}) = MaskedArray(A, bitmask)

"""
    mask(A::AbstractArray, bitmask::AbstractVector{<:CartesianIndex})
    mask(A::AbstractArray, bitmask::AbstractVector{<:Integer})

Mask `A` by zeroing out any elements at indices not in `bitmask`.

# Examples

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
"""
mask(A::AbstractArray, bitmask::AbstractVector{<:CartesianIndex}) = mask(A, _indextomask(A, bitmask))
mask(A::AbstractArray, bitmask::AbstractVector{<:Integer}) = MaskedArray(A, _indextomask(A, bitmask))
mask(A::MaskedArray, bitmask::AbstractVector{<:Integer}) = mask(A, _indextomask(A.data, bitmask))
mask(A::MaskedSliceArray, bitmask::AbstractVector{<:Integer}) = mask(A, _indextomask(A.data, bitmask))

"""
    mask(A::AbstractArray, slices::Tuple)
    mask(A::AbstractArray, slice, slices...)

Mask a slice of `A` specified by the slices missing from `slices`.

# Examples

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
"""
mask(A::AbstractArray, slices::Tuple) = MaskedSliceArray(A, slices)
mask(A::AbstractArray, slice1, slice2, slices...) = mask(A, (slice1, slice2, slices...))
mask(A::MaskedArray, bitmask::AbstractArray{Bool}) =
    mask(A.data, A.mask .* adapt(typeof(A.mask), bitmask))
mask(A::MaskedSliceArray, slices::Tuple) =
    mask(A.data, map((s, s̄) -> intersect(s, s̄), A.slices, to_indices(A.data, slices)))
mask(A::MaskedArray, slices::Tuple) = mask(A.data, A.mask .* _slicetomask(A.data, slices))
function mask(A::MaskedSliceArray, bitmask::AbstractArray{Bool})
    slicemask = _slicetomask(A.data, A.slices)
    mask(A.data, adapt(typeof(slicemask), bitmask .* slicemask))
end

"""
    unmask(A::MaskedArray)
    unmask(A::MaskedSliceArray)

Unmask `A` by returning the original data without a mask applied.
"""
unmask(A::MaskedArray) = A.data
unmask(A::MaskedSliceArray) = A.data

"""
    freeze(A::MaskedArray)
    freeze(A::MaskedSliceArray)
    freeze(A)

Make a masked array permanent by returning the original data with the mask applied.
This is a no-op when `A` is not a masked array type.
"""
freeze(A::MaskedArray) = A.data .* A.mask
freeze(A::MaskedSliceArray) = A.data .* bitmask(A)
freeze(A) = A
