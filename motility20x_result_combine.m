clear all

%% integrate all motility.mat file into one. Organize cell index
all = struct([]);
cellind = 0;
allind = 0;
sample = 1;
for sample = 1 : 7
    foldname = ['/media/kimji/JIhan_SSD/Cellmechanics/on site contact guidance/'...
            'Motility/20x',filesep,sprintf('s%02d',sample),filesep,'result'];
    filename = [foldname,filesep,'motility.mat'];
    load(filename);
    ttot = length(motility);
    cellcount = length(motility{1,1});
    motilinit = motility{1,1}; % initial motility info


    for cell = 1 : cellcount
        r0 = motilinit(cell).cent; % initial position of each cell
        cellind = cellind + 1;
        for t = 1 : ttot

            if t == 1

                allind = allind + 1;
                all(allind).samp = sample;
                all(allind).cellindx = cellind;
                all(allind).time = t;
                all(allind).cent = motilinit(cell).cent;
                all(allind).aspectratio = motilinit(cell).aspectratio;
                all(allind).cell_orient = motilinit(cell).orient;
            else
                motilt1 = cell2mat(squeeze(struct2cell(motility{t,1}))');
                allind = allind + 1;
                r0 = all(allind -1).cent;
                r1 = motilt1(:,2:3);
                dr = sqrt((r1(:,1)-r0(1)).^2 + (r1(:,2)-r0(2)).^2);
                ind = find(dr == min(dr));

                all(allind).samp=  sample;
                all(allind).cellindx = cellind;
                all(allind).time = t;
                all(allind).cent = motilt1(ind,2:4);
                all(allind).aspectratio = motilt1(ind,5);
                all(allind).cell_orient = motilt1(ind,6);
            end

        end
    end
    
end
foldmotil = ['/media/kimji/JIhan_SSD/Cellmechanics/on site contact guidance/'...
        'Motility/20x'];
save([foldmotil,filesep,'motiltiy20x.mat'],'all');

%% check the result by plotting cell tracking path
for sample = 1:7
    imfold =  ['/media/kimji/JIhan_SSD/Cellmechanics/on site contact guidance/'...
                'Motility/20x',filesep,sprintf('s%02d',sample),filesep,'result/mip'];
    figure(100),imshow([imfold,filesep,sprintf('s%02d_t00.tif',sample)]);
    hold on
    all_array = cell2mat(squeeze(struct2cell(all))');
    sample_ind = find(all_array(:,1) == sample);
    cell_sample =  all_array(sample_ind,:);
    cell_numb = unique(cell_sample(:,2));

    for cell_ind = 1: length(cell_numb)
        singlecell = cell_sample(cell_sample(:,2) == cell_numb(cell_ind),4:5);
        plot(singlecell(:,1),singlecell(:,2),'Linewidth',2);
        hold on
    end
    export_fig([foldmotil,filesep,sprintf('s%02d_result',sample)],'-tif');
    hold off
    close all
end

%% crop collagen fiber image and integrate the result into motility.mat file
fiberfold = [foldmotil,filesep,'fiber_crop'];
mkdir(fiberfold);

for sample = 1 : 7
        foldname = ['/media/kimji/JIhan_SSD/Cellmechanics/on site contact guidance/'...
            'Motility/20x',filesep,sprintf('s%02d',sample)];
        for xyzt = 1 : 2
            imfold =  [foldname,filesep,sprintf('xyzt_%02d',xyzt)];
            
        end
        
        
end






    