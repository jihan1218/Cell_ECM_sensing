foldname = '/home/kimji/Project/Cell_mechanics/cell_ECM_sensitivity/25C_collagen_iron/sample_01_40deg/xyzt_60hr/xyzt_01_15mpf';

lz = 14;
lt  = 65;
ch = 0;
count = 0;
for t = 15:lt
   
    for z = 0: lz
        
        imgname = sprintf('/raw_data/*t%02d_z%02d_ch%02d.tif',t,z,ch);
        imname = fullfile(foldname,imgname);
        img = loadimgs(imname);
        
        nname = sprintf('s01_t%02d_z%02d_ch%02d.tif',count, z, ch);
        nimg =  fullfile(foldname, nname);
        imwrite(img, nimg);
    end
    count = count + 1;
end

        
