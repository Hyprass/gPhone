----// Clientside Utility Functions //----

local client = LocalPlayer()

--// Console commands
concommand.Add("gphone", function()
	gPhone.BuildPhone()
end)

concommand.Add("gphone_close", function()
	gPhone.HidePhone()
end)

concommand.Add("gphone_remove", function()
	gPhone.DestroyPhone()
end)

concommand.Add("gphone_configsave", function()
	gPhone.SaveClientConfig()
end)

-- Temp
concommand.Add("vibrate", function()
	gPhone.Vibrate()
end)

--// Fonts
surface.CreateFont( "gPhone_18Lite", {
	font = "Roboto Lt",
	size = 18,
	weight = 500,
	antialias = true,
} )

surface.CreateFont( "gPhone_14", {
	font = "Roboto Lt",
	size = 14,
	weight = 500,
	antialias = true,
} )

surface.CreateFont( "gPhone_12", {
	font = "Roboto Lt",
	size = 12,
	weight = 600,
	antialias = true,
} )

surface.CreateFont( "gPhone_60", {
	font = "Roboto Lt",
	size = 60,
	weight = 300,
	antialias = true,
} )

surface.CreateFont( "gPhone_18", {
	font = "Roboto Lt",
	size = 18,
	weight = 650,
	antialias = true,
} )

surface.CreateFont( "gPhone_22", {
	font = "Roboto Lt",
	size = 22,
	weight = 650,
	antialias = true,
} )

--// Hide or show children of a panel
function gPhone.HideChildren( pnl )
	if not IsValid( pnl ) then return end
	
	for k, v in pairs( pnl:GetChildren() ) do
		if IsValid(v) then
			v:SetVisible(false)
		end
	end
end

function gPhone.ShowChildren( pnl )
	if not IsValid( pnl ) then return end
	
	for k, v in pairs( pnl:GetChildren() ) do
		if IsValid(v) then
			v:SetVisible(true)
		end
	end
end

function gPhone.HideAppObjects()
	if not IsValid( pnl ) then return end
	
	for k, v in pairs( gApp["_children_"] ) do
		if IsValid(v) then
			v:SetVisible( false )
		end
	end
end

--// Chat messages
function gPhone.ChatMsg( text )
	chat.AddText(
		Color(17, 148, 240), "[gPhone]", 
		Color(255,255,255), ": "..text
	)
end
 
net.Receive( "gPhone_ChatMsg", function( len, ply )
	gPhone.ChatMsg( net.ReadString() )
end)

--// Wallpaper
function gPhone.SetWallpaper( bHome, texStr )
	if bHome then
		gPhone.Config.HomeWallpaperMat = Material(texStr)
		gPhone.Config.HomeWallpaper = texStr
	else
		gPhone.Config.LockWallpaperMat = Material(texStr)
		gPhone.Config.LockWallpaper = texStr
	end
end

function gPhone.GetWallpaper( bHome, isMat )
	if bHome then
		if isMat then
			return gPhone.Config.HomeWallpaperMat or Material( gPhone.Config.FallbackWallpaper )
		else
			return gPhone.Config.HomeWallpaper or gPhone.Config.FallbackWallpaper
		end
	else
		if isMat then
			return gPhone.Config.LockWallpaperMat or Material( gPhone.Config.FallbackWallpaper )
		else
			return gPhone.Config.LockWallpaper or gPhone.Config.FallbackWallpaper
		end
	end
end

--// Color the status bar
function gPhone.DarkenStatusBar()
	for class, tab in pairs(gPhone.StatusBar) do
		if class == "text" then
			for k, pnl in pairs(tab) do
				if not IsValid(pnl) then return end
				pnl:SetTextColor(Color(0,0,0))
			end
		else
			for k, pnl in pairs(tab) do
				if not IsValid(pnl) then return end
				pnl:SetImageColor(Color(0,0,0))
			end
		end
	end
end

function gPhone.LightenStatusBar() 
	for class, tab in pairs(gPhone.StatusBar) do
		if class == "text" then
			for k, pnl in pairs(tab) do
				if not IsValid(pnl) then return end
				pnl:SetTextColor(Color(255,255,255))
			end
		else
			for k, pnl in pairs(tab) do
				if not IsValid(pnl) then return end
				pnl:SetImageColor(Color(255,255,255))
			end
		end
	end
end

--// Show or hide the entire status bar or portions
function gPhone.ShowStatusBar()
	for class, tab in pairs(gPhone.StatusBar) do
		for k, pnl in pairs(tab) do
			pnl:SetVisible(true)
		end
	end
end

function gPhone.ShowStatusBarElement( name )
	for class, tab in pairs(gPhone.StatusBar) do
		if tab[string.lower(name)] then
			tab[string.lower(name)]:SetVisible(true)
		end
	end
end

function gPhone.HideStatusBar()
	for class, tab in pairs(gPhone.StatusBar) do
		for k, pnl in pairs(tab) do
			pnl:SetVisible(false)
		end
	end
end

function gPhone.HideStatusBarElement( name )
	for class, tab in pairs(gPhone.StatusBar) do
		if tab[string.lower(name)] then
			tab[string.lower(name)]:SetVisible(false)
		end
	end
end

--// Grab text size easily
function gPhone.GetTextSize(text, font)
	surface.SetFont(font)
	return surface.GetTextSize(text)
end

--// Center text in a panel
function gPhone.SetTextAndCenter(label, parent, vertical)
	label:SizeToContents()
	local x, y = label:GetPos()
	if vertical then
		label:SetPos( parent:GetWide()/2 - label:GetWide()/2, parent:GetTall()/2 - label:GetTall()/2 )
	else
		label:SetPos( parent:GetWide()/2 - label:GetWide()/2, y )
	end
end

--// Config
function gPhone.SaveClientConfig()
	print("Saving gPhone Config")
	
	cfgJSON = util.TableToJSON( gPhone.Config )
	
	file.CreateDir( "gphone" )
	file.Write( "gphone/client_config.txt", cfgJSON)
end

function gPhone.LoadClientConfig()
	print("Loading gPhone Config")
	
	if not file.Exists( "gphone/client_config.txt", "DATA" ) then
		print("gPhone cannot load a non-existant config file! Rebuilding...")
		gPhone.SaveClientConfig()
		gPhone.LoadClientConfig()
		return
	end
	
	local cfgFile = file.Read( "gphone/client_config.txt", "DATA" )
	local cfgTable = util.JSONToTable( cfgFile ) 

	gPhone.Config = cfgTable
end

--// Saves a text message to an existing txt document or a new one
function gPhone.SaveTextMessage( tbl )
	-- tbl.sender, tbl.time, tbl.date, tbl.message
	local ply = util.GetPlayerByNick( tbl.sender )
	local idFormat = gPhone.SteamIDToFormat( ply:SteamID() )
	
	if file.Exists( "gphone/messages/"..idFormat..".txt", "DATA" ) then
		print("Exists")
		local readFile = file.Read( "gphone/messages/"..idFormat..".txt", "DATA" )
		local readTable = util.JSONToTable( readFile ) 
		
		table.insert( readTable, 1, tbl )
	end
	
	PrintTable(tbl)
	
	local json = util.TableToJSON( tbl ) 
		
	file.CreateDir( "gphone/messages" )
	file.Write( "gphone/messages/"..idFormat..".txt", json)
end

--// Loads all text messages for the name
function gPhone.LoadTextMessagesFrom( name )
	local ply = util.GetPlayerByNick( name )
	local idFormat = gPhone.SteamIDToFormat( ply:SteamID() )
	
	local msgTable = {}
	if file.Exists( "gphone/messages/"..idFormat..".txt", "DATA" ) then
		print("Exists")
		local cfgFile = file.Read( "gphone/client_config.txt", "DATA" )
		msgTable = util.JSONToTable( cfgFile ) 
	end
	
	PrintTable( msgTable )
	
	return msgTable
end

function gPhone.SteamIDToFormat( id )

	local idFragments = string.Explode( ":", id )
	
	local oneOrZero = idFragments[2]
	local bulk = idFragments[3]
	
	local fmat = oneOrZero..bulk
	
	return fmat
end

function gPhone.FormatToSteamID( fmat )
	local front = "STEAM_0:"
	
	local formatFrags = string.Explode( "", fmat )
	local middle = formatFrags[1]
	table.remove( formatFrags, 1 )
	local end_ = table.concat( formatFrags, "")
	
	local id = front..middle..":"..end_
	
	return id
end
