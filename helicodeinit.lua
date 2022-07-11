if SERVER then
    hook.Add("PlayerSay", "QuestOpener", function(ply, text)
        if string.find(text:lower(), "!menu") then
            ply:SendLua( "RunMenu()")
        end
    end)
end

if CLIENT then
    function RunMenu()
        local frame = vgui.Create("DFrame")
        frame:SetSize(500,500) -- l/r, u/d
        frame:SetPos(ScrW()-500,-ScrH())
        frame:SetVisible(true)
        frame:MakePopup()
        frame:SetTitle( " " )
        frame:ShowCloseButton( false )
        frame:SetIsMenu( true )
        frame.Paint = function(s,w,h) -- overrides the frame.Paint function
            draw.RoundedBox(5,0,0,w,h,Color(0,0,0,200))
            -- using w and h sets the whole box to the color
            draw.RoundedBox(5,2,2,w-4,h-4,Color(36,36,36,200))

            draw.RoundedBox(0,10,50,
                200,50,
                Color(255,255,255,255)
            )

            draw.RoundedBox(0,290,50,
                200,50,
                Color(255,255,255,255)
        )   


            
        
            draw.SimpleText(
                "Noxifier Quest System",
                "TitleFontHeli",
                10 + 10, 
                20, 
                Color(255,255,255),
                0,1
            )

                    
            draw.SimpleText(
                "Kill the dragon atop the mountain",
                "contFontHeli",
                10 + 10, 
                75, 
                Color(0,0,0),
                0,1
            )

            draw.SimpleText(
                "Kill the troll atop the mountain",
                "contFontHeli",
                10 + 290, 
                75, 
                Color(0,0,0),
                0,1
            )
        
        end

        function CloseWindow()
            print("the button has been pressed")
            frame:Close()
        end

        local button = vgui.Create("DButton", frame)
        button:CenterHorizontal( 0.35 )
        button:CenterVertical( 0.9 )
        button:SetSize(200, 45)
        button:SetText("CLOSE")
        button.DoClick = CloseWindow
        button.Paint = function(s,w,h)
            draw.RoundedBox(0,0,0,w,h,Color(255,255,255,100))
        end

        local button2 = vgui.Create("DButton", frame)
        button2:SetPos(10,100)
        button2:SetSize(200, 50)
        button2:SetText("Trigger Quest")
        button2.DoClick = CloseWindow
        button2.Paint = function(s,w,h)
            draw.RoundedBox(0,0,0,w,h,Color(255,255,255,100))
        end

        local button3 = vgui.Create("DButton", frame)
        button3:SetPos(290,100)
        button3:SetSize(200, 50)
        button3:SetText("Trigger Quest")
        button3.DoClick = CloseWindow
        button3.Paint = function(s,w,h)
            draw.RoundedBox(0,0,0,w,h,Color(255,255,255,100))
        end
        
    end
end

surface.CreateFont( "TitleFontHeli", {
    font = "Orbitron", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = 46,
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
    size = 13,
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