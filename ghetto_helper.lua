script_name('Ghetto Helper')

require('lib.moonloader')
local dlstatus = require('moonloader').download_status
local inicfg = require('inicfg')
local imgui = require('mimgui')
local new = imgui.new
local addons = require('ADDONS')
local fa = require('fAwesome6_solid')
local sampev = require('lib.samp.events')
local requests = require('lib.requests')

local encoding = require("encoding")
encoding.default = 'CP1251'
u8 = encoding.UTF8

--- VARIABLES ---
local sizeX, sizeY = getScreenResolution()
local render_window = new.bool(false)
local window_page = 1
local currentPage = (fa["HOUSE"] .. u8 ' Главное меню')

local auto_update = new.bool(false)
local update_state = false
local update_url = 'https://raw.githubusercontent.com/Sleizyy/ghetto-helper/refs/heads/main/update.ini'
local update_path = getWorkingDirectory() .. '/update.ini'
local update_log = nil

local scriptVersion = 3
script_version('1.01')
local script_url = 'https://github.com/Sleizyy/ghetto-helper/raw/refs/heads/main/ghetto_helper.lua'
local script_path = thisScript().path

local tag = '[{0008ff}Ghetto Assistant{ffffff}]: '

--- SHORTCUTS ---
local cmd = sampRegisterChatCommand
local msg = sampAddChatMessage
local send = sampSendChat

--- MAIN ---
function main()
    while not isSampAvailable() do wait(0) end

    cmd('gh', function()
        render_window[0] = not render_window[0]
    end)

        downloadUrlToFile(update_url, update_path, function(id, status)
            if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                updateIni = inicfg.load(nil, update_path)
                if tonumber(updateIni.info.version) > scriptVersion then
                    msg(tag .. 'Доступно обновление! Версия: ' .. updateIni.info.version_text,
                        -1)
                    update_state = true
                    update_log = updateIni.info.update_log
                end
                os.remove(update_path)
            end
        end)

    while true do
        wait(0)
        if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    msg(tag..'Скрипт успешно обновлен!', 1)
                    thisScript():reload()
                end
            end)
            break
        end
    end
end

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

        if addons.AnimButton(fa["HOUSE"] .. u8 ' Главное меню##1', imgui.ImVec2(120, 30)) then
            window_page = 1
            currentPage = (fa["HOUSE"] .. u8 ' Главное меню')
        end
        if addons.AnimButton(fa["GEARS"] .. u8 ' Настройки##2', imgui.ImVec2(120, 30)) then
            window_page = 2
            currentPage = (fa["GEARS"] .. u8 ' Настройки')
        end
        if addons.AnimButton(fa["INFO"] .. u8 ' Информация##3', imgui.ImVec2(120, 30)) then
            window_page = 3
            currentPage = (fa["INFO"] .. u8 ' Информация')
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
            imgui.Text(u8(update_log))

            imgui.PopFont()
            imgui.EndChild() -- Update Log
            imgui.PopStyleColor()

            imgui.NewLine()

            imgui.LinkText('https://vk.com/ses1404', fa["FILE"] .. u8 ' Ссылка на бластхак')
            imgui.LinkText('https://vk.com/ses1404', fa["MESSAGE"] .. u8 ' Связь с разработчиком')
            imgui.LinkText('https://vk.com/ses1404', fa["FILE_CODE"] .. u8 ' Файл на ГитХабе')
        elseif window_page == 2 then
            imgui.Text('1')
        end

        imgui.EndChild()

        imgui.End()
    end)

imgui.OnInitialize(function()
    fa.Init()
    local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/Montserrat-Bold.ttf', 32, _, glyph_ranges)
    log_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/RobotoMono-Regular.ttf', 15, _,
        glyph_ranges)
    -- local config = imgui.ImFontConfig()
    -- config.MergeMode = true
    -- config.PixelSnapH = true
    -- iconRanges = imgui.new.ImWchar[3](faicons.min_range, faicons.max_range, 0)
    -- imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(faicons.get_font_data_base85('solid'), 14, config, iconRanges)
end)

function imgui.ApplyCustomStyle()
    local style                      = imgui.GetStyle()
    local colors                     = style.Colors

    -- Тёмная тема
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
