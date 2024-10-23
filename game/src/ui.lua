local UI = Class()

function UI:init()
	local updateAlignment = function(newVal)
		ALIGNMENT_FORCE = newVal
	end
	local AlignmentSlider = newSlider(100, 550, 100, ALIGNMENT_FORCE, 0.1, 5, updateAlignment)
	local updateCohesion = function(newVal)
		COHESION_FORCE = newVal
	end
	local CohesionSlider = newSlider(220, 550, 100, COHESION_FORCE, 0.1, 5, updateCohesion)
	local updateSeparation = function(newVal)
		SEPARATION_FORCE = newVal
	end
	local SeparationSlider = newSlider(340, 550, 100, SEPARATION_FORCE, 0.1, 5, updateSeparation)

	self.sliders = {
		alignment = AlignmentSlider,
		cohesion = CohesionSlider,
		separation = SeparationSlider
	}
end

return UI
