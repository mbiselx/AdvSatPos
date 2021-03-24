function [r b] = BancroftFilter(Xk, Pk)
% apply the Bancroft non-linear method to calculate a receiver position

    if (size(Xk, 2) < 4)
        error('Not enough datapoints');
    end

    % constants
    M = diag([ones(1,3), -1]);
    e = ones(size(Xk, 2),1);


    alpha = zeros(size(Pk'));
    for k = 1:length(alpha)
        alpha(k) = .5*[Xk(:,k);Pk(k)]'*M*[Xk(:,k);Pk(k)];
    end

    B = [Xk', Pk'];
    if size(B, 1) > 4   % inverse of B
        Bi = inv(B'*B)*B';
    else
        Bi = inv(B);
    end

    a = (Bi*e)'*M*(Bi*e);   % find roots of polynomial
    b = 2*((Bi*alpha)'*M*(Bi*e) - 1);
    c = (Bi*alpha)'*M*(Bi*alpha);

    lambda = roots([a, b, c]);

    tmp1 = M*Bi*(lambda(1)*e + alpha); % evaluate both solutions
    tmp2 = M*Bi*(lambda(2)*e + alpha);

    % find out which position is valid (i.e. closer to earth surface)
    if sum(tmp1(1:3).^2) < sum(tmp2(1:3).^2)
        r = tmp1(1:3);
        b = tmp1(4);
    else
        r = tmp2(1:3);
        b = tmp2(4);
    end

end
