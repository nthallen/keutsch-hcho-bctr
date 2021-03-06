#! /bin/bash
H=../../HDS/BCtr/BCtr_lib/hdl

for i in *.vhd *.vhdl; do
  echo
  echo $i
  if [ -f $H/$i ]; then
    diff -b $H/$i $i | grep "^[<>] *[^- ]" | grep -v BCtr_lib
  else
    echo "  $H/$i not found"
  fi
done | less
