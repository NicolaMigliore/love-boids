-- Load necessary libraries
Class = require "lib.hump.class"
Vector = require "lib.hump.vector"
require "lib.simple-slider"

-- Import Boid class
Boid = require "src.boid"
Flock = require "src.flock"
local ui = require "src.ui"

local boids = {}

function love.load()
	DEBUG = {}
	WINDOW_WIDTH = love.graphics.getWidth()
	WINDOW_HEIGHT = love.graphics.getHeight()
	worldPadding = 50

	FLOCKS = {}
	ShowPerception = false
	ShowPersonalSpace = false
	ShowFlock = true
	ShowPrints = false
	ShowLines = false

	-- Forces
	ALIGNMENT_FORCE = 185
	COHESION_FORCE = 190
	SEPARATION_FORCE = 370
	BORDER_FORCE = 100000
	PREDATOR_FORCE = 5000
	PREY_FORCE = 500000



	UI = ui()

	-- spawn preys
	for i = 1, 100 do
		-- create boid
		local x = math.random(0, love.graphics.getWidth())
		local y = math.random(0, love.graphics.getHeight())
		local flockID = uuid()
		local boid = Boid(nil, x, y, flockID, 5)
		-- local boid = Boid(tostring(i), positions[i][1],positions[i][2],angles[i],flockID)
		table.insert(boids, boid)

		-- create flock
		local flock = Flock(flockID, { boid })
		FLOCKS[flock.id] = flock
	end
	-- spawn predators
	for i = 1, 2 do
		-- create boid
		local x = math.random(0, love.graphics.getWidth())
		local y = math.random(0, love.graphics.getHeight())
		local flockID = uuid()
		local boid = Boid(nil, x, y, flockID, 20)
		-- local boid = Boid(tostring(i), positions[i][1],positions[i][2],angles[i],flockID)
		table.insert(boids, boid)

		-- create flock
		local flock = Flock(flockID, { boid })
		FLOCKS[flock.id] = flock
	end
end

function love.update(dt)
	for _, boid in ipairs(boids) do
		boid:update(boids, dt)
	end

	for _, slider in pairs(UI.sliders) do
		slider:update()
	end

	DEBUG[1] = "alignment:"..tostring(boids[1].curAlignment)
	DEBUG[2] = "cohesion:"..tostring(boids[1].curCohesion)
	DEBUG[3] = "separation:"..tostring(boids[1].curSeparation)
end

function love.draw()
	-- draw world padding
	love.graphics.rectangle("line", worldPadding, worldPadding, WINDOW_WIDTH - worldPadding * 2, WINDOW_HEIGHT - worldPadding * 2)

	for _, boid in ipairs(boids) do
		love.graphics.setColor(1, 1, 1)
		if _ == 1 then love.graphics.setColor(.5,.5,.9) end
		boid:draw()
	end

	for i, debugMsg in ipairs(DEBUG) do
		love.graphics.print(debugMsg, 10, 12 * i)
	end

	if ShowPrints then
		listFlocks()
		listBoids()
	end
	
	-- Sliders
	UI:draw()
end

function love.keyreleased(key)
	if key == "d" then
		ShowPerception = not ShowPerception
	elseif key == "f" then
		ShowFlock = not ShowFlock
	elseif key == "p" then
		ShowPrints = not ShowPrints
	elseif key == "k" then
		ShowPersonalSpace = not ShowPersonalSpace
	elseif key == "l" then
		ShowLines = not ShowLines
	elseif key == "escape" then
		love.event.quit(0)
	end
end

local random = math.random
function uuid()
	local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
	return string.gsub(template, '[xy]', function(c)
		local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
		return string.format('%x', v)
	end)
end

function listFlocks()
	local cnt = 0
	for id, flock in pairs(FLOCKS) do
		love.graphics.setColor(unpack(flock.color))
		love.graphics.rectangle("fill", 5, 10 + 12 * cnt, 7, 7)
		love.graphics.setColor(1, 1, 1)
		local str = string.sub(flock.id, 1, 4) .. "\t#" .. #flock.boids
		love.graphics.print(str, 15, 5 + 12 * cnt)
		cnt = cnt + 1
	end
end

function listBoids()
	for i, boid in ipairs(boids) do
		local flock = FLOCKS[boid.flockID]
		if flock then
			love.graphics.setColor(unpack(flock.color))
		end
		love.graphics.rectangle("fill", 5, 400 + 12 * i, 7, 7)
		love.graphics.setColor(1, 1, 1)
		local str = string.sub(boid.id, 1, 4) .. "\t" .. boid.flockID
		love.graphics.print(str, 15, 400 + 12 * i)
	end
end
