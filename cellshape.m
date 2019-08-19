cell = loadimgs(['/Volumes/JIhan_SSD/Cellmechanics/on site contact guidance/3d_cellshape/'...
    'cell_03/*.tif']);
membrane = cell;

cellpixels = membrane;
%remove the small dots away fromt he cell
CC = bwconncomp(cellpixels);
numPixels = cellfun(@numel,CC.PixelIdxList);
[biggest,idx] = max(numPixels);
cellpixels(CC.PixelIdxList{idx}) = 1;
cellpixels = single(cellpixels==1);
membrane=cellpixels;



membrane = smooth3(membrane,'box',[3,3,3]);
figure, view(3);
colormap hot;
shading interp;
daspect([1 1 1]);
axis tight;
isosurface(membrane);
camlight;
set(gca, 'DataAspectRatio',[2 2 1],'XTick',[],'YTick',[],'ZTick',[])
