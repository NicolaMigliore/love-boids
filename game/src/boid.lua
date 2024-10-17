local Boid = Class()

function Boid:init(x,y)
	self.position = Vector(x,y)
	self.velocity = Vector(math.random(-100, 100) / 100, math.random(-100, 100) / 100):normalized()
	self.speed = 100
    self.maxForce = 0.05  -- Limit steering force
    self.maxSpeed = 200   -- Limit max speed
end

function Boid:update(boids, dt)
	local alignment = self:alignment(boids) * 1.0
    local cohesion = self:cohesion(boids) * 1.0
    local separation = self:separation(boids) * 1.5

    -- Combine all forces
    local steering = alignment + cohesion + separation

    -- Limit steering force
    steering = steering:trimmed(self.maxForce)

    -- Update velocity and position
    self.velocity = self.velocity + steering
    self.velocity = self.velocity:trimmed(self.maxSpeed)
    self.position = self.position + self.velocity * dt

    -- Handle screen wrapping
    self:wrapAroundScreen()
end

function Boid:draw()
	love.graphics.circle("fill", self.position.x, self.position.y, 5)
	love.graphics.line(self.position.x, self.position.y, self.position.x + self.velocity.x/2, self.position.y + self.velocity.y/2)
end

function Boid:wrapAroundScreen()
    local width, height = love.graphics.getWidth(), love.graphics.getHeight()
    if self.position.x > width then self.position.x = 0 end
    if self.position.x < 0 then self.position.x = width end
    if self.position.y > height then self.position.y = 0 end
    if self.position.y < 0 then self.position.y = height end
end

function Boid:alignment(boids)
    local perceptionRadius = 50
    local avgVelocity = Vector(0, 0)
    local total = 0

    for _, other in ipairs(boids) do
        if other ~= self and self.position:dist(other.position) < perceptionRadius then
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
    local perceptionRadius = 100
    local centerOfMass = Vector(0, 0)
    local total = 0

    for _, other in ipairs(boids) do
        if other ~= self and self.position:dist(other.position) < perceptionRadius then
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
        if other ~= self and distance < perceptionRadius then
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

return Boid
