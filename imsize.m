clear all
station = 1;

if station == 1 % motility plot result 

    %foldname ='/Users/jihan/Desktop/on site contact guidance/motility/4x/s01';
    foldname = '/Volumes/JIhan_SSD/Cellmechanics/on site contact guidance/Motility/4x/s03';


    fresult = [foldname,filesep,'result'];
    fcomb = [fresult,filesep,'combine'];
    nfcomb = [fcomb,filesep,'fixsize'];
    mkdir(nfcomb);

    %stack = loadimgs([fcomb,filesep,'*.tif']);
    side = 839;
    
    d = dir(fcomb);
    n = struct2cell(d);
    ind = find(contains(n(1,:),'comb'));
    

    for i = 1:length(ind)
  
        iname = [fcomb,filesep,d(ind(i)).name];
        im = imread(iname);
        [x,y,z] =size (im);
        dx = x - side;
        dy = y - side;
        xbegin = round(dx/2);
        xend = xbegin+side-1;
        ybegin = round(dy/2);
        yend = ybegin +side-1;
        nim = im(xbegin:xend,ybegin:yend,:);
        imwrite(nim,[nfcomb,filesep,sprintf('comb_t%02d.tif',i)]);
    end


elseif station == 2  % stitched image
    motilfold = ['/Volumes/JIhan_SSD/Cellmechanics/on site contact guidance/'...
        'ECM_nocells/10x/3x3/result/stitch'];

    fixfold = [motilfold,filesep,'modified'];
    mkdir(fixfold);
    side = 2800;

    for i = 1: 17
        im_motil = loadimgs([motilfold,filesep,sprintf('*%03d.tif',i)]);

        [ly, lx] =  size(im_motil);
        dy =  ly - side;
        dx =  lx - side;
        xbegin = round(dx/2);
        xend = xbegin+side-1;
        ybegin = round(dy/2);
        yend = ybegin+side -1;

        im_fix = im_motil(xbegin:xend,ybegin:yend);
        imwrite(im_fix,[fixfold,filesep,sprintf('wide_%02d.tif',i)]);
    end
end

