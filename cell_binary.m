station = 1;

if station == 1
    foldname = ['/home/kimji/Project/Cell_mechanics/cell_ECM_sensitivity/'...
        '25c_collagen_gradient/sample_04_48hr/'];
    s = dir(foldname);
    imfold = s(6).name;
else 
    foldname = '/Users/jihan/Desktop/sample_04_48hr';
    s =  dir(foldname);
    imfold = s(4).name;
end

img = loadimgs([foldname,filesep,imfold,filesep,'*ch00.tif'],0,1);
mkdir([foldname,filesep,imfold,filesep,'BW']);
bw_stack = zeros(1024,1024,length(img(1,1,:)));

for i = 1:length(img(1,1,:))
    imtemp = img(:,:,i);
    im_adjust = imadjust(imtemp);
    imfilt = medfilt2(im_adjust);
    bw = imbinarize(imfilt);
    I = im2uint8(bw);
    imwrite(I,[foldname,filesep,imfold,filesep,'BW',filesep,sprintf('xyz_%02d.tif',i)]);
    bw_stack (:,:,i) = I;
    
end

%% register cells that are interested in
celldata = struct([]);

im_max = max(bw_stack,[],3);
figure(100), imshow(im_max);

breaker = 1;
coordinate = [];

count = 0;
[xmap,ymap] = meshgrid(1:1024,1:1024);
r = 4;

% to add a point: press 1, to finish adding a point: press 2
allcells = [foldname,filesep,imfold,filesep,'cellnumber'];
mkdir(allcells);
while(breaker)
    
    check = getkey;
    
    if check == 49
        count = count + 1;
        [x,y] = ginputc(1,'color','r','LineWidth',1);
        fprintf('The number of points: %02d \n',count);
        coordinate(count,:) = round([x,y]);
        hold on
        plot(x,y,'ro','MarkerSize',5,'MarkerEdgeColor','red',...
            'MarkerFaceColor','red');
        str = sprintf('%d',count);
        text(round(x),round(y),str,'Color','red','FontSize',15);

        
    elseif check == 50
        breaker = 0;
        saveas(gcf,[allcells,filesep,'xyz' num2str(1) '.jpeg']); 
        close(100)
    end
    
end

%% Find a center z position and isolate single cell from other cells

count1 = 0;
zmin = 3;
zprof = [];
cellfold = [foldname,filesep,imfold,filesep,'single_cell'];
mkdir(cellfold);

for i = 1:length(coordinate(:,1))
    
    center = coordinate(i,:);
%     circle = sqrt((xmap-center(1)).^2+(ymap-center(2)).^2);
%     circle(circle < r) = 1;
%     circle(circle > 1) = 0;
%     [yprof, xprof] = find(circle >0);
    bwtemp = bw_stack(center(2),center(1),:);
    bwz = squeeze(bwtemp);
    ztemp = find(bwz > 0);
    l = length(ztemp);
    
    if ztemp(1)+floor(l/2) > zmin && ztemp(l)-floor(l/2) < length(bwz) -zmin 
        celldata(i).coordinates = [center(1), center(2), ztemp(1)+floor(l/2)];
        nstack = bw_stack(:,:,ztemp(1):ztemp(l));
        nmip = max(nstack,[],3);
        cc = bwconncomp(nmip);
        index_center = 1024*(center(1)-1)+center(2);
        
        for j = 1 : length(cc.PixelIdxList)
            cell = cc.PixelIdxList{1,j};
            acell = find(cell == index_center);
            if isempty(acell) == 0
               index_cell = j;
            elseif isempty(acell) == 1
                nmip(cc.PixelIdxList{j}) = 0;
                            
            end
            
        end
        %
        nmip = imbinarize(nmip);
        stat = regionprops(nmip,'all');
        
        %
        cellboundary = bwperim(nmip);
        tempstruct = regionprops(cellboundary,'PixelList');
        outlinecoor = tempstruct.PixelList;
        [A, centerellip] = MinVolEllipse(outlinecoor', 1e-3);
                
        
        nI = im2uint8(nmip);
        imwrite(nI,[cellfold,filesep,sprintf('cell_%02d.tif',i)]);
        
    else 
        celldata(i).coordinates = [center(1), center(2), NaN];
    end
      
end

