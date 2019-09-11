%foldname = '/Volumes/JIhan_SSD/Cellmechanics/on site contact guidance/ECM_nocells/10x/3x3';
<<<<<<< HEAD
rpm = 0;
foldname = ['/home/kimji/Project/Cell_mechanics/On_site_contact_guidance/'...
    'ECM_nocells/10x/different speed/5x5',filesep,sprintf('%drpm',rpm)];
stack = {};

for n = 1:25
    imname = [foldname,filesep,sprintf('r%02d/*ch00.tif',n)];
    stack{n,1} = loadimgs(imname);
end
%%
fresult = [foldname,filesep,'result2D_z8'];
mkdir(fresult);
img = stack{1,1};

for z = 8:8%1:length(img(1,1,:))
    for i = 1:25
        im = stack{i,1};
        imz = im(:,:,z);
        m = [1:25];
        %[y, x] = find(m == i);
        %imwrite(imz,[fresult,filesep,sprintf('Tile_Z%03d_Y%03d_X%03d.tif',z,y,x)]);
        imwrite(imz,[fresult,filesep,sprintf('Tile_%02d.tif',i)]);
=======
speed = 30;
foldname =['/Users/jihan/Documents/Cellmechanics/on site contact guidance/'...
    'ECM_nocells/10x/different speed',filesep,sprintf('%drpm',speed)];
stack = {};
for n = 1:9
    imname = [foldname,filesep,sprintf('r%02d/imseq/*.tif',n)];
    stack{n,1} = loadimgs(imname);
end
%%
[lx,ly,lz] =size(stack{1,1});

fresult = [foldname,filesep,'stitching'];
mkdir(fresult);
zlabel = 0;

for z = round(lz/2):lz
    zlabel = zlabel + 1;
    for i = 1:9
        im = stack{i,1};
        imz = im(:,:,z);
        m = [1,2,3;4,5,6;7,8,9];
        [y, x] = find(m == i);
        imwrite(imz,[fresult,filesep,sprintf('Tile_Z%03d_Y%03d_X%03d.tif',zlabel,y,x)]);
>>>>>>> 1f61536d68bc6cdf73a4018a0acfd36484a01602
    end
    
end


