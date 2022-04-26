for T in (MaskedArray, MaskedSliceArray)
    @eval begin
        Base.:(*)(x::$T{S, 2}, y::AbstractMatrix) where S = freeze(x) * y
        Base.:(*)(x::AbstractMatrix, y::$T{S, 2}) where S = x * freeze(y)
    end
end
