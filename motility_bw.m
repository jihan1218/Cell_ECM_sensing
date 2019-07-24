
clear all 

%foldname = '/home/kimji/Project/Cell_mechanics/On_site_contact_guidance/Motility/4x/s01/';
foldname ='/Users/jihan/Desktop/on site contact guidance/motility/4x/s01';
imfold = [foldname,filesep,'xyzt_01'];
fresult = [foldname,filesep,'result'];
mkdir(fresult);
fbw = [fresult,filesep,'bw'];
mkdir(fbw);
fmip = [fresult,filesep,'mip'];
mkdir(fmip);
fcomb = [fresult,filesep,'combine'];
mkdir(fcomb);
d = dir(imfold);
n = struct2cell(d);
ind = find(contains(n(1,:),'z00_ch00'));
tmax = length(ind);
cellcut =  27;
motility ={};
tcount = 0;


for t = 0: 10%tmax-1
    tcount = tcount + 1;
    
  
    stackbw = [];
    stack = loadimgs(sprintf([imfold,filesep,'*t%02d*ch00.tif'],t),0,1);
    lz = length(stack(1,1,:));
    temp = stack(:,:,round(lz/3));
   
        
    for z = 1:lz
        imtemp = stack(:,:,z);
        [histo, a] = imhist(imtemp);
        histo = histo(1:length(histo)-1,1);
        level = triangle_th(histo,length(histo));
        im_bw = imbinarize(imtemp,level);
        %bw = medfilt2(im_bw);
    
        stackbw(:,:,z) = im_bw;
    end
    cc = bwconncomp(stackbw,26);
    numPixels = cellfun(@numel, cc.PixelIdxList);
    [noncell, idx] = find(numPixels < cellcut);
    for i = 1: length(idx)
        id = idx(i);
        stackbw(cc.PixelIdxList{id}) = 0;
    end
    cc = bwconncomp(stackbw,26);
    cellinfo = [];
    for i = 1: length(cc.PixelIdxList)
        perc = i/length(cc.PixelIdxList)*100;
        fprintf('%02d / %02d: %.1f \n',t,tmax-1,perc);
        
        stacktemp = stackbw;
        stacktemp(cc.PixelIdxList{i}) = 10;
        stacktemp(stacktemp < 10) = 0;
        mip = max(stacktemp,[],3);
        mip = imbinarize(mip);
        stats = regionprops(mip,'Centroid','Orientation','MajorAxisLength','MinorAxisLength');
        cellinfo(i,1) = i;
        cellinfo(i,2:3) = round(stats.Centroid);
        cellinfo(i,4) = stats.MajorAxisLength/stats.MinorAxisLength;
        cellinfo(i,5) = stats. Orientation;
        if cellinfo(i,5) < 0 
            cellinfo(i,5) = cellinfo(i,5) + 180;
        end
        cellinfo(i,6) = stats.MajorAxisLength;
        cellinfo(i,7) = stats.MinorAxisLength;
    end
    
    motility{tcount,1} = cellinfo;
    MIP = max(stackbw,[],3);
    IM = im2uint8(MIP);
    imwrite(IM,[fmip,filesep,sprintf('s01_t%02d.tif',t)]);
    figure(100), imshow(IM);
    hold on 
    plot(cellinfo(:,2),cellinfo(:,3),'r.','MarkerSize', 8);
    set(gcf,'Position',[100 100 900 900]);
    imname = [fcomb,filesep,sprintf('comb_t%02d.jpg',t)];
    export_fig(imname,'-tiff');
    hold off
    close(100)
    for z=1:lz
        I = im2uint8(stackbw(:,:,z));
        imwrite(I,[fbw,filesep,sprintf('s01_t%02d_z%02d.tif',t,z)]);
    end
    
    
end
save([fresult,filesep,'motility.mat'],'motility');

