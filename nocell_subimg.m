clear all

mode = 2;

%1: crop subwindow images
%2: combine data and plot
rpm = 0;
resol = 50; %subresolution within the picture

%foldname = '/media/kimji/JIhan_SSD/Cellmechanics/on site contact guidance/analysis/ECM/useful'; %from linux
foldname = '/Volumes/JIhan_SSD/Cellmechanics/on site contact guidance/ECM_nocells/00rpm 5x5'; %from mac
switch mode
%% obtaining subwindow images
    case 1
        % 100 um -> 100 x 100 pixels in OrientationJ meausre window
        % cell free ECM images are taken with 10x air 
         
        
        map = loadimgs([foldname,filesep,sprintf('rpm%02d.tif',rpm)],0,1);
        mapname = [foldname,filesep,sprintf('map_%02d',rpm)];
        mkdir(mapname);
        wsize = 200; %200x200 pixels 
        halfw = wsize/2;

        [h,w] = size(map); % 2800 x 2800
     
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
              imwrite(swind,[mapname,filesep,sprintf('map_%d.tif',count)]);

              center = [r*resol+halfw, c*resol+halfw];
              mapinfo(count,1:3) = [count,center];


            end
        end
        filename = sprintf('mapinfo_%02d.mat',rpm);
        save([foldname,filesep,filename],'mapinfo');


%% plot mode
    case 2
        
        filenamecol = sprintf('map_%02d.csv',rpm);
        orient =  readtable([foldname, filesep,filenamecol]);
        filename = sprintf('mapinfo_%02d.mat',rpm);
        load([foldname,filesep,filename]);
        
        mapinfo(:,4) = table2array(orient(:,9));
        mapinfo(:,5) = table2array(orient(:,10));
        if resol == 50 
            [col, row] = meshgrid(100:50:2700,100:50:2700);
        elseif resol == 20
            [col, row] = meshgrid(100:20:2700,100:20:2700);
        end
        
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

        c=colorbar;
        imco = sprintf('coherency_%02d.png',rpm);
        export_fig([foldname,filesep,imco],'-png');
        titleco = sprintf('Coherency %02d rpm',rpm);
        title(titleco);
        
        %xticks([])
        %yticks([])
        %set(c,'YTick',[]);
        figure, imagesc(angle);
        set(gcf,'position',[100 100 800 800]) ;
        c1=colorbar;
        imang = sprintf('angle_%02d.png',rpm);
        export_fig([foldname,filesep,imang],'-png');
        titleang = sprintf('Angle %02d rpm',rpm);
        title(titleang);
        %xticks([])
        %yticks([])
        %set(c1, 'YTick',[]);
        %separate colorbar plot
        %{
        colormap('parula');
        cbar = colobar;
        axis off;
        set(cbar,'YTick',[]);
        
        %}
        save([foldname,filesep,filename],'mapinfo','angle','coherency','col','row'); 
       
        
        close all
        
end

        