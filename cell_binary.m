
clear all 
close all
% define working station
station = 1;
n = 2;

if station == 1
    foldname = ['/home/kimji/Project/Cell_mechanics/cell_ECM_sensitivity/'...
        '25c_collagen_gradient/sample_04_48hr/'];
    s = dir(foldname);
    n = n +5;
    imfold = s(n).name;
else 
    foldname = '/Users/jihan/OneDrive/working/spiral collagen/';
    s =  dir(foldname);
    n = n + 3;
    imfold = s(n).name;
end

img = loadimgs([foldname,filesep,imfold,filesep,'*ch00.tif'],0,1);
mkdir([foldname,filesep,imfold,filesep,'BW_xyz']);
bw_stack = zeros(1024,1024,length(img(1,1,:)));

for i = 1:length(img(1,1,:))
    imtemp = img(:,:,i);
    im_adjust = imadjust(imtemp);
    imfilt = medfilt2(im_adjust);
    bw = imbinarize(imfilt);
    I = im2uint8(bw);
    imwrite(I,[foldname,filesep,imfold,filesep,'BW_xyz',filesep,sprintf('xyz_%02d.tif',i)]);
    bw_stack (:,:,i) = I;
    
end

im_max = max(bw_stack,[],3);
im_max = im2uint8(im_max);
outputfold = [foldname,filesep,imfold,filesep,'result'];

%% register cells that are interested in
celldata = struct([]);

%im_max = max(bw_stack,[],3);
%im_max = im2uint8(im_max);

figure(100), imshow(im_max);

breaker = 1;
coordinate = [];

count = 0;
[xmap,ymap] = meshgrid(1:1024,1:1024);
r = 4;

% to add a point: press 1, to finish adding a point: press 2

while(breaker)
    
    check = getkey;
    
    if check == 49
        count = count + 1;
        [x,y] = ginputc(1,'color','r','LineWidth',1);
        fprintf('The number of points: %02d \n',count);
        coordinate(count,:) = round([x,y]);
        hold on
        plot(x,y,'ro','MarkerSize',5,'MarkerEdgeColor','red',...
            'MarkerFaceColor','red');
        str = sprintf('%d',count);
        text(round(x),round(y),str,'Color','red','FontSize',15);

        
    elseif check == 50
        breaker = 0;
        %saveas(gcf,[allcells,filesep,'xyz' num2str(1) '.jpeg']); 
        close(100)
    end
    
end

%% Find a center z position and isolate single cell from other cells

count1 = 0;
zmin = 3;
zprof = [];
cellfold = [foldname,filesep,imfold,filesep,'single_cell'];
mkdir(cellfold);

% isolate single cell images
for i = 1:length(coordinate(:,1))
    
    center = coordinate(i,:);
    bwtemp = bw_stack(center(2),center(1),:);
    bwz = squeeze(bwtemp);
    ztemp = find(bwz > 0);
    l = length(ztemp);
    
    if ztemp(1)+floor(l/2) > zmin && ztemp(l)-floor(l/2) < length(bwz) -zmin 
        count1 = count1 +1;
        celldata(count1).zcenter = ztemp(1)+floor(l/2);
        celldata(count1).xy = [center(1), center(2)];
        if ztemp(1) - 2 <= 0
               
            nstack = bw_stack(:,:,ztemp(1):ztemp(l)+2);
        elseif ztemp(l) + 2 >= length(bwz)+1
            nstack =  bw_stack(:,:,ztemp(1)-2:ztemp(l));
            
        else
            nstack = bw_stack(:,:,ztemp(1)-2:ztemp(l)+2);
        end
        
        nmip = max(nstack,[],3);
        cc = bwconncomp(nmip);
        index_center = 1024*(center(1)-1)+center(2);
        
        for j = 1 : length(cc.PixelIdxList)
            cell = cc.PixelIdxList{1,j};
            acell = find(cell == index_center);
            if isempty(acell) == 0
               index_cell = j;
            elseif isempty(acell) == 1
                nmip(cc.PixelIdxList{j}) = 0;
                            
            end
            
        end
        nmip = imbinarize(nmip);
        nI = im2uint8(nmip);
        imwrite(nI,[cellfold,filesep,sprintf('cell_%02d.tif',count1)]);
    end
end

outputfold = [foldname,filesep,imfold,filesep,'result'];
mkdir(outputfold);
save([outputfold,filesep,'celldata.mat'],'celldata');

%% getting information of cells
load([outputfold,filesep,'celldata.mat'],'celldata');
cellfold = [foldname,filesep,imfold,filesep,'single_cell'];
d = dir(cellfold);
n1= 2;
for i = 1:length(d)- n1
   
    cellname = [cellfold,filesep,d(i+n1).name];
    nmip = imread(cellname);
    nmip = imbinarize(nmip);
    stat = regionprops(nmip,'all');
    ellipse.majoraxis = stat.MajorAxisLength;
    ellipse.minoraxis = stat.MinorAxisLength;
    ellipse.aspectratio = ellipse.majoraxis/ellipse.minoraxis;

    if stat.Orientation < 0
        ellipse.angle = 180 + stat.Orientation;
    else 
        ellipse.angle = stat.Orientation;
    end
    
    celldata(i).aspectratio = ellipse.aspectratio;
    celldata(i).angle = ellipse.angle;
    celldata(i).area = stat.Area;
    celldata(i).centermass = round(stat.Centroid); 
    celldata(i).ellipse = ellipse;
                
        
end  
 
  
outputfold = [foldname,filesep,imfold,filesep,'result'];
mkdir(outputfold);
save([outputfold,filesep,'celldata.mat'],'celldata');

%% plot the result and save

figure(200),imshow(im_max);
t = linspace(0,2*pi,50);
for index = 1: numel(celldata)
    if isempty(celldata(index).xy) == 0
    hold on
        
    angle = celldata(index).angle;
    angle = angle*pi/180;
    plot(celldata(index).centermass(1),celldata(index).centermass(2),'ro','MarkerSize',6,...
        'MarkerEdgeColor','red','MarkerFaceColor','red');
    a = celldata(index).ellipse.majoraxis / 2;
    b = celldata(index).ellipse.minoraxis / 2;
    xc = celldata(index).centermass(1);
    yc = celldata(index).centermass(2);
    xe = xc - a*cos(t)*cos(angle) + b*sin(t)*sin(angle);
    ye = yc + a*cos(t)*sin(angle) + b*sin(t)*cos(angle);
    plot(xe,ye,'b','LineWidth',3)
    xi = xc - a*cos(angle);
    xf = xc + a*cos(angle);
    yi = yc - a*sin(angle);
    yf = yc + a*sin(angle);
    plot([xf xi],[yi yf],'g','LineWidth',2)
    end
end

saveas(gcf,[outputfold,filesep,'xyz_result_ellipse.jpeg']); 
close(200);    

iminvert = uint8(255) - im_max;
figure(300), imshow(iminvert);
hold on
for index2 = 1:numel(celldata)

    str = sprintf('%d',index2);
    text(celldata(index2).xy(1),celldata(index2).xy(2),str,'Color','red','FontSize',20);

end
saveas(gcf,[outputfold,filesep,'cellcount.jpeg']);
close(300)


