if (!game.Singleplayer() and SERVER) then return end

local animations = {}

animations.playing = {}
animations.playing = animations.playing or {}
animations.registered = animations.registered or {}

do
	local old_types = {
		[0] = "gesture", -- Gestures are keyframed animations that use the current position and angles of the bones. They play once and then stop automatically.
		[1] = "posture", -- Postures are static animations that use the current position and angles of the bones. They stay that way until manually stopped. Use TimeToArrive if you want to have a posture lerp.
		[2] = "stance", -- Stances are keyframed animations that use the current position and angles of the bones. They play forever until manually stopped. Use RestartFrame to specify a frame to go to if the animation ends (instead of frame 1).
		[3] = "sequence", -- Sequences are keyframed animations that use the reference pose. They play forever until manually stopped. Use RestartFrame to specify a frame to go to if the animation ends (instead of frame 1).
	}

	local old_interpolations = {
		[0] = "linear", -- Straight linear interp.
		[1] = "cosine", -- Best compatability / quality balance.
		[1] = "cubic", -- Overall best quality blending but may cause animation frames to go 'over the top'.
	}

	function animations.ConvertOldData(data)
		if tonumber(data.Type) then
			data.Type = tonumber(data.Type)
		end

		if tonumber(data.Interpolation) then
			data.Interpolation = tonumber(data.Interpolation)
		end


		if type(data.Type) == "number" then
			data.Type = old_types[data.Type]
		end

		if type(data.Interpolation) == "number" then
			data.Interpolation = old_interpolations[data.Interpolation]
		end

		data.Type = data.Type or "sequence"
		data.Interpolation = data.Interpolation or "cosine"
	end
end

local eases = {}

do
	local c1 = 1.70158
	local c3 = c1 + 1
	local c2 = c1 * 1.525
	local c4 = ( 2 * math.pi ) / 3
	local c5 = ( 2 * math.pi ) / 4.5
	local n1 = 7.5625
	local d1 = 2.75
	local pi = math.pi
	local cos = math.cos
	local sin = math.sin
	local sqrt = math.sqrt


	eases.InSine = function(x)
		return 1 - cos( ( x * pi ) / 2 )
	end

	eases.OutSine = function(x)
		return sin( ( x * pi ) / 2 )
	end

	eases.InOutSine = function(x)
		return -( cos( pi * x ) - 1 ) / 2
	end

	eases.InQuad = function(x)
		return x ^ 2
	end

	eases.OutQuad = function(x)
		return 1 - ( 1 - x ) * ( 1 - x )
	end

	eases.InOutQuad = function(x)
		return x < 0.5 && 2 * x ^ 2 || 1 - ( ( -2 * x + 2 ) ^ 2 ) / 2
	end

	eases.InCubic = function(x)
		return x ^ 3
	end

	eases.OutCubic = function(x)
		return 1 - ( ( 1 - x ) ^ 3 )
	end

	eases.InOutCubic = function(x)
		return x < 0.5 && 4 * x ^ 3 || 1 - ( ( -2 * x + 2 ) ^ 3 ) / 2
	end

	eases.InQuart = function(x)
		return x ^ 4
	end

	eases.OutQuart = function(x)
		return 1 - ( ( 1 - x ) ^ 4 )
	end

	eases.InOutQuart = function(x)
		return x < 0.5 && 8 * x ^ 4 || 1 - ( ( -2 * x + 2 ) ^ 4 ) / 2
	end

	eases.InQuint = function(x)
		return x ^ 5
	end

	eases.OutQuint = function(x)
		return 1 - ( ( 1 - x ) ^ 5 )
	end

	eases.InOutQuint = function(x)
		return x < 0.5 && 16 * x ^ 5 || 1 - ( ( -2 * x + 2 ) ^ 5 ) / 2
	end

	eases.InExpo = function(x)
		return x == 0 && 0 || ( 2 ^ ( 10 * x - 10 ) )
	end

	eases.OutExpo = function(x)
		return x == 1 && 1 || 1 - ( 2 ^ ( -10 * x ) )
	end

	eases.InOutExpo = function(x)
		return x == 0
			&& 0
			|| x == 1
			&& 1
			|| x < 0.5 && ( 2 ^ ( 20 * x - 10 ) ) / 2
			|| ( 2 - ( 2 ^ ( -20 * x + 10 ) ) ) / 2
	end

	eases.InCirc = function(x)
		return 1 - sqrt( 1 - ( x ^ 2 ) )
	end

	eases.OutCirc = function(x)
		return sqrt( 1 - ( ( x - 1 ) ^ 2 ) )
	end

	eases.InOutCirc = function(x)
		return x < 0.5
			&& ( 1 - sqrt( 1 - ( ( 2 * x ) ^ 2 ) ) ) / 2
			|| ( sqrt( 1 - ( ( -2 * x + 2 ) ^ 2 ) ) + 1 ) / 2
	end

	eases.InBack = function(x)
		return c3 * x ^ 3 - c1 * x ^ 2
	end

	eases.OutBack = function(x)
		return 1 + c3 * ( ( x - 1 ) ^ 3 ) + c1 * ( ( x - 1 ) ^ 2 )
	end

	eases.InOutBack = function(x)
		return x < 0.5
			&& ( ( ( 2 * x ) ^ 2 ) * ( ( c2 + 1 ) * 2 * x - c2 ) ) / 2
			|| ( ( ( 2 * x - 2 ) ^ 2 ) * ( ( c2 + 1 ) * ( x * 2 - 2 ) + c2 ) + 2 ) / 2
	end

	eases.InElastic = function(x)
		return x == 0
			&& 0
			|| x == 1
			&& 1
			|| -( 2 ^ ( 10 * x - 10 ) ) * sin( ( x * 10 - 10.75 ) * c4 )
	end

	eases.OutElastic = function(x)
		return x == 0
			&& 0
			|| x == 1
			&& 1
			|| ( 2 ^ ( -10 * x ) ) * sin( ( x * 10 - 0.75 ) * c4 ) + 1
	end

	eases.InOutElastic = function(x)
		return x == 0
			&& 0
			|| x == 1
			&& 1
			|| x < 0.5
			&& -( ( 2 ^ ( 20 * x - 10 ) ) * sin( ( 20 * x - 11.125 ) * c5 ) ) / 2
			|| ( ( 2 ^ ( -20 * x + 10 ) ) * sin( ( 20 * x - 11.125 ) * c5 ) ) / 2 + 1
	end

	eases.InBounce = function(x)
		return 1 - OutBounce( 1 - x )
	end

	eases.OutBounce = function(x)
		if ( x < 1 / d1 ) then
			return n1 * x ^ 2
		elseif ( x < 2 / d1 ) then
			x = x - ( 1.5 / d1 )
			return n1 * x ^ 2 + 0.75
		elseif ( x < 2.5 / d1 ) then
			x = x - ( 2.25 / d1 )
			return n1 * x ^ 2 + 0.9375
		else
			x = x - ( 2.625 / d1 )
			return n1 * x ^ 2 + 0.984375
		end
	end

	eases.InOutBounce = function(x)
		return x < 0.5
			&& ( 1 - OutBounce( 1 - 2 * x ) ) / 2
			|| ( 1 + OutBounce( 2 * x - 1 ) ) / 2
	end
	
end

function animations.GetRegisteredAnimations()
	return animations.registered
end

function animations.RegisterAnimation(name, tInfo)
	if tInfo and tInfo.FrameData then
		local BonesUsed = {}
		for _, tFrame in ipairs(tInfo.FrameData) do
			for iBoneID, tBoneTable in pairs(tFrame.BoneInfo) do
				BonesUsed[iBoneID] = (BonesUsed[iBoneID] or 0) + 1
				tBoneTable.MU = tBoneTable.MU or 0
				tBoneTable.MF = tBoneTable.MF or 0
				tBoneTable.MR = tBoneTable.MR or 0
				tBoneTable.RU = tBoneTable.RU or 0
				tBoneTable.RF = tBoneTable.RF or 0
				tBoneTable.RR = tBoneTable.RR or 0
			end
		end

		if #tInfo.FrameData > 1 then
			for iBoneUsed in pairs(BonesUsed) do
				for _, tFrame in ipairs(tInfo.FrameData) do
					if not tFrame.BoneInfo[iBoneUsed] then
						tFrame.BoneInfo[iBoneUsed] = {MU = 0, MF = 0, MR = 0, RU = 0, RF = 0, RR = 0}
					end
				end
			end
		end
	end

	animations.registered[name] = tInfo
do return end
	for _, ent in ipairs(animations.playing) do
		if ent.starfallgiga_animations and ent.starfallgiga_animations[name] then
			local frame, delta = animations.GetEntityAnimationFrame(ent, name)
			animations.ResetEntityAnimation(ent, name)
			animations.SetEntityAnimationFrame(ent, name, frame, delta)
		end
	end
end

local function AdvanceFrame(tGestureTable, tFrameData)
	if tGestureTable.Paused then return end

	if tGestureTable.TimeScale == 0 then
		local max = #tGestureTable.FrameData
		local offset = tGestureTable.Offset
		local start = tGestureTable.RestartFrame or 1

		offset = Lerp(offset%1, start, max + 1)

		tGestureTable.Frame = math.floor(offset)
		tGestureTable.FrameDelta = offset%1

		return true
	end

	tGestureTable.FrameDelta = tGestureTable.FrameDelta + FrameTime() * tFrameData.FrameRate * tGestureTable.TimeScale

	if tGestureTable.FrameDelta > 1 then
		tGestureTable.Frame = tGestureTable.Frame + 1
		tGestureTable.FrameDelta = math.min(1, tGestureTable.FrameDelta - 1)
		if tGestureTable.Frame > #tGestureTable.FrameData then
			tGestureTable.Frame = math.min(tGestureTable.RestartFrame or 1, #tGestureTable.FrameData)

			return true
		end
	end

	return false
end

local function CosineInterpolation(y1, y2, mu)
	local mu2 = (1 - math.cos(mu * math.pi)) / 2
	return y1 * (1 - mu2) + y2 * mu2
end

local function CubicInterpolation(y0, y1, y2, y3, mu)
	local mu2 = mu * mu
	local a0 = y3 - y2 - y0 + y1
	return a0 * mu * mu2 + (y0 - y1 - a0) * mu2 + (y2 - y0) * mu + y1
end

local EMPTYBONEINFO = {MU = 0, MR = 0, MF = 0, RU = 0, RR = 0, RF = 0}
local function GetFrameBoneInfo(ent, tGestureTable, iFrame, iBoneID)
	local tPrev = tGestureTable.FrameData[iFrame]
	if tPrev then
		return tPrev.BoneInfo[iBoneID] or tPrev.BoneInfo[ent:GetBoneName(iBoneID)] or EMPTYBONEINFO
	end

	return EMPTYBONEINFO
end

local function ProcessAnimations(ent)
	for name, tbl in pairs(ent.starfallgiga_animations) do
		local frame = tbl.Frame
		local frame_data = tbl.FrameData[frame]
		local frame_delta = tbl.FrameDelta
		local die_time = tbl.DieTime
		local power = tbl.Power
		if die_time and die_time - 0.125 <= CurTime() then
			power = power * (die_time - CurTime()) / 0.125
		end
		
		if !tbl.DontAutoPlay then
			if die_time and die_time <= CurTime() then
				animations.StopEntityAnimation(ent, name)
			elseif not tbl.PreCallback or not tbl.PreCallback(ent, name, tbl, frame, frame_data, frame_delta) then
				if tbl.ShouldPlay and not tbl.ShouldPlay(ent, name, tbl, frame, frame_data, frame_delta, power) then
					animations.StopEntityAnimation(ent, name, 0.2)
				end

				if tbl.Type == "gesture" then
					if AdvanceFrame(tbl, frame_data) then
						animations.StopEntityAnimation(ent, name)
					end
				elseif tbl.Type == "posture" then
					if frame_delta < 1 and tbl.TimeToArrive then
						frame_delta = math.min(1, frame_delta + FrameTime() * (1 / tbl.TimeToArrive))
						tbl.FrameDelta = frame_delta
					end
				else
					AdvanceFrame(tbl, frame_data)
				end
			end
		end
	end

	animations.ResetEntityBoneMatrix(ent)

	if not ent.starfallgiga_animations then return end

	local tBuffer = {}

	for _, tbl in pairs(ent.starfallgiga_animations) do
		local iCurFrame = tbl.Frame
		local tFrameData = tbl.FrameData[iCurFrame]
		local fFrameDelta = tbl.FrameDelta
		local fDieTime = tbl.DieTime
		local fPower = tbl.Power
		if fDieTime and fDieTime - 0.125 <= CurTime() then
			fPower = fPower * (fDieTime - CurTime()) / 0.125
		end
		local fAmount = fPower * fFrameDelta

		for iBoneID, tBoneInfo in pairs(tFrameData.BoneInfo) do
			if type(iBoneID) ~= "number" then
				iBoneID = ent:LookupBone(iBoneID)
			end
			if not iBoneID then goto CONTINUE end

			if not tBuffer[iBoneID] then tBuffer[iBoneID] = Matrix() end
			local mBoneMatrix = tBuffer[iBoneID]

			local vCurBonePos, aCurBoneAng = mBoneMatrix:GetTranslation(), mBoneMatrix:GetAngles()
			if not tBoneInfo.Callback or not tBoneInfo.Callback(ent, mBoneMatrix, iBoneID, vCurBonePos, aCurBoneAng, fFrameDelta, fPower) then
				local vUp = aCurBoneAng:Up()
				local vRight = aCurBoneAng:Right()
				local vForward = aCurBoneAng:Forward()
				local iInterp = tbl.Interpolation

				if iInterp == "linear" then
					if tbl.Type == "posture" then
						mBoneMatrix:Translate((tBoneInfo.MU * vUp + tBoneInfo.MR * vRight + tBoneInfo.MF * vForward) * fAmount)
						mBoneMatrix:Rotate(Angle(tBoneInfo.RR, tBoneInfo.RU, tBoneInfo.RF) * fAmount)
					else
						local bi1 = GetFrameBoneInfo(ent, tbl, iCurFrame - 1, iBoneID)

						if tFrameData["EaseStyle"] then
							local curease = tFrameData["EaseStyle"]
							mBoneMatrix:Translate(
								LerpVector(
									eases[curease](fFrameDelta),
									bi1.MU * vUp + bi1.MR * vRight + bi1.MF * vForward,
									tBoneInfo.MU * vUp + tBoneInfo.MR * vRight + tBoneInfo.MF * vForward
								) * fPower
							)

							mBoneMatrix:Rotate(
								LerpAngle(
									eases[curease](fFrameDelta),
									Angle(bi1.RR, bi1.RU, bi1.RF),
									Angle(tBoneInfo.RR, tBoneInfo.RU, tBoneInfo.RF)
								) * fPower
							)
						else
							mBoneMatrix:Translate(
								LerpVector(
									fFrameDelta,
									bi1.MU * vUp + bi1.MR * vRight + bi1.MF * vForward,
									tBoneInfo.MU * vUp + tBoneInfo.MR * vRight + tBoneInfo.MF * vForward
								) * fPower
							)

							mBoneMatrix:Rotate(
								LerpAngle(
									fFrameDelta,
									Angle(bi1.RR, bi1.RU, bi1.RF),
									Angle(tBoneInfo.RR, tBoneInfo.RU, tBoneInfo.RF)
								) * fPower
							)
						end
					end
				elseif iInterp == "cubic" and tbl.FrameData[iCurFrame - 2] and tbl.FrameData[iCurFrame + 1] then
						local bi0 = GetFrameBoneInfo(ent, tbl, iCurFrame - 2, iBoneID)
						local bi1 = GetFrameBoneInfo(ent, tbl, iCurFrame - 1, iBoneID)
						local bi3 = GetFrameBoneInfo(ent, tbl, iCurFrame + 1, iBoneID)

						mBoneMatrix:Translate(CosineInterpolation(bi1.MU * vUp + bi1.MR * vRight + bi1.MF * vForward, tBoneInfo.MU * vUp + tBoneInfo.MR * vRight + tBoneInfo.MF * vForward, fFrameDelta) * fPower)
						mBoneMatrix:Rotate(CubicInterpolation(
							Angle(bi0.RR, bi0.RU, bi0.RF),
							Angle(bi1.RR, bi1.RU, bi1.RF),
							Angle(tBoneInfo.RR, tBoneInfo.RU, tBoneInfo.RF),
							Angle(bi3.RR, bi3.RU, bi3.RF),
							fFrameDelta
						) * fPower)
				elseif iInterp == "none" then
					mBoneMatrix:Translate((tBoneInfo.MU * vUp + tBoneInfo.MR * vRight + tBoneInfo.MF * vForward))
					mBoneMatrix:Rotate(Angle(tBoneInfo.RR, tBoneInfo.RU, tBoneInfo.RF))
				else-- Default is Cosine
					local bi1 = GetFrameBoneInfo(ent, tbl, iCurFrame - 1, iBoneID)
					mBoneMatrix:Translate(CosineInterpolation(bi1.MU * vUp + bi1.MR * vRight + bi1.MF * vForward, tBoneInfo.MU * vUp + tBoneInfo.MR * vRight + tBoneInfo.MF * vForward, fFrameDelta) * fPower)
					mBoneMatrix:Rotate(CosineInterpolation(Angle(bi1.RR, bi1.RU, bi1.RF), Angle(tBoneInfo.RR, tBoneInfo.RU, tBoneInfo.RF), fFrameDelta) * fPower)
				end
			end
			::CONTINUE::
		end
	end

	for iBoneID, mMatrix in pairs(tBuffer) do
		ent:ManipulateBonePosition(iBoneID, mMatrix:GetTranslation())
		ent:ManipulateBoneAngles(iBoneID, mMatrix:GetAngles())
	end
end


function animations.ResetEntityBoneMatrix(ent)
	for i=0, ent:GetBoneCount() - 1 do
		ent:ManipulateBoneAngles(i, angle_zero)
		ent:ManipulateBonePosition(i, vector_origin)
	end
end

function animations.ResetEntityAnimation(ent, name, fDieTime, fPower, fTimeScale)
	local animtable = animations.registered[name]
	if animtable then
		ent.starfallgiga_animations = ent.starfallgiga_animations or {}

		local framedelta = 0
		if animtable.Type == "posture" and not animtable.TimeToArrive then
			framedelta = 1
		end

		ent.starfallgiga_animations[name] = {
			Frame = animtable.StartFrame or 1,
			Offset = 0,
			FrameDelta = framedelta,
			FrameData = animtable.FrameData,
			TimeScale = fTimeScale or animtable.TimeScale or 1,
			Type = animtable.Type,
			RestartFrame = animtable.RestartFrame,
			TimeToArrive = animtable.TimeToArrive,
			ShouldPlay = animtable.ShouldPlay,
			Power = fPower or animtable.Power or 1,
			DieTime = fDieTime or animtable.DieTime,
			Group = animtable.Group,
			UseReferencePose = animtable.UseReferencePose,
			Interpolation = animtable.Interpolation,
		}

		animations.ResetEntityAnimationProperties(ent)

		for i,v in ipairs(animations.playing) do
			if v == ent then
				table.remove(animations.playing, i)
				break
			end
		end

		ent:CallOnRemove("starfallgiga_animations", function()
			for i,v in ipairs(animations.playing) do
				if v == ent then
					table.remove(animations.playing, i)
					break
				end
			end
		end)
		table.insert(animations.playing, ent)
	end
end

function animations.SetEntityAnimation(ent, name, fDieTime, fPower, fTimeScale)
	if ent.starfallgiga_animations and ent.starfallgiga_animations[name] then return end

	animations.ResetEntityAnimation(ent, name, fDieTime, fPower, fTimeScale)
end

function animations.GetEntityAnimation(ent, name)
	if ent.starfallgiga_animations and ent.starfallgiga_animations[name] then return ent.starfallgiga_animations[name] end
end



function animations.SetEntityAnimationFrame(ent, name, f, delta)
	if ent.starfallgiga_animations and ent.starfallgiga_animations[name] then
		local data = ent.starfallgiga_animations[name]

		f = math.ceil(f)
		f = math.Clamp(f, 1, #data.FrameData)

		data.Frame = f
		data.FrameDelta = delta and math.Clamp(delta, 0, 1) or 0
	end
end

function animations.GetEntityAnimationFrame(ent, name)
	if ent.starfallgiga_animations and ent.starfallgiga_animations[name] then
		local data = ent.starfallgiga_animations[name]
		return data.Frame, data.FrameDelta
	end
end

function animations.SetEntityAnimationCycle(ent, name, f)
	if ent.starfallgiga_animations and ent.starfallgiga_animations[name] then
		local data = ent.starfallgiga_animations[name]
		local duration = animations.GetAnimationDuration(ent, name)
		f = f%1


		ROFL = f
		f = f * duration

		local sec = 0
		for i = 1, #data.FrameData do
			local dt = (1/data.FrameData[i].FrameRate)

			if sec+dt >= f then
				data.Frame = i
				data.FrameDelta = math.Clamp((f-sec) / dt, 0, 1)
				break
			end

			sec = sec + dt
		end
	end
end


function animations.GetEntityAnimationCycle(ent, name)
	if ent.starfallgiga_animations and ent.starfallgiga_animations[name] then
		local data = ent.starfallgiga_animations[name]

		local sec = 0
		for i = 1, data.Frame - 1 do
			local dt = (1/data.FrameData[i].FrameRate)
			sec = sec + dt
		end

		sec = Lerp(data.FrameDelta, sec, sec + (1/data.FrameData[data.Frame].FrameRate))

		return sec/animations.GetAnimationDuration(ent, name)
	end
end

function animations.GetAnimationDuration(ent, name)
	if ent.starfallgiga_animations and ent.starfallgiga_animations[name] then
		local total = 0
		for i=1, #ent.starfallgiga_animations[name].FrameData do
			local v = ent.starfallgiga_animations[name].FrameData[i]
			total = total+(1/(v.FrameRate or 1))
		end
		return total
	end
	return 0
end

local function ResetInSequence(ent)
	if ent.starfallgiga_animations then
		for _, tbl in pairs(ent.starfallgiga_animations) do
			if tbl.Type == "sequence" and (not tbl.DieTime or CurTime() < tbl.DieTime - 0.125) or tbl.UseReferencePose then
				ent.starfallgiga_animations_insequence = true
				return
			end
		end

		ent.starfallgiga_animations_insequence = nil
	end
end

hook.Add("CalcMainActivity", "starfallgiga_animations_reset_sequence", function(ent)
	if ent.starfallgiga_animations_insequence then
		ResetInSequence(ent)
		return 0, 0
	end
end)

function animations.ResetEntityAnimationProperties(ent)
	local anims = ent.starfallgiga_animations
	if anims and table.Count(anims) > 0 then
		ent:SetIK(false)
		ResetInSequence(ent)
	else
		--ent:SetIK(true)
		ent.starfallgiga_animations = nil
		ent.starfallgiga_animations_insequence = nil

		ent:RemoveCallOnRemove("starfallgiga_animations")

		for i,v in ipairs(animations.playing) do
			if v == ent then
				table.remove(animations.playing, i)
			end
		end
	end
end

-- Time is optional, sets the die time to CurTime() + time
function animations.StopEntityAnimation(ent, name, time)
	local anims = ent.starfallgiga_animations
	if anims and anims[name] then
		if time then
			if anims[name].DieTime then
				anims[name].DieTime = math.min(anims[name].DieTime, CurTime() + time)
			else
				anims[name].DieTime = CurTime() + time
			end
		else
			anims[name] = nil
		end

		animations.ResetEntityAnimationProperties(ent)
	end
end

function animations.StopAllEntityAnimations(ent, time)
	if ent.starfallgiga_animations then
		for name in pairs(ent.starfallgiga_animations) do
			animations.StopEntityAnimation(ent, name, time)
		end
	end
end

hook.Add("Think", "starfallgiga_custom_animations", function()
	for i,v in ipairs(animations.playing) do
		if v.starfallgiga_animations then
			ProcessAnimations(v)
		end
	end
end)

--- Library for playing Lua anims on entities.
-- @name customanims
-- @class library
-- @libtbl customanims_library
SF.RegisterLibrary("customanims")

return function(instance)
local customanims_library = instance.Libraries.customanims
local eunwrap = instance.Types.Entity.Unwrap

--- Set an animation on an entity.
-- @param Entity ent Entity to set animation on.
-- @param string name Name of registered animation to play.
-- @param number? DieTime Kill the animation after specified time.
-- @param number? Power The weight of the playing animation. (0 is none, 1 is full)
-- @param number? TimeScale How fast the animation plays.
function customanims_library.setAnimation(ent, name, fDieTime, fPower, fTimeScale)
	if ent == instance.player or instance.player==SF.SuperUser or instance.player:IsAdmin() then
		animations.SetEntityAnimation(eunwrap(ent), name, fDieTime, fPower, fTimeScale)
	end
end

--- Set an animation on an entity. Will reset anim if it's already playing.
-- @param Entity ent Entity to set animation on.
-- @param string name Name of registered animation to play.
-- @param number? DieTime Kill the animation after specified time.
-- @param number? Power The weight of the playing animation. (0 is none, 1 is full)
-- @param number? TimeScale How fast the animation plays.
function customanims_library.resetAnimation(ent, name, fDieTime, fPower, fTimeScale)
	if ent == instance.player or instance.player==SF.SuperUser or instance.player:IsAdmin() then
		animations.ResetEntityAnimation(eunwrap(ent), name, fDieTime, fPower, fTimeScale)
	end
end	

--- Register a custom animation.
-- @param string name The ID name of the animation.
-- @param string filepath The filepath leading to the animation file. Relative to data/ folder.		
function customanims_library.registerAnimation(name, filepath)
	local rf = util.JSONToTable(file.Read(filepath, "DATA"))
	if not animations.GetRegisteredAnimations()[name] or instance.player==SF.SuperUser or instance.player:IsAdmin() then
		animations.RegisterAnimation(name, rf)
	end
end

--- Register a custom animation using a string instead of a file.
-- Useful if your anim uses only a single bone or is small.
-- @param string name The ID name of the animation.
-- @param string animstring The JSON table of the anim as a string.
function customanims_library.registerAnimFromString(name, stringy)
	local rf = util.JSONToTable(stringy)
	if not animations.GetRegisteredAnimations()[name] or instance.player==SF.SuperUser or instance.player:IsAdmin() then
		animations.RegisterAnimation(name, rf)
	end
end

--- Returns registered animations.
-- @return table animtable All registered animations.
function customanims_library.getRegisteredAnimations()
	if instance.player==SF.SuperUser or instance.player:IsAdmin() then
		return animations.GetRegisteredAnimations()
	end
end

--- Returns all animations playing on the entity.
-- @param Entity ent Entity to get anims from.
-- @return table animtable All currently playing animations.
function customanims_library.getEntAnims(ent)
	return eunwrap(ent).starfallgiga_animations
end

--- Stops a playing animation.
-- @param Entity ent The entity.
-- @param string name The ID name of the animation.
-- @param number? DieTime The delay after this function is executed to stop the animation.
function customanims_library.stopAnimation(ent, name, dietime)
	local ent = eunwrap(ent)
	if ent == instance.player or instance.player==SF.SuperUser or instance.player:IsAdmin() then
		animations.StopEntityAnimation(ent, name, dietime)
	end
end

--- Stops all playing animations on an entity.
-- @param Entity ent The entity.
-- @param number? DieTime The delay after this function is executed to stop the animation.
function customanims_library.stopAllAnimations(ent, time)
	local ent = eunwrap(ent)
	if ent == instance.player or instance.player==SF.SuperUser or instance.player:IsAdmin() then
		animations.StopAllEntityAnimations(ent, time)
	end
end

--- Gets the animation with the specified ID if it's playing on the entity.
-- @param Entity ent The entity.
-- @param string name The ID name of the animation.
-- @return table animtable The animation table.
function customanims_library.getEntAnim(ent, name)
	local ent = eunwrap(ent)
	return animations.GetEntityAnimation(ent, name)
end

--- Gets the duration of a custom anim playing on an entity.
-- @param Entity ent The entity.
-- @param string name The ID name of the animation.
-- @return number dur The duration of the animation.
function customanims_library.getAnimDuration(ent, name)
	local ent = eunwrap(ent)
	return animations.GetAnimationDuration(ent, name)
end

--- Sets the cycle of a custom anim playing on an entity.
-- @param Entity ent The entity.
-- @param string name The ID name of the animation.
-- @param number newcyc The new cycle.
function customanims_library.setAnimCycle(ent, name, f)
	local ent = eunwrap(ent)
	if ent == instance.player or instance.player==SF.SuperUser or instance.player:IsAdmin() then
		animations.SetEntityAnimationCycle(ent, name, f)
	end
end

--- Gets the cycle of a custom anim playing on an entity.
-- @param Entity ent The entity.
-- @param string name The ID name of the animation.
-- @return number cycle The cycle of the animation.
function customanims_library.getAnimCycle(ent, name)
	local ent = eunwrap(ent)
	return animations.GetEntityAnimationCycle(ent, name)
end

--- Gets the frame of a custom anim playing on an entity.
-- @param Entity ent The entity.
-- @param string name The ID name of the animation.
-- @return number frame The current frame of the animation.
function customanims_library.getAnimFrame(ent, name)
	local ent = eunwrap(ent)
	return animations.GetEntityAnimationFrame(ent, name)
end

--- Gets the frame of a custom anim playing on an entity.
-- @param Entity ent The entity.
-- @param string name The ID name of the animation.
-- @param number frame The frame to set the anim to.
function customanims_library.setAnimFrame(ent, name, fr)
	local ent = eunwrap(ent)
	if ent == instance.player or instance.player==SF.SuperUser or instance.player:IsAdmin() then
		animations.SetEntityAnimationFrame(ent, name, fr)
	end
end

--- If true, stops a custom anim from autoplaying.
-- @param Entity ent The entity.
-- @param string name The ID name of the animation.
-- @param boolean dontautoplay True to stop from autoplaying.
function customanims_library.dontAutoPlay(ent, name, dap)
	local ent = eunwrap(ent)
	if ent == instance.player or instance.player==SF.SuperUser or instance.player:IsAdmin() then
		animations.GetEntityAnimation(ent, name).DontAutoPlay = dap
	end
end
		
end