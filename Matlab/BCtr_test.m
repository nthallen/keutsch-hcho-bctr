%%
%%
serial_port_clear();
%%
[s,port] = serial_port_init();
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
% bin_NA = [10,1,200];
% bin_NB = [1,35,1];
bin_NA = [1,5,200];
bin_NB = [45,40,1];
% bin_NA = [35];
% bin_NB = [2];
NC = 300000;
Nsamples = 600;
for i=1:length(bin_NA)
  write_subbus(s, ctr+1+2*i, bin_NA(i));
  write_subbus(s, ctr+2+2*i, bin_NB(i));
end
write_subbus(s, ctr+11, mod(NC,65536));
write_subbus(s, ctr+12, floor(NC/65536));
status = read_subbus(s, ctr);
if status ~= 32
  error('Counter not ready after init');
end
NBtotal = sum(bin_NB);
exp_ct = NBtotal*NChannels+1;
rm_obj = read_multi_prep([exp_ct ctr+2]);
rm_obj2 = read_multi_prep(ctr, [ctr+1,exp_ct,ctr+2,0]);
Nsave = 1000;
NSk = NaN*zeros(Nsave,1);
Cts = NaN*zeros(Nsave,NBtotal*NChannels);
Nsampled = 0;
%% ACQUISITION using ORIGINAL SYNTAX
write_subbus(s, ctr, 1); % Enable
%
while Nsampled < Nsamples
  status = read_subbus(s,ctr);
  while bitand(status,2) == 0
    if bitand(status,1) == 0
      error('Counter not enabled');
    end
    status = read_subbus(s,ctr);
  end
  NB_rpt = read_subbus(s,ctr+1);
  if NB_rpt ~= exp_ct
    error(sprintf('Receipt NB_rpt %d, expected %d', NB_rpt, exp_ct));
  end
  [values,ack] = read_multi(s,rm_obj);
  if ack == 1
    Nsampled = Nsampled+1;
    NSk(Nsampled) = values(1);
    Cts(Nsampled,:) = values(2:end)';
    fprintf(1,'Nsample = %d\n', Nsampled);
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
    if bitand(status,2) == 1 && NB_rpt ~= exp_ct
      warning('NB_rpt = %d, exp_ct = %d', NB_rpt, exp_ct);
    elseif bitand(status,2) == 0 && NB_rpt ~= 0
      warning('!DRdy + NB_rpt = %d', NB_rpt);
    end
    if NB_rpt == exp_ct
      Nsampled = Nsampled+1;
      NSk(Nsampled) = values(3);
      Cts(Nsampled,:) = values(4:end)';
      fprintf(1,'Nsample = %d\n', Nsampled);
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
%%
write_subbus(s, ctr, hex2dec('8000')); % Reset
status = read_subbus(s,ctr);
if bitand(status,1) == 1
  warning('Counter still enabled after reset');
end
%%
Channel = 2; % 1 or 2
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
%%
figure;
t0 = 0; % In time units
b0 = 0; % In bin resolution units
bin_num = 0;
dt = 10e-9;
normal_width = 350e-9;
for i=1:length(bin_NA)
  for j = 1:bin_NB(i)
    bin_num = bin_num+1;
    b1 = b0 + bin_NA(i);
    t1 = t0 + bin_NA(i)*dt;
    bin_scale = normal_width/(t1-t0);
    bin_mean = mean(Cts(1:Nsampled,bin_num*NChannels+Channel-2))*bin_scale;
    bin_std = std(Cts(1:Nsampled,bin_num*NChannels+Channel-2))*bin_scale;
    mdl_mean = mean(S((b0+1):b1))*normal_width/dt;
    t01 = (t0+t1)/2;
    plot(t01, bin_mean, '*r', t01, mdl_mean, 'xb', ...
      [t0 t1], bin_mean*[1 1], '-k', ...
      t01*[1 1], bin_mean+bin_std*[-1 1], '-k');
    hold on;
    t0 = t1;
    b0 = b1;
  end
end
hold off;
title('Normalized count rates');
%%
hold on
plot(T,S*normal_width/dt,'-b');
hold off;
shg
%%
