
% Poiché i due punti di fuga sono associati a direzioni
% ortogonali, il punto di vista deve stare in una posizione
% dalla quale i punti di fuga sono raggiunti muovendosi 
% lungo due direzioni perpendicolari: dunque il punto
% di vista deve trovarsi su una circonferenza il cui diametro 
% è il segmento che collega i due punti di fuga. 
% Poiché siamo in 3D esistono infinite circonferenze attorno a quel diametro e il luogo di punti
% è perciò una sfera: quella che ha come diametro il segmento di cui sopra. .
% date tre coppie di punti di fuga ottenuti muovendo la telecamera, il punto di vista 
% si trova all'intersezione delle tre sfere. 

function [ K ] = CalibrationWithThreeCoupleOrthoVP( xh , yh , xv , yv )
% CALIBRATIONWITHTHREECOUPLEORTHOVP: this function computes the calibration
% matrix of a camera given three different couples of vanishing points 

% check on each point dimension to be compiant to the algorithm
    if size(xh,1)~= 3 || size(yh,1)~= 3 || size(xv,1)~= 3 || size(yv,1)~= 3
        error('Wrong number of orthogonal vanishing points');
    end

% r: radius [x y]: center - initialization
    r = zeros(3,1);
    x = zeros(3,1);
    y = zeros(3,1);

% for each couple of vanishing points we compute the center of the circle
% [x y] and its radius
    for i=1:3
        x(i) = ( xh(i) + xv(i) ) / 2;
        y(i) = ( yh(i) + yv(i) ) / 2;
    end

    for i=1:3
        diffx = xh(i) - xv(i);
        diffy = yh(i) - yv(i);
        r(i) = sqrt( diffx^2 + diffy^2 )/2;
    end

    A = [ x(1)-x(2) , y(1)-y(2) ;
          x(1)-x(3) , y(1)-y(3) ];

    b = (1/2) * [(x(1)^2 + y(1)^2 -(x(2)^2 + y(2)^2) - r(1)^2 + r(2)^2);
                 (x(1)^2 + y(1)^2 -(x(3)^2 + y(3)^2) - r(1)^2 + r(3)^2)];

    P =  A \ b;

% [x0 y0]: principal point coordinates
% f: focal lenght
    x0 = P(1);
    y0 = P(2);
    f = sqrt(r(1)^2 -(x0-x(1))^2 -(y0-y(1))^2);
% K: calibration matrix
    K = [f,0,x0; 0,f,y0; 0,0,1];

end

