function QuestFormat:new (o, Challenge, Title, Description, Req, Condition, ConditionCheck)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.Progress = 0
    self.Challenge = Challenge
    self.Title = Title
    self.Description = Description
    self.Req = Req
    self.Condition = Conditionw
    self.Check = ConditionCheck
    function QuestFormat:ActivateCondition () = 
        hook.add(self.Condition, "IncrementProgress", function (self))
            if self.Check then
                self.Progress = self.Progress + 1
            end
        end
    end
end

local Quests = {



}

QuestSystem = {}

function QuestSystem:QuestAssaign(Quest1, Quest2, Quest3, Quest4, Quest5, Quest6, Challenge, Type)
    print("Assaigning Quests with a challenge of " .. tostring(Challenge))
    

    end
        