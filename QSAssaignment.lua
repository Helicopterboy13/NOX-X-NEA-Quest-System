Quests = Quests or {}
QuestFormat = QuestFormat or {}

function QuestFormat:new(o, Challenge, Title, Description, Req, Condition, Conditional)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.Progress = 0
    self.Challenge = Challenge
    self.Title = Title
    self.Description = Description
    self.Req = Req
    self.Condition = Condition
    self.Conditional = Conditional
end
    
function QuestFormat:Increment()
    if self.Progress == -1 then
        QuestFormat:Remove()

    elseif self.Progress >= self.Req then
        self.Progress = -1
        QuestFormat:Remove()
        print("Completed: " .. self.Title)
        QuestFormat:Completed()

    else
        self.Progress = self.Progress + 1
        print("Progress made on: " .. self.Title)
    end
end

function QuestFormat:Check(ply)
    if self.conditional == true then
        QuestFormat:Increment()
    end
end

function QuestFormat:Activate() 
    hook.add(self.Condition, "IncrementProgress", QuestFormat:Check(ply))
end

function QuestFormat:Remove()
    hook.remove(self.Condition, "IncrementProgress")
end

function QuestFormat:Completed()
    print("Well Done you Completed a Quest of Challenge Rating " .. string(self.Challenge))
end

local Quests = {
    MessageQuest = QuestFormat:new(nil, 1, "Greet the Server", "Say hello to everyone in OOC (Out of Character) Chat using // or /ooc", "Send 1 message in OOC",
     "PlayerSay", string.find(text:lower(), text, "//") )


}



function Quests:Assaign(Quest1, Quest2, Quest3, Quest4, Quest5, Quest6, Challenge, Type)
    print("Assaigning Quests with a challenge of " .. tostring(Challenge))
    if Type == "Daily" then
        print("Assaigning Quests" .. Type)
        Quest1 = Quests.MessageQuest
        return Quest1
    elseif Type == "Weekly" then
        print("Assaigning Quests" .. Type)
    end
end

function Quests:Test()
    print("CrossCall Works")
end