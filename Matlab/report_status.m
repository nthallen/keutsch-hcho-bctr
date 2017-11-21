function st_out = report_status(status)
  st.en = bitand(status,1) > 0;
  st.drdy = bitand(status,2) > 0;
  st.tx = bitand(status,4) > 0;
  st.config_err_ovf = bitand(status,8) > 0;
  st.config_err_nab = bitand(status,16) > 0;
  st.ready = bitand(status,32) > 0;
  st.N_NAB = bitand(status,7*64)/64;
  st.tx_err_ovf = bitand(status,512) > 0;
  st.expired = bitand(status,1024) > 0;
  fprintf(1,'En:%d DRdy:%d Exp:%d Rdy:%d Tx:%d\n', ...
    st.en, st.drdy, st.expired, st.ready, st.tx);
  fprintf(1,'  cfg_ovf:%d cfg_nab:%d tx_ovf:%d N_NAB:%d\n', ...
    st.config_err_ovf, st.config_err_nab, st.tx_err_ovf, st.N_NAB);
  if nargout > 0
    st_out = st;
  end
