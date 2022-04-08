function _indextomask(A, is)
    bitmask = falses(size(A))
    bitmask[is] .= 1

    return bitmask
end
function _slicetomask(A, slices::Tuple)
    slicemask = falses(size(A))
    if all(!isempty, slices)
        slicemask[slices...] .= 1
    end

    return slicemask
end

mask(A::AbstractArray, bitmask::AbstractArray{Bool}) = MaskedArray(A, bitmask)
# must be Vector{<:Integer} not AbstractVector{<:Integer} to avoid method ambiguity
mask(A::AbstractArray, bitmask::Vector{<:Integer}) = mask(A, _indextomask(A, bitmask))
mask(A::AbstractArray, bitmask::Vector{<:CartesianIndex}) = mask(A, _indextomask(A, bitmask))
mask(A::AbstractArray, slices::Tuple) = MaskedSliceArray(A, slices)
mask(A::AbstractArray, slice, slices...) = mask(A, (slice, slices...))
mask(A::MaskedArray, bitmask::AbstractArray{Bool}) = mask(A.data, A.mask .* bitmask)
mask(A::MaskedSliceArray, slices::Tuple) =
    mask(A.data, map((s, s̄) -> union(s, s̄), A.slices, to_indices(A.data, slices)))
mask(A::MaskedArray, slices::Tuple) = mask(A.data, A.mask .* _slicetomask(A, slices))
mask(A::MaskedSliceArray, bitmask::AbstractArray{Bool}) =
    mask(A.data, bitmask .* _slicetomask(A, A.slices))

unmask(A::MaskedArray) = A.data
unmask(A::MaskedSliceArray) = A.data

freeze(A::MaskedArray) = A.data .* A.mask
freeze(A::MaskedSliceArray) = A.data .* _slicetomask(A, A.slices)
