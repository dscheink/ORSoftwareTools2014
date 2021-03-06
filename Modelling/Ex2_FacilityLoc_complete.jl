### 15.S60 Exercise 2 - LP modelling using Julia/JuMP
# In this exercise we are formulating the facility location
# problem using JuMP. 


using JuMP, Gurobi

# Data: locations of customers and facilities
customerLocs = [3, 7, 9, 10, 12, 15, 18, 20]
facilityLocs = [1, 5, 10, 12, 24]

K = 3 # at most 3 facilities can be opened.

# Get M and N from the location arrays.
M = length(customerLocs)
N = length(facilityLocs)

# Step 1: build the model.
m = Model(solver = GurobiSolver())

# Step 2: define the variables.
@defVar(m, 0 <= x[1:M,1:N] <= 1)
@defVar(m, y[1:N], Bin)

# Step 3a: add the constraint that the amount that facility j can serve
# customer x is at most 1 if facility j is opened, and 0 otherwise.
for i=1:M
	for j=1:N
		@addConstraint(m, x[i,j] <= y[j])
	end
end

# Step 3b: add the constraint that the amount that each customer must
# be served
for i=1:M
	@addConstraint(m, sum{ x[i,j], j=1:N} == 1)
end

# Step 3c: add the constraint that at most 3 facilities can be opened.
@addConstraint(m, sum{ y[j], j=1:N} <= K)

# Step 4: add the objective.
@setObjective(m, Min, sum{ abs(customerLocs[i] - facilityLocs[j]) * x[i,j], i=1:M, j=1:N} )

# Step 5: solve the problem!
solve(m)

# Step 6: post-process the y variables:
# - put the y values in an array
# - find the indices for which y[i] is 1
# - print those indices, and the locations of those facilities.

yvals = zeros(N,1)
for j=1:N
	yvals[j] = getValue(y[j])
end 

finalInds = find( yvals .> 0.5)

println()
println("Chosen facilities: ")
println(finalInds)
println()
println("Locations of those facilities:")
println( facilityLocs[ finalInds[:]])


# Step 7: problem modification for Exercise 3.
# We need to iteratively add constraints to 

zeroInds = find ( yvals .< 0.5 )
oneInds = find ( yvals .> 0.5 )