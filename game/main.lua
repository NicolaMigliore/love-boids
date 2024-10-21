-- Load necessary libraries
Class = require "lib.hump.class"
Vector = require "lib.hump.vector"

-- Import Boid class
Boid = require "src.boid"

local boids = {}
FLOCKS = {}
ShowPerception = false
ShowFlock = false
function love.load()
	for i = 1, 20 do
		local x = math.random(0, love.graphics.getWidth())
		local y = math.random(0, love.graphics.getHeight())
		table.insert(boids, Boid(x, y))
	end
end

function love.update(dt)
	local boidsSnapshot = {}
	for _, boid in ipairs(boids) do
		table.insert(boidsSnapshot, copy(boid))
	end
	for _, boid in ipairs(boids) do
		boid:update(boidsSnapshot, dt)
	end
end

function love.draw()
	for _, boid in ipairs(boids) do
		love.graphics.setColor(1, 1, 1)
		if _ == 1 and boid.curAlignment then
			love.graphics.print("curAlignment:" .. boid.curAlignment:__tostring(), 10, 10)
			love.graphics.print("curCohesion:" .. boid.curCohesion:__tostring(), 10, 30)
			love.graphics.print("curSeparation:" .. boid.curSeparation:__tostring(), 10, 50)
			love.graphics.setColor(.5, 1, .4)
		end
		boid:draw()
	end
end

function love.keyreleased(key)
	if key == "d" then
		ShowPerception = not ShowPerception
	elseif key == "f" then
		ShowFlock = not ShowFlock
	end
end

function copy(obj, seen)
	if type(obj) ~= 'table' then return obj end
	if seen and seen[obj] then return seen[obj] end
	local s = seen or {}
	local res = setmetatable({}, getmetatable(obj))
	s[obj] = res
	for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
	return res
end

local random = math.random
function uuid()
	local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
	return string.gsub(template, '[xy]', function(c)
		local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
		return string.format('%x', v)
	end)
end
