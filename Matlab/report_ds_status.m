function report_ds_status(status)
  if status == 0
    fprintf(1,'Idle\n');
  elseif status == 1
    fprintf(1, 'Scanning\n');
  elseif status == 2
    fprintf(1, 'Online\n');
  elseif status == 4
    fprintf(1, 'Offline\n');
  else
    fprintf(1, 'Unknown: %04X\n', status);
  end
