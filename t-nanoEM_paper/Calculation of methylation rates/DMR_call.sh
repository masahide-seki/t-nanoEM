#!/bin/sh

IN1=$1
IN2=$2
NAME1=$3
NAME2=$4

perl metilene_input.pl --in1 $IN1 --in2 $IN2 -h1 $NAME1 -h2 $NAME2 -o ${NAME1}_${NAME2}.input
metilene_linux64 -a $NAME1 -b $NAME2 ${NAME1}_${NAME2}.input > ${NAME1}_${NAME2}.output
perl metilene_output.pl -q ${NAME1}_${NAME2}.output -o ${NAME1}_${NAME2}.filtered.output -a $NAME1 -b $$NAME2 -p 0.01