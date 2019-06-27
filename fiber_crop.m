clear all
close all
%{
foldname = ['/home/kimji/Project/Cell_mechanics/cell_ECM_sensitivity/'...
            '25C_collagen_iron/sample_01_40deg/xyzt_60hr/xyzt_01_15mpf'];
datafold = ['/home/kimji/Project/Cell_mechanics/cell_ECM_sensitivity/'...
            '25C_collagen_iron/sample_01_40deg/cell_crop'];
nfold = ['/home/kimji/Project/Cell_mechanics/cell_ECM_sensitivity/'...
            '25C_collagen_iron/sample_01_40deg/fiber_crop'];
mkdir(nfold);
%}
sname = 'sample_13_25deg';
fname = '/home/kimji/Project/Cell_mechanics/cell_ECM_sensitivity/25C_collagen_iron';
xytname = 'xyzt_43hr';
t = 0;
d = dir([fname,filesep,sname,filesep,xytname]);

foldname = [fname,filesep,sname,filesep,xytname,filesep,d(3).name];
datafold = [fname,filesep,sname,filesep,'cell_crop'];
nfoldr = [fname,filesep,sname,filesep,'fiber_crop_raw'];
nfold = [fname,filesep,sname,filesep,'fiber_crop'];


mkdir(nfoldr);
mkdir(nfold);

load([datafold,filesep,'xy_corner.mat']);
box (:,4:5) = abs(box(:,4:5));

for ncell = 1: length(box(:,1))
    x = box(ncell,2);
    y = box(ncell,3);
    dx = box(ncell,4);
    dy = box(ncell,5);
    z = floor(mean(zinfo(:,ncell)));
    imgname = sprintf('*t%02d_*_ch00.tif',t);
    fiber = loadimgs([foldname,filesep,imgname]);
    fwindow = fiber(y:y+dy,x:x+dx,z-1:z+1);
    fcrop = max(fwindow,[],3);
    
    [histo,a] = imhist(fcrop);
    histo = histo(1:length(histo)-1,1);
    level = triangle_th(histo,length(histo));
    im_bw = im2bw(fcrop,level);
    
    %cc = bwconncomp(im_bw);
    %numpixels = cellfun(@numel,cc.PixelIdxList);
    
    im_bw = bwareaopen(im_bw,3);
    se1 = strel('disk',4);
    se2 = strel('disk',2);
    im_big = imdilate(im_bw,se1);
    im_small = imerode(im_big,se2);
    im_sk = bwskel(im_small);
    %im_bwclean = filter2(fspecial('average',3),im_bw);
    im_bwclean = im2uint8(im_sk);
    
    imwrite(fcrop,[nfoldr,filesep,sprintf('cell_%03d.tif',ncell)]);
    imwrite(im_bwclean,[nfold,filesep,sprintf('cell_%03d_clean.tif',ncell)]);
    
    
end
