# Chapter 7 — CPU Scheduling (FIFO / SJF / RR)

OSTEP 第 7 章课后模拟作业。使用 `ext/ostep-homework/cpu-sched/scheduler.py` 比较 FIFO、SJF、RR 三种调度器的平均响应时间和平均周转时间。

## 文件说明

| 路径 | 内容 |
|---|---|
| `analysis.md` | Q1–Q7 的书面答案：预测、理由、验证结果、分析 |
| `data/` | 33 份模拟器 `-c` 输出，每份第一行是对应的命令 |
| `run_all.sh` | 重新生成 `data/` 下全部输出的脚本 |

复现方法（在 Codespaces 根目录 `/workspaces/ostep-codespace-lab` 下执行）：

```bash
bash hw/chapter7/run_all.sh
```

## 主要结果

| 题目 | 负载 | 结论 |
|---|---|---|
| Q1 | 200, 200, 200 | FIFO = SJF：平均响应 200.00，平均周转 400.00 |
| Q2 | 100, 200, 300 | FIFO = SJF：平均响应 133.33，平均周转 333.33；反序到达时 FIFO 的平均周转升到 466.67（护航效应） |
| Q3 | 100, 200, 300，RR q=1 | 平均响应 1.00（最好），平均周转 465.67（最差） |
| Q4 | — | 到达顺序已经是从短到长（含等长）时，SJF 与 FIFO 的周转时间相同 |
| Q5 | — | RR 队列按从短到长排列，且 q ≥ 除最后一个作业外每个作业的长度时，RR 与 SJF 的响应时间相同 |
| Q6 | 等长 L × 3 | SJF 的平均响应时间 = L，随作业长度线性增长 |
| Q7 | 300 × 3，q = 1…500 | RR 的最坏响应时间 = (N−1)·q；q ≥ 作业长度后 RR 退化为 FIFO |

所有预测值都先手算，再用 `-c` 核对，33 组结果全部一致。
