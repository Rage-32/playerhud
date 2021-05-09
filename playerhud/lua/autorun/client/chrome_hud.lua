
/* 
---------------------------------------------------------------------------------------------------------------------------------------------
			Fonts
---------------------------------------------------------------------------------------------------------------------------------------------
*/

surface.CreateFont("ammo_main",  	{font = CloseCaption_Normal  	, size = 20, weight = 1000})
surface.CreateFont("abovehead_main",{font = CloseCaption_Normal  	, size = 33, weight = 1000})

/* 
---------------------------------------------------------------------------------------------------------------------------------------------
			Blur Functions
---------------------------------------------------------------------------------------------------------------------------------------------
*/

local blur = Material("pp/blurscreen")

function surface.DrawBlurRect(x, y, w, h, amount, heavyness)
	local X, Y = 0,0
	local scrW, scrH = ScrW(), ScrH()

	surface.SetDrawColor(255,255,255)
	surface.SetMaterial(blur)

	for i = 1, heavyness do
		blur:SetFloat("$blur", (i / 3) * (amount or 6))
		blur:Recompute()

		render.UpdateScreenEffectTexture()

		render.SetScissorRect(x, y, x+w, y+h, true)
			surface.DrawTexturedRect(X * -1, Y * -1, scrW, scrH)
		render.SetScissorRect(0, 0, 0, 0, false)
	end
end

/* 
---------------------------------------------------------------------------------------------------------------------------------------------
			Main Hud Functions
---------------------------------------------------------------------------------------------------------------------------------------------
*/
function chromehud_AmmoHud ()
    local scr_w, scr_h, self = ScrW(), ScrH(), LocalPlayer() 
    chromehud_AmmoHudRender( scr_w, scr_h ) 
end

function chromehud_AmmoHudRender( scr_w, scr_h )
	local ply 	= LocalPlayer()
	local py 	= chromehud_Config.AmmoHudYPosition
	local sy 	= chromehud_Config.AmmoHudHeight
	local pxb 	= chromehud_Config.AmmoHudXPosition
	if not ply:Alive() or not IsValid( ply:GetActiveWeapon() ) then return end
    local ammo, reserve = ply:GetActiveWeapon():Clip1() < 0 and -2 or ply:GetActiveWeapon():Clip1(), ply:GetAmmoCount( ply:GetActiveWeapon():GetPrimaryAmmoType() )
	if ammo <= 0 then ammo = 0 end
	local should_ammo_draw 	= true
	if ammo == 0 and reserve == 0 then should_ammo_draw = false end
	if should_ammo_draw then
		--Ammo & Reserves
		local text 	= string.format( '%i/%i', ammo, reserve )
		local sx  	= string.len(text)*7
		local tw 	= sx
		local px 	= tw*3 + pxb
		surface.DrawBlurRect(scr_w - px, scr_h - py, tw*3, sy, 1, 7)
		surface.SetDrawColor(chromehud_Config.AmmoHudBackColor)
		surface.DrawRect(scr_w - px, scr_h - py, tw*3, sy)
		draw.SimpleText( text, "ammo_main",scr_w - px + (tw*3)/2 , scr_h -py + sy/2  , Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.RoundedBox( 0, scr_w - px, scr_h - py + sy - 2, tw*3, 2, Color(156, 8, 30, 200) )
		--Weapon Name
		local text_weap			= ply:GetActiveWeapon():GetPrintName()
		local sx_weap  			= string.len(text_weap)*10 + 10 
		local space				= 5
		local px 				= sx_weap + pxb
		surface.DrawBlurRect(scr_w - px, scr_h - py + 30 + space , sx_weap, sy, 1, 7) 
		surface.SetDrawColor(chromehud_Config.AmmoHudBackColor)
		surface.DrawRect(scr_w - px, scr_h - py + 30 + space , sx_weap, sy)
		draw.RoundedBox( 0, scr_w - px,scr_h - py + sy + 30 + space , sx_weap, 2, Color(156, 8, 30, 200) )
		draw.SimpleText( text_weap, "ammo_main",scr_w - px + sx_weap/2 , scr_h - py + 30 + space + sy/2  , Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end


function chromehud_AboveHeadHud( ply )
	for k,ply in ipairs(player.GetAll()) do -- to fix the background clip, have to use PostDrawTranslucentRenderables instead of PostPlayerDraw
		if !ply:Alive() then return end
		if ply:GetRenderMode() == RENDERMODE_TRANSALPHA then return end
		
		local distance 		= LocalPlayer():GetPos():Distance(ply:GetPos())
		local displayAng 	= LocalPlayer():EyeAngles()
		local displayPos 	= ply:GetPos() + Vector(0, 0, chromehud_Config.AboveHeadHudYPosition)
		local trace 		= LocalPlayer():GetEyeTrace()
		local shootPos 		= LocalPlayer():GetShootPos()
    	local aimVec 		= LocalPlayer():GetAimVector()
		local name 			= tostring(ply:Nick())
		local job 			= team.GetName(ply:Team())
		local jobcolor      = team.GetColor(ply:Team())
	
		if ply != LocalPlayer() then
			local hisPos 	= ply:GetShootPos()
			if hisPos:DistToSqr(shootPos) < 160000 then
            	local pos 		= hisPos - shootPos
            	local unitPos 	= pos:GetNormalized()
            	if unitPos:Dot(aimVec) > 0 then
                	local trace 	= util.QuickTrace(shootPos, pos, LocalPlayer())
                	if trace.Hit and trace.Entity ~= ply then return end
                	cam.Start3D2D(ply:GetPos() + Vector(0, 0, chromehud_Config.AboveHeadHudYPosition), Angle(0, displayAng.y - 90, 90), 0.15)
						if distance < 300 then

							local c = {
								white = Color(255, 255, 255),
								red = Color(255, 0, 0),
								blue = Color(30,144,255),
								black = Color (0, 0, 0),
							}

							draw.SimpleTextOutlined(job, "abovehead_main", 0, 30, jobcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, c.black)
							-- BOOLEANS HOLY SHIT I HATE MY LIFE
							if ply:getDarkRPVar("wanted") == true then
								draw.SimpleTextOutlined("WANTED", "abovehead_main", 0, 0, c.red, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, c.black)
							end
							if ply:getDarkRPVar("Arrested") == true then
								draw.SimpleTextOutlined("ARRESTED", "abovehead_main", 0, 0, c.red, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, c.black)
							end
							if ply:IsBot() then
								draw.SimpleTextOutlined(name, "abovehead_main", 0, 60, c.blue, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, c.black)
							else
								draw.SimpleTextOutlined(name, "abovehead_main", 0, 60, c.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, c.black)
							end
						end
					cam.End3D2D()
            	end
        	end
		end
	end
end



/* 
---------------------------------------------------------------------------------------------------------------------------------------------
			Hooks
---------------------------------------------------------------------------------------------------------------------------------------------
*/


hook.Add( 'HUDPaint', 'Hook_HUDPaint_AmmoHud_chromehud', chromehud_AmmoHud )

hook.Add("PostDrawTranslucentRenderables","Hook_PostPlayerDraw_AmmoHud_chromehud",chromehud_AboveHeadHud )
