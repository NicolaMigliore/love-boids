local UI = Class()

function UI:init()
	local yOffset = WINDOW_HEIGHT - 50
	local updateAlignment = function(newVal)
		ALIGNMENT_FORCE = newVal
	end
	local AlignmentSlider = newSlider(70, yOffset + 20, 100, ALIGNMENT_FORCE, 0.1, 500, updateAlignment)
	local updateCohesion = function(newVal)
		COHESION_FORCE = newVal
	end
	local CohesionSlider = newSlider(190, yOffset + 20, 100, COHESION_FORCE, 0.1, 500, updateCohesion)
	local updateSeparation = function(newVal)
		SEPARATION_FORCE = newVal
	end
	local SeparationSlider = newSlider(310, yOffset + 20, 100, SEPARATION_FORCE, 0.1, 100000, updateSeparation)
	local updateBorder = function(newVal)
		BORDER_FORCE = newVal
	end
	local BorderSlider = newSlider(430, yOffset + 20, 100, BORDER_FORCE, 0.1, 100000, updateBorder)

	self.sliders = {
		alignment = AlignmentSlider,
		cohesion = CohesionSlider,
		separation = SeparationSlider,
		border = BorderSlider
	}
end

function UI:draw()
	local yOffset = WINDOW_HEIGHT - 50
	love.graphics.setColor(.4,.3,.2)
	love.graphics.rectangle("fill", 0, yOffset, 500, 50)
	love.graphics.setColor(1,1,1)
	for _, slider in pairs(self.sliders) do
		slider:draw()
		love.graphics.print(_..": "..math.floor(slider:getValue()), slider.x -50, slider.y + 10)
	end
end

return UI
