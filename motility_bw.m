
clear all 

for sample = 1: 7
    
%sample = 1;
mode = 2;           % 1: corrodes bw image || 2: without corrosion
windowsize = 3;     % for smoothing bw image (pixel)
cellcut = 500;     % this allow to remove background 
                    % 4x: 70 / 10x: 150 / 20x: 300
                    
%foldname = ['/media/kimji/JIhan_SSD/Cellmechanics/on site contact guidance/'...
%        'Motility/10x',filesep,sprintf('s%02d',sample)];

foldname = ['/Volumes/JIhan_SSD/Cellmechanics/on site contact guidance/Motility/'...
    '20x',filesep,sprintf('s%02d',sample)];   
tlim = 28;          % total 7 hours (15 min/frame)

mask = loadimgs([foldname,filesep,'mask.tif']);
mask =  double(mask);
mask(mask>0) = 1;


for time = 1:2
   
    imfold = [foldname,filesep,sprintf('xyzt_%02d',time)];
    fresult = [foldname,filesep,'result'];

    if ~exist(fresult,'dir')

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
        
        motility ={};
        tcount = 0;
        bt = 0;
    else
        load([fresult,filesep,'motility.mat']);
        tcount = length(motility);
        bt = tcount;
        d = dir(imfold);
        n = struct2cell(d);
        ind = find(contains(n(1,:),'z00_ch00'));
        fbw = [fresult,filesep,'bw'];
        fmip = [fresult,filesep,'mip'];
        fcomb = [fresult,filesep,'combine'];
        tmax = length(ind);
       

    end

    %se = strel('sphere',3);
    se = strel('disk',3);
    %se =strel('cube',3);


    for st = 0:tmax-1
        tcount = tcount + 1;
        t = st + bt;

        stackbw = [];
        stack = loadimgs(sprintf([imfold,filesep,'*t%02d_*ch00.tif'],st),0,1);
        lz = length(stack(1,1,:));
        Imean = [];
        % apply traingle method to create a binary image stack. First find the 
        % brightest plane and determine the threshold value to apply to the
        % entire stack
        
        for z = 1:lz
           Imean(z,1) = mean(mean(stack(:,:,z)));
        end
        [val,k] = max(Imean);
        %[val,k] = min(Imean);
        temp = stack(:,:,k);
        [histo, a] = imhist(temp);
        histo = histo(1:length(histo)-1,1);
        level = triangle_th(histo,length(histo));
        
        if ~isnan(level)
            for z = 1:lz
                imtemp = stack(:,:,z);
                im_bw = imbinarize(imtemp,level);
                bw_sp = medfilt2(im_bw); %remove small dots 

                if mode == 1
                    bw = imerode(bw_sp,se);
                else
                    bw = bw_sp;
                end

                stackbw(:,:,z) = bw;
            end
            % remove regions where multiple cells are overlaped
            
            stackbw = stackbw.*mask;
          
            cc = bwconncomp(stackbw,26);
            numPixels = cellfun(@numel, cc.PixelIdxList);
            [noncell, idx] = find(numPixels < cellcut);
            
            for i = 1: length(idx)
                id = idx(i);
                stackbw(cc.PixelIdxList{id}) = 0;
            end
            cc = bwconncomp(stackbw,26);
            cellinfo = struct([]);

            for i = 1: length(cc.PixelIdxList)
                perc = i/length(cc.PixelIdxList)*100;
                fprintf('%02d / %02d: %.1f \n',st,tmax-1,perc);

                stacktemp = stackbw;
                stacktemp(cc.PixelIdxList{i}) = 10;
                stacktemp(stacktemp < 10) = 0;
                
                cc3d = bwconncomp(stacktemp,26);
                center = regionprops(cc3d, 'Centroid');
                
                mip = max(stacktemp,[],3);
                mip = imbinarize(mip);

               % mip = conv2(mip,kernel,'same'); % smoothing cell binary images

                stats = regionprops(mip,'Orientation','MajorAxisLength','MinorAxisLength');
                cellinfo(i).index = i;
                %cellinfo(i,2:3) = stats.Centroid; % find the center of
                %mass
                
                % find the maximum inscribed cirlce wihtin the cell
                
                cellboundary = bwperim(mip);
                disttoboundary = bwdist(cellboundary);
                celldisttransform = disttoboundary.*double(mip);
                [tempm,tempind] = max(celldisttransform(:));
                [celly,cellx] = ind2sub(size(mip),tempind);
                temppos = center.Centroid;
                cellinfo(i).cent = [cellx,celly,round(temppos(3))];
                              
                cellinfo(i).aspectratio = stats.MajorAxisLength/stats.MinorAxisLength;
                cellinfo(i).orient = stats. Orientation;
                if cellinfo(i).orient < 0 
                    cellinfo(i).orient = cellinfo(i).orient + 180;
                end

            end
            tempcenter = cell2mat(squeeze(struct2cell(cellinfo))');
            
                        
            motility{tcount,1} = cellinfo;
            MIP = max(stackbw,[],3);
            IM = im2uint8(MIP);
            
            imwrite(IM,[fmip,filesep,sprintf('s%02d_t%02d.tif',sample,t)]);
            figure(100), imshow(IM);
            hold on 
            plot(tempcenter(:,2),tempcenter(:,3),'r.','MarkerSize', 12);
            set(gcf,'Position',[100 100 1000 1000]);
            imname = [fcomb,filesep,sprintf('comb_t%02d.tif',t)];
            export_fig(imname,'-tif');
            hold off
            close(100)
            for z=1:lz
                I = im2uint8(stackbw(:,:,z));
                imwrite(I,[fbw,filesep,sprintf('s%02d_t%02d_z%02d.tif',sample,t,z)]);
            end
        end
        
    if tcount == tlim
        break
    end
    
    end
    save([fresult,filesep,'motility.mat'],'motility');
   if tcount == tlim
       break
   end
   
end
clear all

end

 