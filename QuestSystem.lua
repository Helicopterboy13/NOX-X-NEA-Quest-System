include ("QSAssaignment.lua")

if SERVER then
    util.AddNetworkString("QSMenuCaller")
    hook.Add("PlayerSay", "QuestMenuCall", function(ply,text)
        if string.find(text:lower(), "!quest") then
            net.Start("QSMenuCaller")
            net.Send(ply) -- Local Player --> Sends the local player the net msg to open the menu
        end
    end) -- end hook code here, this hook calls the function definied with in it, which simply calls the function to be ran client side
end

-- Server Side Code above and Client Side function called below

if CLIENT then

    net.Receive("QSMenuCaller",function()
        QSMenuCall("Daily")
        print("Gottim Net Boi")


    end)

    local TextColor = Color(180,40,40)

    local DRerollCost = 50000

    local WRerollCost = 250000

    local Challenge = 1

    local QSMenuText = function(QSMenuTab, FrameW, FrameH, frame)
        if QSMenuTab == "Daily" then
            draw.SimpleText(
            "Quests Completed",
            "contFontHeli",
            FrameW*0.401,
            FrameH/5.5, 
            TextColor,
            0,
            1
            )

            draw.SimpleText(
            "Time Untill Reset",
            "contFontHeli",
            FrameW*0.138, 
            FrameH/5.5, 
            TextColor,
            0,
            1
            )

            draw.SimpleText(
            "Reroll Price: " .. tostring(DRerollCost),
            "contFontHeli",
            FrameW*0.4,
            FrameH*0.85,
            TextColor,
            0,
            1
        )

        draw.SimpleText(
            "Challenge Rating",
            "contFontHeli",
            FrameW*0.725,
            FrameH/5.5,
            TextColor,
            0,
            1
        )

        draw.SimpleText(
            tostring(Challenge),
            "TitleFontHeli",
            FrameW*0.8,
            FrameH/4.2,
            TextColor,
            0,
            1
        )

        end
    end

    local QSDailyCompleted = 1

    local QSMenuButtons = function(QSMenuTab, FrameW, FrameH, frame)
        if QSMenuTab == "Daily" then
            print("Daily Quests Render")

            local QuestsCompleted = vgui.Create( "DProgressBar", frame)
            QuestsCompleted:SetSize(FrameW/6, FrameH/14)
            QuestsCompleted:SetPos( FrameW*0.413, FrameH*0.2 )
            QuestsCompleted:SetMin(0)
            QuestsCompleted:SetMax(4)
            QuestsCompleted:SetValue(QSDailyCompleted)

            local TimeLeft = vgui.Create( "DProgressBar",frame)
            TimeLeft:SetSize(FrameW/6, FrameH/14)
            TimeLeft:SetPos( FrameW*0.14, FrameH*0.2 )
            TimeLeft:SetMin(0)
            TimeLeft:SetMax(14400)
            TimeLeft:SetValue(5555)



            function CloseWindow()
                print("Close the Menu")
                frame:Close()
            end
    
            local CloseButton = vgui.Create("DButton", frame)
            CloseButton:CenterHorizontal( 0.725 )
            CloseButton:CenterVertical( 0.89 )
            CloseButton:SetSize(FrameW/6, FrameH/10)
            CloseButton:SetText("CLOSE")
            CloseButton.DoClick = CloseWindow
            CloseButton.Paint = function(s,w,h)
                draw.RoundedBox(5,0,0,w,h,Color(255,255,255,100))
            end
    
            function QSReroll()
                print("Reroll them Quests")
                -- Deduct Credits
                Quests:Assaign(QSD1, QSD2, QSD3, QSD4, nil, nil, Challenge, QSMenuTab)
            end
    
            local RerollButton = vgui.Create("DButton", frame)
            RerollButton:CenterHorizontal(0.45)
            RerollButton:CenterVertical(0.89)
            RerollButton:SetSize(FrameW/6, FrameH/10)
            RerollButton:SetText("REROLL")
            RerollButton.DoClick = QSReroll
            RerollButton.Paint = function(s,w,h)
                draw.RoundedBox(5,0,0,w,h,Color(255,255,255,100))
            end

            function QSHelpMenu()
                print("Open the Help Menu")

            end

            local HelpButton = vgui.Create("DButton", frame)
            HelpButton:CenterHorizontal(0.175)
            HelpButton:CenterVertical(0.89)
            HelpButton:SetSize(FrameW/6, FrameH/10)
            HelpButton:SetText("HELP")
            HelpButton.DoClick = QSHelpMenu
            HelpButton.Paint = function(s,w,h)
                draw.RoundedBox(5,0,0,w,h,Color(255,255,255,100))
            end

        elseif QSMenuTab == "Weekly" then
            print("Weekly Quests Render")

        elseif QSMenuTab == "LifeTime" then
            print("LifeTime Quests Render")
        end
    end


    function QSMenuCall(Type)
        -- create the box window and set the settings for it
        local frame = vgui.Create("DFrame")
        local FrameW = ScrW()/2
        local FrameH = ScrH()/2
        frame:SetSize(FrameW,FrameH) -- l/r, u/d
        frame:SetPos(FrameW/2, FrameH/2) -- 500 pixels away from the users right top corner (scales for different screens setups)
        frame:SetVisible(true) -- The frame in which we are making everything else has a visible background
        frame:MakePopup() -- ?
        frame:SetTitle( " " ) -- Blank Title, im writing it in simple text ltr
        frame:ShowCloseButton(false) -- Dont show an x at the top right, adding my own close window button
        frame:SetIsMenu(true) -- Treats this as a menu

        frame.Paint = function(s,w,h) -- Overrule frame.paint function

            InnerW = w-FrameW/70
            InnerH = h-FrameH/40

            draw.RoundedBox(5,0,0,w,h,Color(100,50,50,255)) -- Opaque window, grey colour, corner rounding is 5 pixels, Pos set from top right of the 2d frame creation, set to fill the same size of the window
            
            draw.RoundedBox(5,FrameW/140,FrameH/80,InnerW,InnerH,Color(36,36,36,245)) -- 2nd layer of different colour to create a 4 pixel border on the window, this is main grey, above is border grey

            draw.RoundedBox(0,FrameW/140+1,FrameH/80,InnerW,InnerH/11,Color(150,20,40,245))

            draw.SimpleText(
                "Noxifier Quest System",
                "TitleFontHeli",
                FrameW*0.225, 
                FrameH/22, 
                Color(230,240,255),
                0,
                1
            )

            QSMenuText(Type,FrameW,FrameH, frame)

        end

        QSMenuButtons(Type, FrameW, FrameH, frame) -- Call the Buttons, draw em as daily

    end
end

surface.CreateFont( "TitleFontHeli", {
    font = "Orbitron", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = ScrH()/20,
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
} )

surface.CreateFont( "contFontHeli", {
    font = "Orbitron", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = ScrH()/50,
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
} )