%%
% Run without gobs of formaldehyde
load cts1.mat
%%
% Run with gobs of formaldehyde
load cts2.mat
%%
t0 = 0; % In time units
b0 = 0; % In bin resolution units
bin_num = 0;
dt = 10e-9;
normal_width = 10e-9;
bT = zeros(sum(bin_NB),1);
bW = zeros(sum(bin_NB),1);
bMean = zeros(sum(bin_NB),1);
bStd = zeros(sum(bin_NB),1);
bMdlMean = zeros(sum(bin_NB),1);
nBins = 0;
for i=1:length(bin_NA)
  for j = 1:bin_NB(i)
    bin_num = bin_num+1;
    b1 = b0 + bin_NA(i);
    t1 = t0 + bin_NA(i)*dt;
    bin_scale = normal_width/(t1-t0);
    bin_mean = mean(Cts(1:Nsampled,bin_num*NChannels+Channel-2))*bin_scale;
    bin_std = std(Cts(1:Nsampled,bin_num*NChannels+Channel-2))*bin_scale ...
      /sqrt(Nsampled);
    mdl_mean = mean(S((b0+1):b1))*normal_width/dt;
    t01 = (t0+t1)/2;
    nBins = nBins+1;
    bT(nBins) = t01;
    bW(nBins) = b1-b0;
    bMean(nBins) = bin_mean;
    bStd(nBins) = bin_std;
    bMdlMean(nBins) = mdl_mean;
    t0 = t1;
    b0 = b1;
  end
end
%%
figure;
plot(bT,bMean,'-*r');
ylabel(sprintf('Counts/sec/%d ns bin', normal_width*1e9));
xlabel('Seconds after trigger');
%%
t0 = 290e-9;
t1 = 700e-9;
V = bT > t0 & bT < t1;
%%
figure;
plot(bT(V),bMean(V),'-*');
%%
K = [ max(bMean(V)), 100e-9, 0 ];
T = bT(V)-min(bT(V));
y = bMean(V);
K = fminsearch('logchi', K, [], T, y );
yfit = K(1)*exp(-T/K(2))+K(3);
%%
figure;
subplot(2,1,1);
plot(bT(~V), bMean(~V),'*',bT(V),y,'*',bT(V),yfit);
ylabel(sprintf('Counts/sec/%d ns bin', normal_width*1e9));
% xlabel('Seconds after trigger');
title(sprintf('tau = %.1f ns', K(2)*1e9));
%
ax = [nsubplot(4,1,3) nsubplot(4,1,4)];
plot(ax(1),bT(V),y,'*',bT(V),yfit);
plot(ax(2),bT(V),y-yfit,'*');
set(ax(1),'XTickLabel',[],'YAxisLocation','Right');
ylabel(ax(2),'Residual');
xlabel('Seconds after trigger');
linkaxes(ax,'x');
orient tall
