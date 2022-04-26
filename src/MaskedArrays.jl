module MaskedArrays

using GPUArrays
using Adapt
import ArrayInterface

export MaskedArray, MaskedSliceArray

include("types.jl")
include("api.jl")
include("fastops.jl")

end
