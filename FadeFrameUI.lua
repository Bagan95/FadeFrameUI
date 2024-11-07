-- Frame and Variables for the Addon
local f = CreateFrame("Frame", "FadeUIFrame")
local fadeOutTimer = 0
local fadeOutDelay = 1.1  -- Time in seconds before fading out
local isFadingOut = false

-- Function to set the alpha of buff frames
local function FadeBuffs(alpha)
    for i = 0, 15 do  -- Buffs in Vanilla WoW are indexed from 0 to 15
        local buff = getglobal("BuffButton" .. i)
        if buff then
            buff:SetAlpha(alpha)  -- Set main buff frame alpha
            
            local icon = getglobal("BuffButton" .. i .. "Icon")
            local border = getglobal("BuffButton" .. i .. "Border")
            local duration = getglobal("BuffButton" .. i .. "Duration")
            
            if icon then icon:SetAlpha(alpha) end
            if border then border:SetAlpha(alpha) end
            if duration then duration:SetAlpha(alpha) end
        end
    end
end

-- Function to update the visibility and alpha of the UI
local function UpdateUIVisibility()
    local playerFrame = PlayerFrame
    local chatFrame = DEFAULT_CHAT_FRAME
    local actionBars = { MainMenuBar, MultiBarBottomLeft, MultiBarBottomRight, MultiBarRight, MultiBarLeft }
    local inCombat = UnitAffectingCombat("player")
    local fullHealth = UnitHealth("player") == UnitHealthMax("player")
    local fullMana = UnitMana("player") == UnitManaMax("player")
    local hasTarget = UnitExists("target")
    
    if inCombat or not fullHealth or not fullMana or hasTarget then
        -- Reset UI elements to fully visible if in combat, not full health/mana, or have a target
        playerFrame:SetAlpha(1)
        chatFrame:SetAlpha(1)
        Minimap:SetAlpha(1)
        MinimapZoneTextButton:SetAlpha(1)
        MinimapBorderTop:SetAlpha(1)
        GameTimeFrame:SetAlpha(1)
        MinimapToggleButton:SetAlpha(1)
        ChatFrameMenuButton:SetAlpha(1)
        
        for _, actionBar in ipairs(actionBars) do
            actionBar:SetAlpha(1)
        end
        
        FadeBuffs(1)  -- Set buff frames to 100%
        fadeOutTimer = 0
        isFadingOut = false
    else
        -- Fade out the UI elements if not in combat and at full health/mana without a target
        if not isFadingOut then
            fadeOutTimer = fadeOutTimer + 1  -- Increment the fade-out timer
            if fadeOutTimer >= fadeOutDelay then
                playerFrame:SetAlpha(0.2)
                Minimap:SetAlpha(0.2)
                MinimapZoneTextButton:SetAlpha(0.2)
                MinimapBorderTop:SetAlpha(0.2)
                GameTimeFrame:SetAlpha(0.2)
                MinimapToggleButton:SetAlpha(0.2)
                ChatFrameMenuButton:SetAlpha(0.2)
                
                for _, actionBar in ipairs(actionBars) do
                    actionBar:SetAlpha(0.2)
                end
                
                FadeBuffs(0.2)  -- Set buff frames to 20%
                isFadingOut = true  -- Set fading out status
            end
        end
    end
end

-- Event handler function
local function OnEvent(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        -- Force immediate fade when entering the world
        UpdateUIVisibility()
    else
        -- Update visibility based on health, mana, and combat status
        UpdateUIVisibility()
    end
end

-- Register events
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("UNIT_HEALTH")
f:RegisterEvent("UNIT_MANA")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_TARGET_CHANGED")

-- Set the script for event handling
f:SetScript("OnEvent", OnEvent)

-- Initial fade-out state check when the addon is loaded
UpdateUIVisibility()
