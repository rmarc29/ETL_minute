ETL_xp_gains = {}
ETL_frame_coordinates = { x = 0, y = 0 }

local REFRESH_INTERVAL = 1

local update_display

local last_update = 0

function ETL_on_xp_gain()
    local _, _, xp_part = strfind(arg1, '(%d+)')
    local gained_xp = tonumber(xp_part)
    if gained_xp then
        tinsert(ETL_xp_gains, { t = GetTime(), xp = gained_xp })
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
    local current_time = GetTime()
    if current_time - last_update > REFRESH_INTERVAL then
        last_update = current_time

        -- Remove XP gains older than 60 seconds
        while ETL_xp_gains[1] and current_time - ETL_xp_gains[1].t > 60 do
            tremove(ETL_xp_gains, 1)
        end

        -- Calculate XP per minute
        local xp_per_minute = 0
        for _, xp_gain in ipairs(ETL_xp_gains) do
            xp_per_minute = xp_per_minute + xp_gain.xp
        end

        -- Avoid division by zero
        local etl_minutes = xp_per_minute > 0 and math.ceil((UnitXPMax('player') - UnitXP('player')) / xp_per_minute) or 0

        -- Update display
        update_display(xp_per_minute, etl_minutes)
    end
end

function update_display(xp_per_minute, etl_minutes)
    ETL_frame_html:SetText(string.format(
        [[
        <html>
        <body>
            <h1 align="center">ETL %s</h1>
            <br/>
            <h2 align="center">XP/min %i</h2>
        </body>
        </html>
        ]],
        xp_per_minute > 0 and string.format('%im', etl_minutes) or 'N/A',
        xp_per_minute
    ))
end
