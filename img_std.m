%% save xyzt image into xyz-std/sum 

foldname = ['/home/kimji/Project/Cell_mechanics/cell_ECM_sensitivity/'...
    '25C_collagen_iron/sample_01_40deg/xyzt_60hr/xyzt_02_15mpf'];
newfold = ['/home/kimji/Project/Cell_mechanics/cell_ECM_sensitivity/'...
    '25C_collagen_iron/sample_01_40deg/xyzt_60hr/xyt_02_std'];
mkdir(newfold);

fname = fullfile(foldname,'*z05*ch00*.tif');
a = dir(fname);
t = size(a);

for i = 0 : (t(1)-1)
    tname = sprintf('*t%02d*ch01.tif',i);
    iname = fullfile(foldname,tname);
    imgz = double( loadimgs(iname));
    %{
    for x = 1:1024
        for y = 1:1024
            imgstd (x,y)= std2(imgz(x,y,:));
        end
    end
    %}
    test = std(imgz,1,3);
    test = mat2gray(test);
    iname2 = sprintf('xyt2_std_t%02d.tiff',i); 
    newimg = fullfile(newfold,iname2);
    imwrite(test,newimg);
    
    
end