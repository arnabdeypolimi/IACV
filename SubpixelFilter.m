function [ imageSubpixData, houghMatrix, pool ] = SubpixelFilter( bw_image, filter_size, param )
% BW_IMAGE: black and white image to be analyzed;
% FILTER_SIZE: dimension of patches to be analyzed;

    debug = 0;
    debughough = 0;
    
    useGauss = false;
    [height, width] = size(bw_image);
    margin = floor(filter_size/2);
    
    houghMaxRho = param(1);
    houghMaxTheta = param(2);
    houghMaxRhoSensed = param(3);
    houghMaxThetaSensed = param(4);
    
    houghMatrix = zeros(houghMaxTheta,houghMaxRho);

    tmp_subpixStruct = struct('slope', 0, 'point1', [0 0],'point2', [0 0], 'pow', 0);
    imageSubpixData = repmat(tmp_subpixStruct,height,width);
    
    tmp_poolStruct = struct('param', [0 0]);
    pool = repmat(tmp_poolStruct,houghMaxTheta,houghMaxRho);
    
    gaussNormDirMatrix = zeros(filter_size,filter_size,2);
    gauss = fspecial('gaussian',[filter_size filter_size], 1.3);
    gaussNormFactor = sum(sum(gauss))-gauss(margin+1,margin+1);
    
    houghgauss = fspecial('gaussian',[5 5], 1.3);
    houghmargin = floor(5/2);

    for i=1:filter_size
        for j=1:filter_size
            if i==margin+1 && j == margin+1
                gaussNormDirMatrix(i,j,:) =[0 0];
            else
                gaussNormDirMatrix(i,j,:) = [i-(margin+1) j-(margin+1)]/norm([i-(margin+1) j-(margin+1)])*gauss(i,j);
            end
        end
    end
    
    % alternativamente popolare questi vettori con le coordinate dei corner
    % d'interesse, in tal caso niente parfor!
    globalXCoords =1+margin:width-margin;
    globalYCoords =1+margin:height-margin;
    
    for x=globalXCoords
        for y=globalYCoords          

            bwTargetValue = bw_image(y,x);
            gradient = [0.0 0.0]';
            
            xCoords = x-margin:x+margin;
            yCoords = y-margin:y+margin;
            for i=yCoords
                for j=xCoords
                    if i ~= y || j ~= x
                        power = bw_image(i,j) - bwTargetValue;
                        gaussNormDirElem = [gaussNormDirMatrix(i-(y-margin)+1,j-(x-margin)+1,1) gaussNormDirMatrix(i-(y-margin)+1,j-(x-margin)+1,2)]';
                        gradient = gradient + power * gaussNormDirElem;
                        if debug==1
                            fprintf('g(1): %f g(2): %f',gaussNormDirElem(1),gaussNormDirElem(2));
                            fprintf(' pow: %f\n',power);
                        end
                    end
                end
            end

            gradient = gradient/gaussNormFactor;
            gradient = [gradient(2) gradient(1)];
            
            [point1, point2] = SubpixelLinePoints(gradient, bwTargetValue);
            slope = atan(gradient(2)/(gradient(1)+eps));
            point1 = point1 + [x y];
            point2 = point2 + [x y];
            if debug==1
                fprintf('slope: %f\ngrad: [%f %f]\n',slope, gradient(1),gradient(2));
            end
            imageSubpixData(y,x) = struct('slope', slope, 'point1', point1,'point2', point2, 'pow', norm(gradient));
            
            m = (point1(2)-point2(2))/(point1(1)-point2(1)+eps);
            q = point1(2)-m*point1(1);
            ix = -(q*m/(m^2+1));
            iy = q/(m^2+1);
            rho = norm([ix iy]);
            
            theta = atand(m);
            
            if debughough == 1
                    fprintf('\ntheta: %f q: %f', theta, q);
            end
            
            if sign(theta) == 1
                if q > 0
                    theta = theta+90;
                else
                    theta = theta-90;
                end
            else
                theta = theta+90;
            end
                        
            if debughough == 1
                    fprintf(' theta: %f', theta);
            end

            irho = int32(rho*houghMaxRho/houghMaxRhoSensed)+1;
            itheta = int32((theta+90)*houghMaxTheta/houghMaxThetaSensed)+1;
            if norm(gradient) > 0.07
                if (itheta >=1 && itheta <= houghMaxTheta) && (irho >= 1 && irho <= houghMaxRho)
                    if ~useGauss
                        houghMatrix(itheta,irho) = houghMatrix(itheta,irho)+1;
                        poolparam = pool(itheta,irho).param;
                            if poolparam(1) == 0 && poolparam(1) == 0
                                pool(itheta,irho) = struct('param', [theta rho]);
                            else
                                pool(itheta,irho) = struct('param', [poolparam; [theta rho]]);
                            end
                    else
                        if itheta - houghmargin >=1 && itheta + houghmargin <= houghMaxTheta && irho - houghmargin >=1 && irho + houghmargin <= houghMaxRho
                            houghMatrix(itheta-houghmargin:itheta+houghmargin,irho-houghmargin:irho+houghmargin) = houghMatrix(itheta-houghmargin:itheta+houghmargin,irho-houghmargin:irho+houghmargin) + houghgauss;
                        end
                    end
                    
                end
                if debughough == 1
                    %fprintf('\nq: %f m: %f rho: %f theta: %f',q,m,rho, theta);
                end
            end
        end
    end    
end

