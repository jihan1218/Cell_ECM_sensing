
clear all 
close all

z = 4;
ch = 2;

filename = ['/home/kimji/Project/Cell_mechanics/cell_ECM_sensitivity/'...
    '25C_collagen_iron/sample_01_40deg/xyzt_60hr/xyzt_01_15mpf'];
imgname = sprintf('*z%02d_ch01.tif',z);
fullname = fullfile(filename,imgname);
stack = loadimgs(fullname);
n_stack = length(stack(1,1,:));

img_sample(:,:,1) = stack(:,:,1);
img_sample(:,:,2) = stack(:,:,round(n_stack/2));
img_sample(:,:,3) = stack(:,:,n_stack);
%rgbImage = cat(3, img_initial, img_mid, img_final);

breaker = 1;
i = 1;

while(breaker)
       
    imshow(img_sample(:,:,i));
    n = getkey;
    if n == 29
        i = i+1;
        if i>3
            i = 1;
        end
       
    elseif n == 28
        i = i-1;
        if i<1
            i=3;
        end
      
    elseif n ==13
        close all
        break;
    end
end


[X Y] = meshgrid(1:1024, 1:1024);

[xpoints ypoints] = ginputc(2, 'color','r','LineWidth',2);



