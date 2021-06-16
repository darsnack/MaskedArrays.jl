for fconv in [:conv, :depthwiseconv], WT in [MaskedArray, MaskedSliceArray]
    @eval $(fconv)(x, w::$WT; kwargs...) = $(fconv)(x, freeze(w); kwargs...)
end
