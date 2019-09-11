%% ecm no cell shade plot

foldname = ['/Users/jihan/Documents/Cellmechanics/on site contact guidance/'...
    'ECM_nocells/10x/3x3'];
filename = [foldname,filesep,'mapinfo20.mat'];

load(filename);

%mapinfo 
%column 2,3 -> x,y coordinates
%column 5 -> coherency
imname = [foldname,filesep,'raw_adjust.tif'];
img = loadimgs(imname);

[lx, ly] = size(img);

xcent = lx/2;

ycent = xcent;

mapinfo(:,6) = sqrt((mapinfo(:,2)-xcent).^2 +(mapinfo(:,3)-ycent).^2);

pars.binsize = 20;
pars.sig =1;
pars.color_area = [103 189 170]./255;    % Blue theme
pars.color_line = [ 0 0 255]./255;
pars.alpha      = 0.5;
pars.line_width = 3;


input(:,1) = mapinfo(:,6);
input(:,2) = mapinfo(:,5);

[bottom,top,mid] = shadeplot(input,pars);
ax = gca;
ax.FontSize = 16;
xlabel ('distance from center (\mum)','FontSize',16);
ylabel ('coherency','FontSize',16);



