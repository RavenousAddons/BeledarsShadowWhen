local ADDON_NAME, ns = ...

local GetAddOnMetadata = C_AddOns.GetAddOnMetadata

ns.name = "Beledar's Shadow When?"
ns.title = GetAddOnMetadata(ADDON_NAME, "Title")
ns.notes = GetAddOnMetadata(ADDON_NAME, "Notes")
ns.version = GetAddOnMetadata(ADDON_NAME, "Version")
ns.icon = GetAddOnMetadata(ADDON_NAME, "IconAtlas")
ns.color = "a060ff"
ns.command = "bsw"
ns.prefix = "BSW_"
