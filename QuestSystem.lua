if CLIENT then

    QuestFormat = QuestFormat or {}

    QuestFormat.__index = QuestFormat

    local QSType = "Daily"
    local QSChallenge = nil
    local DRerollCost = 100000
    local WRerollCost = nil
    local QSMaxDaily = 4
    local QSMaxWeekly = nil
    local QSD = {}
    local QSMenuOpen = false
    local QSDailyRefresh = false
    local QSDailyCompleted = 0












    local QSCUI = QSCUI or {
        FWidth = ScrW(),
        FHeight = ScrH()
    }
    local QSCUIPanel = {}
    local QSCUIMenu = {}
    local QSCUINavBar = {}
    local QSCUIDaily = {}
    QSCUI.Tests = {}

    vgui.Register("GSCUI.Panel", QSCUIPanel, "EditablePanel")
    vgui.Register("GSCUI.Menu", QSCUIMenu, "GSCUI.Panel")
    vgui.Register("GSCUI.NavBar", QSCUINavBar)
    vgui.Register("GSCUI.Daily", QSCUIDaily)

    function QSCUI.CreateFont(name, size, weight)
        surface.CreateFont("QSFont." .. name, {
            font = "Tahoma",
            size = size or 16,
            weight = weight or 500
        } )
    end

    QSCUI.Tests.Frame = function()
        local frame = vgui.Create("GSCUI.Menu")
        frame:SetSize(QSCUI.UISizing.Menu.Width, QSCUI.UISizing.Menu.Height)
        frame:Center()
        frame:MakePopup()
        frame:SetTitle("Noxifer Quest System")
    end

    QSCUI.Design = {
        PColour = Color(80,15,15,245),
        PMSColor = Color(180,115,115,245),
        SColor = Color(80,155,15,245),
        MColor = Color(100,100,100,245),
        BColor = Color(90,75,175,215),
        PTColor = Color(180,40,40),
        STColor = Color(180,55,115,245),
        STAColor = Color(220,55,215,245),
        CloseButton = Color(160,20,20),

        Text = {
            Title = Color(35,35,35)
        }

    }
    QSCUI.UISizing = {

        Menu = {
            Height = QSCUI.FHeight*3/4,
            Width = QSCUI.FWidth*2/3
        },

        TBar = {
            Height = QSCUI.FHeight/20,
            Margin = QSCUI.FWidth/180,
            Font = QSCUI.FHeight/60 + QSCUI.FWidth/60
        },

        TMNBar = {
            Height = QSCUI.FHeight/200
        },

        QSCUINavBar = {
            Height = QSCUI.FHeight/25,
            Margin = QSCUI.FWidth/250,
            Font = QSCUI.FHeight/100 + QSCUI.FWidth / 100,
            AccentHeight = QSCUI.FHeight/300
        },

        Daily = {
            Height = QSCUI.FHeight/16,
            Width = QSCUI.FHeight/18,
            Font = QSCUI.FHeight/80 + QSCUI.FWidth / 80,
            Margin = QSCUI.FWidth / 45,
            Reroll = {
                Font = QSCUI.FHeight/180 + QSCUI.FWidth / 180,
                Margin = QSCUI.FWidth / 75
            }
        }
    }

    QSCUI.CreateFont("TBar", QSCUI.UISizing.TBar.Font, QSCUI.UISizing.TBar.Font*2)
    QSCUI.CreateFont("QSCUINavBar", QSCUI.UISizing.QSCUINavBar.Font, QSCUI.UISizing.QSCUINavBar.Font*5)
    QSCUI.CreateFont("DTBar", QSCUI.UISizing.Daily.Font, QSCUI.UISizing.Daily.Font*2)
    QSCUI.CreateFont("DBBar", QSCUI.UISizing.Daily.Font, QSCUI.UISizing.Daily.Reroll.Font*2)

    function QSCUIMenu:Init()
        self.NavBar = self:Add("GSCUI.NavBar")
        self.NavBar:Dock(TOP)
        self.NavBar:SetParent(self)

        self.NavBar:AddTab("Daily", "GSCUI.Daily")
        self.NavBar:AddTab("Weekly", "DPanel")
        self.NavBar:AddTab("Monthly", "DButton")
        self.NavBar:AddTab("Lifetime")
        self.NavBar:AddTab("Help")
    end

    function QSCUIPanel:Init()
        self.TBar = self:Add("Panel")
        self.TBar:Dock(TOP)
        self.TBar.Paint = function(pn1, w, h)
            draw.RoundedBox(6, 0, 0, w, h, QSCUI.Design.PColour, true, false, false, true)
        end

        self.TBar.CloseButton = self.TBar:Add("DButton")
        self.TBar.CloseButton:Dock(RIGHT)
        self.TBar.CloseButton.DoClick = function(pn1)
            self:Remove()
        end
        self.TBar.CloseButton:SetText("X")

        self.TBar.Title = self.TBar:Add("DLabel")
        self.TBar.Title:Dock(LEFT)
        self.TBar.Title:SetFont("QSFont.TBar")
        self.TBar.Title:SetTextColor(QSCUI.Design.PTColor)
        self.TBar.Title:SetTextInset(QSCUI.UISizing.TBar.Margin, 0)

        self.TMNBar = self:Add("Panel")
        self.TMNBar:Dock(TOP)
        function self.TMNBar:Paint(w, h)
            surface.SetDrawColor(QSCUI.Design.PMSColor)
            surface.DrawRect(0, 0, w, h)
        end
    end

    function QSCUINavBar:Init()
        self.Buttons = {}
        self.Panels = {}
        self.ActiveID = nil
    end

    function QSCUINavBar:Paint(w, h)
        surface.SetDrawColor(QSCUI.Design.SColor)
        surface.DrawRect(0,  0, w, h)
    end

    function QSCUINavBar:AddTab(Name, Panel)
        local i = #self.Buttons + 1
        self.Buttons[i] = self:Add("DButton")
        local Button = self.Buttons[i]
        Button:Dock(LEFT)
        Button.ID = i
        Button:SetText(Name)
        Button:SetFont("QSFont.QSCUINavBar")
        Button:SetTextColor(QSCUI.Design.STColor)
        Button.Paint = function(pn1, w, h)
            if (self.ActiveID == pn1.ID) then
                surface.SetDrawColor(QSCUI.Design.STAColor)
                surface.DrawRect(0, h - QSCUI.UISizing.QSCUINavBar.AccentHeight, w, QSCUI.UISizing.QSCUINavBar.AccentHeight)
            end
        end
        Button:SizeToContents(QSCUI.UISizing.QSCUINavBar.Margin*2)
        Button.DoClick = function(pn1)
            self:SetActive(pn1.ID)
        end

        self.Panels[i] = self:GetParent():Add(Panel or "DPanel")
        Panel = self.Panels[i]
        Panel:Dock(FILL)
        Panel:SetVisible(false)
    end

    function QSCUINavBar:SetActive(ID)
        local Button = self.Buttons[ID]
        if (!IsValid(Button)) then return end
        local ActiveButton = self.Buttons[self.ActiveID]
        if (IsValid(ActiveButton)) then
            ActiveButton:SetTextColor(QSCUI.Design.STColor)
            local ActivePanel = self.Panels[self.ActiveID]
            if IsValid(ActivePanel) then
                ActivePanel:SetVisible(false)
            end

        end
        self.ActiveID = ID
        Button:SetTextColor(QSCUI.Design.STAColor)
        local Panel = self.Panels[ID]
        Panel:SetVisible(true)
    end

    function QSCUIPanel:SetTitle(Text)
        self.TBar.Title:SetText(Text)
        self.TBar.Title:SizeToContents()
    end

    function QSCUIPanel:PerformLayout(w, h)
        self.TBar:SetTall(QSCUI.UISizing.TBar.Height)
        self.TBar.CloseButton:SetWide(self.TBar:GetTall())
        self.TMNBar:SetTall(QSCUI.UISizing.TMNBar.Height)
    end

    function QSCUIMenu:PerformLayout(w, h)
        self.BaseClass.PerformLayout(self, w, h)

        self.NavBar:SetTall(QSCUI.UISizing.QSCUINavBar.Height)
        for i = 1, #self.NavBar.Buttons do
        self.NavBar.Buttons[i]:SetWide(QSCUI.UISizing.Menu.Width/#self.NavBar.Buttons)
        end
    end

    function QSCUIPanel:Paint(w, h)
        draw.RoundedBox(6, 0, 0, QSCUI.UISizing.Menu.Width, QSCUI.UISizing.Menu.Height, QSCUI.Design.BColor)
    end



    function QSCUIDaily:Init()

        CurrentTime = os.date( "!%H") * 60 + os.date( "!%M") + os.date( "!%S")/60
        if CurrentTime >= 1440 then
            net.Start("QSDQAssaignmentCall")
            net.WriteString(QSType)
            net.WriteInt(QSMaxDaily, 4)
            net.SendToServer()
        end

        self.DTBar = self:Add("Panel")
        self.DTBar:Dock(TOP)
        function self.DTBar:Paint(w, h)
            surface.SetDrawColor(QSCUI.Design.MColor)
            surface.DrawRect(0, 0, w, h)
        end
        self.DTBar.TTR = self.DTBar:Add("Panel")
        self.DTBar.TTR:Dock(LEFT)
        self.DTBar.TTR.Title = self.DTBar.TTR:Add("DLabel")
        self.DTBar.TTR.Title:Dock(LEFT)
        self.DTBar.TTR.Title:SetText("Time Untill Reset: ")
        self.DTBar.TTR.Title:SetFont("QSFont.DTBar")
        self.DTBar.TTR.Title:SetTextInset(QSCUI.UISizing.Daily.Margin, 0)
        self.DTBar.TTR.Title:SetTextColor(QSCUI.Design.PTColor)
        self.DTBar.TTR.Title:SizeToContents()
        self.DTBar.TTR.Time = self.DTBar.TTR:Add("DLabel")
        self.DTBar.TTR.Time:Dock(FILL)
        self.DTBar.TTR.Time:SetText(23 - os.date( "!%H") .. "H " .. 60 - os.date( "!%M") .. "M")
        self.DTBar.TTR.Time:SetFont("QSFont.DTBar")
        self.DTBar.TTR.Time:SetTextColor(QSCUI.Design.PTColor)
        self.DTBar.TTR.Time:SizeToContents()

        self.DTBar.CRN = self.DTBar:Add("Panel")
        self.DTBar.CRN:Dock(RIGHT)
        self.DTBar.CRN.Title = self.DTBar.CRN:Add("DLabel")
        self.DTBar.CRN.Title:Dock(LEFT)
        self.DTBar.CRN.Title:SetText("Challenge Rating: ")
        self.DTBar.CRN.Title:SetFont("QSFont.DTBar")
        self.DTBar.CRN.Title:SetTextInset(QSCUI.UISizing.Daily.Margin*0.8, 0)
        self.DTBar.CRN.Title:SetTextColor(QSCUI.Design.PTColor)
        self.DTBar.CRN.Title:SizeToContents()
        self.DTBar.CRN.Challenge = self.DTBar.CRN:Add("DLabel")
        self.DTBar.CRN.Challenge:Dock(FILL)
        self.DTBar.CRN.Challenge:SetText(string.format("%.2f", tostring(6.77)))
        self.DTBar.CRN.Challenge:SetFont("QSFont.DTBar")
        self.DTBar.CRN.Challenge:SetTextColor(QSCUI.Design.PTColor)
        self.DTBar.CRN.Challenge:SizeToContents()

        self.DTBar.QCB = self.DTBar:Add("Panel")
        self.DTBar.QCB:Dock(FILL)
        self.DTBar.QCB.Title = self.DTBar.QCB:Add("DLabel")
        self.DTBar.QCB.Title:Dock(LEFT)
        self.DTBar.QCB.Title:SetText("Quests Completed: ")
        self.DTBar.QCB.Title:SetFont("QSFont.DTBar")
        self.DTBar.QCB.Title:SetTextInset(QSCUI.UISizing.Daily.Margin, 0)
        self.DTBar.QCB.Title:SetTextColor(QSCUI.Design.PTColor)
        self.DTBar.QCB.Title:SizeToContents()
        self.DTBar.QCB.Challenge = self.DTBar.QCB:Add("DLabel")
        self.DTBar.QCB.Challenge:Dock(FILL)
        self.DTBar.QCB.Challenge:SetText(QSDailyCompleted .. "/" ..  QSMaxDaily)
        self.DTBar.QCB.Challenge:SetFont("QSFont.DTBar")
        self.DTBar.QCB.Challenge:SetTextColor(QSCUI.Design.PTColor)
        self.DTBar.QCB.Challenge:SizeToContents()

        self.DBBar = self:Add("Panel")
        self.DBBar:Dock(BOTTOM)
        function self.DBBar:Paint(w, h)
            surface.SetDrawColor(QSCUI.Design.MColor)
            surface.DrawRect(0, 0, w, h)
        end
        self.DBBar.RButton = self.DBBar:Add("DButton")
        self.DBBar.RButton:Dock(RIGHT)
        self.DBBar.RButton:SetText("Reroll")
        self.DBBar.RButton:SetFont("QSFont.DBBar")
        self.DBBar.RButton:SetTextColor(QSCUI.Design.PTColor)
        self.DBBar.RButton.DoClick = function()
            QSReroll()
        end
        self.DBBar.RText = self.DBBar:Add("DLabel")
        self.DBBar.RText:Dock(LEFT)
        self.DBBar.RText:SetText("Cost To Reroll: " .. tostring(DRerollCost))
        self.DBBar.RText:SetFont("QSFont.DBBar")
        self.DBBar.RText:SetTextInset(QSCUI.UISizing.Daily.Reroll.Margin, 0)
        self.DBBar.RText:SetTextColor(QSCUI.Design.PTColor)
        self.DBBar.RText:SizeToContents()

        self.DLBar = self:Add("Panel")
        self.DLBar:Dock(LEFT)
        function self.DLBar:Paint(w, h)
            surface.SetDrawColor(QSCUI.Design.MColor)
            surface.DrawRect(0, 0, w, h)
        end

        self.DRBar = self:Add("Panel")
        self.DRBar:Dock(RIGHT)
        function self.DRBar:Paint(w, h)
            surface.SetDrawColor(QSCUI.Design.MColor)
            surface.DrawRect(0, 0, w, h)
        end

        self.Quests = self:Add("Panel")
        self.Quests:Dock(FILL)
        function self.Quests:Paint(w, h)
            surface.SetDrawColor(QSCUI.Design.MColor)
            surface.DrawRect(0, 0, w, h)
        end
    end

    function QSCUIDaily:PerformLayout(w, h)
        self.DTBar:SetTall(QSCUI.UISizing.Daily.Height)
        self.DTBar.TTR:SetWide(QSCUI.UISizing.Menu.Width/3)
        self.DTBar.CRN:SetWide(QSCUI.UISizing.Menu.Width/3)
        self.DBBar:SetTall(QSCUI.UISizing.Daily.Height)
        self.DBBar.RButton:SetWide(QSCUI.UISizing.Menu.Width/5)
        self.DLBar:SetWide(QSCUI.UISizing.Daily.Width)
        self.DRBar:SetWide(QSCUI.UISizing.Daily.Width)
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








    function QuestFormat:new(o, QSChallenge, Title, Description, Condition, Goal, Credits, Experience, QSQType, QuestTarget, State, QProgress)
        o = {
        QSChallenge = QSChallenge,
        Title = Title,
        Description = Description,
        Condition = Condition,
        CreditReward = Credits,
        XPReward = Experience,
        Goal = Goal,
        QSType = QSQType,
        QTarget = QuestTarget,
        QState = State,
        Progress = QProgress
        }

        print("Progress recieved as: ")
        print(o.Progress)

        setmetatable(o, self)

        if o.QState == "Base" then
            net.Start("QSStartQuestTracking")
            net.WriteString(o.Title)
            net.WriteString(o.QSType)
            net.WriteString(o.QTarget)
            net.SendToServer()
            print("Call for Quest Activate")
        end

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
        DRerollCost = net.ReadInt(24)
        WRerollCost = net.ReadInt(24)
        QSMaxDaily = net.ReadInt(4)
        QSMaxWeekly = net.ReadInt(4)
        QSDailyRefresh = net.ReadBool()
        QSDailyCompleted = net.ReadInt(4)
        if QSDailyRefresh then print("Need a Refresh") end

        for i = 1, QSMaxDaily do
            local QSDT = net.ReadTable(true)
            print("Recieving Progress of: ")
            print(QSDT[11])
            QSD[i] = QuestFormat:new(nil, QSDT[1], QSDT[2], QSDT[3], QSDT[4], QSDT[5], QSDT[6], QSDT[7], QSDT[8], QSDT[9], QSDT[10], QSDT[11])
        end

        if QSMenuOpen then
            CloseWindow()
        end
        QSMenuCall(QSType)
    end)

    net.Receive("QSMenuCaller",function()
        --[[if not QSChallenge then
            net.Start("QSDQAssaignmentCall")
            net.WriteString(QSType)
            net.SendToServer()
        else
            QSMenuCall(QSType)
        end]]

        QSCUI.Tests.Frame()

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













--[[
    local QSMenuButtons = function(QSMenuTab, FrameW, FrameH, frame) -- Create buttons and progress bars for the main menu section - outside the draw function
        if QSMenuTab == "Daily" then

            local QuestsCompleted = vgui.Create( "DProgressBar", frame)
            QuestsCompleted:SetSize(FrameW/6, FrameH/14)
            QuestsCompleted:SetPos( FrameW*0.413, FrameH*0.2 )
            QuestsCompleted:SetMin(0)
            QuestsCompleted:SetMax(QSMaxDaily)
            QuestsCompleted:SetValue(QSDailyCompleted)

            CurrentTime = os.date( "!%H") * 60 + os.date( "!%M") + os.date( "!%S")/60

            if CurrentTime >= 1440 then
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
            TimeLeft:SetValue(CurrentTime)



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
 ]]

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