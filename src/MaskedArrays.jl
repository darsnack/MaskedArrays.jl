module MaskedArrays

using GPUArrays
using Adapt

export MaskedArray, MaskedSliceArray

include("types.jl")
include("api.jl")
include("fastops.jl")

end
