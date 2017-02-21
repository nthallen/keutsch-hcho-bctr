%%
[s,port] = serial_port_init;
s.baudrate = 115200;
%%
addr = hex2dec('30');
for i=0:5
  [value,ack] = read_subbus(s,addr+3*i);
  if ack == 0
    fprintf(1,'No ack from address %s\n', dec2hex(addr+3*i));
  else
    if value > 0
      lsb = read_subbus(s, addr+3*i+1);
      msb = read_subbus(s, addr+3*i+2);
      avg = (msb*65536+lsb)/value;
      volts = 1.25 * avg/8388608.;
      fprintf(1, '%02X: %d %.1f %.2f\n', addr+3*i, value, avg, volts);
    end
  end
end
%%
base = hex2dec('3C');
fullscale = hex2dec('40000000'); % 2^30
Rpu = 1e6;
A = [
  7.15448802908256e-04
  2.17615226269624e-04
  8.69738956668552e-08
];

rm_obj = read_multi_prep([base,1,base+2]);
for i=1:10
  [vals,ack] = read_multi(s, rm_obj);
  if vals(1) > 0
    avg = (vals(3)*65536+vals(2))/vals(1);
    volts = 1.25 * avg/fullscale; % 8388608.;
    Rth = Rpu*avg/(2^31-avg);
    T = SteinHart(Rth,A)-273.15;
    fprintf(1, '%d: %04X %04X %.1f %.7f V %.1f Ohms %.5f C\n', ...
      vals(1), vals(3), vals(2), avg, volts, Rth, T);
  end
  pause(1);
end
%%
serial_port_clear;
%%
raw = hex2dec('0C9F346F');
raw7 = 7*raw;
raw8 = 8*raw;
fprintf(1,'7: %X\n', raw7);
fprintf(1,'8: %X\n', raw8);
%%
fullscale = hex2dec('40000000');
fprintf(1,'Full Scale = %d\n',fullscale);
