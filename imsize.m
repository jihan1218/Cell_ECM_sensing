foldname ='/Users/jihan/Desktop/on site contact guidance/motility/4x/s01';
fresult = [foldname,filesep,'result'];
fcomb = [fresult,filesep,'combine'];
nfcomb = [fcomb,filesep,'fixsize'];
mkdir(nfcomb);
%stack = loadimgs([fcomb,filesep,'*.tif']);

for i = 1: 28
    iname = [fcomb,filesep,sprintf('comb_t%02d.tif',i-1)];
    stack = imread(iname);
    im = stack;
    [x,y] =size (im);
    
    if x ~= 824 && y ~= 824
        nim = im(1:824,1:824,:);
    end
    
    imwrite(nim,[nfcomb,filesep,sprintf('comb_t%02d.tif',i-1)]);
end

