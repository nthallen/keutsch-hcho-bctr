#! /bin/bash
perl -pi -e \
  's/^ *(FOR ALL : .* USE ENTITY BCtr_lib)/-- $1/; s/^(LIBRARY BCtr_lib)/-- $1/; s/^( *USE BCtr_lib)/-- $1/;' \
  *_struct.vhd \
  bctr_syscon_wrapper_tb_tb_rtl.vhd

