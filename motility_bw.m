foldname = '/home/kimji/Project/Cell_mechanics/On_site_contact_guidance/Motility/4x/s01/';
imfold = [foldname,filesep,'xyzt_01'];
fresult = [foldname,filesep,'result'];
mkdir(fresult);

d = dir(imfold);
n = struct2cell(d);
ind = find(contains(n(1,:),'z00_ch00'));
tmax = length(ind);
lvl = [];
stackbw = [];
cellcut =  5;

for t = 0: 0 %tmax-1
    stack = loadimgs(sprintf([imfold,filesep,'*t%02d*ch00.tif'],t),0,1);
    lz = length(stack(1,1,:));
    
    temp = stack(:,:,round(lz/3));
    [histo, a] = imhist(imtemp);
    histo = histo(1:length(histo)-1,1);
    level = triangle_th(histo,length(histo));
        
    for z = 1:lz
        imtemp = stack(:,:,z);
        im_bw = imbinarize(imtemp,level);
        bw = medfilt2(im_bw);
        I = im2uint8(bw);
        stackbw(:,:,z) = bw;
        
    end
    cc = bwconncomp(stackbw,26);
    numPixels = cellfun(@numel, cc.PixelIdxList);
    [noncell, idx] = find(numPixels < cellcut);
    stackbw(cc.PixelIdxList{idx}) = 0;
    stats = regionprops3(stackbw,'all');
    
end
