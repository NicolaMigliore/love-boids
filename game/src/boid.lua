local Boid = Class()
local perceptionRad = 50

function Boid:init(id, x, y, angle, flockID)
	self.id = id or uuid()
	self.position = Vector(x, y)
	self.angle = angle or (math.random() * 2 * math.pi) -- Random angle in radians
	self.speed = 100
	self.maxForce = 0.05                  -- Limit steering force
	self.maxSpeed = 200                   -- Limit max speed
	self.turnSpeed = 0.01                 -- Smooth turning
	self.size = 10 --math.random(5, 20)
	self.flockID = flockID                -- Flock ID for the boid
	self.lastMergeTime = 0
end

function Boid:update(boids, dt)
	if math.random() < 0.01 then
		self:mergeFlocks(boids)
	end

	local flock = FLOCKS[self.flockID]

	if flock then
		self.curAlignment = self:alignment(flock.boids) * 1.0
		self.curCohesion = self:cohesion(flock.boids) * 4.5
		self.curSeparation = self:separation(flock.boids) * 3.5

		-- Combine all forces
		local steering = self.curAlignment + self.curCohesion + self.curSeparation
		steering = steering:trimmed(self.maxForce)

		-- Update angle (steering forces modify direction)
		local desiredAngle = math.atan2(steering.y, steering.x)
		self.angle = self.angle + (desiredAngle - self.angle) * self.turnSpeed

	end
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
	
	local flock = FLOCKS[self.flockID]
	if flock and ShowFlock then
		love.graphics.setColor(flock.color)
	end

	love.graphics.circle("fill", self.position.x, self.position.y, math.floor(5 * sizeModifier))
	local lineEnd = self.position + Vector(math.cos(self.angle), math.sin(self.angle)) * math.floor(10 * sizeModifier)
	love.graphics.line(self.position.x, self.position.y, lineEnd.x, lineEnd.y)

	love.graphics.setColor(1, 1, 1)
	if ShowPerception then
		love.graphics.print(string.sub(self.flockID, 1,4), self.position.x-perceptionRad, self.position.y-perceptionRad-10)
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
function Boid:mergeFlocks(boids)
	local currentTime = love.timer.getTime()  -- Use LOVE2D's timer
    if currentTime - self.lastMergeTime < 1 then return end  -- Merge only once every 1 second
	for _, other in ipairs(boids) do
		if other ~= self and self.flockID ~= other.flockID and self:canFlock(other) then
			local flock = FLOCKS[self.flockID]
			local otherFlock = FLOCKS[other.flockID]
			if flock and otherFlock then
				-- flock:mergeFlock(otherFlock)
				for _, boid in ipairs(otherFlock.boids) do
					boid.flockID = self.flockID
					table.insert(flock.boids, boid)
				end
				FLOCKS[otherFlock.id] = nil
				self.lastMergeTime = currentTime  -- Update last merge time
			end
		end
	end
end

function Boid:alignment(boids)
	local avgVelocity = Vector(0, 0)
	local total = 0

	for _, other in ipairs(boids) do
		if other ~= self and other.flockID == self.flockID then
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
	local modSizeA, modSizeB = math.modf(self.size / 5), math.modf(other.size / 5)
	local distance = self.position:dist(other.position)
	local boidsCanFlock = modSizeA == modSizeB and distance < perceptionRad
	return boidsCanFlock
end

return Boid
