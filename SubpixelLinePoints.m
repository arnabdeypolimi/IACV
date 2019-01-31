function [ subPixel1, subPixel2 ] = SubpixelLinePoints( gradient, fillingFactor )
    % SLOPE: slope of the line passing through the pixel
    % FILLINGFACTOR: how much the pixel il filled

    debug = 0;
    
    gradSlope = atan(gradient(2)/gradient(1));

    if gradSlope <= 0
        slope = gradSlope + pi/2;
    else
        slope = -pi/2 + gradSlope;
    end

    alpha = abs(slope);
    beta = pi/2-alpha;

    isVertical = pi/2-abs(alpha) < 0.001;
    isHorizontal = abs(alpha) < 0.001;

    leftOriented = dot(gradient, [1 0]) < 0;
    rightOriented = dot(gradient, [1 0]) > 0;

    subPixel1 = zeros(1,2);
    subPixel2 = zeros(1,2);

    if isVertical
        % vertical line

        if leftOriented
            if debug == 1
                fprintf('\nV-SX');
            end
            subPixel1 = [fillingFactor 0];
            subPixel2 = [fillingFactor 1];
        else
            if debug == 1
                fprintf('\nV-DX');
            end
            subPixel1 = [1-fillingFactor 0];
            subPixel2 = [1-fillingFactor 1];
        end

    else if isHorizontal
            % horizontal line
            downOriented = dot(gradient, [0 1]) > 0;

            if downOriented
                if debug == 1
                    fprintf('\nH-DW');
                end
                subPixel1 = [0 fillingFactor];
                subPixel2 = [1 fillingFactor];
            else
                if debug == 1
                    fprintf('\nH-UP');
                end
                subPixel1 = [0 1-fillingFactor];
                subPixel2 = [1 1-fillingFactor];
            end
        else
            % slanting

            if alpha < pi/4
                b = cos(beta)/cos(alpha);
                Amax = 0.5 * b;
                Bmin = 1 - Amax;
            else
                a = cos(alpha)/cos(beta);
                Amax = 0.5 * a;
                Bmin = 1 - Amax;
            end

            A1A2case = fillingFactor > Amax && fillingFactor < Bmin;
            ABcase = ~A1A2case;

            if A1A2case
                if leftOriented
                    actualFF = fillingFactor;
                end

                if rightOriented
                    actualFF = 1-fillingFactor;
                end

                if alpha < pi/4
                    a = 1;
                    b = cos(beta)/cos(alpha);
                    A1 = 0.5 * b;
                    c = (actualFF-A1);

                    if sign(slope) == 1
                        if debug == 1
                            fprintf('\nSV-C-/');
                            fprintf('\na: %f\nb: %f\nc: %f',a,b,c);
                        end
                        subPixel1 = [0 1-b-c];
                        subPixel2 = [a 1-c];
                    else
                        if debug == 1
                            fprintf('\nSV-C-\\');
                            fprintf('\na: %f\nb: %f\nc: %f',a,b,c);
                        end
                        subPixel1 = [0 c+b];
                        subPixel2 = [a c];
                    end
                else
                    a = cos(alpha)/cos(beta);
                    b = 1;
                    A1 = 0.5 * a;
                    c = (actualFF-A1);

                    if sign(slope) == 1
                        if debug == 1
                            fprintf('\nSH-C-/');
                            fprintf('\na: %f\nb: %f\nc: %f',a,b,c);
                        end
                        subPixel1 = [c 0];
                        subPixel2 = [c+a b];
                    else
                        if debug == 1
                            fprintf('\nSH-C-\\');
                            fprintf('\na: %f\nb: %f\nc: %f',a,b,c);
                        end
                        subPixel1 = [c+a 0];
                        subPixel2 = [c b];
                    end
                end

            end

            if ABcase
                % A vs B
                AAcase = (leftOriented && fillingFactor <= 0.5) || (rightOriented && fillingFactor > 0.5);
                BBcase = (leftOriented && fillingFactor > 0.5) || (rightOriented && fillingFactor <= 0.5);

                if AAcase
                    if fillingFactor > 0.5
                        actualFF = 1-fillingFactor;
                    else
                        actualFF = fillingFactor;
                    end
                    a = sqrt(actualFF / 0.5 * cos(alpha) / cos(beta));
                    b = a * cos(beta)/cos(alpha);
                    if sign(slope) == 1
                        if debug == 1
                            fprintf('\nS-SX-/');
                            fprintf('\na: %f\nb: %f',a,b);
                        end
                        subPixel1 = [0 1-b];
                        subPixel2 = [a 1];
                    else
                        if debug == 1
                            fprintf('\nS-SX-\\');
                            fprintf('\na: %f\nb: %f',a,b);
                        end
                        subPixel1 = [0 b];
                        subPixel2 = [a 0];
                    end
                end
                if BBcase
                    if fillingFactor > 0.5
                        actualFF = 1-fillingFactor;
                    else
                        actualFF = fillingFactor;
                    end
                    a = sqrt(actualFF / 0.5 * cos(alpha) / cos(beta));
                    b = a * cos(beta)/cos(alpha);

                    if sign(slope) == 1
                        if debug == 1
                            fprintf('\nS-DX-/');
                            fprintf('\na: %f\nb: %f',a,b);
                        end
                        subPixel1 = [1 b];
                        subPixel2 = [1-a 0];
                    else
                        if debug == 1
                            fprintf('\nS-DX-\\');
                            fprintf('\na: %f\nb: %f',a,b);
                        end
                        subPixel1 = [1 1-b];
                        subPixel2 = [1-a 1];
                    end
                end
            end
        end
    end
    if debug == 1
        fprintf('\np1: (%f %f)',subPixel1(1),subPixel1(2));
        fprintf('\np2: (%f %f)',subPixel2(1),subPixel2(2));
        fprintf('\nff: %f',fillingFactor);
        fprintf('\nalpha: %f',alpha/pi*180);
        fprintf('\nbeta: %f\n',beta/pi*180);
    end
    subPixel1 = subPixel1-[0.5 0.5];
    subPixel2 = subPixel2-[0.5 0.5];


end

