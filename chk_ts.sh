#! /bin/bash

function nl_error {
  echo "chk: $*" >&2
  exit 1
}

files="temp_top temp_avg temp_addr temp_acquire temp_i2c i2c_master_top
i2c_master_byte_ctrl i2c_master_bit_ctrl temp_i2c_mid temp_i2c_top"

lcldir=HDS/BCtr/BCtr_lib/hdl
rmtdir=/home/nort/SW/arp-fpga/syscon_usb/idx_fpga/idx_fpga_lib/hdl

echo "< rmtdir: $rmtdir"
echo "> lcldir: $lcldir"
echo

for base in $files; do
  path=''
  for alt in $lcldir/$base*.vhd $lcldir/$base*.vhdl; do
    # echo "$base: Considering $alt"
    if [ -f $alt ]; then
      # [ -n "$path" ] && nl_error "base '$base' matched '$path' and '$alt'"
      # echo "$base: $alt is file"
      path=$alt
      filename=${path#$lcldir/}
      if [ -f $rmtdir/$filename ]; then
        echo
        echo "$filename:"
        diff -b $rmtdir/$filename $path | grep "^[<>] *[^- ]"
        # echo "Compare $path $rmtdir/$filename"
      else
        echo "Could not locate target file '$filename'" >&2
      fi
    fi
  done
  [ -n "$path" ] || nl_error "base '$base' matched nothing"
done
