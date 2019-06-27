
%foldname ='/Users/jihan/OneDrive/working/collagen_gradient_map/before02_10x/' ;
foldname = ['/home/kimji/Project/Cell_mechanics/cell_ECM_sensitivity/'...
            '25C_collagen_iron/collagen_gradient_map/before_10x/'];
        
load([foldname,filesep,'result/fiberangle_test.mat']);
mkdir([foldname,filesep,'result/plot_test']);
mask = loadimgs([foldname,filesep,'/mask/mask.tif']);

mask(mask==0) = 1;
mask(mask>1) = 0;
mask = double(mask);


%z = 1;
numfiber = 1;
radius = 14;
color = jet(256);
intensitymap = 0:1/255:1;
[xc,yc] = meshgrid(16:32:1024,16:32:1024);


[x,y] = meshgrid(1:1024,1:1024);
maskx = mask.*x;
masky = mask.*y;

distmap = [];
for ii = 1:32
    for jj = 1:32
    fxc = xc(jj,ii);
    fyc = yc(jj,ii);
    distprof = sqrt((nonzeros(maskx)-fxc).^2 + (nonzeros(masky)-fyc).^2);
    distmap(jj,ii) = min(distprof(:));
    end
end

%% global color line plot 

zc = 5; % beginning of z-stack

for z = 1:10
    fibertemp = fibernumer(:,:,z);
    fibertemp_index = find(fibertemp(:,5) > numfiber);
    fibertemp = fibertemp(fibertemp_index,:);
    wide = loadimgs([foldname,filesep,sprintf('result/bw_clean/bwclean_z%02d.tif',zc)]);

    figure(100), imshow(wide)
    truesize;
    hold on

    for index = 1:length(fibertemp(:,1))
        Nframe = fibertemp(index,1);
        xcent = xc(Nframe);
        ycent = yc(Nframe);
        theta = fibertemp(index,3);
        xend1 = xcent + radius*cos(theta);
        yend1 = ycent + radius*sin(theta);
        xend2 = xcent - radius*cos(theta);
        yend2 = ycent - radius*sin(theta);
        intensity = fibertemp(index,2);
        [v, index_color] = min(abs(intensitymap - intensity));
        linecolor = color(index_color,:);
        line([xend2,xend1], [yend1,yend2],'Color',linecolor,'LineWidth',2);
        hold on

    end

    hold off
    export_fig(gcf,[foldname,filesep,sprintf('result/plot_test/before_z%02d.jpg',zc)]);
    close(100)
    zc = zc + 1;
    
end
%% histogram plot

numbin = 10;
distlist = unique(distmap(:));
distlist = nonzeros(distlist);
binsize = round(max(distlist)/numbin);
bin = min(distlist): binsize: max(distlist);
k = 1;
numvsdist = cell(numbin-1,k);
%kk = 4;

for kk = 1: 10
    fibertemp = fibernumer(:,:,kk);
    fibertemp_index = find(fibertemp(:,5) > numfiber);
    fibertemp = fibertemp(fibertemp_index,:);
    for i = 1 : numbin -1
        [row, col] = find(distmap >= bin(i) & distmap < bin(i+1));
        smalldata = [];
        count = 0;
        for ii = 1: length(row(:))
            nframe = row(ii) + 32*(col(ii)-1);
            if ismember(nframe,fibertemp(:,1)) == 1 
                count = count + 1;
                index = find(fibertemp(:,1) == nframe);
                smalldata(count,1) = fibertemp(index,2);
            end
        end
        numvsdist{i,k} = smalldata;
    end
    histresult = zeros(length(numvsdist),2);
    for i = 1: length(numvsdist)
        histresult(i,1) = mean(numvsdist{i,k});
        histresult(i,2) = std(numvsdist{i,k});
    end
    figure(200),
    errorbar(bin(1:length(bin)-1)',histresult(:,1),histresult(:,2),'-s','MarkerSize',10,...
        'MarkerEdgeColor','red','MarkerFaceColor','red','LineWidth',2);
    ylim([0 1.1])
    xlim([0 600])
    title('before')
    set(gca,'FontSize',20)
    saveas(gcf,[foldname,filesep,sprintf('result/plot_test/histogram_%02d.png',kk)]);
    close(200)
end

save([foldname,filesep,'result/plot_test/histresult.m'],'histresult','numvsdist');


%% generate coordinate map for each frame

%{
test_str = cell(1024,1);
position=[];
[xi, yi] = meshgrid(1:32:1024,1:32:1024);

for ii = 1 :1024
    test_str{ii} = num2str(ii);
    position(ii,:) = [xi(ii), yi(ii)];
end

rgb=insertText(wide,position,test_str,'FontSize',12,'BoxOpacity',0,'TextColor','Red');
    
imshow(rgb)
%}





