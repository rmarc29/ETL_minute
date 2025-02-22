ETL_xp_gains = {}
ETL_frame_coordinates = { x = 0, y = 0 }

local REFRESH_INTERVAL = 1
local last_update = 0
local font_applied = false -- New flag to check if font was applied

local function ETL_SetCustomFont()
    local fontPath = "Interface\\AddOns\\ETL_minute\\Enchanted_Land.ttf"
    local fontSize = 14  -- Adjust as needed

    if ETL_CustomFontString then
        local success = ETL_CustomFontString:SetFont(fontPath, fontSize, "OUTLINE")
        
        if not success then
            DEFAULT_CHAT_FRAME:AddMessage("|cffff0000ETL: Failed to load custom font. Falling back to default.|r")
            ETL_CustomFontString:SetFont("Fonts\\FRIZQT__.TTF", fontSize, "OUTLINE")
        end

        ETL_CustomFontString:SetText("ETL Loaded")
        font_applied = true -- Mark font as applied
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000ETL: FontString not found!|r")
    end
end

function ETL_on_load()
    local n = getn(ETL_xp_gains)
    if n > 0 then
        local t0 = ETL_xp_gains[n]
        for _, xp_gain in ipairs(ETL_xp_gains) do
            xp_gain.t = xp_gain.t - t0
        end
    end
end

function ETL_on_update()
    if not font_applied then
        ETL_SetCustomFont() -- Apply font once when the UI is ready
    end

    if GetTime() - last_update > REFRESH_INTERVAL then
        last_update = GetTime()
        while ETL_xp_gains[1] and GetTime() - ETL_xp_gains[1].t > 60 do
            tremove(ETL_xp_gains, 1)
        end
        local xp_per_minute = 0
        for _, xp_gain in ipairs(ETL_xp_gains) do
            xp_per_minute = xp_per_minute + xp_gain.xp
        end
        local etl = (UnitXPMax('player') - UnitXP('player')) / xp_per_minute
        local etl_minutes = math.ceil(etl)

        update_display(xp_per_minute, etl_minutes)
    end
end

function update_display(xp_per_minute, etl_minutes)
    if ETL_CustomFontString and ETL_CustomFontString:GetFont() then
        ETL_CustomFontString:SetText(string.format("ETL: %s\nXP/min: %i",
            xp_per_minute > 0 and string.format("%im", etl_minutes) or "N/A",
            xp_per_minute))
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000ETL: Font not set yet!|r")
    end
end
