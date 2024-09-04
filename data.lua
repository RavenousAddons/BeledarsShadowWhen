local _, ns = ...

ns.data = {
    defaults = {
        alertEnd =  true,
        alertStart =  true,
        alert1Minute =  true,
        alert2Minutes =  true,
        alert5Minutes =  true,
        alert10Minutes =  true,
        alert30Minutes =  true,
        alwaysTrackQuest = false,
        sound = true,
        raidwarning = true,
    },
    timers = {
        alert1Minute = 1,
        alert2Minutes = 2,
        alert5Minutes = 5,
        alert10Minutes = 10,
        alert30Minutes = 30,
    },
    timeout = 10,
    sounds = {
        present = 567399, -- alarmclockwarning2.ogg
        future = 567458, -- alarmclockwarning3.ogg
    },
    toggles = {
        recentlyOutput = false,
        timerActive = false,
    },
    classColors = {
        deathknight = "c41e3a",
        demonhunter = "a330c9",
        druid = "ff7c0a",
        evoker = "33937f",
        hunter = "aad372",
        mage = "3fc7eb",
        monk = "00ff98",
        paladin = "f48cba",
        priest = "ffffff",
        rogue = "fff468",
        shaman = "0070dd",
        warlock = "8788ee",
        warrior = "c69b6d",
    },
    questID = 81763, -- Defeat of Beledar's Spawn
    mountID = 2192, -- Beledar's Spawn
}
