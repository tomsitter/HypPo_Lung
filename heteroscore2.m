function patients = heteroscore2(patients)
% this program loads 3 post-processed images just for plotting
% the histograms of their heterogeneity maps

edges=[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 10.01];
logedges=[-Inf -1 -0.9 -0.8 -0.7 -0.6 -0.5 -0.4 -0.3 -0.2 -0.1 Inf];
labelvec=[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1];
loglabvec=[-Inf -1 -0.9 -0.8 -0.7 -0.6 -0.5 -0.4 -0.3 -0.2 -0.1];

total_pixels = 0;

n_patients = length(patients);

pixel_list = cell(n_patients, 1);

n_slices = size(patients(1).lungs, 3);

vecsmax = zeros(n_slices, 1);
vlogmax = zeros(n_slices, 1);

hetscore = zeros(n_slices, n_patients);
t0 = zeros([length(edges) n_patients n_slices]);
t0_log = zeros([length(edges) n_patients n_slices ]);

for p = 1:n_patients

    hetmaps = patients(p).hetero_images;

%     hetscore = zeros(n_slices, 1);
    
    for n=1:n_slices

        hetmap = hetmaps(:,:, n);

        horz = any(hetmap, 1);
        vert = any(hetmap, 2);

        top = find(vert, 1, 'first');
        bottom = find(vert, 1, 'last');
        left = find(horz, 1, 'first');
        right = find(horz, 1, 'last');

        if isempty(top)
            continue
        end
        hetmap = hetmap(top:bottom, left:right);

        all_zeros = hetmap == 0;
        hetmap(all_zeros) = NaN;

        hetvec = hetmap(:)';
        hetvec = hetvec / max(hetvec);
        num_pixels = length(hetvec(:));
    
        %get number of NaN values in vector
        num_nans = sum(isnan(hetvec));
        %get means, subtracting the NaNs from the number of elements
        hetscore(n, p) = nansum(hetvec)/(length(hetvec)-num_nans);

        total_pixels = total_pixels + num_pixels;
        pixel_list{p} = [pixel_list{p} hetvec];

%         figure(ceil(n/6)*2+1)
%         subplot(4,3,mod(n-1,3)+1+mod(floor((n-1)/3),2)*6)

        t0(:, p, n) = histc(hetvec, edges);
%         t0(p, n, :) = t0(1:end-1);
          
%         plot(labelvec, t0/num_pixels, 'k-');
%         title(['het. hist. img#',sprintf('%d',n)])
        vecsmax(n) = max(max(t0(:, p, n)/num_pixels, vecsmax(n)));

%         figure(ceil(n/6)*2+2)
%         subplot(4,3,mod(n-1,3)+1+mod(floor((n-1)/3),2)*6)

        t0_log(:, n, p) = histc(log10(hetvec), logedges);
%         t0_log(p, n, :) = t0_log(1:length(edges)-1);
%         title(['log, het. hist. img#',sprintf('%d',n)])

%         plot(loglabvec, t0_log/num_pixels, 'k-');
        vlogmax(n) = max(max(t0_log(:, p, n)/num_pixels, vlogmax(n)));
    end
    
    patients(p).mean_hetero = nanmean(pixel_list{p});
    patients(p).hetero_score = hetscore(:, p);
end

hold on;
for p = 1:n_patients
    
    if p == 1
        line = 'k-';
    elseif p == 2
        line = 'b-';
    elseif p == 3
        line = 'r-';
    end
    
    for n = 1:n_slices
        figure(ceil(n/6)*2+1)
        subplot(4,3,mod(n-1,3)+1+mod(floor((n-1)/3),2)*6)
        plot(labelvec, t0(1:end-1, p, n)/num_pixels, line);
        title(['het. hist. img#',sprintf('%d',n)])
        
        figure(ceil(n/6)*2+2)
        subplot(4,3,mod(n-1,3)+1+mod(floor((n-1)/3),2)*6)
        title(['log, het. hist. img#',sprintf('%d',n)])
        plot(loglabvec, t0_log(1:end-1, p, n)/num_pixels, line);
    end
end

maxmax=max(vecsmax);
logmax=max(vlogmax);
for n=1:n_slices
    figure(ceil(n/6)*2+1)
    subplot(4,3,mod(n-1,3)+1+mod(floor((n-1)/3),2)*6)
    axis([0 1.1 0 ceil(maxmax*10)/10])
    figure(ceil(n/6)*2+2)
    subplot(4,3,mod(n-1,3)+1+mod(floor((n-1)/3),2)*6)
    axis([-1 0 0 ceil(logmax*10)/10])
    if mod(n,6)==0 || n==n_slices
        figure(ceil(n/6)*2+1)
        eval(['print -djpeg75 ',sprintf('hethist_%d_%d.jpg',floor((n-1)/6)*6+1,n)])
        figure(ceil(n/6)*2+2)
        eval(['print -djpeg75 ',sprintf('hetloghist_%d_%d.jpg',floor((n-1)/6)*6+1,n)])
    end
end
hold off;
% output heterogeneity values for easier input into Excel for plotting
fid=fopen('hetscore.txt4','w');

fprintf(fid,'slice#\tpreMch\tpostMch\tpostDI\n');
for n=1:n_slices
%     fprintf(fid,'%2d\t%7.4f\t%7.4f\t%7.4f\n',...
%             n,hetscore_0(n),hetscore_1(n),hetscore_2(n));
    fprintf(fid, '%2d\t%7.4f\n', n, hetscore(n, 1));
end
% setmean0=mean(pixel_list(1));

fprintf(fid,'set mean\t%7.4f\n',patients(1).mean_hetero);

fclose(fid);
