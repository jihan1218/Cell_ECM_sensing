foldname = '/Volumes/JIhan_SSD/Cellmechanics/on site contact guidance/ECM_chem';
exp = 'bleb_3uM';
sample = 1;
region = 1;

imfold = [foldname,filesep,exp,filesep,sprintf('s%02d/r%02d',sample,region)];
imseq = strcat('"open=[',imfold,'] file=ch02 sort"');
load([imfold,filesep,'result/celldata.mat']);
MIJ.run("Image Sequence...", imseq);
l = length(celldata);
%%

breaker = 1;
i = 1;
while(breaker)
    
    if i == l+1
        break
    end
    fprintf('%02d / %02d \n',i,l);
    xy= celldata(i).centermass;
    specify = sprintf("width=200 height=200 x=%d y=%d slice=1 centered",xy(1),xy(2));
    MIJ.run("Specify...", specify);
    c = getkey;
    
    if c == 49 
        i = i+1;
       
    end
    
end
disp('finished');