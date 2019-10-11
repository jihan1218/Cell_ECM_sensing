clear all
mode = 4;
%foldmotil = ['/media/kimji/JIhan_SSD/Cellmechanics/on site contact guidance/'...
%                'Motility/20x'];
foldmotil = ['/Volumes/JIhan_SSD/Cellmechanics/on site contact guidance/Motility/'...
    '20x'];

switch mode
    
    
%% integrate all motility.mat file into one. Organize cell index
    case 1
        all = struct([]);
        cellind = 0;
        allind = 0;
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
        save([foldmotil,filesep,'motility20x.mat'],'all');

%% check the result by plotting cell tracking path
    case 2
        load([foldmotil,filesep,'motility20x.mat']);
        all_array = cell2mat(squeeze(struct2cell(all))');        
        
        for sample = 1:7
            imfold =  ['/media/kimji/JIhan_SSD/Cellmechanics/on site contact guidance/'...
                        'Motility/20x',filesep,sprintf('s%02d',sample),filesep,'result/mip'];
            figure(100),imshow([imfold,filesep,sprintf('s%02d_t00.tif',sample)]);
            hold on

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

%% crop collagen fiber images based on the center position of cells
    case 3
      
        load([foldmotil,filesep,'motility20x.mat'],'-mat');
        all_array = cell2mat(squeeze(struct2cell(all))');   
        fiberfold = [foldmotil,filesep,'fiber_crop'];
        mkdir(fiberfold);
        tlim = 28;
        windsize = 200;
        
        for sample = 1 : 7
                %foldname = ['/media/kimji/JIhan_SSD/Cellmechanics/on site contact guidance/'...
                %    'Motility/20x',filesep,sprintf('s%02d',sample)];
                foldname = ['/Volumes/JIhan_SSD/Cellmechanics/on site contact guidance/Motility/'...
                    '20x',filesep,sprintf('s%02d',sample)];

                tcount = 0;
                for xyzt = 1 : 2
                    imfold =  [foldname,filesep,sprintf('xyzt_%02d',xyzt)];
                    d = dir(imfold);
                    n = struct2cell(d);
                    ind = find(contains(n(1,:),'z00_ch00'));
                    tmax = length(ind);
                    
                    for t = 0:tmax-1
                        tcount = tcount + 1;
                        fiber_t = loadimgs([imfold,filesep,sprintf('*t%02d*ch02.tif',t)]);
                        img_ind = find(all_array(:,1) == sample & all_array(:,3) == tcount);
                        x = all_array(img_ind,4);
                        y = all_array(img_ind,5);
                        z = all_array(img_ind,6);
                        for i = 1:length(x)
                            
                            xlow = x(i) - windsize/2;
                            if xlow < 1
                                xlow = 1;
                                xhigh = windsize;
                            elseif xlow > 1024 - windsize +1
                                xlow = 1024 - windsize + 1;
                                xhigh = 1024;
                            else
                                xlow = x(i) - windsize/2;
                                xhigh = x(i) + windsize/2 - 1;
                            end
                                                       
                            ylow = y(i) - windsize/2;
                            if ylow < 1
                                ylow = 1;
                                yhigh = windsize;
                            elseif ylow > 1024 - windsize + 1
                                ylow = 1024 - windsize + 1;
                                yhigh = 1024;
                            else
                                ylow = y(i) - windsize/2;
                                yhigh = y(i) + windsize/2 - 1;
                            end
                            imgcut = fiber_t(ylow:yhigh,xlow:xhigh,z(i));
                            
                            if mean(imgcut(:))>180
                                imgcut = fiber_t(ylow:yhigh,xlow:xhigh,z(i)+2);
                            end
                            
                            imwrite(imgcut,[fiberfold,filesep,sprintf('fiber_%04d.tif',img_ind(i))]);
                            
                        end
                        
                        if tcount == tlim
                            break
                        end

                    end

                    if tcount == tlim
                        break
                    end


                end


        end
%% integrate cell data and collagen data
    case 4
        load([foldmotil,filesep,'motility20x.mat']);
        all_array = cell2mat(squeeze(struct2cell(all))');
        m = readtable([foldmotil,filesep,'motility20x_fiber.csv']);
        fiber = table2array(m(:,9:10));
        fangle = fiber(:,1);
        fangle(fangle<0) = fangle(fangle<0) + 180;
        fiber(:,1) = fangle;
        all_array(:,9:10) = fiber;
        al = num2cell(all_array);
        for i = 1: length(al)
            altemp(i,1:3)= al(i,1:3);
            altemp{i,4} = [al{i,4},al{i,5},al{i,6}];
            altemp(i,5:8) = al(i,7:10);
        end
        
        all = cell2struct(altemp,{'sample','cell_index','time','center','aspectratio','cell_orient','fiber_orient','fiber_coherency'},2);
        save([foldmotil,filesep,'motility20x_result.mat'],'all','all_array');
        
end





    