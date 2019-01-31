%% test immagini ad-hoc
clc;

debug = 0;
for im=1:4
    bw_image = single(rgb2gray(imread(['filterTest/test3/',num2str(im),'_10x10.png'])))/255;
    imSubData = SubpixelFilter(bw_image,3,[200, 270, 50, 270]);
    if debug == 1
        fprintf('\n\nimage %d',im);
        fprintf('\npoint1 x: %f y: %f',imSubData(2,2).point1(1),imSubData(2,2).point1(2));
        fprintf('\npoint2 x: %f y: %f',imSubData(2,2).point2(1),imSubData(2,2).point2(2));
        fprintf('\nslope: %f',imSubData(2,2).slope);
    end
    
    figure(im),imshow(bw_image), hold on;
    for i=1:size(bw_image,1)
        for j=1:size(bw_image,2)
            ff = imSubData(i,j).pow;
            t = 0.2;
            %if ff > t || ff < 1-t
                p1 = imSubData(i,j).point1;
                p2 = imSubData(i,j).point2;
                x = [p1(1) p2(1)];
                y = [p1(2) p2(2)];
                plot(x,y,'LineWidth',0.2,'Color','green');
            %end
        end
    end
    
end

%% test immagine intera
clc
color_image = imread('test3.jpg');
bw_image = single(rgb2gray(imread('test3.jpg')))/255;
tic
subpixParam = [200, 270, 180, 270]; % houghMaxRho houghMaxTheta houghMaxRhoSensed houghMaxThetaSensed [200, 270, 80, 270]
[imSubData, houghMatrix,pool]= SubpixelFilter(bw_image,3,subpixParam);
tempo = toc;
avgTempo = tempo/size(bw_image,1)/size(bw_image,2);
fprintf('\ntempo: %f avgTempo: %f',tempo,avgTempo);

figure(1),imshow(color_image), hold on;
for i=1:size(bw_image,1)
    for j=1:size(bw_image,2)
        ff = imSubData(i,j).pow;
        t = 0.07;
        if ff > t
            p1 = imSubData(i,j).point1;
            p2 = imSubData(i,j).point2;
            x = [p1(1) p2(1)];
            y = [p1(2) p2(2)];
            plot(x,y,'LineWidth',0.2,'Color','green');
        end
    end
end


[lineVertices, houghpts]= SubpixelLines(houghMatrix, 2, subpixParam, size(bw_image),pool);

% quello che qui viene messo manualmente come 45-90 dovrà essere un valore
% calcolato con attenzione tra [-90, 90]
%[lineVertices, houghpts]= SubpixelLinesWithSlope(houghMatrix, 10, subpixParam, size(bw_image),pool,15-90); % 2: 43-90
figure(10), imshow(houghMatrix,[]),hold on, plot(houghpts(:,2),houghpts(:,1),'+r','MarkerSize', 10);

for i=1:size(lineVertices,1)
    p1 = lineVertices(i).point1;
    p2 = lineVertices(i).point2;
    x = [p1(1) p2(1)];
    y = [p1(2) p2(2)];
    %figure(1), plot(x,y,'LineWidth',0.2,'Color','red');
end