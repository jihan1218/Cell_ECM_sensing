clear all
%foldname ='/Users/jihan/OneDrive/working/collagen_gradient_map/before_10x/result' ;
foldname = ['/home/kimji/Project/Cell_mechanics/cell_ECM_sensitivity/'...
            '25C_collagen_iron/collagen_gradient_map/before_10x/result/global'];
z = 1; % the number of z stack
fleng = 10;

fiberangle = [];
fibernumer = [];

count = 3 ;% beginning of z position

for k = 1:z
    
    count1 = 0;
    
    %m = readtable([foldname,filesep,'/z00',filesep,d(k).name,filesep,sprintf('z%02d.csv',k-1)]);
    %m = readtable([foldname,filesep,sprintf('z%02d.csv',count)]);
    m = readtable([foldname,filesep,sprintf('global.csv',count)]);
    count = count + 1;
    if width(m) == 8
        result = table2array(m(:,2:7));
        frame = unique(result(:,1));
    elseif width(m) == 7
        
        result = table2array(m(:,1:6));
        frame = unique(result(:,1));
    end
    
        
    for n = 1:length(frame)
      
        nframe = frame(n);
        index_frame = find(result(:,1) == nframe);
        fiber = result(index_frame,2:6);
        fibersep = unique(fiber(:,1));
        
        for n1 = 1:length(fibersep)
            
            index_fiber =  find(fiber(:,1) == fibersep(n1));
            fibersingle = fiber(index_fiber,:);
            if fibersingle(1,5) > fleng
                count1 = count1 + 1;
                acount = 0;
                xt = 0;
                yt = 0;
                s = 0;
                lt = 0;
                theta = 0;
                for ii = 1 : length(fibersingle(:,1))-1
                    acount = acount + 1;
                    dx = fibersingle(ii+1,3)-fibersingle(ii,3);
                    dy = fibersingle(ii+1,4)-fibersingle(ii,4);
                    li = sqrt(dx^2+dy^2);
                                  
                    if dy >= 0 && dx >= 0 
                        fangle = 180 - atan2d(dy,dx);
                    elseif dy <0 && dx >= 0
                        dy = -dy;
                        fangle = atan2d(dy,dx) ;
                    elseif dy >= 0 && dx < 0
                        dx = -dx;
                        fangle = atan2d(dy,dx);
                    elseif dy < 0 && dx < 0
                        dy = -dy;
                        dx = -dx;
                        fangle = 180 - atan2d(dy,dx);
                    end
                    
                    thetai = li*fangle*pi/180;
                    si = li*exp(2*i*fangle*pi/180);
                    s = s + si;
                    lt = lt + li;
                    theta = theta + thetai;
                    

                end
                fiberangle(count1,1,k) = nframe;
                fiberangle(count1,2,k) = count1;
                fiberangle(count1,3,k) = s;
                fiberangle(count1,4,k) = theta;
                fiberangle(count1,5,k) = lt;
                fiberangle(count1,6,k) = fibersingle(1,5);
            end
        end
        
    end
           
    
end
%%
for zz = 1:z
    fiberframe = unique(nonzeros(fiberangle(:,1,zz)));
    for ii = 1: length(fiberframe)
        findex = find(fiberangle(:,1,zz) == fiberframe(ii));
        ftemp = fiberangle(findex,:,zz);
        fibernumer(ii,1,zz) = abs(ftemp(1,1));
        fibernumer(ii,2,zz) = abs(sum(ftemp(:,3))/sum(ftemp(:,5)));
        fibernumer(ii,3,zz) = abs(sum(ftemp(:,4))/sum(ftemp(:,5)));
        fibernumer(ii,4,zz) = abs(sum(ftemp(:,5)));
        fibernumer(ii,5,zz) = abs(length(ftemp(:,1)));
    end
end
    

save([foldname,filesep,'fiberangle_test.mat'],'fiberangle','fibernumer');


