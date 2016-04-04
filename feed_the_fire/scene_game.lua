local composer = require( "composer" )

local scene = composer.newScene()

local widget = require "widget"
widget.setTheme("widget_theme_ios7")

local physics = require "physics"
physics.start()
physics.setGravity(0, 0)

local playerSheetData = {
    width = 120,
    height = 175,
    numFrames = 8,
    sheetContentWidth = 960,
    sheetContentHeight = 175
}
local playerSheet = graphics.newImageSheet("images/characters/ninja.png", playerSheetData)
local playerSequenceData = {
    {name = "hurt", start= 1, count = 2, time = 200, loopCount = 1}
}

local pirateSheetData = {
    width = 185,
    height = 195,
    numFrames = 8,
    sheetContentWidth = 1480,
    sheetContentHeight = 195
}
local pirateSheet1 = graphics.newImageSheet("images/characters/pirate1.png", pirateSheetData)
local pirateSheet2 = graphics.newImageSheet("images/characters/pirate2.png", pirateSheetData)
local pirateSheet3 = graphics.newImageSheet("images/characters/pirate3.png", pirateSheetData)
local pirateSequenceData = {
    {name = "running", start= 1, count = 8, time = 575, loopCount = 0}
}

local poofSheetData = {
    width = 165,
    height = 180,
    numFrames = 5,
    sheetContentWidth = 825,
    sheetContentHeight = 180
}
local poofSheet = graphics.newImageSheet("images/characters/poof.png", poofSheetData)
local poofSequenceData = {
    {name = "poof", start= 1, count = 5, time = 250, loopCount = 1}
}
-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called
-- -----------------------------------------------------------------------------------------------------------------

-- local forward references should go here
local lane = {} -- create a table that will hold the four lanes

local player, playerScore  -- forward declares
local playerEarnScorePoints = 10 -- how much money is earned when a pirate is hit

local enemy = {} -- table to hold enemy objects
local enemyCounter = 0 -- number of enemies sent
local enemySendSpeed = 100 -- how often to send the enemies
local enemyTravelSpeed = 3500 -- how fast enemies travel across the scree
local enemyIncrementSpeed = 1.5 -- how much to increase the enemy speed
local enemyMaxSendSpeed = 5 -- max send speed, if this is not set, the enemies could just be one big flood 

local poof = {}
local poofCounter = 0

local timeCounter = 0 -- how much time has passed in the game
local pauseGame = false -- is the game paused?
local pauseBackground, btn_pause, pauseText, pause_returnToMenu, pauseReminder -- forward declares

local onGameOver, gameOverBox, gameoverBackground, btn_returnToMenu -- forward declare
-- -------------------------------------------------------------------------------


-- "scene:create()"
function scene:create( event )

    local sceneGroup = self.view

    -- Initialize the scene here
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.
    local function returnToMenu (event)
        if(event.phase == "ended") then
            audio.play(_CLICK)
            composer.gotoScene("scene_menu", "slideRight")
        end
    end

    local function onLaneTouch (event)
        local id = event.target.id

        if (event.phase == "began") then
            transition.to(player, {x=lane[id].x, time=125})
        end
    end

    local function sendEnemies ()
        timeCounter = timeCounter + 1
        if((timeCounter%enemySendSpeed) == 0) then
            enemyCounter = enemyCounter + 1
            enemySendSpeed = enemySendSpeed - enemyIncrementSpeed
            if (enemySendSpeed <= enemyMaxSendSpeed) then
                enemySendSpeed = enemyMaxSendSpeed
            end

            local temp = math.random(1,3)

            if (temp == 1) then
                enemy[enemyCounter] = display.newSprite(pirateSheet1, pirateSequenceData)
            elseif(temp == 2) then
                enemy[enemyCounter] = display.newSprite(pirateSheet2, pirateSequenceData)
            else
                enemy[enemyCounter] = display.newSprite(pirateSheet3, pirateSequenceData)
            end

            enemy[enemyCounter].x = lane[math.random(1, #lane)].x
            enemy[enemyCounter].y = _T + 50
            enemy[enemyCounter].id = "enemy"
            enemy[enemyCounter].isFixedRotation = true

            transition.to(enemy[enemyCounter], {y=_CH, time=enemyTravelSpeed, onComplete=function(self)
                    if(self~=nil) then display.remove(self); end
                end})

            enemy[enemyCounter]:setSequence("running")
            enemy[enemyCounter]:play()
        end
    end

    local function playerHit ()

    end

    local function onCollision ()

    end

    local function onPauseTouch ()

    end

    function onGameOver ()

    end

    local background = display.newImageRect(sceneGroup, "images/gamescreen/story-background-factory.jpg", 1425, 925)
        background.x = _CX; background.y = _CY;

    for i=1, 20 do 
        lane[i] = display.newRect(sceneGroup, _L, _B, 100, 200)
        lane[i].x = (100*i) - 200
        lane[i].y = _B - 100
        lane[i].id = i
        lane[i].alpha = 0.5
        lane[i]:setFillColor(1,1,1)
        lane[i]:addEventListener("touch", onLaneTouch)
    end

    btn_pause = display.newImageRect(sceneGroup, "images/gamescreen/btn_pause.png", 77, 71)
        btn_pause.x = _R - 100; btn_pause.y = _T + (btn_pause.height);
        btn_pause:addEventListener("touch", onPauseTouch)
    
    player = display.newSprite(playerSheet, playerSequenceData)
        player.x = lane[1].x + player.width
        player.y = _B - (player.height * .75)
        player.id = "player"
        sceneGroup:insert(player)
        physics.addBody(player)

    -- allows to be able to see invisible physics body
    physics.setDrawMode("hybrid")

    playerFloor = display.newRect(sceneGroup, _L, _B, 1425, 100)
        playerFloor.x = _CX
        playerFloor.y = _B + 10
        playerFloor.id = "player"
        physics.addBody(playerFloor)

    playerScore = display.newText(sceneGroup, user.score, 0, 0, _FONT, 70)
        playerScore.anchorX = 0
        playerScore.x = _L + 50
        playerScore.y = _T + 50
        playerScore:setFillColor( gray )

    Runtime:addEventListener("enterFrame", sendEnemies)
end


-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen)
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen
        -- Insert code here to make the scene come alive
        -- Example: start timers, begin animation, play audio, etc.
    end
end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen)
        -- Insert code here to "pause" the scene
        -- Example: stop timers, stop animation, stop audio, etc.
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view
    -- Insert code here to clean up the scene
    -- Example: remove display objects, save state, etc.
end


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene