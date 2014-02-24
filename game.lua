-----------------------------------------------------------------------------------------
--
-- game.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require("storyboard")
local scene = storyboard.newScene()

-- Include Corona libraries
local math = require "math"
local timer = require "timer"
local widget = require "widget"

-- Include the coins library
local buildings = require "buildings"

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH = display.contentWidth, display.contentHeight

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

local background = nil
local scrollView = nil
local last_x = 0
local last_y = 0

local grid = {}
local reactor_x = (buildings.grid_width + 1) / 2
local reactor_y = (buildings.grid_width + 1) / 2

local projection = "isometric"
local rotation = 0
local num_rotations = 4

local flash_index = 0
local flash_range = 60

local initialized = false

local energy_update_interval = 10
local energy_update_steps = 100
local next_energy_update = energy_update_interval

local energy_generation = 100
local energy_generation_text = nil
local energy_stored = 0
local energy_stored_text = nil
local energy_draw = 0
local energy_draw_text = nil

local group = nil

-- Called when the scene's view does not exist:
function scene:createScene(event)
	group = self.view
	display.setDefault("anchorX", 0)
	display.setDefault("anchorY", 0)

	-- Create a background
	local background = display.newRect(0, 0, screenW, screenH)
	background:setFillColor(0.8, 0.8, 0.8)

	-- Add an event listener to the background, to cancel controller events
	function background:touch(event)
		if (event.phase == "moved") then
			scrollView.x = scrollView.x + event.x - last_x
			scrollView.y = scrollView.y + event.y - last_y

			scrollView.x = math.max(math.min(scrollView.x, screenW), -screenW)
			scrollView.y = math.max(math.min(scrollView.y, screenH), -screenH)
		end

		last_x = event.x
		last_y = event.y

		return true
	end

	background:addEventListener("touch", background)
	group:insert(background)

	scrollView = display.newGroup()
	group:insert(scrollView)

	-- Initialize the building spaces
	buildings.init(grid)
	local x_index = 1

	while (x_index <= buildings.grid_width) do
		local y_index = buildings.grid_width
		grid[x_index] = {}

		while (y_index >= 1) do
			if ((x_index == reactor_x) and (y_index == reactor_y)) then
				local reactor = buildings.newBuilding(scrollView, x_index, y_index, "reactor", 1)
				reactor.x = (screenW / 2) + ((x_index + y_index - (buildings.grid_width + 1.5)) * ((buildings.width + buildings.grid_spacing) / 2))
				reactor.y = (screenH / 2) + ((x_index - y_index) * ((buildings.width + buildings.grid_spacing) / 4))

				grid[x_index][y_index] = reactor
			elseif ((x_index == reactor_x + 1) and (y_index == reactor_y)) then
				local substation = buildings.newBuilding(scrollView, x_index, y_index, "substation", 1)
				substation.x = (screenW / 2) + ((x_index + y_index - (buildings.grid_width + 1.5)) * ((buildings.width + buildings.grid_spacing) / 2))
				substation.y = (screenH / 2) + ((x_index - y_index) * ((buildings.width + buildings.grid_spacing) / 4))

				grid[x_index][y_index] = substation
			elseif ((x_index == reactor_x) and (y_index == reactor_y - 1)) then
				local residential = buildings.newBuilding(scrollView, x_index, y_index, "residential", 2)
				residential.x = (screenW / 2) + ((x_index + y_index - (buildings.grid_width + 1.5)) * ((buildings.width + buildings.grid_spacing) / 2))
				residential.y = (screenH / 2) + ((x_index - y_index) * ((buildings.width + buildings.grid_spacing) / 4))

				grid[x_index][y_index] = residential
			else
				local space = buildings.newSpace(scrollView, x_index, y_index)
				space.x = (screenW / 2) + ((x_index + y_index - (buildings.grid_width + 1.5)) * ((buildings.width + buildings.grid_spacing) / 2))
				space.y = (screenH / 2) + ((x_index - y_index) * ((buildings.width + buildings.grid_spacing) / 4))

				grid[x_index][y_index] = space
			end

			y_index = y_index - 1
		end

		x_index = x_index + 1
	end

	-- Initialize the HUD
	display.setDefault("anchorX", 0)
	display.setDefault("anchorY", 0)

	energy_generation_text = display.newText("Energy generation: " .. energy_generation, 20, 20, native.systemFontBold, 20)
	energy_generation_text:setFillColor(0)
	energy_stored_text = display.newText("Energy stored: " .. energy_stored, 20, 50, native.systemFontBold, 20)
	energy_stored_text:setFillColor(0)
	energy_draw_text = display.newText("Energy draw: " .. energy_draw, 20, 80, native.systemFontBold, 20)
	energy_draw_text:setFillColor(0)

	initialized = true
end

-- Utility function to calculate the energy draw
local function getEnergyDraw()
	-- Spin through the buildings
	local x_index = 1
	energy_draw = 0

	while (x_index <= buildings.grid_width) do
		local y_index = 1

		while (y_index <= buildings.grid_width) do
			if ((grid[x_index][y_index].energy_draw) and (not grid[x_index][y_index].disabled)) then
				energy_draw = energy_draw + grid[x_index][y_index].energy_draw
			end

			y_index = y_index + 1
		end

		x_index = x_index + 1
	end
end

-- Utility function to determine total energy storage capacity
local function getEnergyStorageCapacity()
	-- Spin through the buildings to determine capacity
	local x_index = 1
	energy_capacity = 0

	while (x_index <= buildings.grid_width) do
		local y_index = 1

		while (y_index <= buildings.grid_width) do
			if (grid[x_index][y_index].energy_capacity) then
				energy_capacity = energy_capacity + grid[x_index][y_index].energy_capacity
			end

			y_index = y_index + 1
		end

		x_index = x_index + 1
	end

	return energy_capacity
end

-- Utility function to set the energy stored in each building
local function setEnergyStored(energy_capacity)
	-- Spin through the buildings to set stored energy
	x_index = 1

	while (x_index <= buildings.grid_width) do
		local y_index = 1

		while (y_index <= buildings.grid_width) do
			if (grid[x_index][y_index].energy_capacity) then
				grid[x_index][y_index].setEnergyStored((energy_stored * grid[x_index][y_index].energy_capacity) / energy_capacity)
			elseif (grid[x_index][y_index].energy_draw) then
				grid[x_index][y_index].updateFillLevel(energy_stored, energy_capacity)
			end

			y_index = y_index + 1
		end

		x_index = x_index + 1
	end
end

-- Function to update the screen
local function updateScreen(event)
	if (not initialized) then
		return
	end

	-- Update the flash stage
	flash_index = flash_index + 1

	if (flash_index > flash_range) then
		flash_index = 0
	end

	-- Update the buildings
	local x_index = 1

	while (x_index <= buildings.grid_width) do
		local y_index = 1

		while (y_index <= buildings.grid_width) do
			grid[x_index][y_index].update(flash_index, flash_range)
			y_index = y_index + 1
		end

		x_index = x_index + 1
	end

	-- Update the HUD
	next_energy_update = next_energy_update - 1

	-- Update energy values
	if (next_energy_update <= 0) then
		next_energy_update = energy_update_interval
		energy_generation = grid[reactor_x][reactor_y].level * 100
		getEnergyDraw()

		local energy_capacity = getEnergyStorageCapacity()
		energy_stored = math.max(math.min(energy_stored + ((energy_generation - energy_draw) / energy_update_steps), energy_capacity), 0)
		setEnergyStored(energy_capacity)

		energy_generation_text.text = "Energy generation: " .. energy_generation
		energy_generation_text.x = 20
		energy_stored_text.text = "Energy stored: " .. energy_stored
		energy_stored_text.x = 20
		energy_draw_text.text = "Energy draw: " .. energy_draw
		energy_draw_text.x = 20
	end
end

-- Add a Runtime listener to update the player location
Runtime:addEventListener("enterFrame", updateScreen)

-- Called immediately after scene has moved onscreen:
function scene:enterScene(event)
	local group = self.view
end

-- Called when scene is about to move offscreen:
function scene:exitScene(event)
	local group = self.view
	paused = true
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene(event)
	local group = self.view

	package.loaded[math] = nil
	package.loaded[timer] = nil
	package.loaded[widget] = nil

	math = nil
	timer = nil
	widget = nil
end

-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener("createScene", scene)

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener("enterScene", scene)

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener("exitScene", scene)

scene:addEventListener("overlayBegan", scene)
scene:addEventListener("overlayEnded", scene)

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener("destroyScene", scene)

-----------------------------------------------------------------------------------------

return scene