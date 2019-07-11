%% import cell data and collagen data
clear all 

station = 1;
result = cell(5,1);
count = 0;
for n = 1:5 
    count = count + 1;
    if station == 1
        foldname = ['/home/kimji/Project/Cell_mechanics/cell_ECM_sensitivity/'...
            'ECM_cell_interaction_strong_alignment/sample_01'];
        s = dir(foldname);
        n = n+5;
        imfold = s(n).name;
    else 
        foldname = '/Users/jihan/Desktop/sample_04_48hr';
        s =  dir(foldname);
        n = n + 3 ;
        imfold = s(n).name;
    end

    resultfold = [foldname, filesep, imfold, filesep, 'result'];
    collagen = readtable([resultfold,filesep,'collagen_orient.csv']);
    load([resultfold,filesep,'celldata.mat'],'celldata');

    coltemp = [];
    coltemp(:,1) = table2array(collagen(:,1));
    coltemp(:,2) = table2array(collagen(:,4));
    coltemp(:,3:4) = table2array(collagen(:,9:10));
    comb = [];
    for i = 1: length(celldata)
        z = celldata(i).zcenter;
        index = find(coltemp(:,1) == i);
        subcol = coltemp(index,:);
        index2 = find(subcol(:,2) == z);
        colinf = subcol(index2,3:4);
        if colinf(1,1) < 0 
            colinf(1,1) = 180 + colinf(1,1);        
        end
        comb(i,1) = celldata(i).aspectratio;
        comb(i,2) = celldata(i).angle;
        comb(i,3) = colinf(1,1);
        comb(i,4) = colinf(1,2);

    end
    result{count,1} = comb;
    % result
    % 1: cell aspect ratio
    % 2: cell angle
    % 3: collagen angle
    % 4: collagen coherence (0-1)
end

all = [];
all = [result{1,1};result{2,1};result{3,1};result{4,1};result{5,1}];
all(:,5) = abs(all(:,2) - all(:,3));
indx = find(all(:,5)>= 90);
all(indx,5) = 180 - all(indx,5);


stat=[];
count = 0;
cohm = max(all(:,4));
bin = 10; 
apr = 1.2;

for i = 0:cohm/bin:cohm - cohm/bin
    count = count + 1;
    index = find(all(:,4)> i & all(:,4)<= i + cohm/bin &all(:,1)> apr);
    sub = all(index,:);
    stat(count,1) = i +cohm/(2*bin);
    stat(count,2) = mean(sub(:,5));
    stat(count,3) = std(sub(:,5));
end
