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
    sounds = {
        present = 567399, -- alarmclockwarning2.ogg
        future = 567458, -- alarmclockwarning3.ogg
    },
    toggles = {
        recentlyOutput = false,
        timerActive = false,
    },
    timeouts = {
        short = 10,
        medium = 20,
        long = 60,
    },
}
