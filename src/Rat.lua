require "GlobalVariables"
require "MessageDispatchCenter"
require "Helper"
require "AttackCommand"

local file = "model/rat/rat.c3b"

Rat = class("Rat", function()
    return require "Actor".create()
end)

function Rat:ctor()
    self._useWeaponId = 0
    self._useArmourId = 0
    self._particle = nil
    self._attack = 400  
    self._racetype = EnumRaceType.MONSTER
    self._speed = 300
    self._attackMinRadius = 0
    self._attackMaxRadius = 130
    self._radius = 120
    self._attackRange = 130

    self:init3D()
    self:initActions()
end

function Rat.create()
    local ret = Rat.new()
    ret:initAttackInfo()
    ret._AIEnabled = true

    --this update function do not do AI
    function update(dt)
        ret:baseUpdate(dt)
        ret:stateMachineUpdate(dt)
        ret:movementUpdate(dt)
    end
    ret:scheduleUpdateWithPriorityLua(update, 0.5) 
    return ret
end

function Rat:initAttackInfo()
    --build the attack Infos
    self._normalAttack = {
        minRange = self._attackMinRadius,
        maxRange = self._attackMaxRadius,
        angle    = DEGREES_TO_RADIANS(self._attackAngle),
        knock    = self._attackKnock,
        damage   = self._attack,
        mask     = self._racetype,
        duration = 0, -- 0 duration means it will be removed upon calculation
        speed    = 0
    }
    self._specialAttack = {
        minRange = self._attackMinRadius,
        maxRange = self._attackMaxRadius+50,
        angle    = DEGREES_TO_RADIANS(150),
        knock    = self._attackKnock,
        damage   = self._attack,
        mask     = self._racetype,
        duration = 0,
        speed    = 0
    }
end

function Rat:attackUpdate(dt)
    self._attackTimer = self._attackTimer + dt
    if self._attackTimer > self._attackFrequency then
        self._attackTimer = self._attackTimer - self._attackFrequency
        local function playIdle()
            self:playAnimation("idle", true)
            self._cooldown = false
        end
        --time for an attack, which attack should i do?
        local function createCol()
            self:normalAttack()
        end
        local attackAction = cc.Sequence:create(self._action.attack1:clone(),cc.CallFunc:create(createCol),self._action.attack2:clone(),cc.CallFunc:create(playIdle))
        self._sprite3d:stopAction(self._curAnimation3d)
        self._sprite3d:runAction(attackAction)
        self._curAnimation = attackAction
        self._cooldown = true
    end
end
function Rat:_findEnemy()
    local shortest = self._searchDistance
    local target = nil
    local allDead = true
    for val = HeroManager.first, HeroManager.last do
        local temp = HeroManager[val]
        local dis = cc.pGetDistance(self._myPos,getPosTable(temp))
        if temp._isalive then
            if dis < shortest then
                shortest = dis
                target = temp
            end
            allDead = false
        end
    end
    return target, allDead
end

function Rat:init3D()
    self._sprite3d = cc.EffectSprite3D:create(file)
    self._sprite3d:setTexture("model/Rat/shenti.jpg")
    self._sprite3d:setScale(10)
    self._sprite3d:addEffect(cc.V3(0,0,0),0.005, -1)
    self:addChild(self._sprite3d)
    self._sprite3d:setRotation3D({x = 90, y = 0, z = 0})        
    self._sprite3d:setRotation(-90)
end

-- init Rat animations=============================
do
    Rat._action = {
        idle = createAnimation(file,0,23,0.7),
        knocked = createAnimation(file,30,37,0.7),
        dead = createAnimation(file,41,76,1),
        attack1 = createAnimation(file,81,99,0.7),
        attack2 = createAnimation(file,99,117,0.7),
        walk = createAnimation(file,122,142,0.7)
    }
end
-- end init Rat animations========================
function Rat:initActions()
    self._action = Rat._action
end