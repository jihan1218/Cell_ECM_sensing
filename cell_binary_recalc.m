clear all 
close all
% define working station
station = 1;
n = 1;

if station == 1
    foldname = ['/home/kimji/Project/Cell_mechanics/cell_ECM_sensitivity/'...
        'ECM_cell_interaction_strong_alignment/sample_01/'];
    s = dir(foldname);
    n = n +2;
    imfold = s(n).name;
elseif station == 2 
    foldname = '/Users/jihan/OneDrive/working/spiral collagen/';
    s =  dir(foldname);
    n = n + 3;
    imfold = s(n).name;
else 
    foldname = ['/run/user/1000/gvfs/smb-share:server=sun-nas1.science.oregonstate.edu,'...
        'share=cellmechanics/onsite of contact guidance/'...
        'ECM_cell_interaction_strong_alignment/sample_03'];
    s = dir(foldname);
    n = n +2;
    imfold = s(n).name;
    
end

bw_stack = loadimgs([foldname,filesep,imfold,filesep,'BW_xyz',filesep,'*.tif'],0,1);
im_max = max(bw_stack,[],3);

outputfold = [foldname,filesep,imfold,filesep,'result'];

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

