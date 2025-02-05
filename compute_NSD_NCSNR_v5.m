clc; clear all; close all;

addpath('utilities')
homedir = pwd;
%bidsdir = fullfile('/media','tarrlab','s','datasets','BOLD5000','BIDS');

%%

date = '09_08_20';
groupings = {'one-sess_NSD'};%,'three-sess','five-sess'};
versions = {'TYPEA_ASSUMEHRF','TYPEB_FITHRF','TYPEC_FITHRF_GLMDENOISE','TYPED_FITHRF_GLMDENOISE_RR'};
subjs = {'subj02','subj03','subj04'};%,'CSI2','CSI3'};
nses = 10;
numreps = 3;
nsesimgs = 750;
overwrite = 0;

for g = 1:length(groupings)

    grouping = groupings{g};

    for v = 1:length(versions)

        version = versions{v};

        if contains(version,'ASSUME')
            grouping0 = [grouping '_assume'];
            version0 = 'TYPEB_FITHRF';
        else
            grouping0 = grouping;
            version0 = version;
        end

        for s = 1:length(subjs)

            subj = subjs{s};
            disp([grouping ' ' subj ' ' version])

            betadir = fullfile(homedir,'betas',[date '_' grouping0], subj);
            assert(isfolder(betadir))

            metric_savedir = fullfile(homedir,'betas',[date '_' grouping], 'metrics_v2');
            if ~isfolder(metric_savedir)
                mkdir(metric_savedir)
            end

            repbeta_savedir = fullfile(homedir,'betas',[date '_' grouping],'rep_betas');
            if ~isfolder(repbeta_savedir)
                mkdir(repbeta_savedir)
            end

            repbeta_savefn = fullfile(repbeta_savedir,[subj '_' version '_rep_betas.mat']);

            if ~isfile(repbeta_savefn) || overwrite == 1

                disp('recomputing rep-betas')

                subdirs = struct2table(dir(betadir));
                ses_subdirs = subdirs.name;
                ses_subdirs = ses_subdirs(contains(ses_subdirs,'session'));

                session_betas = [];
                

                %%

                for i = 1:length(ses_subdirs)

                    disp(['loading ses ' num2str(i)])
                    sesstrs = strsplit(ses_subdirs{i},'_');
                    sesnums = str2double(cellstr(sesstrs(2:end)));
                    
                    X = load(fullfile(betadir, ses_subdirs{i}, [version0 '.mat']));
                    
                    betas = X.modelmd;
                    if i == 1
                        session_betas = calczscore(betas, 4, [], [], 0);
                    else
                        session_betas(:,:,:,end+1:end+size(betas,4)) = calczscore(betas, 4, [], [], 0);
                    end
                end
                subdims = size(X.R2);
                clear X
                
                %% get repeat indices

                a1 = load('nsd_expdesign.mat');
                labels = a1.masterordering(1:nsesimgs*nses);
                % experimental design stuff
                ord = labels;
                ordU = unique(ord);
                allixs = [];
                for qq=1:length(ordU)
                    ix = find(ord==ordU(qq));
                    if length(ix)==numreps
                        allixs(:,end+1) = ix(:);
                    end
                end

                for i = 1:size(allixs,2)
                    assert(all(labels(allixs(:,i))==labels(allixs(1,i))))
                end
       

                %%
                rep_betas = zeros(subdims(1), subdims(2), subdims(3), size(allixs,1), size(allixs,2),'single');

                for r = 1:size(allixs,1)
                    for c = 1:size(allixs,2)
                        beta0 = session_betas(:,:,:,allixs(r,c));
                        rep_betas(:,:,:,r,c) = beta0;
                    end
                end
                clear session_betas
                save(repbeta_savefn,'rep_betas','-v7.3')
            else
                disp(['rep beta file already exists, skipping'])
                %continue
                load(repbeta_savefn)
            end

            subdims = [size(rep_betas,1) size(rep_betas,2) size(rep_betas,3)];

            
            % compute vmetric from repeated betas
            disp('computing vmetric')
            vmetric = sqrt(mean(std(rep_betas,[],4).^2,5));

            % compute SNR from vmetric
            disp('computing ncsnr')
            snr = translatevmetric(vmetric);

            % compute percentage of noise ceiling
            ncsnr = (100 .* (snr.^2)) ./ (snr.^2 + 1/numreps);

            disp('computing split half reliability')
            reliability = zeros(subdims(1),subdims(2),subdims(3));

            for ii = 1:subdims(1)
                disp(ii)
                for jj = 1:subdims(2)
                    for kk = 1:subdims(3)
                        aa = squeeze(rep_betas(ii,jj,kk,:,:));
                        if sum(isnan(aa(:))) == 0
                            bb0 = corr(aa(1,:)',aa(2,:)');
                            bb1 = corr(aa(1,:)',aa(3,:)');
                            bb2 = corr(aa(2,:)',aa(3,:)');
                            %bb0 = corr(mean(aa([1 2],:))', mean(aa([3 4],:))'); 
                            %bb1 = corr(mean(aa([1 3],:))', mean(aa([2 4],:))'); 
                            %bb2 = corr(mean(aa([1 4],:))', mean(aa([2 3],:))'); 
                            reliability(ii,jj,kk) = mean([bb0 bb1 bb2]);
                        else
                            reliability(ii,jj,kk) = NaN;
                        end
                    end
                end
            end

            disp('saving metric volumes')
            save(fullfile(metric_savedir,[subj '_' version '_vmetric.mat']), 'vmetric')
            save(fullfile(metric_savedir,[subj '_' version '_snr.mat']), 'snr')
            save(fullfile(metric_savedir,[subj '_' version '_ncsnr.mat']), 'ncsnr')
            save(fullfile(metric_savedir,[subj '_' version '_reliability.mat']), 'reliability')

        end
    end
end

function f = translatevmetric(x)

f = 1 - x.^2;

f(f<0) = 0;

f = sqrt(f) ./ x;

f(isinf(f)) = NaN;

end