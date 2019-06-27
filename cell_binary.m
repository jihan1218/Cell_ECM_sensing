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
mkdir([foldname,filesep,'xyz_01_bw']);
bw_stack = zeros(1024,1024,length(img(1,1,:)));

for i = 1:length(img(1,1,:))
    imtemp = img(:,:,i);
    im_adjust = imadjust(imtemp);
    imfilt = medfilt2(im_adjust);
    bw = imbinarize(imfilt);
    I = im2uint8(bw);
    imwrite(I,[foldname,filesep,'xyz_01_bw',filesep,sprintf('xyz_%02d.tif',i)]);
    bw_stack (:,:,i) = I;
    
end

%% register cells that are interested in

im_max = max(bw_stack,[],3);
figure(100), imshow(im_max);

breaker = 1;
coordinate = [];

count = 0;
[xmap,ymap] = meshgrid(1:1024,1:1024);
r = 4;

% to add a point: press 1, to finish adding a point: press 2

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
        saveas(gcf,[foldname,filesep,'xyz' num2str(1) '.jpeg']); 
        close(100)
    end
    
end

%% Find a center z position and isolate single cell from other cells

count1 = 0;
zmin = 3;
zprof = [];


for i = 1:1 %length(coordinate(:,1))
    
    center = coordinate(i,:);
%     circle = sqrt((xmap-center(1)).^2+(ymap-center(2)).^2);
%     circle(circle < r) = 1;
%     circle(circle > 1) = 0;
%     [yprof, xprof] = find(circle >0);
    bwtemp = bw_stack(center(2),center(1),:);
    bwz = squeeze(bwtemp);
    ztemp = find(bwz > 0);
    l = length(ztemp);
    
    if ztemp(1)+floor(l/2)> zmin
        zprof(i,1) = i;
        zprof(i,2:3) = center;
        zprof(i,4) = ztemp(1) + floor(l/2);
        nstack = bw_stack(:,:,ztemp(1):ztemp(l));
        nmip = max(nstack,[],3);
        cc = bwconncomp(nmip);
        index_center = 1024*(center(1)-1)+center(2);
        
        for j = 1 : length(cc.PixelIdxList)
            cell = cc.PixelIdxList{1,j};
            a = find(cell == index_center);
            if isempty(a) == 0
               index_cell = j;
            elseif isempty(a) == 1
                nmip(cc.PixelIdxList{j}) = 0;
                            
            end
            
        end
        
        
    else 
        zprof(i,1) = i;
        zprof(i,2:3) = center;
        zprof(i,4) = NaN;
    end
      
end

imshow(nmip)
