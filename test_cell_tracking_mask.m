%change workingfolder for each sample, makesure the subfolders are named
%correctly

workingfolder = '/home/kimji/Project/Cell_mechanics/cell_ECM_sensitivity/25C_collagen_iron/sample_09_30deg';



%change this two if you see something wrong in the output. Basically
%distancethreshold is how far apart two pixel clounds can belong to the
%same cell. sizethreshold is used to remove large clouds (such as another
%cell). If the cell contains 100 pixels, then 

sizethreshold = 15;
distancethreshold = 5;


%first detect all the subfolders
cellmaskfolders = dir([workingfolder,filesep,'cell_mask',filesep,'*']);
cellmaskfolders = cellmaskfolders(3:end);

cellrawfolders = dir([workingfolder,filesep,'cell_crop',filesep,'*']);
cellrawfolders = cellrawfolders(3:end);

celltrackfolders = [workingfolder,filesep,'celltrack'];


ncells = numel(cellmaskfolders);



%now process each cell
for indcell = 1:ncells
    maskimagefolder = [cellmaskfolders(indcell).folder,filesep,...
        cellmaskfolders(indcell).name];
    rawimagefolder = [cellrawfolders(indcell).folder,filesep,...
        cellrawfolders(indcell).name];
    
    rawimagename = subdir([rawimagefolder,filesep,'*.tif']);
    celldatacollect = struct([]);
    figure(100)
    
    
    
    
    movieinput = loadimgs([maskimagefolder,filesep,'*.tif'],0,1);
    
    %movieoutput = movieinput*0;
    binaryframes = imbinarize(movieinput);
    nframes = length(binaryframes(1,1,:));
    
    
    outputfolder = [celltrackfolders,filesep,sprintf('cell_%03d',indcell)];
    mkdir(outputfolder);
    for indframe = 1:nframes
        
       
        
        imagenow = squeeze(binaryframes(:,:,indframe));
        [imgout,cellregprop,numobj_exclude] = ...
            masktracking_singlecell(imagenow,...
            sizethreshold,distancethreshold);
        subplot(1,2,1);
        
        imshow(imread(rawimagename(indframe).name));
        hold on;
        [outlinecoor,outlineobj] = contour(imgout,1);
        hold off;
        
        %find the maximum inscribed circle instead of center of mass for
        %cell location
        
        cellboundary = bwperim(imgout);
        disttoboundary = bwdist(cellboundary);
        celldisttransform = disttoboundary.*double(imgout);
        
        [tempm,tempind] = max(celldisttransform(:));
        [celly,cellx] = ind2sub(size(imgout),tempind);
        celldatacollect(indframe).cellcenter_maxfit = [cellx,celly];
        celldatacollect(indframe).area = cellregprop.Area;
        
        %ellipse fiting using second momentum, not very useful
        
        %ellip_secondmom = struct([]);
        ellip_secondmom.aspectratio = ...
            (cellregprop.MajorAxisLength)/(cellregprop.MinorAxisLength);
        ellip_secondmom.majax_angle_degree = ...
            cellregprop.Orientation+90;
        
        celldatacollect(indframe).ellip_2nd_momentum = ellip_secondmom;
        
        %find the minimal enclosing ellipse, better
        tempstruct = regionprops(cellboundary,'PixelList');
        outlinecoor = tempstruct.PixelList;
        [A , centerellip] = MinVolEllipse(outlinecoor', 1e-3);
        
        
        [Ve,De]=eig(inv(A));
        De=sqrt(diag(De));
        [majax,Ie] = max(De);
        veig=Ve(:,Ie);
        angle_min_enc_ell=atan2(veig(2),veig(1));
        minax=De(setdiff([1 2],Ie));

        %ellip_min_enc = struct([]);
        ellip_min_enc.MajorAxisLength = majax;
        ellip_min_enc.MinorAxisLength = minax;
        ellip_min_enc.majax_angle_degree = angle_min_enc_ell*180/pi;
        celldatacollect(indframe).ellip_min_enc = ellip_min_enc;
        celldatacollect(indframe).cellcenter_minell = centerellip;
        %now plot the ellipse
        
        
        

        subplot(1,2,2)
        imagesc(celldisttransform);
        hold on;
        plot(cellx,celly,'ko','MarkerFaceColor','k');
        hold on;
        
        tq=linspace(-pi,pi,20); 
        U=[cos(angle_min_enc_ell) -sin(angle_min_enc_ell);sin(angle_min_enc_ell) cos(angle_min_enc_ell)]*[majax*cos(tq);minax*sin(tq)];
        plot(U(1,:)+centerellip(1),U(2,:)+centerellip(2))

        hold on;
        

        plot([centerellip(1)-majax*cos(angle_min_enc_ell),...
            centerellip(1)+majax*cos(angle_min_enc_ell)],...
            [centerellip(2)-majax*sin(angle_min_enc_ell),...
            centerellip(2)+majax*sin(angle_min_enc_ell)],...
            'w--','LineWidth',2);
        
        daspect([1,1,1])
        hold off; 
        set(gcf,'Position',[100,100,800,400]);
        export_fig([outputfolder,filesep,...
            sprintf('testimages%04d',indframe),'.tif'],'-tif');
    
        
  
    end

    save([outputfolder,filesep,'celltracking.mat'],'celldatacollect');
    close(100)

end