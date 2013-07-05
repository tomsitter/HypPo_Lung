function patient = newPatient()

lungfunc = struct('temp1', -1.0, 'temp2', -1.0);

patient = struct('id', {}, 'lungs', {}, 'body', {}, ...
                         'lungmask', {}, 'bodymask', {}, ...
                         'coreg', {}, 'parmslung', {}, 'parmsbody', {}, ...
                         'analysis', {}, 'dataver', 0.3, 'threshold', {}, ...
                         'mean_noise', {}, 'hetero_images', {}, 'hetero_score', {}, ...
                         'lung_function', {}, 'lung_SNR', {}, 'body_SNR', {}, 'mean_hetero', {});
% patient(1).id = 'newPatient';
% patient(1).dataver = 0.3;
% patient(1).lung_function  = lungfunc;

end