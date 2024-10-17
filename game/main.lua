-- Load necessary libraries
Class = require "lib.hump.class"
Vector = require "lib.hump.vector"

-- Import Boid class
Boid = require "src.boid"

local boids = {}
function love.load()
	for i = 1, 50 do
        local x = math.random(0, love.graphics.getWidth())
        local y = math.random(0, love.graphics.getHeight())
        table.insert(boids, Boid(x, y))
    end
end

function love.update(dt)
	for _, boid in ipairs(boids) do
        boid:update(boids, dt)
    end
end

function love.draw()
	for _, boid in ipairs(boids) do
        boid:draw()
    end
end
