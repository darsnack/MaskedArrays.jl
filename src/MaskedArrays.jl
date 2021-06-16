module MaskedArrays

using NNlib
using ChainRulesCore

export MaskedArray, MaskedSliceArray

include("types.jl")
include("api.jl")
include("fastpaths.jl")

end
