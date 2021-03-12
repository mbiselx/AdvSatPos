function R = RotMat(theta, ax=1)


    if any(size(theta) > 1)
        error("invalid input angle of size (%d, %d). input angle must be a scalar", ...
                size(theta)(1),size(theta)(2));
    end

    s = sin(theta);
    c = cos(theta);

    switch(ax)
        case 1
            R =[ 1  0  0;
                 0  c  s;
                 0 -s  c];
        case 2
            R =[ c  0 -s;
                 0  1  0;
                 s  0  c];
        case 3
            R =[ c  s  0;
                -s  c  0;
                 0  0  1];
         otherwise
            error("invalid rotation axis %d. rotation axis must be 1, 2 or 3", ax);
     end


end
