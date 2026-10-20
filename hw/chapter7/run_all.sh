#!/usr/bin/env bash
# Chapter 7 (CPU Scheduling) — 运行全部验证命令，把 -c 输出保存到 data/
# 用法（在 Codespaces 根目录 /workspaces/ostep-codespace-lab 下）：
#   bash hw/chapter7/run_all.sh
set -euo pipefail
cd "$(dirname "$0")/../.."
SIM=./ext/ostep-homework/cpu-sched/scheduler.py
OUT=hw/chapter7/data
mkdir -p "$OUT"

run() {  # run <输出文件名> <scheduler.py 参数...>
  local name=$1; shift
  { echo "\$ python3 $SIM $* -c"; python3 "$SIM" "$@" -c; } > "$OUT/$name"
}

# Q1：三个长度 200 的作业，FIFO 与 SJF
run q1_fifo.txt -l 200,200,200 -p FIFO
run q1_sjf.txt  -l 200,200,200 -p SJF

# Q2：长度 100, 200, 300，FIFO 与 SJF；补充：反序到达 300, 200, 100
run q2_fifo.txt         -l 100,200,300 -p FIFO
run q2_sjf.txt          -l 100,200,300 -p SJF
run q2_reverse_fifo.txt -l 300,200,100 -p FIFO
run q2_reverse_sjf.txt  -l 300,200,100 -p SJF

# Q3：在 Q2 的基础上加入 RR（时间片 1）；补充：Q1 的等长负载
run q3_rr.txt       -l 100,200,300 -p RR -q 1
run q3_rr_equal.txt -l 200,200,200 -p RR -q 1

# Q4：到达顺序不是“短作业在前”时，SJF 与 FIFO 的周转时间不同
run q4_unsorted_fifo.txt -l 300,100,200 -p FIFO
run q4_unsorted_sjf.txt  -l 300,100,200 -p SJF

# Q5：SJF 与 RR 的响应时间
run q5_sjf.txt          -l 100,200,300 -p SJF
run q5_rr_q100.txt      -l 100,200,300 -p RR -q 100
run q5_rr_q200.txt      -l 100,200,300 -p RR -q 200
run q5_rr_q300.txt      -l 100,200,300 -p RR -q 300
run q5_equal_sjf.txt    -l 200,200,200 -p SJF
run q5_equal_rr_q100.txt -l 200,200,200 -p RR -q 100
run q5_equal_rr_q200.txt -l 200,200,200 -p RR -q 200

# Q6：作业变长时 SJF 的响应时间
for L in 100 200 300 400 500; do
  run "q6_sjf_${L}x3.txt" -l "$L,$L,$L" -p SJF
done
run q6_sjf_scaled_x2.txt  -l 200,400,600    -p SJF
run q6_sjf_scaled_x10.txt -l 1000,2000,3000 -p SJF

# Q7：时间片变大时 RR 的响应时间；最坏响应时间公式
for Q in 1 10 50 100 200 300 500; do
  run "q7_rr_q${Q}.txt" -l 300,300,300 -p RR -q "$Q"
done
run q7_rr_n5_q50.txt  -l 300,300,300,300,300 -p RR -q 50
run q7_rr_mixed_q200.txt -l 100,300,300 -p RR -q 200

echo "done: $(ls "$OUT" | wc -l) files in $OUT"
