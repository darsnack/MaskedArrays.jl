function _indextomask(A, is)
    bitmask = trues(size(A))
    bitmask[is] .= 0

    return bitmask
end
function _slicetomask(A, slices::Tuple)
    slicemask = trues(size(A))
    is = map(s -> isempty(s) ? Colon() : s, slices)
    slicemask[is...] .= 0

    return slicemask
end

mask(A::AbstractArray, bitmask::AbstractArray{Bool}) = MaskedArray(A, bitmask)
mask(A::AbstractArray, bitmask::AbstractVector{<:Integer}) = mask(A, _indextomask(A, bitmask))
mask(A::AbstractArray, slices::Tuple) = MaskedSliceArray(A, slices)
mask(A::AbstractArray, slice, slices...) = mask(A, (slice, slices...))
mask(A::MaskedArray, bitmask::AbstractArray{Bool}) = mask(A.data, A.mask .* bitmask)
mask(A::MaskedSliceArray, slices::Tuple) =
    mask(A.data, map((s, s̄) -> union(s, s̄), A.slices, slices))
mask(A::MaskedArray, slices::Tuple) = mask(A.data, A.mask .* _slicetomask(A, slices))
mask(A::MaskedSliceArray, bitmask::AbstractArray{Bool}) =
    mask(A.data, bitmask .* _slicetomask(A, A.slices))

unmask(A::MaskedArray) = A.data
unmask(A::MaskedSliceArray) = A.data

freeze(A::MaskedArray) = A.data .* A.mask
freeze(A::MaskedSliceArray) = A.data .* _slicetomask(A, A.slices)
