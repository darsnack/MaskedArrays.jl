for fconv in (:conv, :depthwiseconv), WT in (MaskedArray, MaskedSliceArray)
    local ∇conv_data, ∇conv_filter = Symbol.(:∇, fconv, [:_data, :_filter])
    conv_pullback, ∇conv_data_pullback = Symbol.([fconv, ∇conv_data], :_pullback)

    @eval begin
        NNlib.$fconv(x::AbstractArray{xT, N}, w::$WT{wT, N}; kwargs...) where {xT, wT, N} =
            NNlib.$fconv(x, freeze(w); kwargs...)
        NNlib.$fconv(x::AbstractArray{xT, N}, w::$WT{wT, N}, cdims::ConvDims;
                     kwargs...) where {xT, wT, N} = NNlib.$fconv(x, freeze(w), cdims; kwargs...)

        function ChainRulesCore.rrule(::typeof($fconv), x, w::$WT, cdims; kw...)
            function $conv_pullback(Δ)
                Δ = colmajor(Δ)
                return (
                    NoTangent(),
                    @thunk($∇conv_data(Δ, freeze(w), cdims, kw...)),
                    @thunk(w.mask .* $∇conv_filter(x, Δ, cdims, kw...)),
                    NoTangent(),
                )
            end
            return $conv(x, w, cdims; kw...), $conv_pullback
        end

        function ChainRulesCore.rrule(::typeof($∇conv_data), x, w::$WT, cdims; kw...)
            function $∇conv_data_pullback(Δ)
                Δ = colmajor(Δ)
                return (
                    NoTangent(),
                    @thunk($conv(Δ, freeze(w), cdims, kw...)),
                    @thunk(w.mask .* $∇conv_filter(Δ, x, cdims, kw...)),
                    NoTangent(),
                )
            end
            return $∇conv_data(x, w, cdims; kw...), $∇conv_data_pullback
        end
    end
end
