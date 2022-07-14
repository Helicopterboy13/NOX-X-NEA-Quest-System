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

    local QSMenuButtons = function(QSMenuTab, FrameW, FrameH, frame)
        if QSMenuTab == "Daily" then
            print("Daily Quests Render")

            local myProgressBar = vgui.Create( "DProgressBar",frame)
            myProgressBar:SetSize(FrameW/6, FrameH/10)
            myProgressBar:SetPos( 25, 25 )
            myProgressBar:SetMin( 0 )
            myProgressBar:SetMax(16)
            myProgressBar:SetValue(12)
            


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
                -- Rerun the Quest Assaignment algorithm
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

            draw.RoundedBox(0,FrameW/140+1,FrameH/80,InnerW,InnerH/11,Color(180,10,20,245))

            draw.SimpleText(
                "Noxifier Quest System",
                "TitleFontHeli",
                FrameW*0.225, 
                FrameH/22, 
                Color(40,40,150),
                0,
                1
            )



        end

        QSMenuButtons("Daily", FrameW, FrameH, frame) -- Call the Buttons, draw em as daily

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