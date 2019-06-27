clear all
filename = ['/home/kimji/Project/Cell_mechanics/cell_ECM_sensitivity'...
    '/25C_collagen_iron/sample_14_20deg/cell_crop/xy_corner.mat'];
load(filename);
box(:,4:5) = abs(box(:,4:5));
newz = 21;
ncell = 11;

foldname = ['/home/kimji/Project/Cell_mechanics/cell_ECM_sensitivity'...
    '/25C_collagen_iron/sample_14_20deg/xyzt_50hr'];
d = dir(foldname);
foldname1 = ['/home/kimji/Project/Cell_mechanics/cell_ECM_sensitivity'...
    '/25C_collagen_iron/sample_14_20deg/cell_crop/cell_001'];
foldname2 = ['/home/kimji/Project/Cell_mechanics/cell_ECM_sensitivity'...
    '/25C_collagen_iron/sample_14_20deg/cell_crop/'];
imgs = loadimgs([foldname1,filesep,'*.tif']);
l =  length(imgs(1,1,:));
count = 0;

cn = box(ncell,2:5);
zinfo(:,ncell) = newz;
nfold = ['/home/kimji/Project/Cell_mechanics/cell_ECM_sensitivity'...
    '/25C_collagen_iron/sample_14_20deg/cell_crop',filesep,sprintf('cell_%03d',ncell)];
mkdir(nfold)
index = find(poly_cord(:,1)== ncell);
poly_cell = poly_cord(index,:);
polynum = unique(poly_cell(:,2));
lp = length(polynum);


for i = 3: length(d)
    
    imgname = [foldname,filesep,d(i).name,filesep,sprintf('*z%02d_ch01.tif',newz)];
    xyt = loadimgs(imgname);
    xy_crop = xyt(cn(2):cn(2)+cn(4),cn(1):cn(1)+cn(3),:);
    xy_crop = double(xy_crop);

    for j = 1:length(xyt(1,1,:))
        count = count + 1;
        
        if count <= l
            
            for ii = 1:lp
                index2 = find(poly_cell(:,2) == polynum(ii));
                poly_single = poly_cell(index2,3:8);
                vx = poly_single(1,:);
                vy = poly_single(2,:);
                bw = poly2mask(vx,vy,cn(4)+1,cn(3)+1);
                bw = double(bw);
                wb = imcomplement(bw);
                xy_sec = xy_crop(:,:,j).*bw;
                xy_sec(xy_sec>0) = 180;
                xy_hole =  xy_crop(:,:,j).*wb;
                xy_crop(:,:,j) = xy_hole +xy_sec;
            end
            
                xy = xy_crop(:,:,j);
                xy = uint8(xy);
                
            imwrite(xy,[nfold,filesep,sprintf('cell%03d_t%03d.tif',ncell,count)]);
        else
            break;
        end
        
    end
        
    
end

filename2 = [foldname2,filesep,'xy_corner.mat'];
save(filename2,'box','zinfo','poly_cord');