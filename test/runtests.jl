using MaskedArrays
using MaskedArrays: mask, unmask, freeze
using Test

@testset "mask" begin
    x = rand(3, 2, 2)
    m = x .< 0.4
    m2 = x .< 0.8
    m3 = trues(size(x))
    m3[3, :, :] .= false
    ic = findall(m)
    il = Int.(LinearIndices(x)[ic])
    @test mask(x, m) == (x .* m)
    @test mask(x, m) == mask(x, ic)
    @test mask(x, m) == mask(x, il)
    @test mask(mask(x, m), m2) == (x .* m .* m2)
    @test iszero(mask(x, (1:2, :, :))[3, :, :])
    @test mask(mask(x, 1:2, :, :), m2) == (x .* m2 .* m3)
end

@testset "unmask" begin
    x = rand(4, 5)
    m = x .< 0.5
    @test unmask(mask(x, m)) == x
end

@testset "freeze" begin
    x = rand(4, 5)
    m = x .< 0.5
    @test freeze(mask(x, m)) isa Array
    @test count(iszero, freeze(mask(x, m))) == count(iszero, m)
end

@testset "fastops" begin
    x = mask(rand(4, 5), [1, 4, 10])
    y = rand(5, 10)
    @test x * y == x.data .* MaskedArrays.bitmask(x) * y

    x = mask(rand(4, 5), :, 1:2)
    @test x * y == x.data .* MaskedArrays.bitmask(x) * y
end
