clear all

mode = 2;

%1: crop subwindow images
%2: combine data and plot


%foldname = '/media/kimji/JIhan_SSD/Cellmechanics/on site contact guidance/ECM_nocells/10x/3x3/';
foldname = '/Volumes/JIhan_SSD/Cellmechanics/on site contact guidance/ECM_nocells/10x/3x3';
switch mode
%% obtaining subwindow images
    case 1
        % 100 um -> 100 x 100 pixels in OrientationJ meausre window
        
        map = loadimgs([foldname,filesep,'raw_adjust.tif'],0,1);
        mapname = [foldname,filesep,'map'];
        mkdir(mapname);
        wsize = 200; %200x200 pixels 
        halfw = wsize/2;

        [h,w] = size(map); % 2800 x 2800
        resol = 20; % subresolution within the picture

        nframe = (h-wsize)/resol;
        count = 0;
        mapinfo = [];

        for r = 0:nframe
            for c = 0:nframe
                count = count + 1;
        nframe = (h-wsize)/resol;
                if r == 0 && c ~= 0
                    rbegin = 1;
                    rend = wsize;
                    cbegin = c*resol;
                    cend = c*resol +wsize-1;

                elseif r ~= 0  && c == 0 
                    rbegin = r*resol;
                    rend = r*resol +wsize-1;
                    cbegin = 1;
                    cend = wsize;


                elseif r == 0 && c == 0 
                    rbegin = 1;
                    rend = wsize;
                    cbegin = 1;
                    cend = wsize;

                else
                    rbegin = r*resol;
                    rend = r*resol +wsize-1;
                    cbegin = c*resol;
                    cend = c*resol +wsize-1;

                end
              swind = map(rbegin:rend,cbegin:cend);
             % imwrite(swind,[mapname,filesep,sprintf('map_%d.tif',count)]);

              center = [r*resol+halfw, c*resol+halfw];
              mapinfo(count,1:3) = [count,center];


            end
        end
        save([foldname,filesep,'mapinfo.mat'],'mapinfo');


%% plot mode
    case 2
        orient =  readtable([foldname, filesep,'map20.csv']);
        load([foldname,filesep,'mapinfo20.mat']);
        mapinfo(:,4) = table2array(orient(:,9));
        mapinfo(:,5) = table2array(orient(:,10));
        %[col, row] = meshgrid(150:50:2650,150:50:2650);
        [col, row] = meshgrid(100:20:2700,100:20:2700);
        
        [lc,lr] = size(col);
        angle = zeros(lc,lr);
        coherency = angle;
        count = 0;
        for i = 1: lr
            for j = 1: lc
            count = count +1 ;
            angle(i,j) = mapinfo(count,4);
            coherency(i,j) = mapinfo(count,5);
            end
        end
        
        %figure, surf(col,row,coherency);
        %figure, surf(col,row,angle);
        figure, imagesc(coherency);
        set(gcf,'position',[100 100 800 800]) ;
        colormap hot
        %colorbar;
        xticks([])
        yticks([])
        export_fig([foldname,filesep,'coherency_nolabel.png'],'-png');
        figure, imagesc(angle);
        set(gcf,'position',[100 100 800 800]) ;
        %colorbar;
        colormap jet
        xticks([])
        yticks([])
        export_fig([foldname,filesep,'angle_nolabel.png'],'-png');
        save([foldname,filesep,'mapinfo20.mat'],'mapinfo','angle','coherency','col','row');

        
end

        