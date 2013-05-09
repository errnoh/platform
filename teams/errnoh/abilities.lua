local herobot = _G.object

Collection = { tAbilities = {},
               add = function (self, sHero, sAbility, nLevel, nCasttime, nCooldown, nMana, nRange, nDamage, sTarget, nStun)
                 if not self.tAbilities[sHero] then
                     self.tAbilities[sHero] = {}
                 end
                 if not self.tAbilities[sHero][sAbility] then
                     self.tAbilities[sHero][sAbility] = {}
                 end
                 self.tAbilities[sHero][sAbility][nLevel]={casttime=nCasttime, cooldown=nCooldown, mana=nMana, range=nRange, damage=nDamage, stun=nStun}
               end
             }

-- Jokin tyyli merkata meleerangea muuta kuin 0? Myös radius vs range

-- (self, sHero, sAbility, nLevel, nCasttime, nCooldown, nMana, nRange, nDamage)
Collection:add("rampage", "stampede", 1, 1, 30, 100, 900000, 100, "entity", 0.95)
Collection:add("rampage", "stampede", 2, 1, 30, 100, 900000, 140, "entity", 1.15)
Collection:add("rampage", "stampede", 3, 1, 30, 100, 900000, 180, "entity", 1.35)
Collection:add("rampage", "stampede", 4, 1, 30, 100, 900000, 220, "entity", 1.55)
Collection:add("rampage", "mightoftheherd", 1, 0, 15, 50, 300, 0, "self")
Collection:add("rampage", "mightoftheherd", 2, 0, 15, 50, 300, 0, "self")
Collection:add("rampage", "mightoftheherd", 3, 0, 15, 50, 300, 0, "self")
Collection:add("rampage", "mightoftheherd", 4, 0, 15, 50, 300, 0, "self")
Collection:add("rampage", "hornedstrike", 1, 0, 10, 0, 0, 120, "passive")
Collection:add("rampage", "hornedstrike", 2, 0, 10, 0, 0, 120, "passive")
Collection:add("rampage", "hornedstrike", 3, 0, 10, 0, 0, 120, "passive")
Collection:add("rampage", "hornedstrike", 4, 0, 10, 0, 0, 120, "passive")
Collection:add("rampage", "thechainsthatbind", 1, 0.47, 105, 175, 200, 0, "entity")
Collection:add("rampage", "thechainsthatbind", 2, 0.47, 90, 200, 200, 0, "entity")
Collection:add("rampage", "thechainsthatbind", 3, 0.47, 75, 225, 200, 0, "entity")

Collection:add("moonqueen", "moonbeam", 1, 1, 6, 120, 800, 75, "entity", 0.7)
Collection:add("moonqueen", "moonbeam", 2, 1, 6, 120, 800, 150, "entity", 0.8)
Collection:add("moonqueen", "moonbeam", 3, 1, 6, 120, 800, 225, "entity", 0.9)
Collection:add("moonqueen", "moonbeam", 4, 1, 6, 120, 800, 300, "entity", 1)
Collection:add("moonqueen", "multistrike", 1, 0, 1, 0, 0, 0, "toggle")
Collection:add("moonqueen", "multistrike", 2, 0, 1, 0, 0, 0, "toggle")
Collection:add("moonqueen", "multistrike", 3, 0, 1, 0, 0, 0, "toggle")
Collection:add("moonqueen", "multistrike", 4, 0, 1, 0, 0, 0, "toggle")
Collection:add("moonqueen", "lunarglow", 1, 0, 1, 0, 0, 0, "no")
Collection:add("moonqueen", "lunarglow", 2, 0, 1, 0, 0, 0, "no")
Collection:add("moonqueen", "lunarglow", 3, 0, 1, 0, 0, 0, "no")
Collection:add("moonqueen", "lunarglow", 4, 0, 1, 0, 0, 0, "no")
Collection:add("moonqueen", "moonfinale", 1, 1, 160, 150, 700, 1200, "self")
Collection:add("moonqueen", "moonfinale", 2, 1, 140, 200, 700, 1200, "self")
Collection:add("moonqueen", "moonfinale", 3, 1, 120, 250, 700, 1200, "self")

Collection:add("plaguerider", "contagion", 1, 1.1, 9.25, 125, 600, 50, "entity")
Collection:add("plaguerider", "contagion", 2, 1.1, 9.25, 150, 600, 100, "entity")
Collection:add("plaguerider", "contagion", 3, 1.1, 9.25, 170, 600, 125, "entity")
Collection:add("plaguerider", "contagion", 4, 1.1, 9.25, 190, 600, 175, "entity")
Collection:add("plaguerider", "cursedshield", 1, 1.1, 10, 25, 800, 0, "entity")
Collection:add("plaguerider", "cursedshield", 2, 1.1, 10, 25, 800, 0, "entity")
Collection:add("plaguerider", "cursedshield", 3, 1.1, 10, 25, 800, 0, "entity")
Collection:add("plaguerider", "cursedshield", 4, 1.1, 10, 25, 800, 0, "entity")
Collection:add("plaguerider", "extinguish", 1, 1.1, 55, 25, 400, 0, "entity")
Collection:add("plaguerider", "extinguish", 2, 1.1, 50, 25, 400, 0, "entity")
Collection:add("plaguerider", "extinguish", 3, 1.1, 45, 25, 400, 0, "entity")
Collection:add("plaguerider", "extinguish", 4, 1.1, 40, 25, 400, 0, "entity")
Collection:add("plaguerider", "plaguecarrier", 1, 1.1, 145, 200, 750, 280, "entity")
Collection:add("plaguerider", "plaguecarrier", 2, 1.1, 115, 350, 750, 370, "entity")
Collection:add("plaguerider", "plaguecarrier", 3, 1.1, 60, 500, 750, 460, "entity")
