script_name('Ghetto Helper')

require('lib.moonloader')
local dlstatus = require('moonloader').download_status
local inicfg = require('inicfg')
local imgui = require('mimgui')
local addons = require('ADDONS')
local fa = require('fAwesome6_solid')
local sampev = require('lib.samp.events')
local rkeys = require('rkeys')
local hotkey = require 'mimgui_hotkeys'


local encoding = require("encoding")
encoding.default = 'CP1251'
u8 = encoding.UTF8
local function u8d(u8) return encoding.UTF8:decode(u8) end

--- VARIABLES ---
local sizeX, sizeY = getScreenResolution()
local window_page = 1
local currentPage = (fa["INFO"] .. u8' Информация')

local update_state = false
local update_url = 'https://raw.githubusercontent.com/Sleizyy/ghetto-helper/refs/heads/main/update.ini'
local update_path = getWorkingDirectory() .. '/update.ini'

local scriptVersion = 6
script_version('1.06')
local script_url = 'https://github.com/Sleizyy/ghetto-helper/raw/refs/heads/main/ghetto_helper.lua'
local script_path = thisScript().path

local ip, port

local always_not_active = false

local tag = '[{0008ff}Ghetto Assistant{ffffff}]: '

--========================--
local direct_cfg = 'moonloader\\config\\settings.ini'
local cfg = inicfg.load(inicfg.load({
    settings = {
        auto_update = false,
        auto_reconnect = false,
        sbiv_anim = false,
        fast_narko = false,
        sbiv_anim_key = "[85]",
        narko_key = "[91]"
    },
}, direct_cfg))
inicfg.save(cfg, direct_cfg)

--========================--


--========================--
local new = imgui.new
local render_window = new.bool(false)
local auto_update = new.bool(cfg.settings.auto_update)
local auto_reconnect = new.bool(cfg.settings.auto_reconnect)
local test_suka = new.bool(false)
local auto_reconnect_time = new.int()
local sbiv_anim = new.bool(cfg.settings.sbiv_anim)
local narko = new.bool(cfg.settings.fast_narko)
--========================--


--- SHORTCUTS ---
local cmd = sampRegisterChatCommand
local msg = sampAddChatMessage
local send = sampSendChat

--- MAIN ---
function main()
    while not isSampAvailable() do wait(0) end

    -- hotkey.RegisterHotKey('random hotkey 1', false, {}, function() sampAddChatMessage('pressed first hotkey', -1) end)
    -- sbiv_Hotkey = hotkey.RegisterHotKey('Sbiv Hotkey', true, decodeJson(cfg.settings.sbiv_anim_key), clearAnim)
    

    ip, port = sampGetCurrentServerAddress()

    cmd('gh', function()
        render_window[0] = not render_window[0]
    end)

    cmd('test', function ()
        msg(tag .. 'U8 Норм ворк', -1)
    end)

    cmd('save', function ()
        inicfg.save(cfg, direct_cfg)
    end)

    -- clearAnim()

    if auto_update[0] then
        downloadUrlToFile(update_url, update_path, function(id, status)
            if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                updateIni = inicfg.load(nil, update_path)
                if tonumber(updateIni.info.version) > scriptVersion then
                    msg(tag ..'Доступно обновление! Версия: ' .. updateIni.info.version_text,
                        -1)
                    update_state = true
                end
            end
        end)
    end

    while true do
        wait(0)
        if update_state and auto_update[0] then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    msg(tag..'Скрипт успешно обновлен­!', -1)
                    thisScript():reload()
                end
            end)
            break
        end
    end
end

--- HotKey --- 
narko_Hotkey = hotkey.RegisterHotKey('Narko Hotkey', true, decodeJson(cfg.settings.narko_key), function ()
    send('/usedrugs 3')
end)

sbiv_Hotkey = hotkey.RegisterHotKey('Sbiv Hotkey', true, decodeJson(cfg.settings.sbiv_anim_key), function ()
    if sbiv_anim[0] then
        lua_thread.create(function()
            while true do wait(0)
                if not sampIsCursorActive() then
                    if not isCharInAnyCar(PLAYER_PED) then clearCharTasksImmediately(PLAYER_PED) setPlayerControl(playerHandle, 1) freezeCharPosition(PLAYER_PED, false) restoreCameraJumpcut() end
                end break
            end
        end)
    end
end)

--- MIMGUI ---
local newFrame = imgui.OnFrame(function() return render_window[0] end,
    function(player)
        imgui.ApplyCustomStyle()
        local style = imgui.GetStyle()
        local colors = style.Colors
        local clr = imgui.Col
        local ImVec4 = imgui.ImVec4

        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2),
            imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(600, 300), imgui.Cond.FirstUseEver)
        imgui.Begin(u8 "##Main", _,
            imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize +
            imgui.WindowFlags.NoTitleBar)

        imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0.12, 0.12, 0.18, 1.00))
        imgui.BeginChild('##menu', imgui.ImVec2(150, 284), false)

        imgui.SetCursorPos(imgui.ImVec2(0, 25))
        imgui.PushFont(font)
        addons.AlignedText('Ghetto', 2)
        addons.AlignedText('Assistant', 2)
        imgui.PopFont()

        imgui.SetCursorPos(imgui.ImVec2(7, 125))
        imgui.BeginChild('##buttons', imgui.ImVec2(135, 150), true)

        if addons.AnimButton(fa["INFO"] .. u8 ' Информация##1', imgui.ImVec2(120, 30)) then
            window_page = 1
            currentPage = (fa["INFO"] .. u8 ' Информация')
        end
        if addons.AnimButton(fa["GEARS"] .. u8 ' Настройки##2', imgui.ImVec2(120, 30)) then
            window_page = 2
            currentPage = (fa["GEARS"] .. u8 ' Настройки')
        end
        if addons.AnimButton(fa["INFO"] .. u8 ' Для 9-10 Рангов##3', imgui.ImVec2(120, 30)) then
            window_page = 3
            currentPage = (fa["INFO"] .. u8 ' Для 9-10 Рангов')
        end
        if addons.AnimButton(fa["LIST"] .. u8 ' Функции##4', imgui.ImVec2(120, 30)) then
            window_page = 4
            currentPage = (fa["LIST"] .. u8 ' Функции')
        end
        imgui.EndChild() -- Buttons

        imgui.EndChild() -- Menu
        imgui.PopStyleColor()

        imgui.SetCursorPos(imgui.ImVec2(165, 8))
        imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0.12, 0.12, 0.18, 1.00))
        imgui.BeginChild('##currentPage', imgui.ImVec2(390, 30), false)
        imgui.SetCursorPos(imgui.ImVec2(0, 5))
        addons.AlignedText(currentPage, 2)
        imgui.EndChild()
        imgui.PopStyleColor()

        imgui.SetCursorPos(imgui.ImVec2(562, 8)) -- Close button
        addons.CloseButton('Close', render_window, 30)

        imgui.SetCursorPos(imgui.ImVec2(165, 48))
        imgui.BeginChild('##contains', imgui.ImVec2(420, 240), false) -- Main content

        if window_page == 1 then
            imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0.15, 0.15, 0.15, 1.00))
            imgui.BeginChild('##up_log', imgui.ImVec2(400, 150), false)
            imgui.PushFont(log_font)

            imgui.SetCursorPos(imgui.ImVec2(10, 0))
            imgui.Text(u8 'Версия: 1.00')

            imgui.PopFont()
            imgui.EndChild() -- Update Log
            imgui.PopStyleColor()

            imgui.NewLine()

            imgui.LinkText('https://vk.com/ses1404', fa["FILE"] .. u8 ' Тема на бластхаке')
            imgui.LinkText('https://vk.com/ses1404', fa["MESSAGE"] .. u8 ' Мой вк')
            imgui.LinkText('https://vk.com/ses1404', fa["FILE_CODE"] .. u8 ' Файл на ГитХабе')
        elseif window_page == 2 then -- Настройки
        
            imgui.Text(u8'Статус авто обновлений:') imgui.SameLine() imgui.SetCursorPos(imgui.ImVec2(350, 0)) 
            if addons.ToggleButton('##auto_update', auto_update) then
                cfg.settings.auto_update = auto_update[0]
                inicfg.save(cfg,direct_cfg)
            end
            imgui.SetCursorPos(imgui.ImVec2(315, 0)) 
            if addons.StateButton(always_not_active, fa["GEARS"], imgui.ImVec2(25,20)) then end

            imgui.SetCursorPos(imgui.ImVec2(0, 30))
            imgui.Text(u8'Авто реконнект:') imgui.SameLine() imgui.SetCursorPos(imgui.ImVec2(350, 30)) 
            if addons.ToggleButton('##auto_reconnect', auto_reconnect) then
                cfg.settings.auto_reconnect = auto_reconnect[0]
                inicfg.save(cfg,direct_cfg)
            end


            --             if imgui.BeginPopup(u8'inv') then
            -- imgui.Text(u8'Автоматически будет отправлять инвайт с РП отыгровкой. Активация: ПКМ + 1')
            -- if imgui.InputInt(u8'Ранг при инвайте', invrank) then
            --     cfg.config.InvRank = invrank.v
            --     inicfg.save(cfg,'Ghetto Helper/Ghetto Helper.ini')
            -- end
            -- if invrank.v <= 0 or invrank.v >= 9 then
            --     invrank.v = 1
            -- end
            -- imgui.EndPopup()


            imgui.SetCursorPos(imgui.ImVec2(315,30))
            if addons.StateButton(auto_reconnect[0], fa["GEARS"], imgui.ImVec2(25,20)) then end
            
            imgui.SetCursorPos(imgui.ImVec2(0, 60))
            
            imgui.Text(u8'Тест сука:') imgui.SameLine() imgui.SetCursorPos(imgui.ImVec2(350,60))  addons.ToggleButton('##test_suka', test_suka)
            imgui.SetCursorPos(imgui.ImVec2(315, 60))
            if addons.StateButton(test_suka[0], fa["GEAR"], imgui.ImVec2(25,20)) then
                msg(tag .. "Сука блять", -1)
            end


        elseif window_page == 3 then -- Функции рук-ства
            imgui.Text('2')
        elseif window_page == 4 then -- Функции
        
            imgui.Text(u8'Сбив клавишей:')
            imgui.SameLine()
            imgui.SetCursorPos(imgui.ImVec2(350,0))
            if addons.ToggleButton('##sbiv_anim', sbiv_anim) then
                cfg.settings.sbiv_anim = sbiv_anim[0]
                inicfg.save(cfg, direct_cfg)
            end

            imgui.SetCursorPos(imgui.ImVec2(315,0))
            if sbiv_anim[0] then
                if sbiv_Hotkey:ShowHotKey() then
                    cfg.settings.sbiv_anim_key = encodeJson(sbiv_Hotkey:GetHotKey())
                    inicfg.save(cfg, direct_cfg)
                end
            end

            imgui.SetCursorPos(imgui.ImVec2(0,30))
            imgui.Text(u8'Бинд на использование наркотиков:')
            imgui.SetCursorPos(imgui.ImVec2(350, 30))
            if addons.ToggleButton('##narko', narko) then
                cfg.settings.fast_narko = narko[0]
                inicfg.save(cfg,direct_cfg)
            end

            imgui.SetCursorPos(imgui.ImVec2(315,30))
            if narko[0] then
                if narko_Hotkey:ShowHotKey() then
                    cfg.settings.narko_key = encodeJson(narko_Hotkey:GetHotKey())
                    inicfg.save(cfg, direct_cfg)
                end
            end


        end

        imgui.EndChild()

        imgui.End()
    end)

imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
    fa.Init()
    local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/Montserrat-Bold.ttf', 32, _, glyph_ranges)
    log_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/RobotoMono-Regular.ttf', 15, _,
        glyph_ranges)
end)

function imgui.ApplyCustomStyle()
    local style                      = imgui.GetStyle()
    local colors                     = style.Colors

    colors[imgui.Col.WindowBg]       = imgui.ImVec4(0.13, 0.14, 0.17, 1.00)
    colors[imgui.Col.TitleBg]        = imgui.ImVec4(0.10, 0.11, 0.13, 1.00)
    colors[imgui.Col.TitleBgActive]  = imgui.ImVec4(0.16, 0.17, 0.20, 1.00)
    colors[imgui.Col.FrameBg]        = imgui.ImVec4(0.18, 0.19, 0.22, 1.00)
    colors[imgui.Col.FrameBgHovered] = imgui.ImVec4(0.20, 0.22, 0.25, 1.00)
    colors[imgui.Col.FrameBgActive]  = imgui.ImVec4(0.22, 0.24, 0.28, 1.00)
    colors[imgui.Col.Button]         = imgui.ImVec4(0.18, 0.19, 0.22, 1.00)
    colors[imgui.Col.ButtonHovered]  = imgui.ImVec4(0.20, 0.22, 0.25, 1.00)
    colors[imgui.Col.ButtonActive]   = imgui.ImVec4(0.22, 0.24, 0.28, 1.00)
    colors[imgui.Col.CheckMark]      = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[imgui.Col.Header]         = imgui.ImVec4(0.16, 0.17, 0.20, 1.00)
    colors[imgui.Col.HeaderHovered]  = imgui.ImVec4(0.20, 0.22, 0.25, 1.00)
    colors[imgui.Col.HeaderActive]   = imgui.ImVec4(0.22, 0.24, 0.28, 1.00)
    colors[imgui.Col.Separator]      = imgui.ImVec4(0.10, 0.11, 0.13, 1.00)
    style.WindowRounding             = 6
    style.FrameRounding              = 4
    style.GrabRounding               = 4
    style.ScrollbarRounding          = 6
end

function imgui.LinkText(link, text)
    imgui.TextColored(imgui.ImVec4(0.0, 0.7, 1.0, 1.0), text)
    if imgui.IsItemClicked(0) then os.execute(("start %s"):format(link)) end
end

function onReceivePacket(id, data)
    if id == 32 or id == 33 or id == 36 or id == 37 then
        if auto_reconnect[0] then
            local delay = auto_reconnect_time[0] * 1000
            wait(delay)
            sampConnectToServer(ip, port)
        end
    end
end

function imgui.CustomCheck(label, bool)
    local result = false
    local drawList = imgui.GetWindowDrawList()
    local draw = imgui.GetCursorScreenPos()
    local lineHeight = imgui.GetTextLineHeight()
    local itemSpacing = imgui.GetStyle().ItemSpacing
    local boxSize = math.floor(lineHeight * 0.95)
    local clearance = boxSize * 0.2
    local corner = draw + imgui.ImVec2(0, itemSpacing.y + math.floor(0.5 * (lineHeight - boxSize)))
    local color = imgui.GetStyle().Colors[imgui.Col.Text]
    local changedColor = imgui.ImVec4(color.x, color.y, color.z, 0.25)
    local colorMark = color
    local name = string.gsub(label, "##.*", "")
    local radius = boxSize * 0.2
    local conv = imgui.ColorConvertFloat4ToU32
    local ImVec2 = imgui.ImVec2

    if not cMarks then cMarks = {} end
    if not cMarks[label] then cMarks[label] = 0 end

    imgui.BeginGroup()
        imgui.InvisibleButton(label, ImVec2(boxSize, boxSize))
        if #name > 0 then
            imgui.SameLine()
            imgui.SetCursorPosY(imgui.GetCursorPosY() + 2.5)
            imgui.Text(name)
        end
    imgui.EndGroup()
    if imgui.IsItemClicked() then
        bool[0] = not bool[0]
        result = true
        if bool[0] then cMarks[label] = os.clock() end
    end

    changedColor.w = imgui.IsItemHovered() and 1.0 or 0.25
    drawList:AddRect(corner, corner + ImVec2(boxSize, boxSize), conv(changedColor), 0.0, 0, 1.0)

    if bool[0] then
        local pts = {
            corner + ImVec2(clearance, clearance + boxSize * 0.3),
            corner + ImVec2(boxSize * 0.5, boxSize - clearance),
            corner + ImVec2(boxSize - clearance, clearance)
        }
        drawList:AddLine(pts[1], pts[2], conv(colorMark), 1.0)
        drawList:AddLine(pts[2], pts[3], conv(colorMark), 1.0)
    end

    local timer = os.clock() - cMarks[label]
    if timer < 0.4 then
        local r = radius + timer*25
        if timer <= 0.2 then circColor = imgui.ImVec4(color.x, color.y, color.z, r/5)
        else circColor = imgui.ImVec4(color.x, color.y, color.z, r/75)
        end
        drawList:AddCircle(ImVec2(draw.x + boxSize/2, draw.y + boxSize - clearance), r, conv(circColor))
    end
    return result
end