foldname = ['/home/kimji/Project/Cell_mechanics/cell_ECM_sensitivity/'...
    '25C_collagen_iron/working/widefield/img_stitch/'];
txtname = fullfile(foldname,'config.txt');
imgname = fullfile(foldname,'*.tif');

config = readtable(txtname);
config = table2array(config);
config = round(config);

tile = double(loadimgs(imgname));

xend = max(config(:,1));
yend = max(config(:,2));
w =  1024;
imgtot = zeros(w+xend,w+yend);

for i = 1 : 9
    
    switch i 
        case 1
            x = config(i,1);
            y = config(i,2);
            imgtot(1+x:w,1:w) = tile(:,:,i);
        
        case 2
            x = config(i,1);
            y = config(i,2);
            imgtot(1+x:x+w,1:y+w) = tile(:,-y:w,i);
            
            overlap = 
            
        
        
    end
    
end
