% max z projection

foldnum = 2;
type = 'talin';
ch = 2;

imfold = sprintf(['/Volumes/JIhan_SSD/Cellmechanics/on site contact guidance/molecule/'...
    's01_actin_talin/xyzt_%02d'],foldnum);

newfold = ['/Volumes/JIhan_SSD/Cellmechanics/on site contact guidance/molecule/'...
    's01_actin_talin',filesep,sprintf('%s_max_%02d',type,foldnum)];


mkdir(newfold);
d = dir(imfold);
reg = struct2cell(d);
ind = find(contains(reg(1,:),'z0_ch00'));
lt = length(ind);


for t =0 : lt -1
    im = loadimgs([imfold,filesep,sprintf('*t%02d_*ch%02d.tif',t,ch)]);
    mip = max(im,[],3);
    imwrite(mip,[newfold,filesep,sprintf('actin_t%02d.tif',t)]);
end

    
