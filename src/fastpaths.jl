for fconv in (:conv, :depthwiseconv), WT in (MaskedArray, MaskedSliceArray)
    @eval begin
        NNlib.$fconv(x, w::$WT; kwargs...) = NNlib.$fconv(x, freeze(w); kwargs...)
        NNlib.$fconv(x, w::$WT, cdims::ConvDims; kwargs...) = NNlib.$fconv(x, freeze(w), cdims; kwargs...)
    end
end
