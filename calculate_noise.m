function [threshold, mean_noise] = calculate_noise(noise_roi)

if sum(noise_roi(:))==0
	threshold = 0;
	mean_noise = 0;
	return;
end

% Initialize parameters
gf_array = [];      % Distribution of nonbackground pixels
rf_array = [];      % Distribution of best-fit Rayleigh model

noise_roi = imresize(noise_roi, [3*length(noise_roi) 1]);

max_noise = max(noise_roi);
x = 0:1:max_noise;
x = x+0.5;
h = hist(noise_roi, x);
    
% dist_fit=1;
% while dist_fit==1
    
    % User selects initial parameter for regression
    % (Usual values for beta: 0.1, 0.01, 0.001)
    beta_value = 0.01; %input('Input initial parameter beta for regression: ');
    beta = [beta_value, beta_value, beta_value];
    
    % Determines best-fit Rayleigh model
	
	s1 = warning('off','stats:nlinfit:IllConditionedJacobian');
	s2 = warning('off','stats:nlinfit:IterationLimitExceeded');
    betahat = nlinfit(x',h','rayleigh_model',beta);
	warning(s1);
	warning(s2);

    % Calculate predicted values from best-fit Rayleigh model
    yhat = rayleigh_model(betahat,x);
       
    % Plots the distribution
	%{
    figure(2);
    plot(x,h,'o')
    hold on;
    plot(x,yhat,'r')
    hold off;
    close(figure(2));
	%}
	
    % Calculates coefficient of determination, r^2, value
    SStot = sum((h-mean(h)).^2);
    SSerr = sum((h-yhat).^2);
    RR = 1-SSerr/SStot;
    
    % If distribution is a bad fit, reinitialize parameters for regression
%     dist_fit = menu('Reinitialize regression parameters?','Yes','No');
% end

% Calculates g(f)
gf = abs(h-yhat);

% Calculate the optimal threshold from best-fit Rayleigh model
%This whole section can be rewritten in 4 lines of code which are much more
%efficient

%% test edit


% gf_sum1 = cumsum(gf(1:floor(max_noise)))';
% rf_sum1 = [sum(yhat) - cumsum([0 yhat])]';
% rf_sum1 = rf_sum1(1:floor(max_noise));
% ef1 = gf_sum1 + rf_sum1;

for tau = 1:max_noise
    for i = 0:tau-1
        if i == 0
            gf_array = vertcat(gf_array,0);
        else
            gf_array = vertcat(gf_array,gf(i));
        end
    end
    gf_sum(tau,1) = sum(gf_array);
    
    for j = tau:max_noise
        rf = yhat(j);
        rf_array = vertcat(rf_array,rf);
    end
    rf_sum(tau,1) = sum(rf_array);
    
    % Calculates error function
    ef(tau,1) = gf_sum(tau,1)+rf_sum(tau,1);
    
    % Reinitializes array for each iteration
    gf_array = [];
    rf_array = [];
end

%%%%%%%%%%%%%%%%%%%%% Binarization of Hypex Images %%%%%%%%%%%%%%%%%%%%%

% Determines threshold that yields the lowest error function
[vals,ix] = sort(ef);
threshold = ix(1);

% Calculates the mean of the noise distribution
mean_noise = mean(noise_roi);

% Create image mask
% figure(3);
% for n = 1:slices
%     % Finds pixel intensity values that exceed the threshold
%     mask(:,:,n) = data(:,:,n) > thres;
%     
%     % Displays initial segmentation results
%     subplot(m,4,n); 
%     imshow(mask(:,:,n))
% end