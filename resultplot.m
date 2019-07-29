%% import cell data and collagen data
clear all 

style  = 2; 
%1: combine cell and collagen data
%2: 3d clustering and plot 
%

if style == 1

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

elseif style == 2
%% plot data
    %{
    stat=[];
    count = 0;
    cohm = max(all(:,4));
    bin = 10; 
    apr = 1.4;
    ind = find(all(:,4) > 1.4);
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

    %}

    %dfold = '/home/kimji/Project/Cell_mechanics/On_site_contact_guidance/ECM_cell_interaction_strong_alignment/';
    dfold  = '/Volumes/JIhan_SSD/Cellmechanics/on site contact guidance/ECM_cell_interaction_strong_alignment/';
    load([dfold,filesep,'final_result.mat']);
    % within 'all' 
    % column 4: aspect ratio 
    %5: coherence
    %8: dtheta

    cluster = {};
    ap1 = 1.5;
    ap2 = 3;
    apmax = max(all(:,4));
    binsize = 10;

    %------------------------ cluster 1
    ind1 = find(all(:,4) >= 1 & all(:,4) < ap1);
    cluster{1,1} = ones(length(ind1),1);
    cluster{1,2} = all(ind1,5);
    cluster{1,3} = all(ind1,8);

    [N1, edges1] = histcounts(cluster{1,2},binsize);
    cluster{1,4} = ones(length(edges1)-1,1);
    cluster{1,5} = edges1(1,1:binsize)';
    acount = [];
    for i = 1: length(edges1)-1
        tempc = cluster{1,2};
        tempa = cluster{1,3};
        idx = find(tempc(:,1)>= edges1(1,i) & tempc(:,1)<= edges1(1,i+1));
        acount(i,1) = mean(tempa(idx,1));
        acount(i,2) = std(tempa(idx,1));
    end
    cluster{1,6} = acount(:,1);
    cluster{1,7} = acount(:,2);
    %---------------------- cluster 2
    ind2 = find(all(:,4) >= ap1 & all(:,4) < ap2);
    cluster{2,1} = ones(length(ind2),1)*2;
    cluster{2,2} = all(ind2,5);
    cluster{2,3} = all(ind2,8);

    [N2, edges2] = histcounts(cluster{2,2},binsize);
    cluster{2,4} = ones(length(edges2)-1,1)*2;
    cluster{2,5} = edges2(1,1:binsize)';
    acount = [];
    for i = 1: length(edges2)-1
        tempc = cluster{2,2};
        tempa = cluster{2,3};
        idx = find(tempc(:,1)>= edges2(1,i) &tempc(:,1)<= edges2(1,i+1));
        acount(i,1) = mean(tempa(idx,1));
        acount(i,2) = std(tempa(idx,1));
    end
    cluster{2,6} = acount(:,1);
    cluster{2,7} = acount(:,2);
    %------------------------ cluster 3
    ind3 = find(all(:,4)>=ap2 & all(:,4)< apmax+1);
    cluster{3,1} = ones(length(ind3),1)*3; 
    cluster{3,2} = all(ind3,5);
    cluster{3,3} = all(ind3,8);

    [N3, edges3] = histcounts(cluster{3,2},binsize);
    cluster{3,4} = ones(length(edges3)-1,1)*3;
    cluster{3,5} = edges3(1,1:binsize)';
    acount = [];
    for i = 1: length(edges3)-1
        tempc = cluster{3,2};
        tempa = cluster{3,3};
        idx = find(tempc(:,1)>= edges3(1,i) & tempc(:,1)<= edges3(1,i+1));
        acount(i,1) = mean(tempa(idx,1));
        acount(i,2) = std(tempa(idx,1));
    end
    cluster{3,6} = acount(:,1);
    cluster{3,7} = acount(:,2);

    figure, plot3(cluster{1,1},cluster{1,2},cluster{1,3},'g*',cluster{2,1},cluster{2,2},...
        cluster{2,3},'bx',cluster{3,1},cluster{3,2},cluster{3,3},'rs','MarkerSize',5);
    xlabel('Aspect ratio');
    ylabel('Coherency');
    zlabel('d\theta');
    ar1 = legend({'1 - 1.5','1.5 - 3', '3 - 13'},'FontSize',15);
    title(ar1,'Aspect ratio')
    %{
    figure, plot3(cluster{1,4},cluster{1,5},cluster{1,6},'r-',cluster{2,4},cluster{2,5},...
        cluster{2,6},'b-',cluster{3,4},cluster{3,5},cluster{3,6},'g-');
    xlabel('Aspect ratio');
    ylabel('Coherency');
    zlabel('d\theta');
    %}
    figure, plot(cluster{1,5},cluster{1,6},'g-',cluster{2,5},cluster{2,6},'b-',...
        cluster{3,5},cluster{3,6},'r-','LineWidth',3);
   
    xlabel('Coherency');
    ylabel('d\theta');
    ar2 = legend({'1 - 1.5','1.5 - 3', '3 - 13'},'FontSize',15);
    title(ar2,'Aspect ratio')
    
    %{
    e1 = errorbar(cluster{1,5},cluster{1,6},cluster{1,7});
    e1.Marker = 'x';
    e1.Color = 'red';
    e1.CapSize = 0;
    e1.MarkerSize = 5;
  
    e2 = errorbar(cluster{2,5},cluster{2,6},cluster{2,7});
    e2.Marker = 'x';
    e2.Color = 'blue';
    e2.CapSize = 0;
    e2.MarkerSize =5;
    e3 = errorbar(cluster{3,5},cluster{3,6},cluster{3,7});
    e3.Marker = 'x';
    e3.Color = 'green';
    e3.CapSize = 0;
    e3.MarkerSize = 5;
    %}
    
end
