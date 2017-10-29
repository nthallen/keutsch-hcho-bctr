function D = AIO_ramp(s, chan, SPs)
  % D = AIO_Ramp(s, chan, SPs);
  % serial port object
  % chan: 1 or 2
  % SPs: vector of setpoint digital values from 0 to 65535
  % Steps through all the setpoints and reads back from the A/D
  if chan ~= 1 && chan ~= 2
    error('chan must be 1 or 2');
  end
  aio_base = hex2dec('50');
  sp_addr = aio_base + 2*chan - 1;
  sp_offset = 2*chan;
  rb_addr = aio_base+4+chan;
  mr_obj = read_multi_prep([aio_base,1,aio_base+6]);
  D.SPs = SPs;
  D.Vset = zeros(size(SPs));
  D.VRB = zeros(size(SPs));
  D.T(length(SPs)) = now;
  for i = 1:length(SPs)
    SP = SPs(i);
    % fprintf(1,'SP = %d\n', SP);
    D.Vset(i) = SP*5/65536;
    D.T(i) = now;
    write_subbus(s, sp_addr, SP);
    done = 0;
    while done == 0
      values = read_multi(s,mr_obj);
      if (values(sp_offset)) == SP && (values(sp_offset+1) == SP)
        done = 1;
        % else
        % fprintf(1, 'values(2) = %d values(3) = %d\n', values(2), values(3));
      end
    end
    pause(.02);
    temp1 = read_subbus(s, rb_addr);
    D.VRB(i) = 6.144 * temp1/32768;
    fprintf(1,'i=%d SP = %d Vset = %.3f Vtemp = %.3f\n', i, SP, D.Vset(i), D.VRB(i));
    % pause(1);
  end
