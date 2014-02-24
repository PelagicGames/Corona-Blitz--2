-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require("storyboard")
local scene = storyboard.newScene()

-- Include Corona's "widget" library
local widget = require "widget"

--------------------------------------------

-- Buttons
local playButton

-- Handle play button
local function onPlayButtonRelease()
	-- Play the game
	storyboard.gotoScene("game", "fade", 500)
	return true
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

	-- Display a background image
	local background = display.newImageRect("Background.png", display.contentWidth, display.contentHeight)
	background.anchorX = 0
	background.anchorY = 0
	background.x, background.y = 0, 0

	-- Display the logo
	local logo = display.newText("Settlement", 0, 0, native.systemFontBold, 60)
	logo.anchorX = 0.5
	logo.anchorY = 0.5
	logo.x = display.contentWidth / 2
	logo.y = (3 * display.contentHeight) / 8

	-- Create a widget button to play the game
	playButton = widget.newButton{
		label="Play",
		labelColor={default={0}, over={255}},
		font=native.systemFontBold,
		fontSize = 28,
		defaultFile="Button.png",
		overFile="ButtonPressed.png",
		width=240, height=80,
		onRelease=onPlayButtonRelease
	}
	playButton.anchorX = 0.5
	playButton.anchorY = 0.5
	playButton.x = display.contentWidth * 0.5
	playButton.y = (display.contentHeight / 2) + 100

	-- All display objects must be inserted into group
	group:insert(background)
	group:insert(logo)
	group:insert(playButton)
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view

	if playButton then
		playButton:removeSelf()
		playButton = nil
	end
end

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener("createScene", scene)

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener("enterScene", scene)

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener("exitScene", scene)

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener("destroyScene", scene)

-----------------------------------------------------------------------------------------

return scene