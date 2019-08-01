clear all 
close all
% define working station
station = 3;
sample = 1;
region = 5;

if station == 1
    foldname = sprintf(['/home/kimji/Project/Cell_mechanics/cell_ECM_sensitivity/'...
             'ECM_cell_interaction_strong_alignment/sample_%02d'],sample);
    s = dir(foldname);
    

elseif station == 2 
    foldname = sprintf(['/Users/jihan/Desktop/on site contact guidance/'...
            'ECM_chem/bleb_3uM/s%02d'],sample);
    s =  dir(foldname);
    
elseif station == 3 
    foldname = sprintf(['/Volumes/JIhan_SSD/Cellmechanics/on site contact guidance/'...
        'ECM_chem/bleb_3uM/s%02d'],sample);
    s = dir(foldname);
  
end

reg = struct2cell(s);
ind = find(contains(reg(1,:),'r'));
reg = reg(1,ind);
imfold = char(reg(1,region));
  

outputfold = [foldname,filesep,imfold,filesep,'result'];

%load([outputfold,filesep,'celldata.mat'],'celldata');

cellfold = [foldname,filesep,imfold,filesep,'single_cell'];
d = dir(cellfold);
d1 = struct2cell(d);
ind1 = find(contains(d1(1,:),'._cell'));
delfile = [cellfold,filesep,d(ind1).name];
delete delfile


cellstack = loadimgs([cellfold,filesep,'*.tif']);
im_max = max(cellstack,[],3);
n1 = length(d) - length(cellstack(1,1,:));
ccount = 0;

for cellnum = 1: length(cellstack(1,1,:))
    ccount = ccount + 1;
    figure(100),imshow(cellstack(:,:,cellnum));
    cellcount = sprintf('%02d / %02d ',cellnum,length(cellstack(1,1,:)));
    title(cellcount);
    
    [x,y] = ginputc(1,'color','r','LineWidth',1);
    coordinate(ccount,:) = round([x,y]);
end
close(100)
celldata = struct([]);
count1 = 0;
bw_stack = loadimgs([foldname,filesep,imfold,filesep,'BW_xyz/*.tif']);

for i = 1:length(coordinate)
    
    center = coordinate(i,:);
    bwtemp = bw_stack(center(2),center(1),:);
    bwz = squeeze(bwtemp);
    ztemp = find(bwz > 0);
    l = length(ztemp);
    
    count1 = count1 +1;
    celldata(count1).zcenter = ztemp(1)+floor(l/2);
    celldata(count1).xy = [center(1), center(2)];        

end

%%
for i = 1:length(coordinate)
   
    cellname = [cellfold,filesep,d(i+n1).name];
    nmip = imread(cellname);
    nmip = imbinarize(nmip);
    stat = regionprops(nmip,'all');
    ellipse.majoraxis = stat.MajorAxisLength;
    ellipse.minoraxis = stat.MinorAxisLength;
    ellipse.aspectratio = ellipse.majoraxis/ellipse.minoraxis;
    
    if length(stat)>1
       ind = find([stat.Area] > 5);
       stat = stat(ind);
     
    end
    
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
 
  
save([outputfold,filesep,'celldata.mat'],'celldata');

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

