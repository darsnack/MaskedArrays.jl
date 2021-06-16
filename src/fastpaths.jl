for fconv in (:conv, :depthwiseconv), WT in (MaskedArray, MaskedSliceArray)
    @eval begin
        NNlib.$fconv(x::AbstractArray{xT, N}, w::$WT{wT, N}; kwargs...) where {xT, wT, N} =
            NNlib.$fconv(x, freeze(w); kwargs...)
        NNlib.$fconv(x::AbstractArray{xT, N}, w::$WT{wT, N}, cdims::ConvDims;
                     kwargs...) where {xT, wT, N} = NNlib.$fconv(x, freeze(w), cdims; kwargs...)
    end
end
