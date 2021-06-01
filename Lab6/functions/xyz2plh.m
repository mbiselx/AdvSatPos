function B = xyz2plh(A)
% B = xyz2plh(A)
% returns B[latitude,longitude,ellips.height,M,N] given
% the ECEF (cartesian coordinates) A[x,y,z]
% for the WGS84 ellipsoid
%
% JAN SKALOUD, 1994

elp = elips('WGS84') ;
a = elp(1);
e2 = elp(6) ;

x= A(1);
y= A(2) ;
z= A(3) ;

Long  = atan2(y, x);
dist = (sqrt(x * x + y * y));
Lat = atan2(z, dist);

for i=0:10,
	sphi = sin(Lat);
	cphi = cos(Lat);
	rN   = a / sqrt(1.0- e2 * sphi * sphi);
	ht   = ((dist / cphi) - rN);
	Lat  = atan( (z/dist) *(1.0/(1.0 - e2 * rN/(rN + ht))) );
end

W  = sqrt(1.0-e2 * sphi * sphi);
rM = (a * (1.0 - e2)) / (W*W*W);

B = [ Lat Long ht rM rN ] ;

function e = elips( i_datum )

% returns vector of elipsoid parameters defined as
%   e = [ a b we gm flat e2 es2 ]
%
% and corresponding to:
% 'i_datum':  'NAD27', 'CLARK', 'WGS72', 'BESSEL'
%   default: 'WGS84'
%

	if	strcmp(i_datum,'NAD27')
		a = 6378206.4;
		b = 6356583.8;
		we = 7.292115E-5;
		gm = 3986005.0e8;
		flat = ( a - b ) / a;
		e2 = ( a*a - b*b ) /( a*a );
		es2 = e2/(1.0-e2);

	elseif strcmp(i_datum,'CLARK')
		a = 6378206.0;
		b = 6356584.0;
		we = 7.292115E-5;
		gm = 3986005.0e8;
		flat = ( a - b ) / a;
		e2 = ( a*a - b*b ) /( a*a );
		es2 = e2/(1.0-e2);

	elseif strcmp(i_datum,'WGS72')
		a = 6378135.0;
		b = 6.35675E6;
		we = 7.292115E-5;
		gm = 3986005.0e8;
		flat = ( a - b ) / a;
		e2 = ( a*a - b*b ) /( a*a );
		es2 = e2/(1.0-e2);

	elseif strcmp(i_datum,'BESSEL')
		a = 6377397.155;
		flat = 1/299.1528153440298 ;
		we = 7.292115E-5;  % don't know
		gm = 3986005.0e8;  % don't know
		b = a - a*flat;
		e2 = ( a*a - b*b ) /( a*a );
		es2 = e2/(1.0-e2);

   else %strcmp(i_datum,'WGS84')
		a = 6378137.0;
		b = 6356752.3141;
		we = 7.292115E-5;
		gm = 3986005.0e8;
		flat = ( a - b ) / a;
		e2 = ( a*a - b*b ) /( a*a );
      es2 = e2/(1.0-e2);
   end

   e = [ a b we gm flat e2 es2 ] ;
