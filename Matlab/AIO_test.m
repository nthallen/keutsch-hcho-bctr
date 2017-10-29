%%
[s,port] = serial_port_init;
s.baudrate = 115200;
%%
aio_base = hex2dec('50');
mr_obj = read_multi_prep([aio_base,1,aio_base+6]);
%%
values = read_multi(s,mr_obj);
fprintf(1,'Status: %03X\nDAC1 SP: %d  RB: %d\nDAC2 SP: %d  RB: %d\nADC1: %d\nADC2: %d\n', ...
  values);
%%
Status = read_subbus(s,aio_base);
mask = hex2dec('20');
cmd = mask;
write_subbus(s, aio_base, cmd); % htr1 on, htr2 off
while (bitand(Status,mask) ~= cmd)
  Status = read_subbus(s,aio_base);
end

%% Set DAC1 Setpoint
write_subbus(s, aio_base+1, 4*16384-1);
%% Set DAC1 Setpoint
write_subbus(s, aio_base+3, 1000);
%%
SPs = 0:10:65535;
Vset = zeros(size(SPs));
VRB = zeros(size(SPs));
for i = 1:length(SPs)
  SP = SPs(i);
  % fprintf(1,'SP = %d\n', SP);
  Vset(i) = SP*5/65536;
  write_subbus(s, aio_base+1, SP);
  done = 0;
  while done == 0
    values = read_multi(s,mr_obj);
    if (values(2)) == SP && (values(3) == SP)
      done = 1;
    % else
      % fprintf(1, 'values(2) = %d values(3) = %d\n', values(2), values(3));
    end
  end
  pause(.02);
  temp1 = read_subbus(s, aio_base+5);
  VRB(i) = 6.144 * temp1/32768;
  fprintf(1,'i=%d SP = %d Vset = %.3f Vtemp = %.3f\n', i, SP, Vset(i), VRB(i));
  % pause(1);
end
%%
SPs = 0:100:65535;
chan = 2;
D = AIO_ramp(s,chan,SPs);
SPs = 65535:-100:0;
D2 = AIO_ramp(s,chan,SPs);
%
V = D.Vset < 4.82;
V2 = D2.Vset < 4.82;
figure;
plot(D.Vset(V),D.VRB(V)-D.Vset(V),'.',D2.Vset(V2),D2.VRB(V2)-D2.Vset(V2),'.');
title(sprintf('Channel %d', chan));
ylabel('dV V'); xlabel('Setpoint V');
%%
serial_port_clear;
