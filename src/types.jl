struct MaskedArray{T, N, S<:AbstractArray{T, N}} <: AbstractArray{T, N}
    data::S
    mask::BitArray{N}
end

MaskedArray(data::AbstractArray, mask::AbstractArray{Bool}) =
    MaskedArray(data, BitArray(mask))

Base.size(A::MaskedArray) = size(A.data)

Base.IndexStyle(::Type{<:MaskedArray}) = Base.IndexLinear()

Base.getindex(A::MaskedArray, i::Int) = A.data[i] * A.mask[i]

function Base.setindex!(A::MaskedArray, v, i::Int)
    if A.mask[i]
        A.data[i] = v
    end

    return A
end

Base.similar(A::MaskedArray, ::Type{S}, dims::Dims) where S =
    MaskedArray(similar(A.data, S, dims), trues(dims))

struct MaskedSliceArray{T, N, S<:AbstractArray{T, N}, R<:Tuple} <: AbstractArray{T, N}
    data::S
    slices::R

    function MaskedSliceArray(data::S, slices::R) where {T, N, S<:AbstractArray{T, N}, R<:Tuple}
        length(slices) == N ||
            throw(ArgumentError("MaskedSliceArray(data, slices) expects ndims(data) == length(slices) (got $N != $(length(slices)))."))
        for (d, (s, is)) in enumerate(zip(size(data), slices))
            all(i -> i ∈ 1:s, is) ||
                throw(ArgumentError("Attempted to mask out of bounds indices $is ∉ 1:$s at dimension $d."))
        end

        new{T, N, S, R}(data, slices)
    end
end
MaskedSliceArray(data::AbstractArray{<:Any, N}, slices::Vararg{<:Any, N}) where N =
    MaskedSliceArray(data, slices)

Base.size(A::MaskedSliceArray) = size(A.data)

Base.getindex(A::MaskedSliceArray{T, N}, I::Vararg{Int, N}) where {T, N} =
    any(i ∈ s for (i, s) in zip(I, A.slices)) ? zero(T) : A.data[I...]

function Base.setindex!(A::MaskedSliceArray{<:Any, N}, v, I::Vararg{Int, N}) where N
    if all(i ∉ s for (i, s) in zip(I, A.slices))
        A.data[I...] = v
    end

    return A
end
