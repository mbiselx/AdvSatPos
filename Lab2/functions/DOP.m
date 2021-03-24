function [GDOP, PDOP, HDOP, VDOP] = DOP(X, A, P)

    Qxyz = pinv(A'*P*A);				% confidence matrix (cartesian)

    ell = xyz2plh(X);
    Renu = R_ENU(ell(1), ell(2))		% ENU rotation matrix
    Qenu = Renu' * Qxyz(1:3,1:3) * Renu;% confidence matrix (ENU)

    GDOP = sqrt(sum(diag(Qxyz)));		% calculate the different DOPs
    PDOP = sqrt(sum(diag(Qenu)));
    HDOP = sqrt(Qenu(1,1)+Qenu(2,2));
    VDOP = sqrt(Qenu(3,3));


end

function R = R_ENU(lat, lon)
% transforming to a local coordinate system
% see: https://gssc.esa.int/navipedia/index.php/Positioning_Error

    R = [-sin(lon)  -sin(lat)*cos(lon)  cos(lat)*cos(lon)
          cos(lon)  -sin(lat)*sin(lon)  cos(lat)*sin(lon)
          0          cos(lat)           sin(lat)         ];


end
