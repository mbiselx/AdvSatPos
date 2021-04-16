%  Advanced Satellite Positioning - Lab 3 Task 2
clc;
clear
load('Ex1T2_mistery_signal.mat'); % gives a matrix called mistery_s
% plot(mistery_s)

fs = 6.5e6;

maximas = zeros(1,10);
tau     = zeros(1,10);
fprintf("checking:")
tic
for prn = 1:10  % check every prn between 1 and 10
    fprintf(" prn %d\n\t ", prn)
    c = computeCorrelation(mistery_s, generateGoldCodeSampled(prn, fs, 1.023e6, 1));
    [maximas(prn), tau(prn)] = max(c);
end
fprintf("Done!\n")
toc

prns = [1:10](maximas > 2*mean(maximas));
delays = tau(prns)-1; % because matlab arrays start at 1

fprintf("\nThe prns found are %d and %d, at %d and %d sample delay respectively\n", prns(1), prns(2), delays(1), delays(2))

fprintf("This corresponds to a time delay of %f s and %f s respectively\n", delays(1)/fs, delays(2)/fs)

for i = 1:2
    plot(computeCorrelation(mistery_s, generateGoldCodeSampled(prns(i), fs, 1.023e6, 1)));
    hold on
end
hold off
legend(sprintf('cross correlation with PRN%d', prns(1)), sprintf('cross correlation with PRN%d', prns(2)))
