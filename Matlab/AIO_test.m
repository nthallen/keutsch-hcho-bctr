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
serial_port_clear;
