clear
clc

addpath(".//functions")


# input file
filename = "EPFL043K.21l";
[ephm info units] = getrinexephGal(filename);

prn     = 1; # this could be much more elegant, but i can't
crs     = 6;
deltan  = 7;
m0      = 8;
cuc     = 9;
ecc     = 10;
cus     = 11;
sqrta   = 12;
toe     = 13;
cic     = 14;
omega0  = 15; # long. of ascending node
cis     = 16;
i0      = 17; # inclination
crc     = 18;
omega   = 19; # argument of perigee
omegadot= 20;
idot    = 21;

# time of week
tow = 480000;    # [s]

# constants
we  = 7.2921151467e-5  ;    # [rad / s] Earth rotation speed

# satellites of intrest
SVprn = [2, 7, 8, 11, 25, 30, 36];


##################################################
# step 0: select only the important ephemera
##################################################

SVidx = zeros(size(SVprn));

for sv = SVprn
    idx = find( ephm(prn,:) == sv);
    m = max( ephm(toe, idx(ephm(toe, idx) <= tow) ));   % the past time clostest to tow
    SVidx(SVprn == sv) = idx(ephm(toe,idx) == m);
end


##################################################
# EX 1 : ECI satellite coordinates
##################################################

# step 1: calculate position in orbital plane
[x1o, x2o, i, w] = CorrectedOrbitalPlanePosition(ephm(:,SVidx), tow);
Xo = [x1o; x2o; zeros(size(x1o))];

# step 2: calculate position in ECI
Xi = zeros(size(Xo));
for idx = 1:length(SVidx)         # loop for every satellite
    W = ephm(omega0,SVidx(idx)) + ephm(omegadot,SVidx(idx))*(tow - ephm(toe,SVidx(idx)));
    Xi(:,idx) = RotMat(-W,3) * RotMat(-i(idx),1) *  RotMat(-w(idx),3) * Xo(:,idx);
end


##################################################
# EX 2 : ECEF satellite coordinates
##################################################

# step 3: calculate position in ECEF
Xe = zeros(size(Xo));
for idx = 1:length(SVidx)         # loop for every satellite
    Xe(:,idx) = RotMat(we * tow, 3) * Xi(:,idx);     % re-use values from EX 1
end
