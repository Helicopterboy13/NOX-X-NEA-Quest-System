

function QSOpenMenu( ply, text)  
    if string.sub( text, 1, 6 ) == "!quest" then  
    print("Open QS Menu")
    surface.SetDrawColor(50,50,50,255)
    surface.DrawRect(250, 250, 400, 400)
    end
end

hook.Add("PlayerSay", "QSCallMenu", QSOpenMenu)