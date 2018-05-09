function report_ds_status(s, addr)
  status = read_subbus(s, addr);
  value = read_subbus(s, addr+1);
  if status == 0
    fprintf(1,'Idle\n');
  elseif status == 1
    fprintf(1, 'Scanning: %d\n', value);
  elseif status == 2
    fprintf(1, 'Online: %d\n', value);
  elseif status == 4
    fprintf(1, 'Offline: %d\n', value);
  else
    fprintf(1, 'Unknown: %04X\n', status);
  end
