using NeutralLandscapes
using Plots
using Distributions 
boundedval(val, upperbounds) = begin 
    val < upperbounds[1] && return 1

    for i in 2:length(upperbounds)
        val < upperbounds[i] && val > upperbounds[i-1] && return i
    end
    return length(upperbounds)
end

discretize(landscape, numcategories=5) = map(i -> boundedval(i, [(1/numcategories)*j for j in 1:numcategories]), landscape)


makecover(;dims=(250,250), numcategories=10, autocorrelation=0.8) = discretize(rand(DiamondSquare(autocorrelation), dims), numcategories)


makepoints(n::Integer=25) = rand(Uniform(0.1, 0.9), n,2)

makepoints(mat::Matrix{T}; n=25) where {T<:Integer} = begin
    pts = makepoints(n)
    
    xscale = size(mat)[1]
    yscale = size(mat)[2]
    gridcoords = zeros(Int64,size(pts)...) 

    for pt in 1:n
        gridcoords[pt,1] = floor(xscale*pts[pt,1])
        gridcoords[pt,2] = floor(yscale*pts[pt,2])
    end
    gridcoords
end


plotlandscape(landcover, pts) = begin
    heatmap(landcover, c=:viridis, xticks=:none, yticks=:none, frame=:box, size=(500,500), colorbar=:none, aspectratio=1)
    scatter!(pts[:,1], pts[:,2], mc=:white, ms=5, msw=1, msc=:black, legend=:none)
end