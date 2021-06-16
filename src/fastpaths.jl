for fconv in [:conv, :depthwiseconv], WT in [MaskedArray, MaskedSliceArray]
    @eval NNlib.$fconv(x, w::$WT; kwargs...) = NNlib.$fconv(x, freeze(w); kwargs...)
end
