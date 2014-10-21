require "Manager"
require "Knight"
require "Mage"
require "Monster"
require "Actor"
require "GlobalVariables"
require "Piglet"
require "Archer"

local heroOriginPositionX = -2900
local gloableZOrder = 1
local monsterCount = {dragon=3,slime=3,piglet=3,rat=3}
local minMonsterCount = 2

local GameMaster = class("GameMaster")

local size = cc.Director:getInstance():getWinSize()

function GameMaster:ctor()
	self._totaltime = 0
	self._logicFrq = 1.0
end

function GameMaster.create()
	local gm = GameMaster.new()
	gm:init()

	return gm
end

function GameMaster:init()
	self:AddHeros()
	self:addMonsters()
end

function GameMaster:update(dt)
    self._totaltime = self._totaltime + dt
	if self._totaltime > self._logicFrq then
		self._totaltime = self._totaltime - self._logicFrq
		self:logicUpdate()
	end
end

function GameMaster:logicUpdate()
    local max_const_count = monsterCount.piglet
    local last_count = List.getSize(DragonPool) + List.getSize(SlimePool) + List.getSize(SlimePool) + List.getSize(PigletPool)
    if max_const_count - last_count < minMonsterCount then
    	self:randomShowMonster()
    end
end

function GameMaster:AddHeros()

	local knight = Knight:create()
   	knight:setPosition(heroOriginPositionX+500, 400)
    currentLayer:addChild(knight)
    knight:idleMode()
    List.pushlast(HeroManager, knight)

	local mage = Mage:create()
   	mage:setPosition(heroOriginPositionX+500, 200)
   	currentLayer:addChild(mage)
   	mage:idleMode()
   	List.pushlast(HeroManager, mage)
   	
    local archer = Archer:create()
    archer:setPosition(heroOriginPositionX+300, 100)
    currentLayer:addChild(archer)
    archer:idleMode()
    List.pushlast(HeroManager, archer)   	

end

function GameMaster:addMonsters()
--	self:addDragon()
	-- self:addSlime()
	 self:addPiglet()
--	 self:addRat()
end

function GameMaster:addDragon()
	for var=1, monsterCount.dragon do
		local dragon = Dragon:create()
		dragon:retain()
		List.pushlast(DragonPool,dragon)
	end 
end

function GameMaster:addSlime()
    for var=1, monsterCount.slime do
    	local slime = Slime:create()
    	slime:retain()
    	List.pushlast(SlimePool,slime)
    end   
end

function GameMaster:addPiglet()
    for var=1, monsterCount.piglet do
    	local piglet = Piglet:create()
    	piglet:retain()
    	List.pushlast(PigletPool,piglet)
    end   
end

function GameMaster:addRat()
    for var=1, monsterCount.rat do
    	local rat = Rat:create()
    	rat:retain()
    	List.pushlast(RatPool,rat)
    end   
end

function GameMaster:ShowDragon()
    if List.getSize(DragonPool) ~= 0 then
        local dragon  = List.poplast(DragonPool)
        dragon:setPosition({x=800,y=0})
        currentLayer:addChild(dragon)
        List.pushlast(MonsterManager, dragon)
    end
end

function GameMaster:ShowPiglet()
    if List.getSize(PigletPool) ~= 0 then
        local piglet = List.popfirst(PigletPool)
        piglet:setPosition({x=800,y=100})
        currentLayer:addChild(piglet)
        List.pushlast(MonsterManager, piglet)
    end
end

function GameMaster:ShowSlime()
	if List.getSize(SlimePool) ~= 0 then
        local slime = List.popfirst(SlimePool)
        slime:setPosition({x=800,y=100})
        currentLayer:addChild(slime)
        List.pushlast(MonsterManager, slime)
    end
end

function GameMaster:ShowRat()
	if List.getSize(RatPool) ~= 0 then
        local rat = List.popfirst(RatPool)
        rat:setPosition({x=800,y=100})
        currentLayer:addChild(rat)
        List.pushlast(MonsterManager, rat)
    end
end

function GameMaster:randomShowMonster()
	local random_var = math.random()
	random_var = 0.4
	if random_var<0.25 then
		self:ShowDragon()
	elseif random_var<0.5 then
		self:ShowPiglet()
	elseif random_var<0.75 then
		self:ShowSlime()
	else
		self:ShowRat()
	end
end

return GameMaster