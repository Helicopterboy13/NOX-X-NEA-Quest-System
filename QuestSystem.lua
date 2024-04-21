if CLIENT then

    QuestFormat = QuestFormat or {}

    QuestFormat.__index = QuestFormat

    local QSType = "Daily"
    local QSChallenge = nil
    local QSD = {}
    local QSMenuOpen = false
    local QSDailyRefresh = false
    local QSDailyCompleted = 0

    local QSMaxDaily = 4
    local QColour = Color(80,15,15,245)
    local TextColor = Color(180,40,40)
    local DRerollCost = 50000
    local WRerollCost = 250000

    function QuestFormat:new(o, QSChallenge, Title, Description, Condition, Goal, Credits, Experience, QSQType, QuestTarget, State)
        if State then
            State = "Claimed"
            Progress = Goal
        else
            State = "Pending"
            Progress = 0
        end
        print(State)
        o = {
        Progress = Progress,
        QSChallenge = QSChallenge,
        Title = Title,
        Description = Description,
        Condition = Condition,
        CreditReward = Credits,
        XPReward = Experience,
        Goal = Goal,
        QSType = QSQType,
        QTarget = QuestTarget,
        QState = State
        }
        
        setmetatable(o, self)
        return o
    end

    function QuestFormat:Get(Target)
        if Target == "Title" then
            return self.Title
        elseif Target == "Description" then
            return self.Description
        elseif Target == "Progress" then
            return self.Progress
        elseif Target == "QSChallenge" then
            return self.QSChallenge
        elseif Target == "Condition" then
            return self.Condition
        elseif Target == "CreditReward" then
            return self.CreditReward
        elseif Target == "XPReward" then
            return self.XPReward
        elseif Target == "Goal" then
            return self.Goal
        elseif Target == "QSType" then
            return self.QSType
        elseif Target == "QTarget" then
            return self.QTarget
        elseif Target == "State" then
            return self.QState
        end
    end

    function QuestFormat:Set(Target, NewVal)
        if Target == "State" then
            self.QState = NewVal
        end
    end
    
    function QuestFormat:Increment()
        if self.Progress + 1 == self.Goal then
            self.Progress = self.Goal
            self:Remove()
            print("Completed: " .. self.Title)
            self:Completed()
    
        else
            self.Progress = self.Progress + 1
            print("Progress made on: " .. self.Title)
            if QSTrackedQuest then
                if QSTrackedQuest:Get("Title") == self:Get("Title") then
                    QSTrackingClose()
                    QSQuestTracking(QSTracking, QSTrackedQuest)
                end
            end
        end
    end
    
    function QuestFormat:Activate() 
        net.Start("QSStartQuestTracking")
        net.WriteString(self.Title)
        net.WriteString(self.QSType)
        net.WriteString(self.QTarget)
        net.SendToServer()
        print("Call for Quest Activate")
    end
    
    function QuestFormat:Remove()
        net.Start("QSEndQuestTracking")
        net.WriteString(self.Title)
        net.WriteString(self.QSType)
        net.SendToServer()
        print("Call for Quest End")
    end
    
    function QuestFormat:Completed()
        print("Well Done you Completed a Quest of QSChallenge Rating " .. tostring(self.QSChallenge))
        self.QState = "Claimed"
        QSDailyCompleted = QSDailyCompleted + 1

        if QSTrackedQuest then
            if QSTrackedQuest:Get("Title") == self:Get("Title") then
                QSTracking = false
                QSTrackedQuest = nil
                QSQuestTracking(QSTracking, QSTrackedQuest)
            end
        end

        net.Start("QSQuestCompleted")
        net.WriteString(self.Title)
        net.WriteInt(QSMaxDaily, 4)
        net.SendToServer()
    end

    net.Receive("QSDQAssaignmentReturn", function()
        QSChallenge = net.ReadFloat()
        QSDailyRefresh = net.ReadBool()
        QSDailyCompleted = net.ReadInt(4)
        if QSDailyRefresh then print("Need a Refresh") end

        for i = 1, QSMaxDaily do
            local QSDT = net.ReadTable(true)
            QSD[i] = QuestFormat:new(nil, QSDT[1], QSDT[2], QSDT[3], QSDT[4], QSDT[5], QSDT[6], QSDT[7], QSDT[8], QSDT[9], QSDT[10])
        end

        if QSMenuOpen then
            CloseWindow()
        end
        QSMenuCall(QSType)
    end)

    net.Receive("QSMenuCaller",function()
        if not QSChallenge then
            net.Start("QSDQAssaignmentCall")
            net.WriteString(QSType)
            net.WriteInt(QSMaxDaily, 4)
            net.SendToServer()
        else
            QSMenuCall(QSType)
        end
    end)

    net.Receive("QSIncrementQuestTracking", function()
        local IncrementTitle = net.ReadString()

        for i = 1, QSMaxDaily do
            if QSD[i]:Get("Title") == IncrementTitle then
                QSD[i]:Increment()
            end
        end
    end)

    net.Receive("QSChallengeUpdate", function ()
        QSChallenge = net.ReadFloat()
    end)

    local QSMenuText = function(QSMenuTab, FrameW, FrameH, frame) -- Text for the main menu, called within the draw function
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
            "Minutes Until Reset",
            "contFontHeli",
            FrameW*0.138, 
            FrameH/5.5, 
            TextColor,
            0,
            1
            )

            draw.SimpleText(
            "Reroll Price: " .. tostring(DRerollCost), -- Make into 2 different texts, and put on the button
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
            string.format("%.2f", tostring(QSChallenge)),
            "TitleFontHeli",
            FrameW*0.8,
            FrameH/4.2,
            TextColor,
            0,
            1
            )

        end
    end

    local QSMenuButtons = function(QSMenuTab, FrameW, FrameH, frame) -- Create buttons and progress bars for the main menu section - outside the draw function
        if QSMenuTab == "Daily" then

            local QuestsCompleted = vgui.Create( "DProgressBar", frame)
            QuestsCompleted:SetSize(FrameW/6, FrameH/14)
            QuestsCompleted:SetPos( FrameW*0.413, FrameH*0.2 )
            QuestsCompleted:SetMin(0)
            QuestsCompleted:SetMax(QSMaxDaily)
            QuestsCompleted:SetValue(QSDailyCompleted)

            if os.date( "!%H") * 60 + os.date( "!%M") + os.date( "!%S")/60 >= 1440 then
                net.Start("QSDQAssaignmentCall")
                net.WriteString(QSType)
                net.WriteInt(QSMaxDaily, 4)
                net.SendToServer()
            end

            local TimeLeft = vgui.Create( "DProgressBar",frame)
            TimeLeft:SetSize(FrameW/6, FrameH/14)
            TimeLeft:SetPos( FrameW*0.14, FrameH*0.2 )
            TimeLeft:SetMin(0)
            TimeLeft:SetMax(1440)
            TimeLeft:SetValue(os.date( "!%H") * 60 + os.date( "!%M") + os.date( "!%S")/60)



            function CloseWindow()
                frame:Close()
                QSMenuOpen = false
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

                -- Deduct Credits

                if QSTracking then
                    QSTrackedQuest = nil
                    QSTracking = false
                    QSQuestTracking()
                end

                local QSQWanted = 0

                for i = 1, QSMaxDaily do
                    if QSD[i]:Get("State") ~= "Claimed" then
                        if QSD[i]:Get("State") == "Active" or QSD[i]:Get("State") == "Base" then
                            QSD[i]:Remove()
                        end
                        QSQWanted = QSQWanted + 1
                    end
                end
                if QSQWanted > 0 then
                    print("Ask for Quests")
                    net.Start("QSDQAssaignmentCall")
                    net.WriteString(QSType)
                    net.WriteInt(QSMaxDaily, 4)
                    net.SendToServer()
                end

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

    local QSQuestsText = function(QSType, FrameW, FrameH, frame, QSD, QSW) -- Text for the Quests, drawn from the assaignment file, called in the draw function

        local QSDFrameFrom = {
            {FrameW*0.435/22, FrameH*1.4/5},
            {FrameW*11.15/22, FrameH*1.4/5},
            {FrameW*0.435/22, FrameH*2.85/5},
            {FrameW*11.15/22, FrameH*2.85/5},           

        }

        if QSType == "Daily" then

            for i = 1, QSMaxDaily do
                
                draw.RoundedBox(3, QSDFrameFrom[i][1], QSDFrameFrom[i][2], FrameW/2.1, FrameH/3.6, QColour) -- Quest 1
            
                draw.SimpleText(
                    QSD[i]:Get("Title"),
                    "contFontHeli",
                    QSDFrameFrom[i][1] + FrameW*2.065/22,
                    QSDFrameFrom[i][2] + FrameH*0.2/5,
                    TextColor,
                    0,
                    1
                )
                draw.SimpleText(
                    QSD[i]:Get("Condition"),
                    "contFontHeli",
                    QSDFrameFrom[i][1] + FrameW*1.065/22,
                    QSDFrameFrom[i][2] + FrameH*0.4/5,
                    TextColor,
                    0,
                    1
                )
                draw.SimpleText(
                    tostring(QSD[i]:Get("QSChallenge")),
                    "TitleFontHeli",
                    QSDFrameFrom[i][1] + FrameW*9.765/22,
                    QSDFrameFrom[i][2] + FrameH*0.2/5,
                    TextColor,
                    0,
                    1
                )
                draw.SimpleText(
                    "Credits",
                    "contFontHeli",
                    QSDFrameFrom[i][1] + FrameW*0.365/22,
                    QSDFrameFrom[i][2] + FrameH*1/5,
                    TextColor,
                    0,
                    1
                )
                draw.SimpleText(
                    QSD[i]:Get("CreditReward"),
                    "contFontHeli",
                    QSDFrameFrom[i][1] + FrameW*0.565/22,
                    QSDFrameFrom[i][2] + FrameH*1.2/5,
                    TextColor,
                    0,
                    1
                )
                draw.SimpleText(
                    "Experience",
                    "contFontHeli",
                    QSDFrameFrom[i][1] + FrameW*7.765/22,
                    QSDFrameFrom[i][2] + FrameH*1/5,
                    TextColor,
                    0,
                    1
                )
                draw.SimpleText(
                    QSD[i]:Get("XPReward"),
                    "contFontHeli",
                    QSDFrameFrom[i][1] + FrameW*8.365/22,
                    QSDFrameFrom[i][2] + FrameH*1.2/5,
                    TextColor,
                    0,
                    1
                )

            end

        elseif QSType == "Weekly" then
            print("Draw Weekly Page")

        elseif QSType == "LifeTime" then
            print("Lifetime Go Brrr")
        end

    end
    
    function QSStateToText(State)
        if State == "Base" then
            return "Track Quest"
        elseif State == "Active" then
            return "Stop Tracking"
        --elseif State == "Complete" then
            --return "Claim Rewards"
        elseif State == "Claimed" then
            return "Completed"
        elseif State == "Pending" then
            return "Accept Quest"
        end
    end

    local QSQuestsButtons = function(QSType, FrameW, FrameH, frame, QSD) -- Text for the Quests, drawn from the assaignment file, called in the draw function

        local QColour = Color(80,15,15,245)

        local QSDFrameFrom = {
            {0.435/22, 1.4/5},
            {11.15/22, 1.4/5},
            {0.435/22, 2.85/5},
            {11.15/22, 2.85/5},           

        }

        local QSQuestButton = {}
        local QSQuestPBar = {}

        if QSType == "Daily" then

            for i = 1, QSMaxDaily do
            
                QSQuestButton[i] = vgui.Create("DButton", frame)
                QSQuestButton[i]:CenterHorizontal(QSDFrameFrom[i][1] + 4.065/22)
                QSQuestButton[i]:CenterVertical(QSDFrameFrom[i][2] + 1.05/5)
                QSQuestButton[i]:SetSize(FrameW/6, FrameH/12)
                QSQuestButton[i]:SetText(QSStateToText(QSD[i]:Get("State")))
                QSQuestButton[i].DoClick = function()
                    
                    if QSD[i]:Get("State") == "Base" then
                        if QSTracking then
                            QSTracking = false
                            QSTrackedQuest:Set("State", "Base")
                            QSTrackedQuest = nil
                            QSQuestTracking(QSTracking, QSTrackedQuest)
                        end
                        QSTracking = true
                        QSD[i]:Set("State", "Active")
                        QSTrackedQuest = QSD[i]
                        QSQuestTracking(QSTracking, QSTrackedQuest)
                    elseif QSD[i]:Get("State") == "Active" then
                        QSTracking = false
                        QSD[i]:Set("State", "Base")
                        QSTrackedQuest = nil
                        QSQuestTracking(QSTracking, QSTrackedQuest)
                    --elseif QSD[i]:Get("State") == "Complete" then
                    --    QSTracking = false
                    --    QSD[i]:Set("State", "Claimed")
                    --    QSTrackedQuest = nil
                    --    QSD[i]:Completed()
                    --    QSQuestTracking(QSTracking, QSTrackedQuest)
                    elseif QSD[i]:Get("State") == "Pending" then
                        QSD[i]:Set("State", "Base")
                        QSD[i]:Activate()
                    end
                    frame:Close()
                    QSMenuCall(QSType)
                end
                QSQuestButton[i].Paint = function(s,w,h)
                    draw.RoundedBox(5,0,0,w,h,Color(255,255,255,100))
                end
    
                QSQuestPBar[i] = vgui.Create( "DProgressBar", frame)
                QSQuestPBar[i]:SetSize(FrameW/5, FrameH/12)
                QSQuestPBar[i]:SetPos( FrameW*(QSDFrameFrom[i][1] + 2.865/22), FrameH*(QSDFrameFrom[i][2] + 0.5/5) )
                QSQuestPBar[i]:SetMin(0)
                QSQuestPBar[i]:SetMax(QSD[i]:Get("Goal"))
                QSQuestPBar[i]:SetValue(QSD[i]:Get("Progress"))
            end

        

        elseif QSType == "Weekly" then

        elseif QSType == "LifeTime" then
            print("Lifetime Go Brrr")
        end

    end

    function QSMenuCall(QSType)

        QSMenuOpen = true

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

            draw.RoundedBox(0,FrameW/140+1,FrameH/80,InnerW,InnerH/11,Color(150,20,40,245)) -- The Title Box

            draw.SimpleText(
                "Noxifier Quest System",
                "TitleFontHeli",
                FrameW*0.225, 
                FrameH/22, 
                Color(230,240,255),
                0,
                1
            ) -- Title Function

            QSQuestsText(QSType, FrameW, FrameH, frame, QSD)

            QSMenuText(QSType,FrameW,FrameH, frame)

        end

        QSQuestsButtons(QSType, FrameW, FrameH, frame, QSD)

        QSMenuButtons(QSType, FrameW, FrameH, frame) -- Call the Buttons, draw em as daily

    end

    function QSQuestTracking(QSTracking, QSTrackedQuest)
        if QSTracking then
            local frame = vgui.Create("DFrame")
            local FrameW = ScrW()/4
            local FrameH = ScrH()/6
            frame:SetSize(FrameW,FrameH) -- l/r, u/d
            frame:SetPos(FrameW/10, FrameH/10) -- away from the users top left corner (scales for different screens setups)
            frame:SetVisible(true) -- The frame in which we are making everything else has a visible background
            -- frame:MakePopup() -- ?
            frame:SetTitle( " " ) -- Blank Title, im writing it in simple text ltr
            frame:ShowCloseButton(false) -- Dont show an x at the top right, adding my own close window button
            frame:SetIsMenu(false) -- Treats this as a menu

            function QSTrackingClose()
                frame:Close()
            end

            frame.Paint = function(s,w,h) -- Overrule frame.paint function

                InnerW = w-FrameW/70
                InnerH = h-FrameH/40

                draw.RoundedBox(5,0,0,w,h,Color(100,50,50,255)) -- Opaque window, grey colour, corner rounding is 5 pixels, Pos set from top right of the 2d frame creation, set to fill the same size of the window
                
                draw.RoundedBox(5,FrameW/140,FrameH/80,InnerW,InnerH,Color(36,36,36,245)) -- 2nd layer of different colour to create a 4 pixel border on the window, this is main grey, above is border grey

                draw.RoundedBox(0,FrameW/140+1,FrameH/80,InnerW,InnerH/11,Color(150,20,40,245)) -- The Title Box

                draw.SimpleText(
                    QSTrackedQuest:Get("Title"),
                    "contFontHeli",
                    FrameW*0.2, 
                    FrameH/22, 
                    Color(230,240,255),
                    0,
                    1
                ) -- Title Function
                draw.SimpleText(
                    QSTrackedQuest:Get("Description"),
                    "contFontHeli",
                    FrameW*0.05, 
                    FrameH*3/22, 
                    Color(230,240,255),
                    0,
                    1
                )
                draw.SimpleText(
                    QSTrackedQuest:Get("Condition"),
                    "contFontHeli",
                    FrameW*0.2, 
                    FrameH*5/22, 
                    Color(230,240,255),
                    0,
                    1
                )
                draw.SimpleText(
                    "Credits",
                    "contFontHeli",
                    FrameW*1.2/22,
                    FrameH*4.1/5,
                    TextColor,
                    0,
                    1
                )
                draw.SimpleText(
                    QSTrackedQuest:Get("CreditReward"),
                    "contFontHeli",
                    FrameW*1.4/22,
                    FrameH*4.6/5,
                    TextColor,
                    0,
                    1
                )
                draw.SimpleText(
                    "Experience",
                    "contFontHeli",
                    FrameW*18/22,
                    FrameH*4.1/5,
                    TextColor,
                    0,
                    1
                )
                draw.SimpleText(
                    QSTrackedQuest:Get("XPReward"),
                    "contFontHeli",
                    FrameW*18.8/22,
                    FrameH*4.6/5,
                    TextColor,
                    0,
                    1
                )
            end

            local QSQuestPBarTracking = vgui.Create( "DProgressBar", frame)
            QSQuestPBarTracking:SetSize(FrameW/1.8, FrameH/4)
            QSQuestPBarTracking:SetPos( FrameW*0.15, FrameH*0.38 )
            QSQuestPBarTracking:SetMin(0)
            QSQuestPBarTracking:SetMax(QSTrackedQuest:Get("Goal"))
            QSQuestPBarTracking:SetValue(QSTrackedQuest:Get("Progress"))

        else
            QSTrackingClose()
        end
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