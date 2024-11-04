local UI = Class()

function UI:init()
	local updateAlignment = function(newVal)
		ALIGNMENT_FORCE = newVal
	end
	local AlignmentSlider = newSlider(100, 550, 100, ALIGNMENT_FORCE, 0.1, 500, updateAlignment)
	local updateCohesion = function(newVal)
		COHESION_FORCE = newVal
	end
	local CohesionSlider = newSlider(220, 550, 100, COHESION_FORCE, 0.1, 500, updateCohesion)
	local updateSeparation = function(newVal)
		SEPARATION_FORCE = newVal
	end
	local SeparationSlider = newSlider(340, 550, 100, SEPARATION_FORCE, 0.1, 100000, updateSeparation)
	local updateBorder = function(newVal)
		BORDER_FORCE = newVal
	end
	local BorderSlider = newSlider(460, 550, 100, BORDER_FORCE, 0.1, 100000, updateBorder)

	self.sliders = {
		alignment = AlignmentSlider,
		cohesion = CohesionSlider,
		separation = SeparationSlider,
		border = BorderSlider
	}
end

function UI:draw()
	love.graphics.setColor(.4,.3,.2)
	love.graphics.rectangle("fill", 30, 530, 500, 70)
	love.graphics.setColor(1,1,1)
	for _, slider in pairs(self.sliders) do
		slider:draw()
		love.graphics.print(_..": "..math.floor(slider:getValue()), slider.x -50, slider.y + 10)
	end
end

return UI
