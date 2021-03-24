function draw_ellipsoid(cart, labels)
% function draw_ellipsoid(cart)
%
% draws the ellipsoid specified, and places the points ogiven in cartesian coordinates
%
% cart    : cartesian coordinates [m]
%           [X, Y, Z]
% ellipse : struct describing the ellipse
% declare ellipses as structs (swisstopo)
GRS80  = struct("name", 'GRS80',  "a", 6378137.000, "b", 6356752.314140 , "e2", 0);
GRS80.e2  = 1-GRS80.b^2/GRS80.a^2;

% resolution magic number: big is more resolution, but more computing (so slower)
  N=40;

% scale (because octave doesn't handle big numbers in displays well)
  SF = 1e-3;

% prepare the surface of the ellipsoid (PS: a function ellipsoid()
% exists, which can be used for precistely this, but that's no fun)
  [theta, phi] = ndgrid(linspace(-pi/2, pi/2, N), linspace(-pi, pi, N));
  Rn = GRS80.b ./ sqrt(1-GRS80.e2*(cos(theta).^2));
  Xs = Rn.*cos(theta).*cos(phi);
  Ys = Rn.*cos(theta).*sin(phi);
  Zs = Rn.*sin(theta);

% make a nice blue color map so the ellipsoid is pretty
  cmap = .9*ones(ceil(N/2),3) - ([.9;.5;.2] * linspace(0,1,ceil(N/2)))';

% plot surface
  figure()
  surf(Xs*SF, Ys*SF, Zs*SF, Rn);
  title(GRS80.name)
  axis("equal", 'off')
  colormap(cmap)
  shading flat;
  grid off;
  rotate3d on;

% plot the points
  for n = [1:size(cart, 1)]
    hold on
    plot3(cart(n,1)*SF, cart(n,2)*SF, cart(n,3)*SF, 'rx');
    text(cart(n,1)*SF, cart(n,2)*SF, cart(n,3)*SF, labels{n});
  end
  hold off

end
