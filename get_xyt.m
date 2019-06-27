clear all
close all

fname1 = ['/home/kimji/Project/Cell_mechanics/cell_ECM_sensitivity/'...
    '25C_collagen_iron/'];
fdir = dir(fname1);
fdir = fdir(~ismember({fdir.name},{'.','..'}));
ns = length(fdir); % number of sample

fname2 = fullfile(foldname,fdir([1]).name); 

fdir2 = dir(fname2);
fdir2 = fdir2(~ismember({fdir2.name},{'.','..'}));
fname3 = fullfile(fname2,fdir2([5]).name);


img_xyz =  loadimgs();

