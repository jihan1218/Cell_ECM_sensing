%% import cell data and collagen data
clear all 

station = 2;
result = {};
scount = 0;

all = [];
count = 0;
for sample = 1:3 
    scount = scount + 1;
    if station == 1
        foldname = sprintf(['/home/kimji/Project/Cell_mechanics/cell_ECM_sensitivity/'...
            'ECM_cell_interaction_strong_alignment/sample_$02d'],sample);
        s = dir(foldname);
%         n = n+5;
%         imfold = s(n).name;
    else 
        foldname = sprintf(['/Users/jihan/Desktop/on site contact guidance/'...
            'ecm strong alignment/sample_%02d'],sample);
        s =  dir(foldname);
%         n = n + 3 ;
%         imfold = s(n).name;
    end
    rcount = 0 ;
    for nr =1: length(s)
        imfold = s(nr).name;
        
        if strfind(imfold,'region') == 1
            rcount = rcount + 1;
            count = count + 1;
            
            
            resultfold = [foldname, filesep, imfold, filesep, 'result'];
            collagen = readtable([resultfold,filesep,'collagen_orient_200.csv']);
            load([resultfold,filesep,'celldata.mat'],'celldata');

            coltemp = [];
            coltemp(:,1) = table2array(collagen(:,1));
            coltemp(:,2) = table2array(collagen(:,4));
            coltemp(:,3:4) = table2array(collagen(:,9:10));
            coltemp(:,5:6) = table2array(collagen(:,2:3));
            comb = [];
            ccount = 0 ;
            for i = 1: length(celldata)
                ccount = ccount + 1;
                z = celldata(i).zcenter;
                index = find(coltemp(:,1) == i);
                subcol = coltemp(index,:);
                index2 = find(subcol(:,2) == z);
                colinf = subcol(index2,3:4);
                colcord = subcol(index2,5:6);
                
                if colinf(1,1) < 0 
                    colinf(1,1) = 180 + colinf(1,1);        
                end
                comb(i,1) = scount;
                comb(i,2) = rcount;
                comb(i,3) = ccount;
                comb(i,4) = celldata(i).aspectratio;
                comb(i,5) = colinf(1,2); % coherency
                comb(i,6) = celldata(i).angle;
                comb(i,7) = colinf(1,1);
                if comb(i,7) < 0
                    comb(i,7) = 180 + comb(i,7);
                end
                
                comb(i,8) = abs(comb(i,6) - comb(i,7));
                if comb(i,8) > 90
                    comb(i,8) = 180 - comb(i,8);
                end
                
                comb(i,9) = celldata(i).centermass(1) - colcord(1,1);
                comb(i,10) = celldata(i).centermass(2)- colcord(1,2);
            end
             result{count,1} = comb;
        end
    end
    
end

for i = 1: length(result)
    m = result{i,1};
    all = [all; m];
end

save(['/Users/jihan/Desktop/on site contact guidance/ecm strong alignment/final_result.mat'],'all','result');

%% plot data

stat=[];
count = 0;
cohm = max(all(:,4));
bin = 10; 
apr = 1.4;
ind = find(all(:,4) > 1.2);
figure(100), scatter3(all(ind,4),all(ind,5),all(ind,8));
xlabel('Aspect ratio');
ylabel('Coherency');
zlabel('d \Theta');
%{
for i = 0:cohm/bin:cohm - cohm/bin
    count = count + 1;
    index = find(all(:,4)> i & all(:,4)<= i + cohm/bin &all(:,1)> apr);
    sub = all(index,:);
    stat(count,1) = i +cohm/(2*bin);
    stat(count,2) = mean(sub(:,5));
    stat(count,3) = std(sub(:,5));
end
%}
