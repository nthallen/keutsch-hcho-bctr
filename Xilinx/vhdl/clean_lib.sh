#! /bin/bash
perl -pi -e 's/^ *(FOR ALL : .* USE ENTITY BCtr_lib)/-- $1/; s/^(LIBRARY BCtr_lib)/-- $1/' *_struct.vhd
