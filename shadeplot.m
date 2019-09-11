function[bottom,top,mid]=shadeplot(inputraw,pars)
if isempty(pars)    
    pars.binsize = 10;
    pars.sig = 1;
    pars.color_area = [128 193 219]./255;    % Blue theme
    pars.color_line = [ 52 148 186]./255;
    pars.alpha      = 0.5;
    pars.line_width = 2;
   
    
end

bin = pars.binsize ;
sig = pars.sig;
carea = pars.color_area;
cline = pars.color_line;
lwidth = pars.line_width;
alpha = pars.alpha;



inputbin = inputraw(:,1);
inputvalue =  inputraw(:,2);

binmin =min(inputbin);
binmax = max(inputbin);

step = binmax/bin;
bottom = [];
top = [];
mid = [];
count = 0;
for i = 0:step:binmax-step
    count = count + 1;
    ind = find(inputbin>=i &inputbin< i +step );
    temp = inputvalue(ind);
    top(count,1) = (i + step/2);
    top(count,2) = mean(temp) +sig*std(temp);
    bottom(count,1) = top(count,1);
    bottom(count,2) = mean(temp)-sig*std(temp);
    mid(count,1) = top(count,1);
    mid(count,2) = mean(temp);

end
x = [bottom(:,1)',fliplr(bottom(:,1)')];
y = [bottom(:,2)',fliplr(top(:,2)')];
figure, fill(x,y,carea);
set(patch, 'edgecolor', 'none');
set(patch, 'FaceAlpha', alpha);

    hold on;
 plot(mid(:,1), mid(:,2), 'color', cline, ...
        'LineWidth', lwidth);

    hold off;

end


