-----------------------------------------------------------------------------------------
--
-- buildings.lua
--
-----------------------------------------------------------------------------------------

-- Include Corona's libraries
local math = require "math"
local storyboard = require "storyboard"
local timer = require "timer"
local widget = require "widget"

local screenW, screenH = display.contentWidth, display.contentHeight

-- Public interface
buildings = {}

-- Public variables
buildings.width = 150
buildings.height = 50
buildings.grid_width =7
buildings.grid_spacing = 50

-- Building colours
building_colours = {
	commercial = {
		left = {0.6, 0.6, 0.2},
		right = {0.5, 0.5, 0.1},
		top = {0.8, 0.8, 0.3}
	},
	industrial = {
		left = {0.1, 0.9, 0.1},
		right = {0, 0.7, 0},
		top = {0.2, 1, 0.2}
	},
	reactor = {
		left = {0.2, 0.2, 0.8},
		right = {0.1, 0.1, 0.6},
		top = {0.3, 0.3, 0.9}
	},
	residential = {
		left = {0.9, 0.1, 0.1},
		right = {0.7, 0, 0},
		top = {1, 0.2, 0.2}
	},
	substation = {
		left = {0.2, 0.5, 0.9},
		right = {0.1, 0.4, 0.7},
		top = {0.3, 0.6, 1}
	}	
}

-- Reference to the grid
local grid = nil

function buildings.init(init_grid)
	grid = init_grid
end

-- Utility function to reorder buildings
function buildings.reorder()
	local x_index = 1

	while (x_index <= buildings.grid_width) do
		local y_index = buildings.grid_width

		while (y_index >= 1) do
			if ((grid[x_index]) and (grid[x_index][y_index])) then
				grid[x_index][y_index]:toFront()
			end

			y_index = y_index - 1
		end

		x_index = x_index + 1
	end
end

function buildings.newBuilding(group, x_index, y_index, type, level)
	local building = display.newGroup()
	building.group = group
	building.type = type
	building.x_index = x_index
	building.y_index = y_index

	if (type == "space") then
		local vertices = {
			-buildings.width / 2, 0,
			0, -buildings.width / 4,
			buildings.width / 2, 0,
			0, buildings.width / 4
		}

		local space = display.newPolygon(0, 0, vertices)
		space:setFillColor(0.5, 0.5, 0.5)
		space:setStrokeColor(0.1, 0.1, 0.1)
		space.strokeWidth = 2

		function building.update(frame_index, frame_range)
			return
		end

		-- Add an event listener to the space, to create a new building
		function building:tap(event)
			-- Just create a random building for now, because I don't have time to do this properly
			local random_type = math.random(4)

			if (random_type == 1) then
				local substation = buildings.newBuilding(building.group, building.x_index, building.y_index, "substation", 1)
				building.group:remove(building)
				grid[building.x_index][building.y_index] = substation
				substation.x = (screenW / 2) + ((building.x_index + building.y_index - (buildings.grid_width + 1.5)) * ((buildings.width + buildings.grid_spacing) / 2))
				substation.y = (screenH / 2) + ((building.x_index - building.y_index) * ((buildings.width + buildings.grid_spacing) / 4))
			elseif (random_type == 2) then
				local residential = buildings.newBuilding(building.group, building.x_index, building.y_index, "residential", 1)
				building.group:remove(building)
				grid[building.x_index][building.y_index] = residential
				residential.x = (screenW / 2) + ((building.x_index + building.y_index - (buildings.grid_width + 1.5)) * ((buildings.width + buildings.grid_spacing) / 2))
				residential.y = (screenH / 2) + ((building.x_index - building.y_index) * ((buildings.width + buildings.grid_spacing) / 4))
			elseif (random_type == 3) then
				local industrial = buildings.newBuilding(building.group, building.x_index, building.y_index, "industrial", 1)
				building.group:remove(building)
				grid[building.x_index][building.y_index] = industrial
				industrial.x = (screenW / 2) + ((building.x_index + building.y_index - (buildings.grid_width + 1.5)) * ((buildings.width + buildings.grid_spacing) / 2))
				industrial.y = (screenH / 2) + ((building.x_index - building.y_index) * ((buildings.width + buildings.grid_spacing) / 4))
			elseif (random_type == 4) then
				local commercial = buildings.newBuilding(building.group, building.x_index, building.y_index, "commercial", 1)
				building.group:remove(building)
				grid[building.x_index][building.y_index] = commercial
				commercial.x = (screenW / 2) + ((building.x_index + building.y_index - (buildings.grid_width + 1.5)) * ((buildings.width + buildings.grid_spacing) / 2))
				commercial.y = (screenH / 2) + ((building.x_index - building.y_index) * ((buildings.width + buildings.grid_spacing) / 4))
			end

			buildings.reorder()

			return true
		end

		building:insert(space)
	else
		local left_vertices = {
			-buildings.width / 2, 0,
			-buildings.width / 2, -buildings.height * level,
			0, (-buildings.height * level) + (buildings.width / 4),
			0, buildings.width / 4
		}
		local right_vertices = {
			0, buildings.width / 4,
			0, (-buildings.height * level) + (buildings.width / 4),
			buildings.width / 2, -buildings.height * level,
			buildings.width / 2, 0
		}
		local top_vertices = {
			-buildings.width / 2, -buildings.height * level,
			0, (-buildings.height * level) - (buildings.width / 4),
			buildings.width / 2, -buildings.height * level,
			0, (-buildings.height * level) + (buildings.width / 4)
		}

		local left = display.newPolygon(0, 0, left_vertices)
		left:setStrokeColor(0.1, 0.1, 0.1)
		left.strokeWidth = 2
		left.x = 0
		left.y = (-buildings.height * level) + (buildings.width / 4)
		building:insert(left)

		local right = display.newPolygon(0, 0, right_vertices)
		right:setStrokeColor(0.1, 0.1, 0.1)
		right.strokeWidth = 2
		right.x = buildings.width / 2
		right.y = (-buildings.height * level) + (buildings.width / 4)
		building:insert(right)

		local top = display.newPolygon(0, 0, top_vertices)
		top:setStrokeColor(0.1, 0.1, 0.1)
		top.strokeWidth = 2
		top.x = 0
		top.y = -buildings.height * level
		building:insert(top)

		building.level = level
		building.max_fill_level = 100 * level
		building.fill_level = 0

		if (type == "reactor") then
			building.fill_level = building.max_fill_level

			-- Add an event listener to the reactor, to upgrade it
			function building:tap(event)
				-- Just upgrade for now, because I don't have time to do this properly
				local reactor = buildings.newBuilding(building.group, building.x_index, building.y_index, "reactor", building.level + 1)
				building.group:remove(building)
				grid[building.x_index][building.y_index] = reactor
				reactor.x = (screenW / 2) + ((building.x_index + building.y_index - (buildings.grid_width + 1.5)) * ((buildings.width + buildings.grid_spacing) / 2))
				reactor.y = (screenH / 2) + ((building.x_index - building.y_index) * ((buildings.width + buildings.grid_spacing) / 4))

				buildings.reorder()

				return true
			end
		elseif (type == "substation") then
			function building.setEnergyStored(energy_stored)
				building.fill_level = energy_stored
			end

			building.energy_capacity = building.max_fill_level

			-- Add an event listener to the substation, to upgrade it or destroy it
			function building:tap(event)
				-- Just upgrade or destroy randomly for now, because I don't have time to do this properly
				local random_action = math.random(2)

				if (random_action == 1) then
					local substation = buildings.newBuilding(building.group, building.x_index, building.y_index, "substation", building.level + 1)
					building.group:remove(building)
					grid[building.x_index][building.y_index] = substation
					substation.x = (screenW / 2) + ((building.x_index + building.y_index - (buildings.grid_width + 1.5)) * ((buildings.width + buildings.grid_spacing) / 2))
					substation.y = (screenH / 2) + ((building.x_index - building.y_index) * ((buildings.width + buildings.grid_spacing) / 4))
				elseif (random_action == 2) then
					local space = buildings.newSpace(building.group, building.x_index, building.y_index)
					building.group:remove(building)
					grid[building.x_index][building.y_index] = space
					space.x = (screenW / 2) + ((building.x_index + building.y_index - (buildings.grid_width + 1.5)) * ((buildings.width + buildings.grid_spacing) / 2))
					space.y = (screenH / 2) + ((building.x_index - building.y_index) * ((buildings.width + buildings.grid_spacing) / 4))
				end

				buildings.reorder()

				return true
			end
		elseif ((type == "residential") or (type == "industrial") or (type == "commercial")) then
			building.energy_draw = building.max_fill_level / 10

			function building.updateFillLevel(energy_stored, energy_capacity)
				if (building.disabled) then
					return
				end

				if (energy_stored >= energy_capacity) then
					building.fill_level = math.min(building.fill_level + building.energy_draw, building.max_fill_level)
				elseif (energy_stored > 0) then
					building.fill_level = math.min(building.fill_level + (building.energy_draw / 10), building.max_fill_level)
				else
					building.fill_level = math.max(building.fill_level - building.energy_draw, 0)
				end
			end

			-- Add an event listener to the residential building, to upgrade it, disable it or destroy it
			function building:tap(event)
				-- Just upgrade, disable/enable or destroy randomly for now, because I don't have time to do this properly
				local random_action = math.random(3)

				if (random_action == 1) then
					local residential = buildings.newBuilding(building.group, building.x_index, building.y_index, building.type, building.level + 1)
					building.group:remove(building)
					grid[building.x_index][building.y_index] = residential
					residential.x = (screenW / 2) + ((building.x_index + building.y_index - (buildings.grid_width + 1.5)) * ((buildings.width + buildings.grid_spacing) / 2))
					residential.y = (screenH / 2) + ((building.x_index - building.y_index) * ((buildings.width + buildings.grid_spacing) / 4))
				elseif (random_action == 2) then
					local space = buildings.newSpace(building.group, building.x_index, building.y_index)
					building.group:remove(building)
					grid[building.x_index][building.y_index] = space
					space.x = (screenW / 2) + ((building.x_index + building.y_index - (buildings.grid_width + 1.5)) * ((buildings.width + buildings.grid_spacing) / 2))
					space.y = (screenH / 2) + ((building.x_index - building.y_index) * ((buildings.width + buildings.grid_spacing) / 4))
				elseif (random_action == 3) then
					building.disabled = not building.disabled
				end

				buildings.reorder()

				return true
			end
		end

		function building.update(frame_index, frame_range)
			if (building.disabled) then
				frame_index = 0
			end

			local ratio = ((math.cos(2 * math.pi * frame_index / frame_range) + 3) / 4) * ((building.fill_level + 10) / (building.max_fill_level + 10))
			left:setFillColor(building_colours[type]["left"][1] * ratio, building_colours[type]["left"][2] * ratio, building_colours[type]["left"][3] * ratio, (ratio + 2) / 3)
			right:setFillColor(building_colours[type]["right"][1] * ratio, building_colours[type]["right"][2] * ratio, building_colours[type]["right"][3] * ratio, (ratio + 2) / 3)
			top:setFillColor(building_colours[type]["top"][1] * ratio, building_colours[type]["top"][2] * ratio, building_colours[type]["top"][3] * ratio, (ratio + 2) / 3)
			return
		end

		left:setFillColor(building_colours[type]["left"][1], building_colours[type]["left"][2], building_colours[type]["left"][3])
		right:setFillColor(building_colours[type]["right"][1], building_colours[type]["right"][2], building_colours[type]["right"][3])
		top:setFillColor(building_colours[type]["top"][1], building_colours[type]["top"][2], building_colours[type]["top"][3])
	end

	building:addEventListener("tap", building)
	group:insert(building)

	return building
end

function buildings.newSpace(group, x_index, y_index)
	return buildings.newBuilding(group, x_index, y_index, "space", 0)
end

return buildings