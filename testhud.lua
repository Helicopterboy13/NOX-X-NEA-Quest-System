--[[hook.Add("HUDPaint", "DrawMyHud", function()


    draw.RoundedBox(0,100,100,100,100,Color(120,255,120,150))
    --draw.RoundedBox(howrounded,xpos,ypos,wdth,hght,Color(120,255,120))
    --draw.SimpleText( "hello world","TheDefaultSettings" , 0, 0, Color(255,120,120),0,0)

    surface.SetDrawColor(120,120,255,255)
    surface.DrawRect(10,10,100,100)
    surface.SetTextPos(10,10)
    surface.SetFont("TheDefaultSettings")
    surface.SetTextColor(Color(255,120,120))
    surface.DrawText("Hello World")
end)]]--

--[[hook.Add("HUDPaint", "overridehealth", function()

    local playerhealth = LocalPlayer():Health()
    draw.RoundedBox(0,8,ScrH() - 200,300+4,30+ 4,Color(40,40,40)) -- background
    draw.RoundedBox(0,10,ScrH() - 198,playerhealth*3,30,Color(255,120,120)) -- health bar
    draw.SimpleText(
        playerhealth.." HP",
        "TheDefaultSettings",
        10 + 10, 
        ScrH() - 183, 
        Color(255,255,255),
        0,1
    )



    
end)]]--

--[[ text,
font, 
boxstartposx + indent, 
scrH() - allignment
]]--

hook.Add("HUDPaint", "overridehealth", function()

    local playerhealth = LocalPlayer():Health()
    local playerarmour = LocalPlayer():Armor()

    if playerhealth <= 9 then
        playerhealth = "000"..LocalPlayer():Health()
    elseif playerhealth <= 99 then
        playerhealth = "00"..LocalPlayer():Health()
    elseif playerhealth <= 999 then
        playerhealth = "0"..LocalPlayer():Health()
    elseif playerhealth > 9999 then
        playerhealth = "9999"
    end

    if playerarmour <= 9 then
        playerarmour = "000"..LocalPlayer():Armor()
    elseif playerarmour <= 99 then
        playerarmour = "00"..LocalPlayer():Armor()
    elseif playerarmour <= 999 then
        playerarmour = "0"..LocalPlayer():Armor()
    elseif playerarmour > 9999 then
        playerarmour = "9999"
    end

    if LocalPlayer():Alive() then

        draw.SimpleText(
            playerhealth,
            "TheDefaultSettings",
            10 + 10, 
            ScrH() - 140, 
            Color(255,255,255),
            0,1
        )

        draw.SimpleText(
            "HP",
            "TheDefaultSettings",
            10 + 150, 
            ScrH() - 140, 
            Color(255,255,255),
            0,1
        )

        draw.SimpleText(
            playerarmour,
            "TheDefaultSettings",
            10 + 10, 
            ScrH() - 90, 
            Color(255,255,255),
            0,1
        )

        draw.SimpleText(
            "AP",
            "TheDefaultSettings",
            10 + 150, 
            ScrH() - 90, 
            Color(255,255,255),
            0,1
        )

        local ammoinreserve = LocalPlayer():GetAmmoCount( LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType())
        if ammoinreserve <= 9 then
            ammoinreserve = "000"..ammoinreserve
        elseif ammoinreserve <= 99 then
            ammoinreserve = "00"..ammoinreserve
        elseif ammoinreserve <= 999 then
            ammoinreserve = "0"..ammoinreserve
        elseif ammoinreserve > 9999 then
            ammoinreserve = "9999"
        end

        draw.SimpleText(
            ammoinreserve,
            "TheDefaultSettings",
            10 + 1600, 
            ScrH() - 140, 
            Color(255,255,255),
            0,1
        )

        draw.SimpleText(
            "Cells",
            "TheDefaultSettings",
            10 + 1740, 
            ScrH() - 140, 
            Color(255,255,255),
            0,1
        )


        local ammoingun = LocalPlayer():GetActiveWeapon():Clip1()
        if ammoingun == -1 then
            ammoinguntoprint = "0000"
        elseif ammoingun <= 9 then
            ammoinguntoprint = "000"..ammoingun
        elseif ammoingun <= 99 then
            ammoinguntoprint = "00"..ammoingun
        elseif ammoingun <= 999 then
            ammoinguntoprint = "0"..ammoingun
        elseif ammoingun > 9999 then
            ammoinguntoprint = "9999"
        end

        if engine.ActiveGamemode() == "DarkRP" then
            local playermoney = LocalPlayer():getDarkRPVar("money")
            if playermoney <= 9 then
                playermoney = "0000"..playermoney
            elseif playermoney <= 99 then
                playermoney = "000"..playermoney
            elseif playermoney <= 999 then
                playermoney = "00"..playermoney
            elseif playermoney <= 9999 then
                playermoney = "0"..playermoney
            elseif playermoney > 99999 then
                playermoney = "99999+"
            end
        end

        draw.SimpleText(
            ammoinguntoprint,
            "TheDefaultSettings",
            10 + 1600, 
            ScrH() - 90, 
            Color(255,255,255),
            0,1
        )

        draw.SimpleText(
            "Clip",
            "TheDefaultSettings",
            10 + 1740, 
            ScrH() - 90, 
            Color(255,255,255),
            0,1
        )

        draw.SimpleText(
            "D",
            "moneysymbol",
            10, 
            ScrH() - 1060, 
            Color(255,255,255),
            0,1
        )
    
        draw.SimpleText(
            playermoney,
            "TheDefaultSettings",
            70, 
            ScrH() - 1060, 
            Color(255,255,255),
            0,1
        )

        if #player.GetAll() <= 5 then
            draw.SimpleText(
            "DOWNTIME IS ACTIVE",
            "TheDefaultSettings",
            690, 
            ScrH() - 950, 
            Color(255,0,0),
            0,1
            )
        end




    end





    
end)




local hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
    ["CHudAmmo"] = true	
}

hook.Add( "HUDShouldDraw", "HideHUD", function( name )
	if ( hide[ name ] ) then
		return false
	end

	-- Don't return anything here, it may break other addons that rely on this hook.
end )

surface.CreateFont( "TheDefaultSettings", {
    font = "Orbitron", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = 50,
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

surface.CreateFont( "moneysymbol", {
    font = "Aurek-Besh", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = 50,
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