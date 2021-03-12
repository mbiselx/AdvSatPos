function [meas, tow] = GetRecieverMeasurements(filename)

    fid = fopen(filename) ;

    ln = fgetl(fid); % skip first line
    tow = 479420;    % cheat: is contained in first line

    meas=[];
    while (1)        % gets pseudroranges from file
        [data, nb] = fscanf(fid, "%d %f/n");
        if nb == 0; break; end
        meas=[meas,data];
    end

end
