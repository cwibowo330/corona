-- File: scene_game.lua
-- Desc: allow player to play game

local composer = require( "composer" )

local scene = composer.newScene()

local widget = require "widget"
widget.setTheme("widget_theme_ios7")


local physics = require "physics"
physics.start()
physics.setGravity( -3, 7 )

local playerSheetData = {
    width = 120,
    height = 175,
    numFrames = 8,
    sheetContentWidth = 960,
    sheetContentHeight = 175
}
local playerSheet = graphics.newImageSheet("images/characters/ninja.png", playerSheetData)
local playerSequenceData = {
    {name = "shooting", start= 1, count = 6, time = 300, loopCount = 1},
    {name = "hurt", start= 7, count = 2, time = 200, loopCount = 1}
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

local player, tmr_playershoot, playerMoney  -- forward declares
local playerShootSpeed = 1250   - ( user.shootlevel*100 ) -- determines how fast the player will shoot
local playerEarnMoney = 10 -- how much money is earned when a pirate is hit

local lives = {} -- table that will hold the lives object
local livesCount = 1 + (user.liveslevel) -- the number of lives the player has

local bullets = {} -- table that will hold the bullet objects
local bulletCounter = 0 -- number of bullets shot
local bulletTransition = {} -- table to hold bullet transitions
local bulletTransitionCounter = 0 -- number of bullet transitions made

local enemy = {} -- table to hold enemy objects
local enemyCounter = 0 -- number of enemies sent
local enemySendSpeed = 75 -- how often to send the enemies
local enemyTravelSpeed = 3500 -- how fast enemies travel across the scree
local enemyIncrementSpeed = 1.5 -- how much to increase the enemy speed
local enemyMaxSendSpeed = 20 -- max send speed, if this is not set, the enemies could just be one big flood 

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

    local function playerShoot ()
        audio.play(_THROW)

        bulletCounter = bulletCounter + 1
        bullets[bulletCounter] = display.newImageRect(sceneGroup, "images/gamescreen/shuriken.png", 64, 64)
        bullets[bulletCounter].x = player.x - (player.width * 0.5)
        bullets[bulletCounter].y = player.y 
        bullets[bulletCounter].id = "bullet"
        physics.addBody(bullets[bulletCounter])
        bullets[bulletCounter].isSensor = true

        bulletTransition[bulletCounter] = transition.to(bullets[bulletCounter], {
                x=350, 
                time=1000, 
                onComplete=function(self) 
                    if (self ~= nil) then
                        display.remove(self)
                    end
                end
            })

        player:setSequence("shooting")
        player:play()
    end

    local function onLeftButton (event)
        if (event.phase == "ended") then
            audio.play(_CLICK)
            player.x = player.x - 20
            
        end
    end

    local function onRightButton (event)
        if (event.phase == "ended") then
            audio.play(_CLICK)
            player.x = player.x + 20
        end
    end

    local function sendEnemies ()

    end

    local function playerHit ()

    end

    local function enemyHit ()

    end

    local function onCollision ()

    end

    local function onPauseTouch ()

    end

    local function onGameOver ()

    end

    local background = display.newImageRect(sceneGroup, "images/gamescreen/story-background2.png", 1425, 925)
        background.x = _CX; background.y = _CY;

    lane = display.newImageRect(sceneGroup, "images/gamescreen/story-grass.png", 1425, 150)
        lane.x = _CX; lane.y = _B - 80;

    floor1 = display.newRect(sceneGroup, _CW * 0.8, _B - 75, 200, 100)
    physics.addBody(floor1, "static", {friction=0.5, bounce=0.3})

    floor2 = display.newRect(sceneGroup, _CW * 0.4, _B - 300, 50, 100)
    physics.addBody(floor2, "static", {friction=0.5, bounce=0.3})

    floor3 = display.newRect(sceneGroup, _CW * 0.2, _B - 600, 100, 100)
    physics.addBody(floor3, "static", {friction=0.5, bounce=0.3})

    -- add buttons to game
   leftButton = widget.newButton {
        width = 125,
        height = 125,
        defaultFile = "images/gamescreen/ctrl-left-btn.png",
        overFile = "images/menuscreen/btn_play_over.png",
        onEvent = onLeftButton
    }
    leftButton.x = _L + 200
    leftButton.y = _B * 0.85
    sceneGroup:insert(leftButton) 

    rightButton = widget.newButton {
        width = 125,
        height = 125,
        defaultFile = "images/gamescreen/ctrl-right-btn.png",
        overFile = "images/menuscreen/btn_play_over.png",
        onEvent = onRightButton
    }
    rightButton.x = leftButton.width * 2
    rightButton.y = _B * 0.85
    sceneGroup:insert(rightButton) 

    -- add lives to game
    for i=1, livesCount do
        lives[i] = display.newImageRect(sceneGroup, "images/gamescreen/heart.png", 50, 51)
        lives[i].x = _L + (i*65) - 25
        lives[i].y = _T + lives[i].height
    end

    btn_pause = display.newImageRect(sceneGroup, "images/gamescreen/btn_pause.png", 77, 71)
        btn_pause.x = _R - 100; btn_pause.y = _T + (btn_pause.height);
        btn_pause:addEventListener("touch", onPauseTouch)

    player = display.newSprite(playerSheet, playerSequenceData)
    player.x = _R - (player.width * 1.2)
    --player.y = lane.y - 150
    player.y = _T
    player.id = "player"
    sceneGroup:insert(player)
    physics.addBody(player, "dynamic", { density=3.0, friction=0.5, bounce=0.3 })
    player.isFixedRotation = true

    local function jumpPlayer(event)
        player:applyLinearImpulse( -20, -120, player.x, player.y )
    end
    player:addEventListener("touch", jumpPlayer)
    -- makes physics boundaries viewable
    physics.setDrawMode("hybrid")

    playerWall = display.newRect(sceneGroup, 0,0, 50, _CH)
        playerWall.x = _R + 75
        playerWall.y = _CY
        playerWall.id = "player"
        physics.addBody(playerWall, "static")

    playerMoney = display.newText(sceneGroup, "$"..user.money, 0, 0, _FONT, 72)
        playerMoney.anchorX = 1
        playerMoney.x = _R - 5
        playerMoney.y = _B - 50

    tmr_playershoot = timer.performWithDelay(playerShootSpeed, playerShoot, 0)
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
