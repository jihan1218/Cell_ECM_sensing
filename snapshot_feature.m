foldname = ['/Users/jihan/Documents/Cellmechanics/on site contact guidance/'...
    'analysis/strong alignment'];
filename = ['/Users/jihan/Documents/Cellmechanics/on site contact guidance/'...
    'analysis/strong alignment/final_result.mat'];
load(filename);
x = all(:,4); % aspect ratio
y = all(:,5); % coherency
z = all(:,8); % angle difference
%surf(x,y,z)
%scatter3(x,y,z,'filled')
mincoh = min(all(:,5));
maxcoh = max(all(:,5));
rel = {};
count = 0;
step = 0.1;

for i = 0:step:0.6
    count = count + 1;
    indcut = find(all(:,4) > 1.3);
    allcut = all(indcut,:);
    ind = find ( allcut(:,5)>=i & allcut(:,5)< i + step);
    rel{count,1} = [allcut(ind,4),allcut(ind,8)];
end

%%

coh = 0.05:0.1:0.65;


for i = 1:7
    temp = rel{i,1};
    [population,gof] = fit(temp(:,1),temp(:,2),'exp1');
    A = population.a;
    B = population.b;
    x = 1:0.5:14;
    y = A*exp(B*x);
    figure, plot(temp(:,1),temp(:,2),'x');
    hold on
    plot(x,y,'r-')
    xlabel('aspect ratio');
    ylabel('angle difference');
    str = sprintf('coherency: %d', i*0.1-0.05);
    legend(str)
    
    export_fig([foldname,filesep,sprintf('coherency_%d.png',i)],'-png');
end



 

