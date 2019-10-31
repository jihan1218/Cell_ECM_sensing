% max z projection
clear all

ch = 0;
%sample = 1;
time = 4;


%foldname = ['/Volumes/JIhan_SSD/Cellmechanics/on site contact guidance/Motility/'...
%    '10x',filesep,sprintf('s%02d',sample)];
%foldname = ['/media/kimji/JIhan_SSD/Cellmechanics/on site contact guidance/Motility/'...
%    '20x',filesep,sprintf('s%02d',sample)];
foldname = ['/home/kimji/Project/Cell_mechanics/Collagen_geometry/'...
    'cell shape dynamics/circle 21C'];

newfold = [foldname,filesep,'xyt_max'];
mkdir(newfold);
count = 0;

for t = 1: time
    imfold = [foldname,filesep,sprintf('xyzt_%02d_15mpf',t)];
    d = dir(imfold);
    reg = struct2cell(d);
    ind = find(contains(reg(1,:),'z00_ch00.tif'));
    lt = length(ind);
    for ti = 0 :lt-1
        if lt >= 100
            img = loadimgs([imfold,filesep,sprintf('*_t%03d_*_ch%02d.tif',ti,ch)]);
        elseif lt >= 10 && lt <100
            img = loadimgs([imfold,filesep,sprintf('*_t%02d_*_ch%02d.tif',ti,ch)]);
        elseif lt < 10 
            img = loadimgs([imfold,filesep,sprintf('*_t%d_*ch%02d.tif',ti,ch)]);
        end
        
            mip = max(img,[],3);
      
            count = count + 1;
            imwrite(mip,[newfold,filesep,sprintf('max_t%02d.tif',count)]);
        
        
    end
    
end


    
