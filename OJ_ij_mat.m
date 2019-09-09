%% run this section first 
% Miji; to start with imagej in Matlab
%

%foldname = '/Volumes/JIhan_SSD/Cellmechanics/on site contact guidance/ECM_chem';
foldname = '/Users/jihan/Documents/Cellmechanics/on site contact guidance/ECM_chem';
exp = 'bleb_5uM';
sample = 2;
region = 7;

imfold = [foldname,filesep,exp,filesep,sprintf('s%02d/r%02d',sample,region)];
imseq = strcat('"open=[',imfold,'] file=ch02 sort"');
load([imfold,filesep,'result/celldata.mat']);
MIJ.run("Image Sequence...", imseq);
l = length(celldata);
%% start OrientationJ measure manually 
% run the second section
% after clicking measure button, type '1' to move on to the next box
% make sure each time select the matlab window to run the code


breaker = 1;
i = 1;
while(breaker)
    
    if i == l+1
        break
    end
    fprintf('%02d / %02d \n',i,l);
    xy= celldata(i).centermass;
    specify = sprintf("width=200 height=200 x=%d y=%d slice=10 centered",xy(1),xy(2));
    MIJ.run("Specify...", specify);
    c = getkey;
    
    if c == 49 
        i = i+1;
       
    end
    
end
disp('finished');