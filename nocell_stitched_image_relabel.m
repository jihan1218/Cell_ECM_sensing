foldname = '/Volumes/JIhan_SSD/Cellmechanics/on site contact guidance/ECM_nocells/10x/3x3';
stack = {};
for n = 1:9
    imname = [foldname,filesep,sprintf('%1d/*ch00.tif',n)];
    stack{n,1} = loadimgs(imname);
end

fresult = [foldname,filesep,'result'];
mkdir(fresult);

for z = 1:17
    for i = 1:9
        im = stack{i,1};
        imz = im(:,:,z);
        m = [1,2,3;4,5,6;7,8,9];
        [y, x] = find(m == i);
        imwrite(imz,[fresult,filesep,sprintf('Tile_Z%03d_Y%03d_X%03d.tif',z,y,x)]);
    end
    
end
