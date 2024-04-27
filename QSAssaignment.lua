if SERVER then

    Quests = Quests or {}
    QuestFormat = QuestFormat or {}
    
    QSCRC = {1000, 2500, 5000, 10000, 20000}
    QSCRXP = {1000, 2500, 5000, 10000, 20000}

    QSDRerollCost = 25000
    QSWRerollCost = 100000
    QSMaxDaily = 4
    QSMaxWeekly = 6

    QuestTypes = {
        "ChatMessage",
        "NPCKill",
        "PlayerKill",
    }

    QSChallengeDecayRate = 0.8
    QSChallengeGrowthRate = 0.1

    util.AddNetworkString("QSDQAssaignmentCall")
    util.AddNetworkString("QSDQAssaignmentReturn")
    util.AddNetworkString("QSMenuCaller")
    util.AddNetworkString("QSStartQuestTracking")
    util.AddNetworkString("QSEndQuestTracking")
    util.AddNetworkString("QSIncrementQuestTracking")
    util.AddNetworkString("QSQuestCompleted")
    util.AddNetworkString("QSChallengeUpdate")
    util.AddNetworkString("QSDailyReroll")

    hook.Add("PlayerSay", "QuestMenuCall", function(ply,text)
        if string.find(text:lower(), "!quest") then
            net.Start("QSMenuCaller")
            net.Send(ply) -- Local Player --> Sends the local player the net msg to open the menu
        end
    end)

    function Quests:Assaign(Challenge, Type, DupeCheck, DupeLength) -- Needs structure generated
        if Type == "Daily" then
    
            local AssaignDaily = function(Challenge)
                
                return QSQuestList[math.random(8)]

            end

            local QSDQuest = AssaignDaily(Challenge)
            local i = 1
            while i <= DupeLength do
                if DupeCheck[i] == QSDQuest[2] then
                    i = 0
                    QSDQuest = AssaignDaily(Challenge)
                    
                end
                i = i +1
            end
            return QSDQuest
            
        elseif Type == "Weekly" then
            print("Assaigning Quests" .. Type)
        end
    end

    net.Receive("QSDQAssaignmentCall", function(len, ply)
        local QSType = net.ReadString()
        local QSDailyRefresh = false
        local QSDupeCheck = {}
        local QSDupeLength = 0
        local CurrentDate = os.date( "!%x", os.time() )
        local QSDCompleted = ply:GetPData("QSDCompleted", 0 )
        local QSPlayerLastConnect = ply:GetPData( "QSLastConnected", 0 )
        local QSChallenge = ply:GetPData( "QSChallenge", 0 ) * QSChallengeDecayRate

        local QSDQList = util.JSONToTable(ply:GetPData("QSDQList", nil ))

        ply:SetPData( "QSChallenge", QSChallenge)

        if QSPlayerLastConnect ~= CurrentDate then -- QSPlayerLastConnect ~= CurrentDate
            QSDailyRefresh = true
            ply:SetPData( "QSDCompleted", 0 )
            QSDCompleted = 0
            QSDQList = nil
            ply:SetPData( "QSLastConnected", CurrentDate )
        end

        net.Start("QSDQAssaignmentReturn")
        net.WriteFloat(QSChallenge)
        net.WriteInt(QSDRerollCost, 24)
        net.WriteInt(QSWRerollCost, 24)
        net.WriteInt(QSMaxDaily, 4)
        net.WriteInt(QSMaxWeekly, 4)
        net.WriteBool(QSDailyRefresh)
        net.WriteInt(QSDCompleted, 4)

        if QSDQList then

            for i = 1, QSMaxDaily do
                if QSDQList[i][10] ~= "Pending" then
                    QSDupeCheck[QSDupeLength + 1] = QSDQList[i][2]
                    QSDupeLength = QSDupeLength + 1
                    print("Progress Sent As: ")
                    print(QSDQList[i][11])
                    net.WriteTable(QSDQList[i], true)
                end
            end

            for i = 1, QSMaxDaily do
                if QSDQList[i][10] == "Pending" then
                    local QSDQ = Quests:Assaign(QSChallenge, QSType, QSDupeCheck, QSDupeLength)
                    QSDupeCheck[QSDupeLength + 1] = QSDQ[2]
                    QSDupeLength = QSDupeLength + 1
                    net.WriteTable(QSDQ, true)

                    QSDQList[i] = QSDQ
                end
            end
        else
            QSDQList = {}
            for i = 1, QSMaxDaily do

                local QSDQ = Quests:Assaign(QSChallenge, QSType, QSDupeCheck, QSDupeLength)
                QSDupeCheck[i] = QSDQ[2]
                QSDupeLength = QSDupeLength + 1
                net.WriteTable(QSDQ, true)

                QSDQList[i] = QSDQ
            end
        end
        ply:SetPData("QSDQList", util.TableToJSON(QSDQList))

        net.Send(ply)
        print("Give back Quests")
    end)

    QSQIncremented = function(ply, QTitle)
        
        local QSDQList = util.JSONToTable(ply:GetPData("QSDQList", nil))
        for i = 1, QSMaxDaily do
            if QSDQList[i][2] == QTitle then
                QSDQList[i][10] = "Base"
                print("Set new state")
                print(QSDQList[i][11])
                QSDQList[i][11] = QSDQList[i][11] + 1
                print("Set new Progress")
            end
        end
        ply:SetPData("QSDQList", util.TableToJSON(QSDQList))

        net.Start("QSIncrementQuestTracking")
        net.WriteString(QTitle)
        net.Send(ply) -- Local Player --> Sends the local player the net msg
    end

    net.Receive("QSStartQuestTracking", function(len, ply)
        local QTitle = net.ReadString()
        local QType = net.ReadString()
        local QTarget = net.ReadString()
        
        if QType == "ChatMessage" then
            hook.Add("PlayerSay", ply:Nick() .. QTitle, function(ply, text)
                if string.find(text:lower(), QTarget) then
                    QSQIncremented(ply, QTitle)
                end
            end)
        end
    end)

    net.Receive("QSEndQuestTracking", function(len, ply)
        local QTitle = net.ReadString()
        local QType = net.ReadString()

        if QType == "ChatMessage" then
            hook.Remove("PlayerSay", ply:Nick() .. QTitle)
            
        end
    end)

    net.Receive("QSQuestCompleted", function(len, ply)
        local CQTitle = net.ReadString()
        local QSMaxDaily = net.ReadInt(4)
        local QSDCompleted = ply:GetPData("QSDCompleted", 0)
        local QSChallenge = ply:GetPData( "QSChallenge", 0 )
        local QSDQList = util.JSONToTable(ply:GetPData("QSDQList", nil))
        for i = 1, QSMaxDaily do
            if QSDQList[i][2] == CQTitle then
                QSDQList[i][10] = "Claimed"
                QSDQList[i][11] = QSDQList[i][5]
                QSChallenge = QSChallenge + QSChallengeGrowthRate * QSDQList[i][1]
                ply:SetPData( "QSChallenge", QSChallenge )
            end
        end

        ply:SetPData("QSDQList", util.TableToJSON(QSDQList))
        ply:SetPData( "QSDCompleted", ply:GetPData( "QSDCompleted", 0 ) + 1)
        net.Start("QSChallengeUpdate")
        net.WriteFloat(QSChallenge)
        net.Send(ply)

        if QSDCompleted == QSMaxDaily then
            print("BIG BOI WELL DONE")
        end

        -- Give credits and give XP

    end)

    QuestFormat.__index = QuestFormat

    function QuestFormat:new(o, Challenge, Title, Description, Condition, Goal, QType, QTarget)
        o = {
        Challenge,
        Title,
        Description,
        Condition,
        Goal,
        QSCRC[Challenge],
        QSCRXP[Challenge],
        QuestTypes[QType],
        QTarget,
        "Pending",
        0
        }
        setmetatable(o, self)
        return o
    end
    
    function Quests:new(o)
        o = o or {}   -- create object if user does not provide one
        setmetatable(o, self)
        self.__index = self
        return o
    end
    
    QSQuestList = {
        QuestFormat:new(nil, 1, "Greet the Server", "Say something in OOC using //", "Send 1 message in OOC", 1, 1, "//"),
        QuestFormat:new(nil, 1, "Greet Those Far away", "Say something over a distance with /y", "Send 1 message with Yell", 1, 1, "/y"),
        QuestFormat:new(nil, 1, "Greet Those Nearby", "Say something in chat", "Send 1 message in chat", 1, 1, " "),
        QuestFormat:new(nil, 1, "Greet Those closet to you", "Say something to those close with /w", "Send 1 message with Whispher", 1, 1, "/w"),
        QuestFormat:new(nil, 2, "Greet the Server 2", "Say something in OOC using // or /ooc", "Send 5 messages in OOC", 5, 1, "//"),
        QuestFormat:new(nil, 2, "Greet Those Far away 2", "Say something over a distance with /y", "Send 5 messages with Yell", 5, 1, "/y"),
        QuestFormat:new(nil, 2, "Greet Those Nearby 2", "Say something in chat", "Send 5 messages in chat", 5, 1, " "),
        QuestFormat:new(nil, 2, "Greet Those closet to you 2", "Say something to those close with /w", "Send 5 messages with Whispher", 5, 1, "/w")
    }

    QSChallengeLists = {}
    for i =1, #QSCRC do
        QSChallengeLists[i] = {} 
    end
    for i = 1, #QSQuestList do
        QSChallengeLists[QSQuestList[i][1]][#QSChallengeLists[QSQuestList[i][1]]] = QSQuestList[i]
    end

end