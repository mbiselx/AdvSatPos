settings = initSettings;

hax=[];
for d = [.5, .3, .1]
    settings.spacing = d;

    mee_hrc;

    hax = [hax, h];
end

legend(hax, {"d = 0.5", "d = 0.3", "d = 0.1"})
