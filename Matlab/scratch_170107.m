%%
% Try to simulate a fluoresence distribution
pulserate = 300000; % Hz
pulseperiod = 1/pulserate;
dt = 10e-9; % Sec: bin resolution
Nbins = floor(pulseperiod/dt);
tau = 10e-7; % Sec
k1 = 45; % Amplitude of exponential
tau2 = 2.5e-8;
k2 = 500; % Amplitude of 2nd exp
k3 = 100;
T = dt*(1:Nbins);
S = (min(k3, max(k2*exp(-T/tau2), k1*exp(-T/tau))));
%%
vbin = T>=100e-9 & T <= 450e-9;
bincts = sum(S(vbin));
totcts = sum(S);
plot(T,S,'.-');
title(sprintf('Binned counts: %.1f Total counts: %.1f', bincts, totcts));
%%
Pdist = S/pulserate;
P0 = 1 - sum(Pdist);
plot(T,Pdist*100,'.-');
title(sprintf('P(0) = %.2f %', P0*100));
ylabel('P(T) %');
xlabel('T sec');
%%
Pcumsum = cumsum(Pdist);
plot(T,Pcumsum);
%%
% Pick a resolution <= min(Pdist), then map the cumsum onto integers
Presmax = min(Pdist);
IPmaxmin = floor(1/Presmax);
Nbits = ceil(log(IPmaxmin)/log(2));
Pres = 2^(-Nbits);
IPcumsum = floor(Pcumsum/Pres);
maxbits = dec2hex(max(IPcumsum), ceil(Nbits/4));
IPmax = 2^Nbits;
plot(T,IPcumsum,'.');
title(sprintf('Nbits = %d, IPmax = %.3g, max = %s', Nbits, IPmax, maxbits));
%%
plot(diff(IPcumsum),'.');
%%
R = rand(pulserate,1)*IPmax;
dT = interp1([IPcumsum IPmax],[1:length(IPcumsum) 0], R, 'next', 'extrap');
h = histogram(dT,[0:length(IPcumsum)+1]);
plot(T,S,T,h.Values(2:end),'.');
%%
% This is data from simulation where
% N_CHANNELS := 1
NA = 4;
% NB := 75
% NC := 300000, which matches pulserate above
simCt = [103 359 150 159 129 164 134 125 145 120 107 122 129 108 109 ...
  104 90 82 96 93 62 89 74 61 67 66 74 62 65 54 70 51 49 53 39 47 33 ...
  37 37 39 37 38 39 30 29 19 30 26 32 23 18 31 23 26 25 20 19 20 18 ...
  14 13 22 10 14 18 11 10 14 13 15 10 7 16 6 10];
simT = (1:length(simCt))*NA*10e-9;
hold on
plot(simT,simCt/NA,'*b');
hold off
legend('P(T)','Matlab Sim','MODELSIM');
xlabel('T');
ylabel('counts');
%%
N = 1000;
bcts = zeros(N,1);
for i=1:N
  R = rand(pulserate,1)*IPmax;
  dT = interp1([IPcumsum IPmax],[T 0], R, 'next', 'extrap');
  bcts(i) = sum(dT>=100e-9 & dT <= 450e-9);
end
bcts_mean = mean(bcts);
bcts_std = std(bcts);
fprintf(1,'mean = %.1f  std = %.1f  var = %.1f\n', bcts_mean, bcts_std, bcts_std^2);
%%
for i=1:Nbins
  fprintf(1, '%3d: %05X\n', i, IPcumsum(i));
end
%%
Nbitsnz = ceil(log2(max(IPcumsum)));
indent = '          ';
fprintf(1, '%sIF (R <= %d) THEN\n%s  Nbins <= my_US(1);\n', indent, IPcumsum(1), indent );
for i=2:Nbins
  fprintf(1, '%sELSIF (R <= %d) THEN\n%s  Nbins <= my_US(%d);\n', indent, IPcumsum(i), indent, i);
end
fprintf(1, '%sELSE\n%s  Nbins <= my_US(0);\n%sEND IF;\n', indent, indent, indent);
% %%
% R = rand(1,1)*IPmax;
% dT = binsearch(IPcumsum, R);
% %%
% function ind = binsearch(T, R, low, high)
%   if nargin < 4
%     low = 1;
%     high = length(T);
%     if R > T(high)
%       ind = high+1;
%       return;
%     end
%   end
%   if low==high
%     ind = low;
%   else
%     mid = floor((low+high)/2);
%     if R > T(mid)
%       ind = binsearch(T, R, mid+1, high);
%     else
%       ind = binsearch(T, R, low, mid);
%     end
%   end
%   return;
% end
% 
% 
