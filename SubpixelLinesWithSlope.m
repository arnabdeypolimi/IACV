function [ couples, houghpoints ] = SubpixelLinesWithSlope( hMatrix, lines, param, dim, pool,slope)
% SUBPIXELLINESWITHSLOPE: this function analyses the output data from the
% subpixel analysis in order to extract a certain amount of lines with a
% specified slope
% HMATRIX : output from the subpixel filter algorithm
% LINES : number of lines to be identified
% PARAM : parameters defining the pool
% DIM : dimensions of the image analyzed
% POOL : pool containing all raw data from the subpixel analysis
% SLOPE: angle in degrees between [-90, 90] of the lines to extract

% this function contains different algorithms in order to provide different
% line recognition properties


    debug = 0;
    debugalgorithm = 0;
    
    houghMaxRho = param(1);
    houghMaxTheta = param(2);
    houghMaxRhoSensed = param(3);
    houghMaxThetaSensed = param(4);

    n = lines;
    mmax = zeros(1,n);
    xmax = zeros(1,n);
    ymax = zeros(1,n);
    
    angle_margin = 8; %18
    patch = round(angle_margin /houghMaxThetaSensed*houghMaxTheta); % ± angle_margin°
    if slope <= 0
        slopeThetaIndex = round((slope+180)/houghMaxThetaSensed*houghMaxTheta);
        thetaRange = slopeThetaIndex-patch:slopeThetaIndex+patch;
    else
        slopeThetaIndex = round((slope)/houghMaxThetaSensed*houghMaxTheta);
        thetaRange = slopeThetaIndex-patch:slopeThetaIndex+patch;
        slopeThetaIndex = round((slope+180)/houghMaxThetaSensed*houghMaxTheta);
        thetaRange = [thetaRange, slopeThetaIndex-patch:slopeThetaIndex+patch];
    end

    for i=thetaRange
        if i > 0 && i < size(hMatrix,1)
        for j=1:size(hMatrix,2)
            k=1;
            put = false;
            while k<=n && ~put
                if hMatrix(i,j) >= mmax(k) && hMatrix(i,j)~= 0
                    if k==1
                        tmmax = [hMatrix(i,j) mmax];
                        txmax = [i, xmax];
                        tymax = [j, ymax];
                        mmax = tmmax(1:n);
                        xmax = txmax(1:n);
                        ymax = tymax(1:n);
                        put = true;
                    else
                        tmmax = [mmax(1:k-1) hMatrix(i,j) mmax(k:n)];
                        txmax = [xmax(1:k-1), i, xmax(k:n)];
                        tymax = [ymax(1:k-1), j, ymax(k:n)];
                        mmax = tmmax(1:n);
                        xmax = txmax(1:n);
                        ymax = tymax(1:n);
                        put = true;
                    end
                end
                k = k + 1;
            end
        end
        end
    end
    
    actualLines = 0;
    for i=1:n
        if xmax(i) ~= 0 || ymax(i) ~= 0
            actualLines = actualLines + 1;
        end
    end
    
    m_vett = zeros(actualLines,1);
    q_vett = zeros(actualLines,1);
    maxY = dim(1);
    maxX = dim(2);
   
    for i=1:actualLines

%      VI Method
        patchSize = 6; %2:  7
        
        [xrange, yrange] = PatchCentered([xmax(i) ymax(i)],patchSize, size(hMatrix));
        
        paramSize = 0;
        for k=xrange
            for h=yrange
                poolparam = pool(k,h).param;
                if hMatrix(k,h)~= 0
                    paramSize = paramSize + size(poolparam,1);
                end
            end
        end
        
        thetaVals = zeros(paramSize,1);
        rhoVals = zeros(paramSize,1);
        valsCount = 1;
        
        for k=xrange
            for h=yrange
                if hMatrix(k,h)~= 0
                    poolparam = pool(k,h).param;
                    poolparamSize = size(poolparam,1);
                    thetaVals(valsCount:valsCount+poolparamSize-1) = poolparam(:,1);
                    rhoVals(valsCount:valsCount+poolparamSize-1) = poolparam(:,2);
                    valsCount = valsCount + poolparamSize;
                end
            end
        end
        theta = median(thetaVals);
        rho= median(rhoVals);
        if debugalgorithm==1
            fprintf('\ntheta: %f \trho: %f',theta,rho);
        end
        
        
%       V Method ~ asymmetric
%         theta = 0;
%         rho = 0;
%         thetaPatchSize = 2;
%         rhoPatchSize = 5;
%         gauss = fspecial('gaussian',[thetaPatchSize*2+1 rhoPatchSize*2+1], (rhoPatchSize*2+1)/6);
%         
%         if subplus(xmax(i)-thetaPatchSize) == 0
%              xrange = 1:xmax(i)+thetaPatchSize;
%         else
%              xrange = subplus(xmax(i)-thetaPatchSize):xmax(i)+thetaPatchSize;
%         end
%         
%         if subplus(ymax(i)-rhoPatchSize) == 0
%              yrange = 1:ymax(i)+rhoPatchSize;
%         else
%              yrange = subplus(ymax(i)-rhoPatchSize):ymax(i)+rhoPatchSize;
%         end
%         
%         xrangeMin = xrange(1);
%         yrangeMin = yrange(1);
%         for k=xrange
%             for h=yrange
%                 if hMatrix(k,h)~= 0
%                     gaussx = k-xrangeMin+1;
%                     gaussy = h-yrangeMin+1;
%                     gWeight = gauss(gaussx, gaussy);
%                     poolparam = pool(k,h).param;
%                     theta = theta + sum(poolparam(:,1))/size(poolparam,1)*gWeight;
%                     rho = rho + sum(poolparam(:,2))/size(poolparam,1)*gWeight;
%                 end
%             end
%         end        
    
%       IV Method ~ III + gauss ~ DA SISTEMARE
%         theta = 0;
%         rho = 0;
%         patchSize = 1;
%         gauss = fspecial('gaussian',[patchSize*2+1 patchSize*2+1], (patchSize*2+1)/6);
%         xrange = subplus(xmax(i)-patchSize):xmax(i)+patchSize;
%         yrange = subplus(ymax(i)-patchSize):ymax(i)+patchSize;
%         xrangeMin = xrange(1);
%         yrangeMin = yrange(1);
%         for k=xrange
%             for h=yrange
%                 if hMatrix(k,h) ~= 0
%                 gaussx = k-xrangeMin+1;
%                 gaussy = h-yrangeMin+1;
%                 gWeight = gauss(gaussx, gaussy);
%                 poolparam = pool(k,h).param;
%                 theta = theta + sum(poolparam(:,1))/size(poolparam,1)*gWeight;
%                 rho = rho + sum(poolparam(:,2))/size(poolparam,1)*gWeight;
%                 end
%             end
%         end
        
%       III Method ~ when patchSize = 0 EQUALS II Method [Missing hMatrix check]
%         weight = 0;
%         theta = 0;
%         rho = 0;
%         patchSize = 0;
%         xrange = subplus(xmax(i)-patchSize):xmax(i)+patchSize;
%         yrange = subplus(ymax(i)-patchSize):ymax(i)+patchSize;
%         for k=xrange
%             for h=yrange
%                 poolparam = pool(k,h).param;
%                 newWeight = weight + size(poolparam,1);
%                 theta = (theta*weight + sum(poolparam(:,1)))/newWeight;
%                 rho = (rho*weight + sum(poolparam(:,2)))/newWeight;
%                 weight = newWeight;
%             end
%         end
        
%        II Method        
%        poolparam = pool(xmax(i),ymax(i)).param;
%        theta = sum(poolparam(:,1))/size(poolparam,1);
%        rho = sum(poolparam(:,2))/size(poolparam,1);
        
%        I Method
%        theta = xmax(i)/houghMaxTheta*houghMaxThetaSensed;
%        rho = ymax(i)/houghMaxRho*houghMaxRhoSensed;
            
        m = -1/tand(theta);
        q = rho*(-m*cosd(theta)+sind(theta));
        m_vett(i) = m;
        q_vett(i) = q;
    end
    
    m_vett = DeleteDuplicates(m_vett);
    q_vett = DeleteDuplicates(q_vett);
    
    coupleStruct = struct('point1', [0 0],'point2', [0 0]);
    couples = repmat(coupleStruct,size(m_vett,1),1);
    
    for i=1:size(m_vett,1);
        m = m_vett(i);
        q = q_vett(i);
        
        p1 = [1 q+m];
        p2 = [(1-q)/m 1];
        p3 = [maxX m*maxX+q];
        p4 = [(maxY-q)/m maxY];

        pts = [p1; p2; p3; p4];
        fpts = zeros(2);
        ipts = 1;

        for j=1:4
            if pts(j,1) >= 0 && pts(j,1) <= maxX && pts(j,2) >= 0 && pts(j,2) <= maxY
                fpts(ipts,:) = pts(j,:);
                ipts = ipts + 1;
            end
        end

        if debug == 1
                fprintf('\nq: %f m: %f rho: %f theta: %f',q,m,rho, theta);
                fprintf('\np1:[%f %f]',p1(1),p1(2));
                fprintf('\np2:[%f %f]',p2(1),p2(2));
                fprintf('\np3:[%f %f]',p3(1),p3(2));
                fprintf('\np4:[%f %f]',p4(1),p4(2));
        end

        couples(i) =struct('point1', fpts(1,:), 'point2', fpts(2,:));
        
    end
    
    houghpoints = horzcat(xmax',ymax');
end