close all 
clear all

                    
breaker = 1;
frate = 20; % min/frame
ttime =  24; % total hour
nfold = 4; % the number of folder
tframe = round(ttime*60/frate); % total number of time frame
numsample = 3; %sample number
angle = 25; %sample angle
totaltime = 50; %total xyzt time
framerate = frate;
lt = 0;
p = 0.8; % weight factor
bg = 180; % background intensity

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

%{
filename = sprintf(['/home/kimji/Project/Cell_mechanics/cell_ECM_sensitivity/'...
                    '25C_collagen_iron/sample_%02d_%02ddeg/xyt_cell/xy_corner.mat'],...
                        numsample,angle);
%}

filename = sprintf(['/Users/jihan/OneDrive/working/sample_%02d_%02ddeg/'...
    'xyt_cell/xy_corner.mat'],...
    numsample,angle);                     
                    
                    
if isfile(filename)
    load(filename)
    nc = length(box(:,1));
    lboxi = nc;
    
else
    lboxi = 0;
end

count4 = 0;

while(breaker)
    img2d = xytz{zindex,1};
    img2d = img2d(:,:,tlist(tindex));
    figure(100),imshow(img2d);
    imtitle = sprintf('cell%03d, z = %02d, t = %02d, click (%01d)',nc, ...
        zlist(zindex),tlist(tindex),n);
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
        edge = round([xi,yi,dx,dy]);
        
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
            
    elseif b == 50 % '2' to save box data and move to next cells
        n = 0;
        nc = nc + 1;
        box(nc,1) = nc;
        box(nc,2:5) = edge;
        close all 
        tindex2 = 1;
        zindex2 = 1;
        breaker2 = 1;
        
        while(breaker2)
            
            img2d = xytz{zindex2,1};
            cell_crop = img2d(edge(2):edge(2)+abs(edge(4)),edge(1):edge(1)+...
            abs(edge(3)),tlist(tindex2));
            
            figure(200),imshow(cell_crop);
            truesize([500 500]);
            b2 = getkey;
            np = 0;
            
            if b2 == 29 % arror >
                tindex2 = tindex2 + 1;
                if tindex2 > length(tlist)
                    tindex2 = 1;
                end
                
            elseif b2 == 28 %  arrow <
                tindex2 = tindex2 - 1;
                if tindex2 < 1
                    tindex2 = length(tlist);
                end
            elseif b2 == 30 % arrow up
                zindex2 = zindex2 + 1;
                if zindex2 > length(zlist)
                    zindex2 = 1;
                end
            elseif b2 == 31 % arrow down
                zindex2 = zindex2 - 1;
                if zindex2 < 1
                    zindex2 = length(zlist);
                end
                        
                
            elseif b2 == 49 % '1' to draw polygons
                breaker3 = 1;
                count3 = 0
                while(breaker3)
                    b3 = getkey;
                    
                    if b3 == 49 % '1' add a point
                        count3 = count3 + 1;
                        [vx, vy] = ginputc(1,'color','r','LineWidth',1);
                        poly(count3,1) = vx;
                        poly(count3,2) = vy; 
                    elseif b3 == 50 % '2' finish
                        breaker3 = 0;
                        np = np + 1;
                        count4 = count4 + 1;
                    elseif b3 == 48 % '0' to cancel a point
                        count3 = count 3 -1;
                        poly = poly(1:count3,:);
                    end
                    
                    if count3 < 7
                        
                        fprintf('poly points %01d\n / 6',count3);
                        h = impoly(gca,poly);
                    else
                        fprintf('too many points');
                        breaker3 = 0;
                        poly = poly(1:count3-1,:);
                        np = np + 1 ;
                        count4 = count4  + 1 ;
                      
                    end
                                                               
                end
                
                for ii = 1 : 2
                        pindex1 = (count4-1)*2 + ii;
                        poly_cord(pindex1,1) = nc;
                        poly_cord(pindex1,2) = np';
                        poly_cord(pindex1,3) = poly(1:count3,ii)';
                end
                 
                    
            elseif b2 == 99 %'c' to complete
                breaker2 = 0;
            end
            
            
        end
        
    elseif b == 98 % 'b' back to previous cell to correct error
        nc = nc - 1;
        
        
    elseif b == 99 % 'c' to finish
        breaker = 0;
         
    end
    
    hold off 
    
    if breaker == 0 
        close all
    end
end

lbox = length(box(:,1));
%lbox = 3;
nfold = 3;


for l = lboxi+1: lbox
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
                    numsample,angle,l);
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
                
                polycheck = isempty(find(poly_cord(:,1) == l));
                if polycheck == 0
                    pin = find(poly_cord(:,1) == l);
                    poly_cell = poly_cord(pin,:);
                    lp = length(poly_cell)/2;
                    for ii = 1: lp
                        pin2 = find(poly_cell(:,2) == ii);
                        poly_single = poly_cell(pin2,3:8);
                        vx = poly_single(1,:);
                        vy = poly_single(2,:);
                        bw = poly2mask(vx,vy,abs(cn(4))+1,abs(cn(3))+1);
                        bw = double(bw)
                        wb = imcomplement(bw);
                        for jj = 1: lz
                            xy_sec(:,:,jj) = xyz_crop(:,:,jj).*bw;
                            xy_sec(xy_sec>0) = 180;
                            xy_hole(:,:,jj) = xyz_crop(:,:,jj).*wb;
                            xyz_crop = xy_hole +xy_sec;
                        end
                    end
                    
                    
                end
                
                    
                
                
                for k = 1:step:ly
                    index1 = index1 + 1;
                    imgcs = squeeze(xyz_crop(k,:,:));
                    [ztemp,im] = diagdetect(imgcs,sobel1,sobel2);
                    zpos(index1,1) = ztemp;
                end

                if nnz(zpos)>1
                    zp = round(mean(nonzeros(zpos)));
                    zdepth(count2,1) = zp;
                    zp = round((mean(zdepth(1:count2,1))*(1-p)+p*zp));
                    xy = xyz_crop(:,:,zp);
                    zinfo(count2,l)=zp;
                    namecrop = sprintf('cell%03d_t%03d.tif',l,count2);
                    nimg = fullfile(nfoldname,namecrop);
                    imwrite(xy,nimg);

                else
                    fprintf('z cannot be detected at cell%03d\n t = %03d\n',l,count2-1);
                    zp = zdepth(count2-1,1);
                    xy = xyz_crop(:,:,zp+1);
                    namecrop = sprintf('cell%03d_t%03d.tif',l,count2);
                    nimg = fullfile(nfoldname,namecrop);
                    imwrite(xy,nimg);
                end
            else
                break
            end
            
        end
        
        
    end
    clearvars zdepth
end

%{                  
filename = sprintf(['/home/kimji/Project/Cell_mechanics/cell_ECM_sensitivity/'...
                    '25C_collagen_iron/sample_%02d_%02ddeg/xyt_cell/xy_corner.mat'],...
                        numsample,angle);
%}               
filename = sprintf(['/Users/jihan/OneDrive/working/sample_%02d_%02ddeg/'...
    'xyt_cell/xy_corner.mat'],...
    numsample,angle); 
                    
save(filename,'box','zinfo','poly_cord');



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


