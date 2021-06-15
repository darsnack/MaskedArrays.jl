function _slicetomask(A, slices::Tuple)
    slicemask = trues(size(A))
    slicemask[slices] .= 0

    return slicemask
end

mask(A::AbstractArray, mask::BitArray) = MaskedArray(A, mask)
mask(A::AbstractArray, slices::Tuple) = MaskedSliceArray(A, slices)
mask(A::AbstractArray, slice, slices...) = mask(A, (slice, slices...))
mask(A::MaskedArray, mask::BitArray) = mask(A.data, A.mask .* mask)
mask(A::MaskedSliceArray, slices::Tuple) =
    mask(A.data, map((s, s̄) -> union(s, s̄), A.slices, slices))
mask(A::MaskedArray, slices::Tuple) = mask(A.data, A.mask .* _slicetomask(A, slices))
mask(A::MaskedSliceArray, mask::BitArray) = mask(A.data, mask .* _slicetomask(A, A.slices))

unmask(A::MaskedArray) = A.data
unmask(A::MaskedSliceArray) = A.data

freeze(A::MaskedArray) = A.data .* A.mask
freeze(A::MaskedSliceArray) = A.data .* _slicetomask(A, A.slices)
