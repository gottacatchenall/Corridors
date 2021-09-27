include("00_generate_landcover.jl")
using Random
landcover = makecover(autocorrelation=0.6, dims=(1000,1000))
pts = makepoints(landcover)
plotlandscape(landcover, pts)



function newtopology(gen)
    totalcost = 0
    
    edgelist = deepcopy(gen.feasible)
    shuffle!(edgelist) 

    newtop = []
    for i in 1:length(edgelist)
        thisedge = edgelist[i]
        push!(newtop, thisedge)
        totalcost += gen.distances[thisedge...]
        totalcost > gen.budget && break
    end
    newtop
    # sample without replacement until you hit B.  
    # what if it crosses B? maybe check in `propose()` that its not above 1.1B or something
end

function distancematrix(points) 
    npts = size(points)[1]
    
    distmatrix = zeros(npts,npts)

    for i in 1:npts, j in 1:npts
        if i != j
            x,y = points[i,:] .- points[j,:]
            distmatrix[i,j] = sum(abs.([x,y]))
        else 
            distmatrix[i,j] = 10^8
        end
    end
    distmatrix
end

# TODO MST of the points, and then choose edges < budget 

function feasiblelist(distmatrix, budget) 
    feasiblelist = []
    for i in 1:size(distmatrix)[1], j in 1:size(distmatrix)[2]
        val = distmatrix[i,j] < budget && i != j 
        val == true && push!(feasiblelist, (i,j))
    end
    feasiblelist
end



abstract type ProposalGenerator end

"""
    proposes new topology every time and then pick new manhattan dist comb
"""
struct GraphBasedOneRound{B,C,P,D,F} <: ProposalGenerator
    budget::B     # total number of cells the proposed modifcation changes
    cover::C      # landcover map 
    points::P     # list of coordinates
    distances::D  # matrix of distances between each pair of points
    feasible::F   # list of edges that could be connected given the budget
end

GraphBasedOneRound(; 
    budget = 250, 
    landcover= makecover(), 
    points= makepoints(landcover)) = GraphBasedOneRound(budget, landcover, points, distancematrix(points), feasiblelist(points, budget))

function propose(gen::GraphBasedOneRound)
    landcover, points = gen.cover, gen.points 
    newtop = newtopology(gen)
    modification = zeros(size(landcover)...)
    for (i,j) in newtop        
        icoord, jcoord = points[i,:], points[j,:]
        thismod = connectnodes(icoord, jcoord)

        for (modi, modj) in thismod
            modification[modi,modj] = 1
        end

    end
    modification
end

"""
    proposes new topology with probability ∝ chain temp
"""
struct GraphBasedTwoRounds <: ProposalGenerator
    budget     # total number of cells the proposed modifcation changes
    points     # list of coordinates
    feasible   # matrix of nodes that could be connected given the budget
end

function propose(gen::GraphBasedTwoRounds, pts)
    
    # there should be two layers here. 
    # 1) change the topolgoy of the graph probabilistically proportional to temp
    # 2) change the breakdown of the manhattan distance for a given topology 
end


function connectnodes(icoord, jcoord)
    deltacoords = jcoord .- icoord
    xdist, ydist = abs(deltacoords[1]), abs(deltacoords[2])
    totaldist = sum(abs.(deltacoords))
 
    xoffset, yoffset = 0, 0

    h = deltacoords[1] > 0 ? 1 : -1
    v = deltacoords[2] > 0 ? 1 : -1

    modlist = []
    for s in 1:totaldist 
        if xoffset < xdist && yoffset < ydist
            if rand() < 0.5 
                xoffset += 1
            else 
                yoffset += 1
            end
        elseif xoffset < xdist
            xoffset += 1
        elseif yoffset < ydist
            yoffset += 1
        end
        push!(modlist, (icoord .+ (h*xoffset, v*yoffset) ))
    end
    modlist
end



cov = makecover(dims=(500,500))
pts = makepoints(cov)

propgen = GraphBasedOneRound(budget=500,landcover=cov, points=pts)
prop = propose(propgen)


heatmap(prop')
scatter!(pts[:,1], pts[:,2], mc=:white, msc=:black, ms=5)
