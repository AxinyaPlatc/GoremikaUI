local moneyHistory = {};
local update_throttle = 0;

function GoremikaUI_OnLoad(self)
    self:RegisterForDrag("LeftButton");
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    print("|cffFFD700GoremikaUI:|r Loaded and ready to work!");
end

function GoremikaUI_OnEvent(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        updateMoney(self);
    end
end

function GoremikaUI_OnUpdate(self, elapsed)
    update_throttle = update_throttle + elapsed;
    if update_throttle < 1 then return; end
    update_throttle = 0;
    updateHealthAndMana(self);
    updateMoney(self);
    updateMoneyRate(self);
end

function updateHealthAndMana(self)
    local hp = UnitHealth("player");
    local hpMax = UnitHealthMax("player");
    local mp = UnitPower("player", 0);
    local mpMax = UnitPowerMax("player", 0);
    _G[self:GetName().."_HP"]:SetText(string.format("HP: %d / %d", hp, hpMax));
    _G[self:GetName().."_MP"]:SetText(string.format("MP: %d / %d", mp, mpMax));
end

function updateMoney(self)
    local totalCopper = GetMoney();
    local gold = math.floor(totalCopper / 10000);
    local silver = math.floor(math.fmod(totalCopper, 10000) / 100);
    local copper = math.fmod(totalCopper, 100);
    local moneyText = string.format("Money: |cffFFD700%dг|r |cffC7C7CF%dс|r |cffEDA55F%dм|r", gold, silver, copper);
    _G[self:GetName().."_Money"]:SetText(moneyText);
end

function updateMoneyRate(self)
    local currentTime = GetTime(); 
    local currentMoney = GetMoney();
    table.insert(moneyHistory, {time = currentTime, amount = currentMoney});
    while moneyHistory[1] and currentTime - moneyHistory[1].time > 60 do
        table.remove(moneyHistory, 1);
    end

    if #moneyHistory > 1 then
        local moneyThen = moneyHistory[1].amount;
        local rate = currentMoney - moneyThen;
        local rateText;
        if rate > 0 then
            rateText = string.format("|cff00FF00+ %dm/min|r", rate);
        elseif rate < 0 then
            rateText = string.format("|cffff0000- %dm/min|r", -rate);
        else
            rateText = "0m/min";
        end
        _G[self:GetName().."_Rate"]:SetText("Rate: " .. rateText);
    end
end
