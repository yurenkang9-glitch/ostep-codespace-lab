# OSTEP Ch.4 Homework Answers

表中每行表示一个 tick 执行时的状态；`*` 表示有 I/O 在该 tick 完成。CPU 列为空表示空闲；IOs 列为空表示没有进行中的 I/O。`RUN:io` 和 `RUN:io_done` 也使用 CPU。最后一条指令执行后进程才转为 DONE。以下使用默认 I/O 等待长度 5。

## Q1

- Prediction / 预测:

预测命令：`python3 process-run.py -l 5:100,5:100`。

```
Time  PID 0          PID 1          CPU   IOs
1     RUN:cpu        READY          1     
2     RUN:cpu        READY          1     
3     RUN:cpu        READY          1     
4     RUN:cpu        READY          1     
5     RUN:cpu        READY          1     
6     DONE           RUN:cpu        1     
7     DONE           RUN:cpu        1     
8     DONE           RUN:cpu        1     
9     DONE           RUN:cpu        1     
10    DONE           RUN:cpu        1     
```

预计 Total Time：10 ticks；CPU Busy：10 ticks，CPU 利用率：10/10 = 100.00%；IO Busy：0 ticks（0.00%）。

- Reasoning / 理由:

两个进程的指令都是 cpu。PID 0 连续运行 5 个 tick 后结束，PID 1 再运行 5 个 tick。没有 I/O 等待，所以 CPU 始终有工作，利用率是 100%。

## Q2

- Prediction / 预测:

预测命令：`python3 process-run.py -l 4:100,1:0`。

```
Time  PID 0          PID 1          CPU   IOs
1     RUN:cpu        READY          1     
2     RUN:cpu        READY          1     
3     RUN:cpu        READY          1     
4     RUN:cpu        READY          1     
5     DONE           RUN:io         1     
6     DONE           BLOCKED              1
7     DONE           BLOCKED              1
8     DONE           BLOCKED              1
9     DONE           BLOCKED              1
10    DONE           BLOCKED              1
11*   DONE           RUN:io_done    1     
```

预计 Total Time：11 ticks；CPU Busy：6 ticks，CPU 利用率：6/11 = 54.55%；IO Busy：5 ticks（45.45%）。

- Reasoning / 理由:

PID 0 先占用 CPU 4 个 tick，PID 1 在这期间处于 READY。PID 1 在 tick 5 发出 I/O，随后等待 5 个 tick，到 tick 11 执行 io_done。此时 PID 0 已结束，没有其他进程能利用等待时间，所以 CPU 空闲 5 个 tick。一次 I/O 包含 1 个发起 tick、5 个等待 tick 和 1 个完成指令 tick。

## Q3

- Prediction / 预测:

预测命令：`python3 process-run.py -l 1:0,4:100`。

```
Time  PID 0          PID 1          CPU   IOs
1     RUN:io         READY          1     
2     BLOCKED        RUN:cpu        1     1
3     BLOCKED        RUN:cpu        1     1
4     BLOCKED        RUN:cpu        1     1
5     BLOCKED        RUN:cpu        1     1
6     BLOCKED        DONE                 1
7*    RUN:io_done    DONE           1     
```

预计 Total Time：7 ticks；CPU Busy：6 ticks，CPU 利用率：6/7 = 85.71%；IO Busy：5 ticks（71.43%）。

- Reasoning / 理由:

把 I/O 进程放在前面后，它在 tick 1 发出 I/O。默认 SWITCH_ON_IO 允许 PID 1 在 tick 2—5 运行，将它的 4 个 CPU tick 和 I/O 等待重叠。tick 6 没有进程可运行，tick 7 执行 io_done。CPU 忙碌时间仍为 6 个 tick，总时间从 Q2 的 11 降为 7。

## Q4

- Prediction / 预测:

预测命令：`python3 process-run.py -l 1:0,4:100 -S SWITCH_ON_END`。

```
Time  PID 0          PID 1          CPU   IOs
1     RUN:io         READY          1     
2     BLOCKED        READY                1
3     BLOCKED        READY                1
4     BLOCKED        READY                1
5     BLOCKED        READY                1
6     BLOCKED        READY                1
7*    RUN:io_done    READY          1     
8     DONE           RUN:cpu        1     
9     DONE           RUN:cpu        1     
10    DONE           RUN:cpu        1     
11    DONE           RUN:cpu        1     
```

预计 Total Time：11 ticks；CPU Busy：6 ticks，CPU 利用率：6/11 = 54.55%；IO Busy：5 ticks（45.45%）。

- Reasoning / 理由:

SWITCH_ON_END 只在进程结束时切换。PID 0 等待 I/O 时，PID 1 虽然 READY，但不能使用 CPU，因此 tick 2—6 都空闲。PID 0 在 tick 7 执行 io_done 并结束后，PID 1 才能运行。总时间回到 11 个 tick。

## Q5

- Prediction / 预测:

预测命令：`python3 process-run.py -l 1:0,4:100 -S SWITCH_ON_IO`。

```
Time  PID 0          PID 1          CPU   IOs
1     RUN:io         READY          1     
2     BLOCKED        RUN:cpu        1     1
3     BLOCKED        RUN:cpu        1     1
4     BLOCKED        RUN:cpu        1     1
5     BLOCKED        RUN:cpu        1     1
6     BLOCKED        DONE                 1
7*    RUN:io_done    DONE           1     
```

预计 Total Time：7 ticks；CPU Busy：6 ticks，CPU 利用率：6/7 = 85.71%；IO Busy：5 ticks（71.43%）。

- Reasoning / 理由:

SWITCH_ON_IO 会在 PID 0 发出 I/O 后切换到 PID 1，使 4 个 CPU tick 与 I/O 等待重叠。结果应与 Q3 相同，总时间 7 个 tick，比 Q4 少 4 个 tick，CPU 利用率从 54.55% 提高到 85.71%。

## Q6

- Prediction / 预测:

预测命令：`python3 process-run.py -l 3:0,5:100,5:100,5:100 -S SWITCH_ON_IO -I IO_RUN_LATER`。

```
Time  PID 0          PID 1          PID 2          PID 3          CPU   IOs
1     RUN:io         READY          READY          READY          1     
2     BLOCKED        RUN:cpu        READY          READY          1     1
3     BLOCKED        RUN:cpu        READY          READY          1     1
4     BLOCKED        RUN:cpu        READY          READY          1     1
5     BLOCKED        RUN:cpu        READY          READY          1     1
6     BLOCKED        RUN:cpu        READY          READY          1     1
7*    READY          DONE           RUN:cpu        READY          1     
8     READY          DONE           RUN:cpu        READY          1     
9     READY          DONE           RUN:cpu        READY          1     
10    READY          DONE           RUN:cpu        READY          1     
11    READY          DONE           RUN:cpu        READY          1     
12    READY          DONE           DONE           RUN:cpu        1     
13    READY          DONE           DONE           RUN:cpu        1     
14    READY          DONE           DONE           RUN:cpu        1     
15    READY          DONE           DONE           RUN:cpu        1     
16    READY          DONE           DONE           RUN:cpu        1     
17    RUN:io_done    DONE           DONE           DONE           1     
18    RUN:io         DONE           DONE           DONE           1     
19    BLOCKED        DONE           DONE           DONE                 1
20    BLOCKED        DONE           DONE           DONE                 1
21    BLOCKED        DONE           DONE           DONE                 1
22    BLOCKED        DONE           DONE           DONE                 1
23    BLOCKED        DONE           DONE           DONE                 1
24*   RUN:io_done    DONE           DONE           DONE           1     
25    RUN:io         DONE           DONE           DONE           1     
26    BLOCKED        DONE           DONE           DONE                 1
27    BLOCKED        DONE           DONE           DONE                 1
28    BLOCKED        DONE           DONE           DONE                 1
29    BLOCKED        DONE           DONE           DONE                 1
30    BLOCKED        DONE           DONE           DONE                 1
31*   RUN:io_done    DONE           DONE           DONE           1     
```

预计 Total Time：31 ticks；CPU Busy：21 ticks，CPU 利用率：21/31 = 67.74%；IO Busy：15 ticks（48.39%）。

- Reasoning / 理由:

PID 0 的第一次 I/O 在 tick 7 完成，但 IO_RUN_LATER 只把它放回 READY，不立即抢占当前进程。PID 2、PID 3 先后运行，PID 0 到 tick 17 才执行第一次 io_done。tick 7—18 没有未完成的 I/O，之后另外两次 I/O 等待各造成 5 个 CPU 空闲 tick。CPU 总工作量为 15 个 cpu 加 3 个 io 和 3 个 io_done，共 21 个 tick；总时间预计为 31。

## Q7

- Prediction / 预测:

预测命令：`python3 process-run.py -l 3:0,5:100,5:100,5:100 -S SWITCH_ON_IO -I IO_RUN_IMMEDIATE`。

```
Time  PID 0          PID 1          PID 2          PID 3          CPU   IOs
1     RUN:io         READY          READY          READY          1     
2     BLOCKED        RUN:cpu        READY          READY          1     1
3     BLOCKED        RUN:cpu        READY          READY          1     1
4     BLOCKED        RUN:cpu        READY          READY          1     1
5     BLOCKED        RUN:cpu        READY          READY          1     1
6     BLOCKED        RUN:cpu        READY          READY          1     1
7*    RUN:io_done    DONE           READY          READY          1     
8     RUN:io         DONE           READY          READY          1     
9     BLOCKED        DONE           RUN:cpu        READY          1     1
10    BLOCKED        DONE           RUN:cpu        READY          1     1
11    BLOCKED        DONE           RUN:cpu        READY          1     1
12    BLOCKED        DONE           RUN:cpu        READY          1     1
13    BLOCKED        DONE           RUN:cpu        READY          1     1
14*   RUN:io_done    DONE           DONE           READY          1     
15    RUN:io         DONE           DONE           READY          1     
16    BLOCKED        DONE           DONE           RUN:cpu        1     1
17    BLOCKED        DONE           DONE           RUN:cpu        1     1
18    BLOCKED        DONE           DONE           RUN:cpu        1     1
19    BLOCKED        DONE           DONE           RUN:cpu        1     1
20    BLOCKED        DONE           DONE           RUN:cpu        1     1
21*   RUN:io_done    DONE           DONE           DONE           1     
```

预计 Total Time：21 ticks；CPU Busy：21 ticks，CPU 利用率：21/21 = 100.00%；IO Busy：15 ticks（71.43%）。

- Reasoning / 理由:

IO_RUN_IMMEDIATE 让 PID 0 在 I/O 完成时立即运行，随后尽快发出下一次 I/O。三次 I/O 等待分别与 PID 1、PID 2、PID 3 的 5 个 CPU tick 重叠。CPU 需要的工作量仍是 21 个 tick，但没有空闲 tick，因此总时间为 21，CPU 利用率是 100%。这种安排也能更早开始下一次 I/O。

## Q8

- Prediction / 预测:

对每个种子预测三种设置：默认（SWITCH_ON_IO、IO_RUN_LATER）、`-I IO_RUN_IMMEDIATE`、`-S SWITCH_ON_END`。

### Seed 1

PID 0：cpu → io → io_done → io → io_done。

PID 1：cpu → cpu → cpu。

#### default

```
Time  PID 0          PID 1          CPU   IOs
1     RUN:cpu        READY          1     
2     RUN:io         READY          1     
3     BLOCKED        RUN:cpu        1     1
4     BLOCKED        RUN:cpu        1     1
5     BLOCKED        RUN:cpu        1     1
6     BLOCKED        DONE                 1
7     BLOCKED        DONE                 1
8*    RUN:io_done    DONE           1     
9     RUN:io         DONE           1     
10    BLOCKED        DONE                 1
11    BLOCKED        DONE                 1
12    BLOCKED        DONE                 1
13    BLOCKED        DONE                 1
14    BLOCKED        DONE                 1
15*   RUN:io_done    DONE           1     
```

预计 Total Time：15 ticks；CPU Busy：8 ticks，CPU 利用率：8/15 = 53.33%；IO Busy：10 ticks（66.67%）。

#### -I IO_RUN_IMMEDIATE

```
Time  PID 0          PID 1          CPU   IOs
1     RUN:cpu        READY          1     
2     RUN:io         READY          1     
3     BLOCKED        RUN:cpu        1     1
4     BLOCKED        RUN:cpu        1     1
5     BLOCKED        RUN:cpu        1     1
6     BLOCKED        DONE                 1
7     BLOCKED        DONE                 1
8*    RUN:io_done    DONE           1     
9     RUN:io         DONE           1     
10    BLOCKED        DONE                 1
11    BLOCKED        DONE                 1
12    BLOCKED        DONE                 1
13    BLOCKED        DONE                 1
14    BLOCKED        DONE                 1
15*   RUN:io_done    DONE           1     
```

预计 Total Time：15 ticks；CPU Busy：8 ticks，CPU 利用率：8/15 = 53.33%；IO Busy：10 ticks（66.67%）。

#### -S SWITCH_ON_END

```
Time  PID 0          PID 1          CPU   IOs
1     RUN:cpu        READY          1     
2     RUN:io         READY          1     
3     BLOCKED        READY                1
4     BLOCKED        READY                1
5     BLOCKED        READY                1
6     BLOCKED        READY                1
7     BLOCKED        READY                1
8*    RUN:io_done    READY          1     
9     RUN:io         READY          1     
10    BLOCKED        READY                1
11    BLOCKED        READY                1
12    BLOCKED        READY                1
13    BLOCKED        READY                1
14    BLOCKED        READY                1
15*   RUN:io_done    READY          1     
16    DONE           RUN:cpu        1     
17    DONE           RUN:cpu        1     
18    DONE           RUN:cpu        1     
```

预计 Total Time：18 ticks；CPU Busy：8 ticks，CPU 利用率：8/18 = 44.44%；IO Busy：10 ticks（55.56%）。

### Seed 2

PID 0：io → io_done → io → io_done → cpu。

PID 1：cpu → io → io_done → io → io_done。

#### default

```
Time  PID 0          PID 1          CPU   IOs
1     RUN:io         READY          1     
2     BLOCKED        RUN:cpu        1     1
3     BLOCKED        RUN:io         1     1
4     BLOCKED        BLOCKED              2
5     BLOCKED        BLOCKED              2
6     BLOCKED        BLOCKED              2
7*    RUN:io_done    BLOCKED        1     1
8     RUN:io         BLOCKED        1     1
9*    BLOCKED        RUN:io_done    1     1
10    BLOCKED        RUN:io         1     1
11    BLOCKED        BLOCKED              2
12    BLOCKED        BLOCKED              2
13    BLOCKED        BLOCKED              2
14*   RUN:io_done    BLOCKED        1     1
15    RUN:cpu        BLOCKED        1     1
16*   DONE           RUN:io_done    1     
```

预计 Total Time：16 ticks；CPU Busy：10 ticks，CPU 利用率：10/16 = 62.50%；IO Busy：14 ticks（87.50%）。

#### -I IO_RUN_IMMEDIATE

```
Time  PID 0          PID 1          CPU   IOs
1     RUN:io         READY          1     
2     BLOCKED        RUN:cpu        1     1
3     BLOCKED        RUN:io         1     1
4     BLOCKED        BLOCKED              2
5     BLOCKED        BLOCKED              2
6     BLOCKED        BLOCKED              2
7*    RUN:io_done    BLOCKED        1     1
8     RUN:io         BLOCKED        1     1
9*    BLOCKED        RUN:io_done    1     1
10    BLOCKED        RUN:io         1     1
11    BLOCKED        BLOCKED              2
12    BLOCKED        BLOCKED              2
13    BLOCKED        BLOCKED              2
14*   RUN:io_done    BLOCKED        1     1
15    RUN:cpu        BLOCKED        1     1
16*   DONE           RUN:io_done    1     
```

预计 Total Time：16 ticks；CPU Busy：10 ticks，CPU 利用率：10/16 = 62.50%；IO Busy：14 ticks（87.50%）。

#### -S SWITCH_ON_END

```
Time  PID 0          PID 1          CPU   IOs
1     RUN:io         READY          1     
2     BLOCKED        READY                1
3     BLOCKED        READY                1
4     BLOCKED        READY                1
5     BLOCKED        READY                1
6     BLOCKED        READY                1
7*    RUN:io_done    READY          1     
8     RUN:io         READY          1     
9     BLOCKED        READY                1
10    BLOCKED        READY                1
11    BLOCKED        READY                1
12    BLOCKED        READY                1
13    BLOCKED        READY                1
14*   RUN:io_done    READY          1     
15    RUN:cpu        READY          1     
16    DONE           RUN:cpu        1     
17    DONE           RUN:io         1     
18    DONE           BLOCKED              1
19    DONE           BLOCKED              1
20    DONE           BLOCKED              1
21    DONE           BLOCKED              1
22    DONE           BLOCKED              1
23*   DONE           RUN:io_done    1     
24    DONE           RUN:io         1     
25    DONE           BLOCKED              1
26    DONE           BLOCKED              1
27    DONE           BLOCKED              1
28    DONE           BLOCKED              1
29    DONE           BLOCKED              1
30*   DONE           RUN:io_done    1     
```

预计 Total Time：30 ticks；CPU Busy：10 ticks，CPU 利用率：10/30 = 33.33%；IO Busy：20 ticks（66.67%）。

### Seed 3

PID 0：cpu → io → io_done → cpu。

PID 1：io → io_done → io → io_done → cpu。

#### default

```
Time  PID 0          PID 1          CPU   IOs
1     RUN:cpu        READY          1     
2     RUN:io         READY          1     
3     BLOCKED        RUN:io         1     1
4     BLOCKED        BLOCKED              2
5     BLOCKED        BLOCKED              2
6     BLOCKED        BLOCKED              2
7     BLOCKED        BLOCKED              2
8*    RUN:io_done    BLOCKED        1     1
9*    RUN:cpu        READY          1     
10    DONE           RUN:io_done    1     
11    DONE           RUN:io         1     
12    DONE           BLOCKED              1
13    DONE           BLOCKED              1
14    DONE           BLOCKED              1
15    DONE           BLOCKED              1
16    DONE           BLOCKED              1
17*   DONE           RUN:io_done    1     
18    DONE           RUN:cpu        1     
```

预计 Total Time：18 ticks；CPU Busy：9 ticks，CPU 利用率：9/18 = 50.00%；IO Busy：11 ticks（61.11%）。

#### -I IO_RUN_IMMEDIATE

```
Time  PID 0          PID 1          CPU   IOs
1     RUN:cpu        READY          1     
2     RUN:io         READY          1     
3     BLOCKED        RUN:io         1     1
4     BLOCKED        BLOCKED              2
5     BLOCKED        BLOCKED              2
6     BLOCKED        BLOCKED              2
7     BLOCKED        BLOCKED              2
8*    RUN:io_done    BLOCKED        1     1
9*    READY          RUN:io_done    1     
10    READY          RUN:io         1     
11    RUN:cpu        BLOCKED        1     1
12    DONE           BLOCKED              1
13    DONE           BLOCKED              1
14    DONE           BLOCKED              1
15    DONE           BLOCKED              1
16*   DONE           RUN:io_done    1     
17    DONE           RUN:cpu        1     
```

预计 Total Time：17 ticks；CPU Busy：9 ticks，CPU 利用率：9/17 = 52.94%；IO Busy：11 ticks（64.71%）。

#### -S SWITCH_ON_END

```
Time  PID 0          PID 1          CPU   IOs
1     RUN:cpu        READY          1     
2     RUN:io         READY          1     
3     BLOCKED        READY                1
4     BLOCKED        READY                1
5     BLOCKED        READY                1
6     BLOCKED        READY                1
7     BLOCKED        READY                1
8*    RUN:io_done    READY          1     
9     RUN:cpu        READY          1     
10    DONE           RUN:io         1     
11    DONE           BLOCKED              1
12    DONE           BLOCKED              1
13    DONE           BLOCKED              1
14    DONE           BLOCKED              1
15    DONE           BLOCKED              1
16*   DONE           RUN:io_done    1     
17    DONE           RUN:io         1     
18    DONE           BLOCKED              1
19    DONE           BLOCKED              1
20    DONE           BLOCKED              1
21    DONE           BLOCKED              1
22    DONE           BLOCKED              1
23*   DONE           RUN:io_done    1     
24    DONE           RUN:cpu        1     
```

预计 Total Time：24 ticks；CPU Busy：9 ticks，CPU 利用率：9/24 = 37.50%；IO Busy：15 ticks（62.50%）。

预测统计汇总：

| Seed | 设置 | 总时间 | CPU Busy | CPU 利用率 |
| --- | --- | ---: | ---: | ---: |
| 1 | default | 15 | 8 | 53.33% |
| 1 | -I IO_RUN_IMMEDIATE | 15 | 8 | 53.33% |
| 1 | -S SWITCH_ON_END | 18 | 8 | 44.44% |
| 2 | default | 16 | 10 | 62.50% |
| 2 | -I IO_RUN_IMMEDIATE | 16 | 10 | 62.50% |
| 2 | -S SWITCH_ON_END | 30 | 10 | 33.33% |
| 3 | default | 18 | 9 | 50.00% |
| 3 | -I IO_RUN_IMMEDIATE | 17 | 9 | 52.94% |
| 3 | -S SWITCH_ON_END | 24 | 9 | 37.50% |

- Reasoning / 理由:

Seed 1：PID 1 的 3 条 CPU 指令在 PID 0 第一次 I/O 等待期间就结束了。因此默认设置和立即运行设置应相同。SWITCH_ON_END 不允许这段重叠，预计增加 3 个 tick，总时间从 15 变为 18。

Seed 2：默认设置下，两进程的 I/O 等待可以重叠。预计 I/O 完成的 tick 为 7、9、14、16，此时另一个进程没有正在执行的 CPU 指令，所以 IO_RUN_IMMEDIATE 不改变安排，仍需 16 个 tick。SWITCH_ON_END 让两个进程依次完成，各自需 15 个 tick，总时间为 30。

Seed 3：tick 9，PID 1 的第一次 I/O 完成。默认设置让 PID 0 先执行最后一条 cpu，PID 1 到 tick 11 才发出第二次 I/O。立即运行设置在 tick 9 让 PID 1 执行 io_done，tick 10 发出下一次 I/O，再让 PID 0 在 tick 11 执行最后一条 cpu。这样第二次 I/O 提前 1 个 tick 开始，总时间预计从 18 降到 17。SWITCH_ON_END 不能重叠两个进程的工作，预计需 24 个 tick。

因此，SWITCH_ON_IO 可以用其他进程的计算填补 I/O 等待；IO_RUN_IMMEDIATE 有时能更快发起下一次 I/O，但是否改善总时间取决于实际指令和完成时机。
