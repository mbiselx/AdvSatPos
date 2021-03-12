clear
clc
addpath(".//functions")

% constant declarations
c       = 299792458;             % [m s^-1]
we      = 7.2921151467e-5;       % [rad s^-1]

Xe = [  -12522936.0	  9219150.6	21645309.5
          8198595.7	 15366463.9	20430971.9
         -1377763.1	 19788593.0	17301213.3
        -18866890.6	-11916778.5	15176225.1
        -26350373.3	   327459.3	 3638608.4
        -15781457.3	 21148800.8	 1252783.6	]';

Pk = [20870095.9, 24042783.1, 21621621.3, 24379728.7, 22757162.3, 21659750.4];

Xe=Xe(:,1:4);
Pk=Pk(:,1:4);


%% iteration 1
tau =  0.072*ones(size(Pk));
for i = 1:length(Pk)
    Xk(:,i) = RotMat(we*tau(i), 3)*Xe(:,i);
end

[r, b] = BancroftFilter(Xk, Pk)
psr = sqrt(sum((Xk - r).^2));

if any(abs([r;b]-[-3941742.3 3354290.3 3714880.9 144901.5]') > 1)
    error('First iteration failed, still not good');
else
    disp("first iteration ok");
end


% iteration 2
tau = psr/c;
for i = 1:length(Pk)
    Xk(:,i) = RotMat(we*tau(i), 3)*Xe(:,i);
end

[r, b] = BancroftFilter(Xk, Pk)

if any(abs([r;b]-[-3941738.6 3354289.5 3714888.4  144906.2]') > 1)
    error('Second iteration failed, still not good');
else
    disp("Second iteration ok");
end
