Quests = Quests or {}
QuestFormat = QuestFormat or {}

function QuestFormat:new (o, Challenge, Title, Description, Req, Condition, Conditional ConditionCheck)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.Progress = 0
    self.Challenge = Challenge
    self.Title = Title
    self.Description = Description
    self.Req = Req
    self.Check = ConditionCheck
    self.Condition = Condition
    function QuestFormat:ActivateCondition() 
        hook.add(self.Condition, "IncrementProgress", function(self,ply,Conditional)
            if self.Check then
                self.Progress = self.Progress + 1
            end
        end)
    end
end

local Quests = {
    MessageQuest = QuestFormat:new(nil, 1, "Greet the Server", "Say hello to everyone in OOC (Out of Character) Chat using // or /ooc", "Send 1 message in OOC", "PlayerSay", string.find(text:lower(), text, "//") )


}



Quests:Assaign = function(Quest1, Quest2, Quest3, Quest4, Quest5, Quest6, Challenge, Type)
    print("Assaigning Quests with a challenge of " .. tostring(Challenge))
    if Type == "Daily" then
        print("Assaigning Quests" .. Type)
        Quest1 = MessageQuest
        return Quest1
    elseif Type == "Weekly" then
        print("Assaigning Quests" .. Type)
    end
end