ETL_xp_gains = {}
ETL_frame_coordinates = { x = 0, y = 0 }

local REFRESH_INTERVAL = 1

local update_display

local last_update = 0

function ETL_on_xp_gain()
    local _, _, xp_part = strfind(arg1, '(%d+)')
    local gained_xp = tonumber(xp_part)
    tinsert(ETL_xp_gains, { t=GetTime(), xp=gained_xp })
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
    ETL_frame_html:SetText(string.format(
        [[
        <html>
        <body>
            <h1 align="center">ETL %s</h1>
            <br/>
            <h2 align="center">XP/minute %i</h2>
        </body>
        </html>
        ]],
        xp_per_minute > 0 and string.format('%im', etl_minutes) or 'N/A',
        xp_per_minute
    ))
end
