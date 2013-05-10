local herobot = _G.object

Echo("Loading abilities...")

Collection = { tAbilities = {},
               add = function (self, sHero, sAbility, nLevel, nCasttime, nCooldown, nMana, nRange, nDamage, sTarget, sType, nStun)
                 if not self.tAbilities[sAbility] then
                     self.tAbilities[sAbility] = {}
                 end
                 self.tAbilities[sAbility][nLevel]={casttime=nCasttime, cooldown=nCooldown, mana=nMana, range=nRange, damage=nDamage, type=sType, stun=nStun}
               end
             }

-- Jokin tyyli merkata meleerangea muuta kuin 0? Myös radius vs range

-- (self, sHero, sAbility, nLevel, nCasttime, nCooldown, nMana, nRange, nDamage)
Collection:add("rampage", "Ability_Rampage1", 1, 1, 30, 100, 900000, 100, "entity", "physical", 0.95)
Collection:add("rampage", "Ability_Rampage1", 2, 1, 30, 100, 900000, 140, "entity", "physical", 1.15)
Collection:add("rampage", "Ability_Rampage1", 3, 1, 30, 100, 900000, 180, "entity", "physical", 1.35)
Collection:add("rampage", "Ability_Rampage1", 4, 1, 30, 100, 900000, 220, "entity", "physical", 1.55)
Collection:add("rampage", "Ability_Rampage2", 1, 0, 15, 50, 300, 0, "self", "physical")
Collection:add("rampage", "Ability_Rampage2", 2, 0, 15, 50, 300, 0, "self", "physical")
Collection:add("rampage", "Ability_Rampage2", 3, 0, 15, 50, 300, 0, "self", "physical")
Collection:add("rampage", "Ability_Rampage2", 4, 0, 15, 50, 300, 0, "self", "physical")
Collection:add("rampage", "Ability_Rampage3", 1, 0, 10, 0, 0, 120, "passive", "")
Collection:add("rampage", "Ability_Rampage3", 2, 0, 10, 0, 0, 120, "passive", "")
Collection:add("rampage", "Ability_Rampage3", 3, 0, 10, 0, 0, 120, "passive", "")
Collection:add("rampage", "Ability_Rampage3", 4, 0, 10, 0, 0, 120, "passive", "")
Collection:add("rampage", "Ability_Rampage4", 1, 0.47, 105, 175, 200, 0, "entity", "physical")
Collection:add("rampage", "Ability_Rampage4", 2, 0.47, 90, 200, 200, 0, "entity", "physical")
Collection:add("rampage", "Ability_Rampage4", 3, 0.47, 75, 225, 200, 0, "entity", "physical")

Collection:add("moonqueen", "Ability_Krixi1", 1, 1, 6, 120, 800, 75, "entity", "magic", 0.7)
Collection:add("moonqueen", "Ability_Krixi1", 2, 1, 6, 120, 800, 150, "entity", "magic", 0.8)
Collection:add("moonqueen", "Ability_Krixi1", 3, 1, 6, 120, 800, 225, "entity", "magic", 0.9)
Collection:add("moonqueen", "Ability_Krixi1", 4, 1, 6, 120, 800, 300, "entity", "magic", 1)
Collection:add("moonqueen", "Ability_Krixi2", 1, 0, 1, 0, 0, 0, "toggle", "physical")
Collection:add("moonqueen", "Ability_Krixi2", 2, 0, 1, 0, 0, 0, "toggle", "physical")
Collection:add("moonqueen", "Ability_Krixi2", 3, 0, 1, 0, 0, 0, "toggle", "physical")
Collection:add("moonqueen", "Ability_Krixi2", 4, 0, 1, 0, 0, 0, "toggle", "physical")
Collection:add("moonqueen", "Ability_Krixi3", 1, 0, 1, 0, 0, 0, "no", "")
Collection:add("moonqueen", "Ability_Krixi3", 2, 0, 1, 0, 0, 0, "no", "")
Collection:add("moonqueen", "Ability_Krixi3", 3, 0, 1, 0, 0, 0, "no", "")
Collection:add("moonqueen", "Ability_Krixi3", 4, 0, 1, 0, 0, 0, "no", "")
Collection:add("moonqueen", "Ability_Krixi4", 1, 1, 160, 150, 700, 1200, "self", "magic")
Collection:add("moonqueen", "Ability_Krixi4", 2, 1, 140, 200, 700, 1200, "self", "magic")
Collection:add("moonqueen", "Ability_Krixi4", 3, 1, 120, 250, 700, 1200, "self", "magic")

Collection:add("plaguerider", "contagion", 1, 1.1, 9.25, 125, 600, 50, "entity", "magic")
Collection:add("plaguerider", "contagion", 2, 1.1, 9.25, 150, 600, 100, "entity", "magic")
Collection:add("plaguerider", "contagion", 3, 1.1, 9.25, 170, 600, 125, "entity", "magic")
Collection:add("plaguerider", "contagion", 4, 1.1, 9.25, 190, 600, 175, "entity", "magic")
Collection:add("plaguerider", "cursedshield", 1, 1.1, 10, 25, 800, 0, "entity", "magic")
Collection:add("plaguerider", "cursedshield", 2, 1.1, 10, 25, 800, 0, "entity", "magic")
Collection:add("plaguerider", "cursedshield", 3, 1.1, 10, 25, 800, 0, "entity", "magic")
Collection:add("plaguerider", "cursedshield", 4, 1.1, 10, 25, 800, 0, "entity", "magic")
Collection:add("plaguerider", "extinguish", 1, 1.1, 55, 25, 400, 0, "entity", "magic")
Collection:add("plaguerider", "extinguish", 2, 1.1, 50, 25, 400, 0, "entity", "magic")
Collection:add("plaguerider", "extinguish", 3, 1.1, 45, 25, 400, 0, "entity", "magic")
Collection:add("plaguerider", "extinguish", 4, 1.1, 40, 25, 400, 0, "entity", "magic")
Collection:add("plaguerider", "plaguecarrier", 1, 1.1, 145, 200, 750, 280, "entity", "magic")
Collection:add("plaguerider", "plaguecarrier", 2, 1.1, 115, 350, 750, 370, "entity", "magic")
Collection:add("plaguerider", "plaguecarrier", 3, 1.1, 60, 500, 750, 460, "entity", "magic")

Echo("Loaded abilities.")