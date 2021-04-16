%  Advanced Satellite Positioning - Lab 3 Task 1

% Step 1: Compute PRN codes using generateCAcode()
PRN2  = generateCAcode(2);
PRN17 = generateCAcode(17);


% Step 2: Compute and plot circular auto correlation for PRN 17
corr_17_17 = computeCorrelation(PRN17, PRN17);
figure(1)
plot(0:length(corr_17_17)-1, corr_17_17)
axis([-10, length(corr_17_17)+10, -100, 1000])
title("auto-correlation of PRN17")
xlabel('\tau [chip]')

% Step 3: Compute and plot circular cross correlation for PRN 2 and PRN 17
figure(2)
corr_2_17 = computeCorrelation(PRN2, PRN17);
plot(0:length(corr_2_17)-1, corr_2_17)
axis([-10, length(corr_2_17)+10, -100, 1000])
title("cross-correlation of PRN2 and PRN17")
xlabel('\tau [chip]')
