%%
cd C:\Users\nort.ARP\Documents\Exp\HCHO\BCtr\Matlab
%%
serial_port_clear();
%%
[s,port] = serial_port_init();
%set(s,'BaudRate',57600);
set(s,'BaudRate',115200);
%%
% First check that the board is BCtr
BdID = read_subbus(s, 3);
if BdID ~= 8
  error('Expected BdID 8, reported %d', BdID);
end
Build = read_subbus(s,2);
if Build < 8
  error('BCtr build is %d: must be >= 8 for BCtr2 operations', BdID);
end
fprintf(1, 'Attached to BCtr2 Build # %d\n', Build);
if Build >= 10
  ct_offset = 6;
else
  ct_offset = 4;
end
%%
ctr = 32;
%%
write_subbus(s, ctr, hex2dec('0000')); % Disable
write_subbus(s, ctr, hex2dec('8000')); % Reset
status = read_subbus(s,ctr);
while status ~= 0
  status = read_subbus(s,ctr);
end
%%
NChannels = 2;
Channel = 1; % 1 or 2
bin_opt = 2;
if bin_opt == 1
  bin_NA = [10,35,200];
  bin_NB = [1, 1, 1];
elseif bin_opt == 2
  bin_NA = [10,1,200];
  bin_NB = [1,35,1];
elseif bin_opt == 3
  bin_NA = [1,5,80];
  bin_NB = [45,40,1];
end
if sum(bin_NA.*bin_NB) > 330
  warning('Bins exceed pulse period');
end
Nsamples = 120;
for i=1:length(bin_NA)
  write_subbus(s, ctr+1+2*i, bin_NA(i));
  write_subbus(s, ctr+2+2*i, bin_NB(i));
end
status = read_subbus(s, ctr);
N_NAB = floor(status/(2^6));
if bitand(status, 32) ~= 32 || N_NAB ~= length(bin_NB)
  error('Counter not ready after init');
end
NBtotal = sum(bin_NB);
exp_ct = NBtotal*NChannels+ct_offset;
% rm_obj = read_multi_prep([exp_ct ctr+2]);
rm_obj2 = read_multi_prep(ctr, [ctr+1,exp_ct,ctr+2,0]);
Nsave = 1000;
Statuses = NaN*zeros(Nsave,1);
IPnum = NaN*zeros(Nsave,1);
NTrig = NaN*zeros(Nsave,1);
LaserV = NaN*zeros(Nsave,1);
Cts = NaN*zeros(Nsave,NBtotal*NChannels);
Nsampled = 0;
%%
% Setup dacscan
ds_start = 0;
ds_end = round(0.600*65536/5); % 1 V
ds_steps = 600;
ds_step = round((ds_end-ds_start)*8/ds_steps);
ds_base = hex2dec('80');
report_ds_status(s, ds_base);
write_subbus(s, ds_base+2, ds_start);
write_subbus(s, ds_base+3, ds_end);
write_subbus(s, ds_base+4, ds_step);
%%
status = read_subbus(s,ctr);
report_status(status);
%% ACQUISITION USING MULTI SYNTAX
write_subbus(s, ctr, 1); % Enable
write_subbus(s, ds_base, 1); % start scan

Nsampled = 0;
Nsamples = 35;
while Nsampled < Nsamples
  [values,ack] = read_multi(s,rm_obj2);
  if ack == 1
    status = values(1);
    NB_rpt = values(2);
    if bitand(status,1) == 0
      error('Counter not enabled');
    end
    if length(values) ~= NB_rpt+2
      error('NB_rpt:%d returned %d Values', NB_rpt, length(values));
    else
%       if bitand(status,2) == 2 && NB_rpt ~= exp_ct
%         warning('NB_rpt = %d, exp_ct = %d', NB_rpt, exp_ct);
%       end
      if bitand(status,2) == 0 && NB_rpt ~= 0
        warning('!DRdy + NB_rpt = %d', NB_rpt);
      end
      if bitand(status,2) == 2
        if NB_rpt >= 6
          Nsampled = Nsampled+1;
          Statuses(Nsampled) = status;
          IPnum(Nsampled) = bitand(values(3),63);
          NTrig(Nsampled) = values(4)+values(5)*65536;
          LaserV(Nsampled) = values(6);
          % should log LaserinP here.
          if NB_rpt > ct_offset
            if NB_rpt > exp_ct
              NB_rpt = exp_ct;
            end
            Cts(Nsampled,1:(NB_rpt-ct_offset)) = ...
              values((2+ct_offset+1):(2+NB_rpt))';
            fprintf(1,'Nsample:%d: IPnum:%d', Nsampled, IPnum(Nsampled));
            fprintf(1,' %d',Cts(Nsampled,1:2:end));
            fprintf(1,'\n');
          else
            Cts(Nsampled,:) = 0;
          end
        end
      end
    end
  else
    warning('read_multi() returned ack %d',ack);
  end
end
%
write_subbus(s, ctr, 0); % Disable
status = read_subbus(s,ctr);
report_status(status);
if bitand(status,1) == 1
  warning('Counter still enabled after disable');
end
%%
write_subbus(s, ctr, hex2dec('8000')); % Reset
status = read_subbus(s,ctr);
report_status(status);
if bitand(status,1) == 1
  warning('Counter still enabled after reset');
end
%%
if NBtotal == 3
  clf;
  Nax = 4;
  ax = zeros(Nax,1);
  for i=1:Nax
    ax(i) = nsubplot(Nax,1,i);
  end
  plot(ax(1), NSk,'.');
  plot(ax(2), Cts(:, Channel), '.');
  plot(ax(3), Cts(:, Channel+2), '.');
  plot(ax(4), Cts(:, Channel+4), '.');
  set(ax([2 4]),'YAxisLocation','Right');
  set(ax(1:3),'XTickLabel',[]);
  ylabel(ax(1),'NSk');
  ylabel(ax(2),'Bin1');
  ylabel(ax(3),'Bin2');
  ylabel(ax(4),'Bin3');
  shg;
end
%%
% Get T,S from original model: top section of scratch_170107.m
% copied in from 170107 for customization of the delay
% Try to simulate a fluoresence distribution
pulserate = 300000; % Hz
pulseperiod = 1/pulserate;
integration_period = 0.1;
dt = 10e-9; % Sec: bin resolution
Nbins = floor(pulseperiod/dt);
tau = 10e-7; % Sec
k1 = 45; % Amplitude of exponential
tau2 = 2.5e-8;
k2 = 500; % Amplitude of 2nd exp
k3 = 100;
T = dt*(1:Nbins);
S = (min(k3, max(k2*exp(-T/tau2), k1*exp(-T/tau))));
prop_delay = 3;
S(1+prop_delay:end) = S(1:end-prop_delay);
S(1:prop_delay) = 0;
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
    bMdlMean(nBins) = mdl_mean * integration_period;
%     plot(t01, bin_mean, '-*r', ...
%       [t0 t1], bin_mean*[1 1], '-k', ...
%       t01*[1 1], bin_mean+bin_std*[-1 1], '-k');
%     hold on;
    t0 = t1;
    b0 = b1;
  end
end
% hold off;
% title('Normalized count rates');
%%
hold on
plot(T,S*normal_width/dt,'-b');
hold off;
shg
%%
figure;
%%
plot(bT,bMean,'*r',bT,bMdlMean);
ylabel(sprintf('Counts/sec/%d ns bin', normal_width*1e9));
xlabel('Seconds after trigger');
shg;
%%
plot(bT,bMean-bMdlMean,'*',bT,bStd*[1,-1],'k',bT,bStd*[3,-3],'c');
%plot(bT,bStd*[1,-1],'k',bT,bStd*[3,-3],'c');
legend('residual','1 \sigma','','3 \sigma','');
xlabel('Time after trigger, sec');
ylabel('Normalized residual counts');
shg;
%%
% Test dacscan
ds_start = 0;
ds_end = round(65536/5); % 1 V
ds_steps = 600;
ds_step = round((ds_end-ds_start)*8/ds_steps);
ds_base = hex2dec('80');
report_ds_status(s, ds_base);
write_subbus(s, ds_base+2, ds_start);
write_subbus(s, ds_base+3, ds_end);
write_subbus(s, ds_base+4, ds_step);
report_ds_status(s, ds_base);
write_subbus(s, ds_base, 1); % start scan
%%
report_ds_status(s, ds_base);
%% BCtr2: test expiration...
report_status(read_subbus(s,ctr));
%%
write_subbus(s, ctr, 1); % Enable
status = read_subbus(s, ctr);
while bitand(status,2) == 0
  status = read_subbus(s,ctr);
end
while bitand(status,1024) == 0
  status = read_subbus(s,ctr);
end
fprintf(1,'Reporting expired status:\n');
report_status(status);
[values,ack] = read_multi(s,rm_obj2);
% report_status(values(1));
IPnum = bitand(values(3),63);
ExpBit = bitand(values(3),32768) > 0;
NW = values(2);
fprintf(1,'Late     Expired:%d IPnum:%d NW:%d\n', ExpBit, IPnum, NW);
[values2,ack2] = read_multi(s,rm_obj2);
IPnum = bitand(values2(3),63);
ExpBit = bitand(values2(3),32768) > 0;
NW = values2(2);
fprintf(1,'Followup Expired:%d IPnum:%d NW:%d\n', ExpBit, IPnum, NW);
write_subbus(s, ctr, 0); % Disable
%% BCtr HCHO Data Requirements
NChannels = 2;
NBins = 101;
CPB = 5; % ASCII representation: MXXXX
SampleRate = 10; % Hz

Bytes = SampleRate * NBins * NChannels;
Chars = Bytes * CPB;
Baud = Chars * 10;
