%% Create 
dirname = ['/home/kimji/Project/Cell_mechanics/cell_ECM_sensitivity/'...
    '25C_collagen_iron/sample_09_30deg/widefield'];

for i = 1 : 9
subname = sprintf('s%02d',i);
foldname = fullfile(dirname,subname);
name_cells = fullfile(foldname,'*ch00.tif');
name_collagen = fullfile(foldname,'*ch01.tif');
img_cells = loadimgs(name_cells);
img_collagen = loadimgs(name_collagen);

l = length(img_cells(1,1,:));
    for i = 1 : l
        
