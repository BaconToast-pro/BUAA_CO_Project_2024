# 北航计算机组成 CO 2024
## 写在前面（请注意！！！）
该项目所有的源代码（`.circ`、`.v`和`.asm`文件）**禁止抄袭**。

北航计算机组成课程组对抄袭零容忍，代码查重包括课上课下，同届学生代码以及往届学生的代码，一旦发现抄袭作弊将实验部分成绩记零以及取消下次上机资格。

请对自己负责，**不要质疑学院制裁抄袭的决心，更不要挑战学院制裁抄袭的决心！** 如有学术不端相关问题，请联系笔者删除 zhouzq@buaa.edu.cn
## 该项目有什么内容
BaconToast 整理了 2024 秋北航计组实验课程历次 Project 的相关工作，包括设计文档、源代码、MIPS 指令集原英文文档、课程组魔改版 Mars 和辅助小工具等。

CO 历次项目内容如下：

- **Pre**：自学 Pre 部分，即 Logisim、ISE、Mars 三大件的使用，适应上机环境；
- **P0**：学习电路模拟软件 Logisim 的使用；
- **P1**：学习硬件描述语言 Verilog 的编写；
- **P2**：学习汇编语言 MIPS 的编写；
- **P3**：使用 Logisim 搭建单周期 CPU；
- **P4**：使用 Verilog 搭建单周期 CPU；
- **P5**：使用 Verilog 搭建流水线 CPU （初级，相比于单周期需要增加针对冒险的阻塞和转发）；
- **P6**：使用 Verilog 搭建流水线 CPU （扩充，相比于 P5 增加了乘除指令和按字节访存指令）；
- **P7**：实现 MIPS 微系统（增加异常中断处理、系统桥和外设等）。

**一句话课程目标**：最终实现 MIPS 架构的五级流水线 CPU ，模拟微系统的行为，支持以下指令：
```MIPS
add, sub, and, or, slt, sltu, lui
addi, andi, ori
lb, lh, lw, sb, sh, sw
mult, multu, div, divu, mfhi, mflo, mthi, mtlo
beq, bne, jal, jr
mfc0, mtc0, syscall
```

## 该项目有什么空白
直到最后一次上机结束，BaconToast 仅通过了 P6 课上而已，P7 课下已通过，但由于时间原因仅通过弱测，因此该项目给出的 P7 代码有一些 bug ，设计文档中给出了一个相对较强的测试数据，大家可以参考。

其次，目前该项目只包含计组实验部分，也许未来 BaconToast 会加入计组理论部分。
## 关于小工具
`code2Mips.c` 是 BaconToast 编写的 C 语言小工具，用于将十六进制机器码转为 MIPS 汇编代码，支持 P7 的所有指令。简而言之，相当于 Mars 导出机器码的逆操作。运行时输入待转机器码文件的路径，以及目标 `.asm` 文件路径即可。
## 最后
祝大家 CO 快乐！附最终设计图：

[![pALStbT.png](https://s21.ax1x.com/2024/12/16/pALStbT.png)](https://imgse.com/i/pALStbT)
