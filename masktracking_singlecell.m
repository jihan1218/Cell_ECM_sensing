function [imgout,cellregprop,numobj_exclude,internaldata] = masktracking_singlecell(imagenow, sizethreshold,distancethreshold)
%imagenow should be a binary image containing only one cell to be the
%largest connected component. Other components will either be connected to
%the cell or erased

%sizethreshold: for connected components with less than N/sizethreshold,
%they are considered as cell fragments or noise. N is the size (number of
%pixels) of the biggest connected component

%distancethreshold: small objects (smaller than N/sizethreshold) are
%considered to be part of the cell protrusion and connected to the cell
%component if they are less than distancethreshold pixels from the cell
%component

%imgout is a binary image with only one connected component, the cell
%component.

%eg. imageout = masktracking_singlecell(imagenow,15,2);

numobj_exclude = 0;
CC = bwconncomp(imagenow);
numPixels = cellfun(@numel,CC.PixelIdxList);
[biggest,idxbiggest] = max(numPixels);
temp1 = imagenow*0;
%pick out the largest connective component
temp1(CC.PixelIdxList{idxbiggest}) = 1;
imgout = imfill(temp1,'holes');
temp1 = imgout;
distmaptobiggest  = bwdist(imgout,'chessboard');
internaldata = struct([]);

for indcc = 1:(CC.NumObjects)
    internaldata(indcc).numpixs = biggest;
    internaldata(indcc).disttobigest = 0;  
    internaldata(indcc).isprotrusion = 0;
    if (indcc ~= idxbiggest)
        numobj_exclude = numobj_exclude+1;
        
        numpixs = numel(CC.PixelIdxList{indcc});
        internaldata(indcc).numpixs = numpixs;
        internaldata(indcc).disttobigest = NaN;  
        %so this component is unlikely to be another cell
        if numpixs< biggest/sizethreshold
            [mindistance,indpix] = min(distmaptobiggest(CC.PixelIdxList{indcc}));
            
            internaldata(indcc).disttobigest =  mindistance;
            
            %so this component should be connected to the cell
            if mindistance<=distancethreshold
                temp2 = imagenow*0;
                temp2(CC.PixelIdxList{indcc}) = 1;
                distmaptoprotrusion = bwdist(temp2,'chessboard');
                totaldist = distmaptobiggest+distmaptoprotrusion;
                path = imregionalmin(totaldist);
                temp1(path) = 1;
                numobj_exclude = numobj_exclude-1;
                internaldata(indcc).isprotrusion = 1;
                
            end
        end
        
    end
end
imgout = imfill(temp1,'holes');
cellregprop = regionprops(imgout,'all');
    
end

