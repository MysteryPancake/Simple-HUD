
if ( SERVER ) then return end

CreateClientConVar( 'SimpleHUD', '1', true, false )
CreateClientConVar( 'SimpleHUD_Vertical', '1', true, false )
CreateClientConVar( 'SimpleHUD_ShowAmmo', '0', true, false )
CreateClientConVar( 'SimpleHUD_HealthColor', '206 0 0 255', true, false )
CreateClientConVar( 'SimpleHUD_ArmorColor', '255 158 0 255', true, false )
CreateClientConVar( 'SimpleHUD_SpeedWalkColor', '0 158 206 255', true, false )
CreateClientConVar( 'SimpleHUD_SpeedVehicleColor', '75 186 56 255', true, false )
CreateClientConVar( 'SimpleHUD_BGColor', '0 0 0 170', true, false )
CreateClientConVar( 'SimpleHUD_GunBGColor', '0 0 0 170', true, false )
CreateClientConVar( 'SimpleHUD_ArmorIcon', 'icon16/shield.png', true, false )
CreateClientConVar( 'SimpleHUD_HealthIcon', 'icon16/heart.png', true, false )
CreateClientConVar( 'SimpleHUD_WalkIcon', 'icon16/user_go.png', true, false )
CreateClientConVar( 'SimpleHUD_DriveIcon', 'icon16/car.png', true, false )
CreateClientConVar( 'SimpleHUD_MaxDriveSpeed', '1000', true, false )
CreateClientConVar( 'SimpleHUD_MaxRunSpeed', '1500', true, false )
CreateClientConVar( 'SimpleHUD_Clamp', '1', true, false )

local HealthIcon = GetConVar( 'SimpleHUD_HealthIcon' )
local ArmorIcon = GetConVar( 'SimpleHUD_ArmorIcon' )
local WalkIcon = GetConVar( 'SimpleHUD_WalkIcon' )
local DriveIcon = GetConVar( 'SimpleHUD_DriveIcon' )

local HealthMat = Material( HealthIcon:GetString() or'icon16/heart.png', 'noclamp smooth' )
local ArmorMat = Material( ArmorIcon:GetString() or 'icon16/shield.png', 'noclamp smooth' )
local SpeedMat = Material( WalkIcon:GetString() or 'icon16/user_go.png', 'noclamp smooth' )
local SpeedInCarMat = Material( DriveIcon:GetString() or 'icon16/car.png', 'noclamp smooth' )

local AmmoMat = Material( 'icon16/gun.png', 'noclamp smooth' )

local HealthAlpha, ArmorAlpha, SpeedAlpha = 255, 255, 255

local Simple = GetConVar( 'SimpleHUD' )
local Vertical = GetConVar( 'SimpleHUD_Vertical' )
local ShowAmmo = GetConVar( 'SimpleHUD_ShowAmmo' )
local HealthColor = GetConVar( 'SimpleHUD_HealthColor' )
local ArmorColor = GetConVar( 'SimpleHUD_ArmorColor' )
local SpeedColor = GetConVar( 'SimpleHUD_SpeedWalkColor' )
local CarColor = GetConVar( 'SimpleHUD_SpeedVehicleColor' )
local BGColor = GetConVar( 'SimpleHUD_BGColor' )
local GunBGColor = GetConVar( 'SimpleHUD_GunBGColor' )
local Clamp = GetConVar( 'SimpleHUD_Clamp' )
local MaxDriveSpeed = GetConVar( 'SimpleHUD_MaxDriveSpeed' )
local MaxRunSpeed = GetConVar( 'SimpleHUD_MaxRunSpeed' )

hook.Add( 'HUDPaint', 'DrawAmazingHUD', function()
if Simple:GetBool() then

	local PlySpeed, SpeedPercent = 0, 0
	local PlyAmmo, PlySecondaryAmmo, TotalAmmo = 0, 0, 0
	local Driving = LocalPlayer():InVehicle()
	
	if Driving then PlySpeed = math.floor(LocalPlayer():GetVehicle():GetVelocity():Length() / MaxDriveSpeed:GetFloat() * 200)
	else PlySpeed = math.floor(LocalPlayer():GetVelocity():Length() / MaxRunSpeed:GetFloat() * 200) end

	local PlyHealth = math.floor(LocalPlayer():Health() / LocalPlayer():GetMaxHealth() * 200)
	
	if PlyHealth < 0 then PlyHealth = 0 end
	
	local PlyArmor = math.floor(LocalPlayer():Armor() / 100 * 200)
	
	if Clamp:GetBool() then
		PlySpeed = math.Clamp( PlySpeed, 0, 200 )
		PlyHealth = math.Clamp( PlyHealth, 0, 200 )
		PlyArmor = math.Clamp( PlyArmor, 0, 200 )
	end
	
	local Weapon = LocalPlayer():GetActiveWeapon()
	if Weapon ~= NULL then
		PlyAmmo = Weapon:Clip1()
		PlySecondaryAmmo = LocalPlayer():GetAmmoCount( Weapon:GetSecondaryAmmoType() )
		TotalAmmo = LocalPlayer():GetAmmoCount( Weapon:GetPrimaryAmmoType() )
	end
	
	if Driving then
		local AmmoType, ClipSize, Count = LocalPlayer():GetVehicle():GetAmmo()
		if Count ~= nil then
			PlyAmmo = -1
			TotalAmmo = Count -- Pretty hacky
			PlySecondaryAmmo = -1
		end
	end
	
	local Up = Vertical:GetBool()
	
	local function DrawHealthRect( x, y, col, alpha )
		surface.SetDrawColor( col.r + 90, col.g + 90, col.b + 90, alpha )
		surface.SetMaterial( HealthMat )
		surface.DrawTexturedRect( x - 10, y, 20, 20 )
	end
	
	local function DrawArmorRect( x, y, col, alpha )
		surface.SetDrawColor( col.r + 90, col.g + 90, col.b + 90, alpha )
		surface.SetMaterial( ArmorMat )
		surface.DrawTexturedRect( x - 10, y, 20, 20 )
	end
	
	local function DrawSpeedRect( x, y, walkingcol, drivingcol, alpha )
		if Driving then
		surface.SetDrawColor( drivingcol.r + 90, drivingcol.g + 90, drivingcol.b + 90, alpha )
		surface.SetMaterial( SpeedInCarMat ) else
		surface.SetDrawColor( walkingcol.r + 90, walkingcol.g + 90, walkingcol.b + 90, alpha )
		surface.SetMaterial( SpeedMat ) end
		surface.DrawTexturedRect( x - 10, y, 20, 20 )
	end
	
	local function DrawGunRect( x, y )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( AmmoMat )
		surface.DrawTexturedRect( x - 10, y, 20, 20 )
	end
	
	if PlyHealth <= 25 then HealthAlpha = math.Clamp( HealthAlpha - 10, 0, 255 ) 
	else HealthAlpha = math.Clamp( HealthAlpha + 10, 0, 255 ) end
	
	if PlyArmor <= 40 then ArmorAlpha = math.Clamp( ArmorAlpha - 10, 0, 255 )
	else ArmorAlpha = math.Clamp( ArmorAlpha + 10, 0, 255 ) end
	
	if PlySpeed <= 20 then SpeedAlpha = math.Clamp( SpeedAlpha - 50, 0, 255 )
	else SpeedAlpha = math.Clamp( SpeedAlpha + 50, 0, 255 ) end
	
	draw.NoTexture()
	surface.SetFont( 'DermaDefaultBold' )
	
	if Up then
		draw.RoundedBox( 8, 5, ScrH() - 235, 120, 230, string.ToColor( BGColor:GetString() ) )
		else
		draw.RoundedBox( 8, 5, ScrH() - 125, 255, 120, string.ToColor( BGColor:GetString() ) )
	end
	
	--The speed
	
	local drivingcol, walkingcol = string.ToColor( CarColor:GetString() ), string.ToColor( SpeedColor:GetString() )
	
	if Driving then
		surface.SetDrawColor( drivingcol )
		else
		surface.SetDrawColor( walkingcol )
	end
	
	if Up then
		surface.DrawRect( 15, ScrH() - 15 - PlySpeed, 30, PlySpeed )
		DrawSpeedRect( 15 + 15, ScrH() - PlySpeed - 5, walkingcol, drivingcol, SpeedAlpha )
		else
		surface.DrawRect( 15, ScrH() - 45, PlySpeed, 30 )
		DrawSpeedRect( PlySpeed - 5, ScrH() - 40, walkingcol, drivingcol, SpeedAlpha )
	end
	
	if Driving then
		surface.SetTextColor( drivingcol.r + 60, drivingcol.g + 60, drivingcol.b + 60,  drivingcol.a )
		else
		surface.SetTextColor( walkingcol.r + 60, walkingcol.g + 60, walkingcol.b + 60,  walkingcol.a )
	end

	local w, h = surface.GetTextSize( math.floor( PlySpeed / 2 ) .. '%' )
	
	if Up then
		surface.SetTextPos( 30 - w / 2, ScrH() - PlySpeed - 30 )
		else
		surface.SetTextPos( PlySpeed + w / 2 + 5, ScrH() - 30 - h / 2 )
	end
	
	surface.DrawText( math.floor( PlySpeed / 2 ) .. '%' )

	--The health
	
	local healthcol = string.ToColor( HealthColor:GetString() )
	
	surface.SetDrawColor( healthcol )
	
	if Up then
		surface.DrawRect( 50, ScrH() - 15 - PlyHealth, 30, PlyHealth )
		DrawHealthRect( 65, ScrH() - PlyHealth - 5, healthcol, HealthAlpha )
		else
		surface.DrawRect( 15, ScrH() - 80, PlyHealth, 30 )
		DrawHealthRect( PlyHealth - 5, ScrH() - 75, healthcol, HealthAlpha )
	end
	
	if math.floor(PlyHealth/2) >= 20 then
	surface.SetTextColor( healthcol.r + 60, healthcol.g + 60, healthcol.b + 60,  healthcol.a ) else
	surface.SetTextColor( healthcol.r + 255, healthcol.g, healthcol.b,  healthcol.a ) end
	
	local w, h = surface.GetTextSize( math.floor( PlyHealth / 2 ) .. '%' )
	
	if Up then
		surface.SetTextPos( 65 - w / 2, ScrH() - PlyHealth - 30 )
		else
		surface.SetTextPos( PlyHealth + w / 2 + 5, ScrH() - 65 - h / 2 )
	end
	
	surface.DrawText( math.floor(PlyHealth/2) .. '%' )
	
	--The armor
	
	local armorcol = string.ToColor( ArmorColor:GetString() )
	
	surface.SetDrawColor( armorcol )
	
	if Up then
		surface.DrawRect( 85, ScrH() - 15 - PlyArmor, 30, PlyArmor )
		DrawArmorRect( 100, ScrH() - PlyArmor - 5, armorcol, ArmorAlpha )
		else
		surface.DrawRect( 15, ScrH() - 115, PlyArmor, 30 )
		DrawArmorRect( PlyArmor - 5, ScrH() - 110, armorcol, ArmorAlpha )
	end
	
	surface.SetTextColor( armorcol.r + 60, armorcol.g + 60, armorcol.b + 60,  healthcol.a )
	
	local w, h = surface.GetTextSize( math.floor( PlyArmor / 2 ) .. '%' )
	
	if Up then
		surface.SetTextPos( 100 - w / 2, ScrH() - PlyArmor - 30 )
		else
		surface.SetTextPos( PlyArmor + w / 2 + 5, ScrH() - 100 - h / 2 )
	end
	surface.DrawText( math.floor(PlyArmor/2) .. '%' )
	
	--The ammo
	
	if ShowAmmo:GetBool() and ( TotalAmmo > 0 or PlySecondaryAmmo > 0 ) then
	
		if Up then
			draw.RoundedBox( 8, 5, ScrH() - 300, 120, 60, string.ToColor( GunBGColor:GetString() ) )
			else
			draw.RoundedBox( 8, 270, ScrH() - 125, 130, 120, string.ToColor( GunBGColor:GetString() ) )
		end
		
		local w, h = surface.GetTextSize( PlyAmmo .. ' / ' .. TotalAmmo )
		surface.SetTextColor( 255, 255, 255, 255 )
		
		if Up then
			if PlySecondaryAmmo > 0 and TotalAmmo > 0 then
				surface.SetTextPos( 50, ScrH() - 280 - h / 2 )
				else
				surface.SetTextPos( 50, ScrH() - 270 - h / 2 )
			end
			else
			if PlySecondaryAmmo > 0 and TotalAmmo > 0 then
				surface.SetTextPos( 320, ScrH() - 75 - h / 2 )
				else
				surface.SetTextPos( 320, ScrH() - 65 - h / 2 )
			end
		end

		if PlyAmmo < 0 then
			surface.DrawText( TotalAmmo )
		else
			if TotalAmmo > 0 then
			surface.DrawText( PlyAmmo .. ' / ' .. TotalAmmo )
			else
			surface.DrawText( PlySecondaryAmmo )
			end
		end
		
		if PlySecondaryAmmo > 0 and TotalAmmo > 0 then
			if Up then
				surface.SetTextPos( 50, ScrH() - 270 )
				else
				surface.SetTextPos( 320, ScrH() - 60 )
			end
			surface.DrawText( PlySecondaryAmmo )
		end
		
		if Up then
			DrawGunRect( 30, ScrH() - 280 )
			else
			DrawGunRect( 300, ScrH() - 75 )
		end
	
	end
	
end
end )

hook.Add( "HUDShouldDraw", "HideNonAmazingHUD", function( name )

	if Simple:GetBool() then
		if ShowAmmo:GetBool() then
			if name == 'CHudHealth' or name == 'CHudBattery' or name == 'CHudAmmo' or name == 'CHudSecondaryAmmo' then return false end
			else
			if name == 'CHudHealth' or name == 'CHudBattery' then return false end
		end
	end
	
end )

hook.Add( 'PopulateToolMenu', 'SimpleHUDSettings', function()
	spawnmenu.AddToolMenuOption( 'Options', 'HUD', 'SimpleHUD_Options', 'Simple HUD', '', '', function( panel )
		
		local function MakeColorMixer( label, command, color )
			local name = vgui.Create( 'DColorMixer' )
			name:SetPalette( true )
			name:SetAlphaBar( true )
			name:SetWangs( true )
			name:SetLabel( label )
			name:SetColor( color )
			--function name:ValueChanged( color ) RunConsoleCommand( command, string.FromColor( color ) ) end
			panel:AddItem( name )
			return name
		end
		
		local function MakeIconPicker( label, mat, command )
			local lb = vgui.Create( 'DLabel' )
			lb:SetText( label )
			lb:SetDark( true )
			panel:AddItem( lb )
			local iconbrowser = vgui.Create( "DIconBrowser" )
			iconbrowser:SetSize( 100, 100 )
			iconbrowser:SelectIcon( mat:GetName()..'.png' )
			iconbrowser:ScrollToSelected()
			panel:AddItem( iconbrowser )
			return iconbrowser
		end
		
		panel:ClearControls()
			
		local enabled = vgui.Create( 'DCheckBoxLabel' )
		enabled:SetText( 'Simple HUD enabled?' )
		enabled:SetValue( Simple:GetBool() )
		enabled:SetConVar( 'SimpleHUD' )
		enabled:SetDark(true)
			
		panel:AddItem( enabled )
		
		local showammo = vgui.Create( 'DCheckBoxLabel' )
		showammo:SetText( 'Show ammo of weapon with Simple HUD?' )
		showammo:SetValue( ShowAmmo:GetBool() )
		showammo:SetConVar( 'SimpleHUD_ShowAmmo' )
		showammo:SetDark(true)
		
		panel:AddItem( showammo )
		
		local clamp = vgui.Create( 'DCheckBoxLabel' )
		clamp:SetText( 'Clamp bars of Simple HUD to never go over 100 percent?' )
		clamp:SetValue( Clamp:GetBool() )
		clamp:SetConVar( 'SimpleHUD_Clamp' )
		clamp:SetDark(true)
		
		panel:AddItem( clamp )
		
		local horizontalorvertical, colormixerhealth, colormixerarmor, colormixerwalkspeed, colormixerspeed, colormixerbg, iconarmor, iconhealth, iconwalkspeed, icondrivespeed, colormixergunbg
		
		local updatebutton = vgui.Create( 'DButton' )
		updatebutton:SetText( 'Apply Changes Below to Simple HUD' )
		updatebutton:SetTooltip( 'You can reset the colors and buttons at the bottom of the controls' )
		updatebutton.DoClick = function()
		
			if horizontalorvertical:GetValue() == 'Vertical' then					
				RunConsoleCommand( 'SimpleHUD_Vertical', '1' )
				else
				RunConsoleCommand( 'SimpleHUD_Vertical', '0' )
			end
			RunConsoleCommand( 'SimpleHUD_BGColor', string.FromColor( colormixerbg:GetColor() ) )
			RunConsoleCommand( 'SimpleHUD_GunBGColor', string.FromColor( colormixergunbg:GetColor() ) )
			RunConsoleCommand( 'SimpleHUD_ArmorColor', string.FromColor( colormixerarmor:GetColor() ) )
			RunConsoleCommand( 'SimpleHUD_HealthColor', string.FromColor( colormixerhealth:GetColor() ) )
			RunConsoleCommand( 'SimpleHUD_SpeedWalkColor', string.FromColor( colormixerwalkspeed:GetColor() ) )
			RunConsoleCommand( 'SimpleHUD_SpeedVehicleColor', string.FromColor( colormixerspeed:GetColor() ) )
			RunConsoleCommand( 'SimpleHUD_ArmorIcon', iconarmor:GetSelectedIcon() )
			ArmorMat = Material( iconarmor:GetSelectedIcon(), 'noclamp smooth' )
			RunConsoleCommand( 'SimpleHUD_HealthIcon', iconhealth:GetSelectedIcon() )
			HealthMat = Material( iconhealth:GetSelectedIcon(), 'noclamp smooth' )
			RunConsoleCommand( 'SimpleHUD_WalkIcon', iconwalkspeed:GetSelectedIcon() )
			SpeedMat = Material( iconwalkspeed:GetSelectedIcon(), 'noclamp smooth' )
			RunConsoleCommand( 'SimpleHUD_DriveIcon', icondrivespeed:GetSelectedIcon() )
			SpeedInCarMat = Material( icondrivespeed:GetSelectedIcon(), 'noclamp smooth' )
			
		end
		
		panel:AddItem( updatebutton )
		
		local function RefreshStuff()
		
			if Vertical:GetBool() then
				horizontalorvertical:SetValue( 'Vertical' )
				else
				horizontalorvertical:SetValue( 'Horizontal' )
			end
			colormixerhealth:SetColor( string.ToColor( HealthColor:GetString() ) )
			colormixerarmor:SetColor( string.ToColor( ArmorColor:GetString() ) )
			colormixerwalkspeed:SetColor( string.ToColor( SpeedColor:GetString() ) )
			colormixerspeed:SetColor( string.ToColor( CarColor:GetString() ) )
			colormixerbg:SetColor( string.ToColor( BGColor:GetString() ) )
			colormixergunbg:SetColor( string.ToColor( GunBGColor:GetString() ) )
			iconarmor:SelectIcon( ArmorIcon:GetString() )
			iconhealth:SelectIcon( HealthIcon:GetString() )
			iconwalkspeed:SelectIcon( WalkIcon:GetString() )
			icondrivespeed:SelectIcon( DriveIcon:GetString() )
			
		end
		
		local refreshbutton = vgui.Create( 'DButton' )
		refreshbutton:SetText( 'Refresh Controls Below' )
		refreshbutton:SetTooltip( 'If you changed any convars outside of this menu, pressing this should update the controls below' )
		refreshbutton.DoClick = function()
		
			RefreshStuff()
			
		end
		
		panel:AddItem( refreshbutton )
		
		local horizontalorverticaltext = vgui.Create( 'DLabel' )
		horizontalorverticaltext:SetText( 'Should the Simple HUD be horizontal or vertical?' )
		horizontalorverticaltext:SetDark(true)
		
		panel:AddItem( horizontalorverticaltext )
		
		horizontalorvertical = vgui.Create( 'DComboBox' )
			
		horizontalorvertical:AddChoice( "Horizontal" )
		horizontalorvertical:AddChoice( "Vertical" )
		if Vertical:GetBool() then
			horizontalorvertical:SetValue( 'Vertical' )
			else
			horizontalorvertical:SetValue( 'Horizontal' )
		end
			
		panel:AddItem( horizontalorvertical )
		
		colormixerbg = MakeColorMixer( 'Color of background box:', 'SimpleHUD_BGColor', string.ToColor( BGColor:GetString() ) )
		colormixergunbg = MakeColorMixer( 'Color of background box (for ammo):', 'SimpleHUD_GunBGColor', string.ToColor( GunBGColor:GetString() ) )
		colormixerarmor = MakeColorMixer( 'Color of armor bar:', 'SimpleHUD_ArmorColor', string.ToColor( ArmorColor:GetString() ) )
		iconarmor = MakeIconPicker( 'Icon of armor bar:', ArmorMat, 'SimpleHUD_ArmorIcon' )
		colormixerhealth = MakeColorMixer( 'Color of health bar:', 'SimpleHUD_HealthColor', string.ToColor( HealthColor:GetString() ) )
		iconhealth = MakeIconPicker( 'Icon of health bar:', HealthMat, 'SimpleHUD_HealthIcon' )
		colormixerwalkspeed = MakeColorMixer( 'Color of speed bar (when walking):', 'SimpleHUD_SpeedWalkColor', string.ToColor( SpeedColor:GetString() ) )
		iconwalkspeed = MakeIconPicker( 'Icon of speed bar (when walking):', SpeedMat, 'SimpleHUD_WalkIcon' )
		colormixerspeed = MakeColorMixer( 'Color of speed bar (when driving):', 'SimpleHUD_SpeedVehicleColor', string.ToColor( CarColor:GetString() ) )
		icondrivespeed = MakeIconPicker( 'Icon of speed bar (when driving):', SpeedInCarMat, 'SimpleHUD_DriveIcon' )
		
		local resettodefault = vgui.Create( 'DButton' )
		resettodefault:SetText( 'Reset Colors' )
		resettodefault.DoClick = function()
			Derma_Query( "Are you sure?", 'Simple HUD', 'Yes', function()
			RunConsoleCommand( 'SimpleHUD_BGColor', '0 0 0 170' )
			RunConsoleCommand( 'SimpleHUD_GunBGColor', '0 0 0 170' )
			RunConsoleCommand( 'SimpleHUD_ArmorColor', '255 158 0 255' )
			RunConsoleCommand( 'SimpleHUD_HealthColor', '206 0 0 255' )
			RunConsoleCommand( 'SimpleHUD_SpeedWalkColor', '0 158 206 255' )
			RunConsoleCommand( 'SimpleHUD_SpeedVehicleColor', '75 186 56 255' ) timer.Simple( 0.3, function() RefreshStuff() end ) end, 'No', function() end )
		end
		
		panel:AddItem( resettodefault )
		
		local resettodefaulticons = vgui.Create( 'DButton' )
		resettodefaulticons:SetText( 'Reset Icons' )
		resettodefaulticons.DoClick = function()
			Derma_Query( "Are you sure?", 'Simple HUD', 'Yes', function()
			RunConsoleCommand( 'SimpleHUD_HealthIcon', 'icon16/heart.png' )
			RunConsoleCommand( 'SimpleHUD_ArmorIcon', 'icon16/shield.png' )
			RunConsoleCommand( 'SimpleHUD_WalkIcon', 'icon16/user_go.png' )
			RunConsoleCommand( 'SimpleHUD_DriveIcon', 'icon16/car.png' )
			HealthMat = Material( 'icon16/heart.png', 'noclamp smooth' )
			ArmorMat = Material( 'icon16/shield.png', 'noclamp smooth' )
			SpeedMat = Material( 'icon16/user_go.png', 'noclamp smooth' )
			SpeedInCarMat = Material( 'icon16/car.png', 'noclamp smooth' ) timer.Simple( 0.3, function() RefreshStuff() end ) end, 'No', function() end )
		end
		
		panel:AddItem( resettodefaulticons )
			
	end )
end )
