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

plotproposal(landcover, pts, proposal) = begin
    plt = heatmap(landcover, c=:GnBu_9, xticks=:none, yticks=:none, frame=:box, size=(750,750), dpi=140, colorbar=:none, aspectratio=1)

    ind = collect(findall(x -> x==1, proposal))

    for v in ind
        x,y = v[1], v[2] # transpose to fit the heatmap
        scatter!(plt, [x],[y], shape=:rect, mc=:orange, msw=0, ms=3, label="")
    end
    scatter!(plt, pts[:,1], pts[:,2], mc=:white, msc=:black, ms=5, label="")

    plt
end

cov = makecover(dims=(100, 100), autocorrelation=0.8)
pts = makepoints(cov)

anim = @animate for i in 1:100
    plotproposal(cov, pts, propose(GraphBasedOneRound(budget=25, points=pts, landcover=cov)))
end

gif(anim, "test.gif", fps=5)

