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
        QSMenuCall()
        print("Gottim Net Boi")


    end)

    function QSMenuCall()
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
            draw.RoundedBox(5,0,0,w,h,Color(100,50,50,255)) -- Opaque window, grey colour, corner rounding is 5 pixels, Pos set from top right of the 2d frame creation, set to fill the same size of the window
            
            draw.RoundedBox(5,6,6,w-12,h-12,Color(36,36,36,245)) -- 2nd layer of different colour to create a 4 pixel border on the window, this is main grey, above is border grey
        end

        draw.SimpleText(
            "Noxifier Quest System",
            "TitleFontHeli",
            10 + 10, 
            20, 
            Color(150,40,40),
            0,1
        )

        function CloseWindow()
            print("the button has been pressed")
            frame:Close()
        end

        local button = vgui.Create("DButton", frame)
        button:CenterHorizontal( 0.4 )
        button:CenterVertical( 0.9 )
        button:SetSize(FrameW/8, FrameH/12)
        button:SetText("CLOSE")
        button.DoClick = CloseWindow
        button.Paint = function(s,w,h)
            draw.RoundedBox(5,0,0,w,h,Color(255,255,255,100))
        end
    end
end
