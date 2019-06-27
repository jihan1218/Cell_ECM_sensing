close all 
clear all

breaker = 1;
frate = 20; % min/frame
ttime =  24; % total hour
nfold = 4; % the number of folder
tframe = round(ttime*60/frate); % total number of time frame
numsample = 3;
angle = 25;
totaltime = 50;
framerate = frate;
lt = 0;

sobel1 = [0,1,2;-1,0,1;-2,-1,0];  %sobel filter to detect diagonal line
sobel2 = [2,1,0;1,0,-1;0,-1,-2];

%{
foldname = sprintf(['/home/kimji/Project/Cell_mechanics/cell_ECM_sensitivity/'...
        '25C_collagen_iron/sample_%02d_%02ddeg/xyzt_%02dhr/xyzt_%02d_%02dmpf'],...
        numsample,angle,totaltime,1,framerate);
  %}

foldname = sprintf(['/Users/jihan/OneDrive/working'...
        '/sample_%02d_%02ddeg/xyzt_%02dhr/xyzt_%02d_%02dmpf'],...
         numsample,angle,totaltime,1,framerate);
    
imgtime = sprintf('*t%02d*ch01.tif',1);
imgnamet = fullfile(foldname,imgtime);
s = dir(imgnamet);
[lz, a] = size(s); % lz: the total number of z-stack



for i =1 : nfold
    %{
    foldname = sprintf(['/home/kimji/Project/Cell_mechanics/cell_ECM_sensitivity/'...
        '25C_collagen_iron/sample_%02d_%02ddeg/xyzt_%02dhr/xyzt_%02d_%02dmpf'],...
        numsample,angle,totaltime,i,framerate);
    %}
    
    foldname = sprintf(['/Users/jihan/OneDrive/working'...
        '/sample_%02d_%02ddeg/xyzt_%02dhr/xyzt_%02d_%02dmpf'],...
        numsample,angle,totaltime,i,framerate);

    imgz =  sprintf('*z%02d*ch01.tif', 2);
    imgnamez = fullfile(foldname, imgz);
    s = dir(imgnamez);
    [dt,a] = size(s);
    flt(i,1) = dt;
    lt = lt + dt; % lt: the total number of xyt-stack
        
end 
zlist = 1:round(lz/4):lz;
tlist = 1:round(tframe/5):tframe;
% create xyt in four differernt z position
count = 0;

for j = 1: length(zlist)
    z = zlist(j);
    count = count + 1;
    for i = 1 : nfold
    %{
        foldname = sprintf(['/home/kimji/Project/Cell_mechanics/cell_ECM_sensitivity/'...
            '25C_collagen_iron/sample_%02d_%02ddeg/xyzt_%02dhr/xyzt_%02d_%02dmpf'],...
            numsample,angle,totaltime,i,framerate);
      %}
        foldname = sprintf(['/Users/jihan/OneDrive/working'...
        '/sample_%02d_%02ddeg/xyzt_%02dhr/xyzt_%02d_%02dmpf'],...
        numsample,angle,totaltime,i,framerate);

        
        imgz =  sprintf('*z%02d*ch01.tif', z);
        imgnamez = fullfile(foldname, imgz);

        if i == 1
            xyt = loadimgs(imgnamez);
        else
            img_zstack = loadimgs(imgnamez);
            xyt = cat (3,xyt, img_zstack);
        end
    end
    xyt = xyt(:,:,1:tframe);
    xytz{count,1} = xyt;
end

tindex = 1;
zindex = 1;
n = 0;
nc = 0;
box = [0, 0, 0, 0 ];


while(breaker)
    img2d = xytz{zindex,1};
    img2d = img2d(:,:,tlist(tindex));
    figure(100),imshow(img2d);
    imtitle = sprintf('z = %02d, t = %02d',zlist(zindex),tlist(tindex));
    title(imtitle);
   
    if n == 1
        line([1,1024], [yp(n,1),yp(n,1)],'Color','red');
        line([xp(n,1),xp(n,1)], [1,1024],'Color','red');
    
    elseif n == 2
        
        dx = xp(2) - xp(1);
        dy = yp(2) - yp(1);
        
        if dx > 0 && dy >0 
            xi = xp(1);
            yi = yp(1);
            rectangle('Position',[xi,yi,abs(dx),abs(dy)],'Edgecolor','r');
            
        elseif dx > 0 && dy < 0
            xi = xp(1);
            yi = yp(2);
            rectangle('Position',[xi,yi,abs(dx),abs(dy)],'Edgecolor','r');            
                  
        elseif dx <0 && dy > 0
            xi = xp(2);
            yi = yp(1);
            rectangle('Position',[xi,yi,abs(dx),abs(dy)],'Edgecolor','r');         
                   
        elseif dx < 0 && dy < 0
            xi = xp(2);
            yi = yp(2);
            rectangle('Position',[xi,yi,abs(dx),abs(dy)],'Edgecolor','r');
                
        end   
        edge = round([xi,yi,dx,dy])
        
    end
    
    for i = 1:nc
        rectangle('Position',abs(box(i,:)),'Edgecolor','r');
        hold on 
    end
   
    b = getkey;
    if b == 29 % arrow -> : next frame
        tindex = tindex + 1;
        
        if tindex > length(tlist)
            tindex = 1;
        end
        
    elseif b == 28 % arrow <- : previous frame
        tindex = tindex - 1;
        if tindex < 1
            tindex = length(tlist) ;
        end
            
    elseif b == 30 % arrow up
        zindex = zindex +1;
        if zindex > length(zlist)
            zindex = 1;
        end
        
    elseif b == 31 % arrow down
        zindex = zindex - 1;
        if zindex < 1
            zindex = length(zlist);
        end
           
    elseif b == 49 % '1' to register a point
        n = n + 1;
        [imx, imy, b_p] = ginputc(1,'color','r','LineWidth',2);
        xp(n,1) = imx;
        yp(n,1) = imy;
            
    elseif b == 50 % '2' to move next cells
        n = 0;
        nc = nc + 1;
        box(nc,:) = edge
        
    elseif b == 99 % 'c' to finish
        breaker = 0;
         
    end
    hold off 
    
    if breaker == 0 
        close all
    end
end

%lbox = length(box(:,1));
lbox = 3;
nfold = 1;


for l = 1: lbox
    count2 = 0;
    for i = 1 : nfold
   %{
    foldname = sprintf(['/home/kimji/Project/Cell_mechanics/cell_ECM_sensitivity/'...
                '25C_collagen_iron/sample_%02d_%02ddeg/xyzt_%02dhr/xyzt_%02d_%02dmpf'],...
                numsample,angle,totaltime,i,framerate);
    %}    
    foldname = sprintf(['/Users/jihan/OneDrive/working'...
        '/sample_%02d_%02ddeg/xyzt_%02dhr/xyzt_%02d_%02dmpf'],...
        numsample,angle,totaltime,i,framerate);
        for j = 0 : flt(nfold)-1
            count2 = count2 + 1;
            
            if count2 <= tframe
                
                if count2 == 1
                    %{
                    nfoldname = sprintf(['/home/kimji/Project/Cell_mechanics/cell_ECM_sensitivity/'...
                    '25C_collagen_iron/sample_%02d_%02ddeg/xyt_cell/cell_%03d'],...
                    numsample,angle,count1);
                    %}
                    
                    nfoldname = sprintf(['/Users/jihan/OneDrive/working'...
                        '/sample_%02d_%02ddeg/xyt_cell/cell_%03d'],...
                        numsample,angle,l);

                    mkdir(nfoldname);
                end
                
                imname = sprintf('*t%02d*ch01.tif',j);
                xyzname = fullfile(foldname,imname);
                xyz = loadimgs(xyzname);

                cn = box(l,:);
                xyz_crop = xyz(cn(2):cn(2)+abs(cn(4)),cn(1):cn(1)+abs(cn(3)),:);
                ly = length(xyz_crop(:,1,1));
                step = 5; % half size of cells
                index1 = 0;
                for k = 1:step:ly
                    index1 = index1 + 1;
                    imgcs = squeeze(xyz_crop(k,:,:));
                    [ztemp,im] = diagdetect(imgcs,sobel1,sobel2);
                    zpos(index1,1) = ztemp;
                end

                if nnz(zpos)>1
                    zp = round(mean(nonzeros(zpos)));
                    zdepth(count2,1) = zp;
                    zp = round(mean(zdepth(:,1)));
                    xy = xyz_crop(:,:,zp+1);
                    namecrop = sprintf('cell%03d_t%03d.tif',l,count2);
                    nimg = fullfile(nfoldname,namecrop);
                    imwrite(xy,nimg);

                else
                    fprintf('z cannot be detected at cell%03d\n t = %03d\n',l,count2-1);
                end
            else
                break
            end
            
        end
        clearvars zdepth
        
    end
    
end



%{
h = histogram(imgcs);
ctot = sum(h.Values);
p = 0.2;
nbin = length(h.BinEdges(1,:));
cb = 0;
ct = ctot;

for i = 1: nbin-1
    cb = cb + h.Values(1,i);
    if cb > ctot*p
        bthresh = h.BinEdges(1,i);
        
        break
    end
end
for i = 1: nbin -1
    ct = ct - h.Values(1,nbin-i);
    if ct < ctot*(1-p)
        tthresh = h.BinEdges(1,nbin-i);
        break
    end
end
ly = length(imgcs(:,1));

bright = imgcs;
dark = imgcs;
bright(bright < tthresh) = 0;
dark(dark > bthresh) = 0;
b_el =  bright(bright>0);
d_el =  dark(dark>0);
[brow, bcol] = find(bright == max(b_el));
[drow, dcol] = find(dark == min(d_el));
 
bright(brow:ly,:) = 0;
dark(drow:ly,:) = 0;
bright(:,1:bcol) = 0;
dark(:,dcol:lz) = 0;



figure, imagesc(bright)
figure, imagesc(dark)

[dz, dy] = meshgrid(1:lz,1:ly);
bright2bw = imbinarize(bright);
dark2bw = imbinarize(dark);
bright2bwdy = dy.*bright2bw;
bright2bwdz = dz.*bright2bw;
dark2bwdy = dy.*dark2bw;
dark2bwdz = dz.*dark2bw;

bry = nonzeros(bright2bwdy);
brz = nonzeros(bright2bwdz);
day = nonzeros(dark2bwdy);
daz = nonzeros(dark2bwdz);

pb = polyfit(brz, bry, 1);
pd = polyfit(daz, day, 1);

fb = polyval(pb, brz);
fd = polyval(pd, daz);
figure, scatter(brz, bry)
hold on 
plot(brz,fb)
scatter(daz,day)
plot(daz,fd)
%}


