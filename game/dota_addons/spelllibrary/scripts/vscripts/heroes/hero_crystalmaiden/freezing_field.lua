--[[
	Author: kritth
	Date: 1.1.2015.
	Order the explosion in clockwise direction
]]
function freezing_field_order_explosion( keys )
	Timers:CreateTimer( 0.1, function()
		keys.ability:ApplyDataDrivenModifier( keys.caster, keys.caster, "modifier_freezing_field_northwest_thinker_datadriven", {} )
		end )
		
	Timers:CreateTimer( 0.2, function()
		keys.ability:ApplyDataDrivenModifier( keys.caster, keys.caster, "modifier_freezing_field_northeast_thinker_datadriven", {} )
		end )
	
	Timers:CreateTimer( 0.3, function()
		keys.ability:ApplyDataDrivenModifier( keys.caster, keys.caster, "modifier_freezing_field_southeast_thinker_datadriven", {} )
		end )
	
	Timers:CreateTimer( 0.4, function()
		keys.ability:ApplyDataDrivenModifier( keys.caster, keys.caster, "modifier_freezing_field_southwest_thinker_datadriven", {} )
		end )
end

--[[
	Author: kritth
	Date: 1.1.2015.
	Apply the explosion
	NOTE: Need to fire sound at impact location insteads of caster
]]
function freezing_field_explode( keys )
	local ability = keys.ability
	local caster = keys.caster
	local casterLocation = keys.caster:GetAbsOrigin()
	local abilityDamage = ability:GetLevelSpecialValueFor( "damage", ( ability:GetLevel() - 1 ) )
	local minDistance = ability:GetLevelSpecialValueFor( "explosion_min_dist", ( ability:GetLevel() - 1 ) )
	local maxDistance = ability:GetLevelSpecialValueFor( "explosion_max_dist", ( ability:GetLevel() - 1 ) )
	local radius = ability:GetLevelSpecialValueFor( "explosion_radius", ( ability:GetLevel() - 1 ) )
	local directionConstraint = keys.section
	local modifierName = "modifier_freezing_field_debuff_datadriven"
	local particleName = "particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_explosion.vpcf"
	local soundEventName = "hero_Crystal.freezingField.explosion"
	
	-- Get random point
	local castDistance = RandomInt( minDistance, maxDistance )
	local angle = RandomInt( 0, 90 )
	local dy = castDistance * math.sin( angle )
	local dx = castDistance * math.cos( angle )
	local attackPoint = Vector( 0, 0, 0 )
	
	if directionConstraint == 0 then			-- NW
		attackPoint = Vector( casterLocation.x - dx, casterLocation.y + dy, casterLocation.z )
	elseif directionConstraint == 1 then		-- NE
		attackPoint = Vector( casterLocation.x + dx, casterLocation.y + dy, casterLocation.z )
	elseif directionConstraint == 2 then		-- SE
		attackPoint = Vector( casterLocation.x - dx, casterLocation.y - dy, casterLocation.z )
	else										-- SW
		attackPoint = Vector( casterLocation.x - dx, casterLocation.y - dy, casterLocation.z )
	end
	
	-- From here onwards might be possible to port it back to datadriven through modifierArgs with point but for now leave it as is
	-- Loop through basic units
	local units = FindUnitsInRadius( caster:GetTeamNumber(), attackPoint, caster, radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
	for k, v in pairs( units ) do
		local damageTable =
		{
			victim = v,
			attacker = caster,
			damage = abilityDamage,
			damage_type = keys.ability:GetAbilityDamageType()
		}
		ApplyDamage( damageTable )
	end
	
	-- Loop through hero units
	local units = FindUnitsInRadius( caster:GetTeamNumber(), attackPoint, caster, radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
	for k, v in pairs( units ) do
		local damageTable =
		{
			victim = v,
			attacker = caster,
			damage = abilityDamage,
			damage_type = keys.ability:GetAbilityDamageType()
		}
		ApplyDamage( damageTable )
	end
	
	-- Fire effect
	local fxIndex = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( fxIndex, 0, attackPoint )
	ParticleManager:ReleaseParticleIndex( fxIndex )
	
	-- Fire sound
	StartSoundEvent( soundEventName, caster )
end
