%%
serial_port_clear();
%%
[s,port] = serial_port_init();
%set(s,'BaudRate',115200,'InputBufferSize',3000);
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
bin_resolution = 10; % ns
bin_NA = [  1, 50,500]; % bin widths in units of bin_resolution
bin_NB = [100, 90, 50]; % number of bins of each width
NC = 3000; % Triggers per second
% bin_NA = [  1, 5, 100];
% bin_NB = [ 50, 20,   1];
% NC = 300000;
pulse_period = 1000/NC; % ms
n_bins = sum(bin_NB);
bin_width = ones(n_bins,1);
j0 = 0;
for i=1:length(bin_NB)
  j1 = j0+bin_NB(i);
  bin_width((j0+1):j1) = bin_NA(i);
  j0 = j1;
end
scan_time = sum(bin_width)*bin_resolution*1e-6;
if scan_time > pulse_period
  warning('Bins time %.5f ms exceed pulse period %.5f ms', scan_time, pulse_period);
else
  fprintf(1,'Scan time is %.5f ms pulse period is %.5f ms\n', scan_time, pulse_period);
end
bin_center = bin_resolution*(cumsum(bin_width) - bin_width/2)*1e-3;
%%
figure;
plot(bin_center,bin_width);
drawnow;
%%
Nsamples = 60; % The number of seconds to integrate
for i=1:length(bin_NA)
  write_subbus(s, ctr+1+2*i, bin_NA(i));
  write_subbus(s, ctr+2+2*i, bin_NB(i));
end
write_subbus(s, ctr+11, mod(NC,65536));
write_subbus(s, ctr+12, floor(NC/65536));
status = read_subbus(s, ctr);
N_NAB = floor(status/(2^6));
if bitand(status, 32) ~= 32 || N_NAB ~= length(bin_NB)
  error('Counter not ready after init');
end
NBtotal = sum(bin_NB);
exp_ct = NBtotal*NChannels+1;
% rm_obj = read_multi_prep([exp_ct ctr+2]);
rm_obj2 = read_multi_prep(ctr, [ctr+1,exp_ct,ctr+2,0]);
Nsave = 1000;
NSk = NaN*zeros(Nsave,1);
Cts1 = NaN*zeros(Nsave,NBtotal);
Cts2 = NaN*zeros(Nsave,NBtotal);
Nsampled = 0;
%% ACQUISITION USING NEW MULTI SYNTAX
write_subbus(s, ctr, 1); % Enable

while Nsampled < Nsamples
  [values,ack] = read_multi(s,rm_obj2);
  if ack == 1
    status = values(1);
    NB_rpt = values(2);
    if bitand(status,1) == 0
      error('Counter not enabled');
    end
    if length(values) ~= NB_rpt+2
      error('Values returned do not match NB_rpt');
    end
    if bitand(status,2) == 2 && NB_rpt ~= exp_ct
      warning('NB_rpt = %d, exp_ct = %d', NB_rpt, exp_ct);
    elseif bitand(status,2) == 0 && NB_rpt ~= 0
      warning('!DRdy + NB_rpt = %d', NB_rpt);
    end
    if NB_rpt == exp_ct
      Nsampled = Nsampled+1;
      NSk(Nsampled) = values(3);
      Cts1(Nsampled,:) = values(4:NChannels:end)';
      Cts2(Nsampled,:) = values(5:NChannels:end)';
      fprintf(1,'Nsample = %d: ', Nsampled);
      % fprintf(1,' %d',Cts(Nsampled,:));
      fprintf(1,'\n');
      %%
      Ctsum = sum(Cts1(1:Nsampled,:))/Nsampled;
      plot(bin_center,Ctsum'./bin_width, bin_center, ...
        Cts1(Nsampled,:)'./bin_width,'.');
      xlabel('Bin center, us');
      ylabel('Ctr/sec/10ns');
      drawnow;
      if NSk(Nsampled) == 0
        pause(0.4);
      end
    end
  else
    warning('read_multi() returned ack %d',ack);
  end
end
%
write_subbus(s, ctr, 0); % Disable
status = read_subbus(s,ctr);
if bitand(status,1) == 1
  warning('Counter still enabled after disable');
end
%
write_subbus(s, ctr, hex2dec('8000')); % Reset
status = read_subbus(s,ctr);
if bitand(status,1) == 1
  warning('Counter still enabled after reset');
end

