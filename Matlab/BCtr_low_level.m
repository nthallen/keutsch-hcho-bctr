%% This is a low-level checkout
serial_port_clear();
%%
[s,port] = serial_port_init();
set(s,'BaudRate',115200);
%%
ctr = 32;
%%
[value,ack] = read_subbus(s,0);
if ack
  warning('Permanent Ackhowledge');
end
%%
build = read_subbus(s,2)
InstID = read_subbus(s,3)
