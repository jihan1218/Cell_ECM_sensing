clear all 
close all
foldname  = '/Users/jihan/OneDrive/working/collagen_gradient_map/before02_10x';
%foldname = '/home/kimji/Project/Cell_mechanics/cell_ECM_sensitivity/25C_collagen_iron/collagen_gradient_map/before02_10x';
imgname = fullfile(foldname,'*ch00.tif');
mask = imread([foldname,filesep,'mask/mask.tif']);
mask(mask>0) = 1;


boxwidth = 64;
img = loadimgs(imgname);
[row, col] = size(img(:,:,1));
z = length(img(1,1,:));
nfoldname1 = fullfile(foldname,'result/bw_raw1');
nfoldname2 = fullfile(foldname,'result/bw_clean1');
mkdir(nfoldname1);
mkdir(nfoldname2);
x = 1:boxwidth:row;
y = x;
fden = zeros(length(x)-1,length(x)-1,z);
particle = double(mask);
particle = (particle - 1)*-1;
particle = imresize(particle, [31,31]);


for k = 1:z
    imtemp = img(:,:,k);
    [histo, a] = imhist(imtemp);
    histo = histo(1:length(histo)-1,1);
    
    level = triangle_th(histo,length(histo));
    im_bw = im2bw(imtemp,level);
    im_bw = bwareaopen(im_bw,3);
    im_bwclean = filter2(fspecial('average',3),im_bw);
      
    im_bwclean = im2uint8(im_bwclean);
    im_bw = im2uint8(im_bw);
    im_bw = im_bw.*mask;
    im_bwclean = im_bwclean.*mask;
    
    imwrite(im_bw,[nfoldname1,filesep,sprintf('bw_z%02d.tif',k-1)]);
    imwrite(im_bwclean,[nfoldname2,filesep,sprintf('bwclean_z%02d.tif',k-1)]);
    mkdir([foldname,filesep,sprintf('result/z%02d',k-1)]);
    for i = 1:length(x)
        for j = 1:length(x)
            subim = im_bwclean(x(i):x(i)+boxwidth-1,y(j):y(j)+boxwidth-1);
            imwrite(subim,[foldname,filesep,sprintf('result/z%02d/x%02d_y%02d.tif',k-1,j,i)]);
            fden(i,j,k) = nnz(subim)/numel(subim);
                        
        end
    end
    
            
        
    
end

save([foldname,filesep,'result/result.mat'],'x','y','fden','particle','mask');


%{
for i = 1: length(x)-1 
    for j = 1:length(x)-1
        
        
    end
end

%}  