local Flock = Class()
function Flock:init(id, boids, color)
	self.id = id or uuid()
    self.boids = boids or {}
	self.color = color or { math.random(), math.random(), math.random() }
end

function Flock:addBoid(boid)
	table.insert(self.boids, boid)
end

function Flock:removeBoid(boid)
	local index = 1
	for i, b in ipairs(self.boids) do
		if b == boid then
			index = i
			break
		end		
	end
	table.remove(self.boids, index)
end

function Flock:mergeFlock(other)
	for _, b in ipairs(other.boids) do
		b.flockID = self.id
		table.insert(self.boids, b)
	end
	FLOCKS[other.id] = nil
end

return Flock
