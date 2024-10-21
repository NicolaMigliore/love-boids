local Boid = Class()
local perceptionRad = 30

function Boid:init(x, y)
	self.position = Vector(x, y)
	self.angle = math.random() * 2 * math.pi -- Random angle in radians
	self.speed = 100
	self.maxForce = 0.05                  -- Limit steering force
	self.maxSpeed = 200                   -- Limit max speed
	self.turnSpeed = 0.01                 -- Smooth turning
	self.size = 10                        --math.random(5, 20)
	self.flockID = nil                    -- Flock ID for the boid
end

function Boid:update(boids, dt)
	-- Find the flock this boid belongs to, if not already set or recalculate periodically
	if not self.flockID or math.random() < 0.01 then -- Periodically recheck flock
		self:findFlock(boids)
	end

	self.curAlignment = self:alignment(boids) * 1.0
	self.curCohesion = self:cohesion(boids) * 4.5
	self.curSeparation = self:separation(boids) * 3.5

	-- Combine all forces
	local steering = self.curAlignment + self.curCohesion + self.curSeparation
	steering = steering:trimmed(self.maxForce)

	-- Update angle (steering forces modify direction)
	local desiredAngle = math.atan2(steering.y, steering.x)
	self.angle = self.angle + (desiredAngle - self.angle) * self.turnSpeed

	-- Calculate velocity based on angle and speed
	self.velocity = Vector(math.cos(self.angle), math.sin(self.angle)) * self.maxSpeed / 10
	-- self.velocity = self.velocity:normalized() * self.maxSpeed / 10
	self.velocity = self.velocity:trimmed(self.maxSpeed)
	self.position = self.position + self.velocity * dt

	-- Handle screen wrapping
	self:wrapAroundScreen()
end

function Boid:draw()
	local sizeModifier = math.modf(self.size / 10)
	
	if self.flockID and ShowFlock then
		love.graphics.setColor(FLOCKS[self.flockID])
	end

	love.graphics.circle("fill", self.position.x, self.position.y, math.floor(5 * sizeModifier))
	local lineEnd = self.position + Vector(math.cos(self.angle), math.sin(self.angle)) * math.floor(10 * sizeModifier)
	love.graphics.line(self.position.x, self.position.y, lineEnd.x, lineEnd.y)

	love.graphics.setColor(1, 1, 1)
	if ShowPerception then
		love.graphics.circle("line", self.position.x, self.position.y, perceptionRad)
	end
end

function Boid:wrapAroundScreen()
	local width, height = love.graphics.getWidth(), love.graphics.getHeight()
	if self.position.x > width then self.position.x = 0 end
	if self.position.x < 0 then self.position.x = width end
	if self.position.y > height then self.position.y = 0 end
	if self.position.y < 0 then self.position.y = height end
end

-- Function to find the flock the boid belongs to
function Boid:findFlock(boids)
	for _, other in ipairs(boids) do
		if other ~= self and self:canFlock(other) then
			local flockID = other.flockID
			if flockID == nil then
				flockID = uuid()
				FLOCKS[flockID] = { math.random(), math.random(), math.random() }
			end
			self.flockID = flockID -- Assign a random flock ID
			other.flockID = self.flockID -- Ensure the other boid belongs to the same flock
		end
	end
end

function Boid:alignment(boids)
	local perceptionRadius = 50
	local avgVelocity = Vector(0, 0)
	local total = 0

	for _, other in ipairs(boids) do
		if other ~= self and other.flockID == self.flockID and self:canFlock(other) then
			avgVelocity = avgVelocity + Vector(math.cos(other.angle), math.sin(other.angle))
			total = total + 1
		end
	end

	if total > 0 then
		avgVelocity = avgVelocity / total
		return avgVelocity:normalized()
	else
		return Vector(0, 0)
	end
end

function Boid:cohesion(boids)
	local perceptionRadius = 100
	local centerOfMass = Vector(0, 0)
	local total = 0

	for _, other in ipairs(boids) do
		if other ~= self and other.flockID == self.flockID and self:canFlock(other) then
			centerOfMass = centerOfMass + other.position
			total = total + 1
		end
	end

	if total > 0 then
		centerOfMass = centerOfMass / total
		return (centerOfMass - self.position):normalized()
	else
		return Vector(0, 0)
	end
end

function Boid:separation(boids)
	local perceptionRadius = 30
	local total = 0
	local steer = Vector(0, 0)

	for _, other in ipairs(boids) do
		local distance = self.position:dist(other.position)
		if other ~= self and other.flockID == self.flockID and distance ~= 0 and distance < perceptionRadius then
			local diff = (self.position - other.position):normalized() / distance
			steer = steer + diff
			total = total + 1
		end
	end

	if total > 0 then
		steer = steer / total
	end

	if steer:len() > 0 then
		return steer:normalized()
	else
		return Vector(0, 0)
	end
end

function Boid:canFlock(other)
	local modA, modB = math.modf(self.size / 5), math.modf(other.size / 5)
	local distance = self.position:dist(other.position)
	return modA == modB and distance < perceptionRad
end

function getMagnitude(v)
	local magnitude = math.sqrt(v.x ^ 2 + v.y ^ 2)
	return magnitude
end

return Boid
