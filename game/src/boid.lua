local Boid = Class()
local perceptionRad = 50

function Boid:init(id, x, y, flockID)
	self.id = id or uuid()
	self.position = Vector(x, y)
	self.velocity = Vector(math.random() * 2 - 1, math.random() * 2 - 1):normalized() * 100 -- Initial random velocity
	self.size = math.random(5, 20)                                                       -- Size of the boid
	self.maxForce = 100 / math.modf(self.size / 5)                                       -- Limit steering force
	self.maxSpeed = 100 / math.modf(self.size / 5)                                       -- Limit max speed
	self.personalSpace = math.modf(self.size) * 8											-- Boids personal space
	self.flockID = flockID                                                               -- Flock ID for the boid
	self.lastMergeTime = 0
end

function Boid:update(boids, dt)
	if math.random() < 0.01 then
		self:mergeFlocks(boids)
	end

	local flock = FLOCKS[self.flockID]

	-- Calculate border avoidance force
	local borderAvoidanceForce = self:avoidBorder() *
		BORDER_FORCE -- Give this a strong influence to prioritize border avoidance

	local steering = borderAvoidanceForce

	if flock then
		-- Calculate forces
		self.curAlignment = self:alignment(flock.boids) * ALIGNMENT_FORCE
		self.curCohesion = self:cohesion(flock.boids) * COHESION_FORCE
		self.curSeparation = self:separation(flock.boids) * SEPARATION_FORCE

		-- Combine all forces
		steering = steering + self.curAlignment + self.curCohesion + self.curSeparation

		-- Limit the steering force to maxForce
		steering = steering:trimmed(self.maxForce)

		-- Update velocity based on steering
		self.velocity = self.velocity + steering * dt  -- Apply steering over time
		self.velocity = self.velocity:trimmed(self.maxSpeed) -- Limit velocity to max speed
	end

	-- Update position based on velocity
	self.position = self.position + self.velocity * dt
end

function Boid:draw()
	local sizeModifier = math.modf(self.size / 5)

	local flock = FLOCKS[self.flockID]
	if flock and ShowFlock then
		love.graphics.setColor(flock.color)
	end

	love.graphics.circle("fill", self.position.x, self.position.y, math.floor(5 * sizeModifier))
	local lineEnd = self.position + self.velocity:normalized() * math.floor(10 * sizeModifier)
	love.graphics.line(self.position.x, self.position.y, lineEnd.x, lineEnd.y)
	love.graphics.print(math.floor(self.maxForce), self.position.x - 15 - sizeModifier * 5,
		self.position.y - 10 - sizeModifier * 5)

	love.graphics.setColor(1, 1, 1)
	
	-- Debug drawing
	if ShowPerception then
		love.graphics.print(string.sub(self.flockID, 1, 4), self.position.x - perceptionRad,
			self.position.y - perceptionRad - 10)
		love.graphics.circle("line", self.position.x, self.position.y, perceptionRad)
	end
	if ShowPersonalSpace then
		love.graphics.setColor(1, .5, .5)
		love.graphics.circle("line", self.position.x, self.position.y, self.personalSpace)
	end
end

function Boid:avoidBorder()
	local width, height = WINDOW_WIDTH, WINDOW_HEIGHT
	local steer = Vector(0, 0)
	local padding = worldPadding

	-- return targetAngle
	if self.position.x < padding then
		steer = steer + Vector(1, 0) * (padding - self.position.x)
	elseif self.position.x > width - padding then
		steer = steer + Vector(-1, 0) * (self.position.x - (width - padding))
	end

	if self.position.y < padding then
		steer = steer + Vector(0, 1) * (padding - self.position.y)
	elseif self.position.y > height - padding then
		steer = steer + Vector(0, -1) * (self.position.y - (height - padding))
	end

	return steer:trimmed(self.maxForce)
end

-- Function to find the flock the boid belongs to
function Boid:mergeFlocks(boids)
	local currentTime = love.timer.getTime()             -- Use LOVE2D's timer
	if currentTime - self.lastMergeTime < 1 then return end -- Merge only once every 1 second
	for _, other in ipairs(boids) do
		if other ~= self and self.flockID ~= other.flockID and self:canFlock(other) then
			local flock = FLOCKS[self.flockID]
			local otherFlock = FLOCKS[other.flockID]
			if flock and otherFlock then
				for _, boid in ipairs(otherFlock.boids) do
					boid.flockID = self.flockID
					table.insert(flock.boids, boid)
				end
				FLOCKS[otherFlock.id] = nil
				self.lastMergeTime = currentTime -- Update last merge time
			end
		end
	end
end

function Boid:alignment(boids)
	local avgVelocity = Vector(0, 0)
	local total = 0

	for _, other in ipairs(boids) do
		if other ~= self and other.flockID == self.flockID then
			avgVelocity = avgVelocity + other.velocity
			total = total + 1
		end
	end

	if total > 0 then
		avgVelocity = avgVelocity / total
		return (avgVelocity - self.velocity):normalized()
	else
		return Vector(0, 0)
	end
end

function Boid:cohesion(boids)
	local centerOfMass = Vector(0, 0)
	local total = 0

	for _, other in ipairs(boids) do
		if other ~= self and other.flockID == self.flockID then
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
	local total = 0
	local steer = Vector(0, 0)

	for _, other in ipairs(boids) do
		local distance = self.position:dist(other.position)
		if other ~= self and other.flockID == self.flockID and distance ~= 0 and distance < self.personalSpace then
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
	local modSizeA, modSizeB = math.modf(self.size / 5), math.modf(other.size / 5)
	local distance = self.position:dist(other.position)
	local boidsCanFlock = modSizeA == modSizeB and distance < perceptionRad
	return boidsCanFlock
end

return Boid
