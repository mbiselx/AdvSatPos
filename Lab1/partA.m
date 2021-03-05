clear
clc

addpath(".//functions")

# ephemeris
M0  = .761313105850E+00;    # [rad]
ecc = .452461070381E-03;    # []
sqrta=.544060110855E+04;    # [m^(1/2)]
toe = .475200000000E+06;    # [s]

# constants
GM  = 3.986005e14      ;    # [m^3 / s^2] Earth gravitation constant
w   = 7.2921151467e-5  ;    # [rad / s] Earth rotation speed
R   = 6371e3;               # [m] Earth Radius

# position at a different time
tp  = 474278           ;    # [s]
Xp  = 23599391.74      ;    # [m]
Yp  = 17849499.96      ;    # [m]

# timespan
t   = [453600:50:504000];  # [s]


##################################################
# EX 1 : calculate patition (X,Y) at t0
##################################################

[X0, Y0] = OrbitalPlanePosition(M0, sqrta, ecc);

printf("Time: %d | (X,Y) = (%.2f, %.2f)\n", toe, X0, Y0)


##################################################
# EX 2.0 : verify procedure on control
##################################################
tol = 1e-2;

Mp = MeanAnomaly(M0, sqrta, toe, tp);
[Xpc, Ypc] = OrbitalPlanePosition(Mp, sqrta, ecc);

printf("Time: %d | (X,Y) = (%.2f, %.2f)\n", tp, Xpc, Ypc)
assert( (abs(Xp - Xpc) < tol) && (abs(Yp - Ypc) < tol), ...
        "The calculated point (%.2f,%.2f) does not \n\tcorrespond to the real point (%.2f,%.2f)",Xpc,Ypc, Xp,Yp)
printf("The calculated point matches the real point to within %g\n", tol)


##################################################
# EX 2.1 : calculate position (X,Y) for time range
##################################################

M = MeanAnomaly(M0, sqrta, toe, t);
[X, Y] = OrbitalPlanePosition(M, sqrta, ecc);

figure(1)
sf = 1e-6; #scaling factor because otherwise axis("equals") crashes octave
    h1 = plot(sf*X, sf*Y, "linewidth",1.5);         # orbit
    hold on;
    h2 = plot(sf*X0, sf*Y0, "o", "linewidth",1.5);  # Position at toe
    h3 = plot(sf*ecc*(sqrta^2)*[-1, 1], [0, 0], "kx", "linewidth",1.5); # foci
    h4 = plot(sf*(R*(cos(-.1:.1:2*pi)) + ecc*sqrta^2), sf*R*(sin(-.1:.1:2*pi)), "g", "linewidth",1.5);
    axis("equal")
    legend([h3, h4, h2, h1], "Foci", "Earth (F1)", "Position at t_0", "Orbit over t", "location", "southeast")
    set(get(gca,'XLabel'),'String','X [10^6 m]');
    set(get(gca,'YLabel'),'String','Y [10^6 m]');
    title("position of satellite in orbtal plane");
    hold off;


##################################################
# EX 4 : max distance from earth center (Apogee)
##################################################

# a(1+e)
Apogee = sqrta^2*(1+ecc);
printf("Apogee at %.2fm from Earth center,\n", Apogee);


##################################################
# EX 5 : min distance from earth center
##################################################

# a(1-e)
Perigee = sqrta^2*(1-ecc);
printf("Perigee at %.2fm from Earth center.\n", Perigee)
printf("Difference: %.2fm.\n", Apogee - Perigee)


##################################################
# EX 6 : orbit duration
##################################################

Period = 2*pi * sqrta^3 / sqrt(GM) ;
printf("Orbital period of %.2fs, or %dh %dmin %ds.\n", Period, round(Period/60^2), round((mod(Period, 60^2))/60), round(mod(Period, 60)))
