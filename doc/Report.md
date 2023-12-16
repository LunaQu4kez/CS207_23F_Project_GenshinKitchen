# CS207课程项目GenshinKitchen报告

## 团队分工

| 学号     | 姓名   | 分工                              | 贡献比 |
| -------- | ------ | --------------------------------- | ------ |
| 12211026 | 冯秋皓 | 报告攥写、项目测试                | 33.33% |
| 12211655 | 于斯瑶 | 手动模式、算法设计                | 33.33% |
| 12110120 | 赵钊   | 脚本模式及异常处理、项目架构、VGA | 33.33% |

## 计划日程安排和实施情况

11.06 project发布
11.06-13 熟悉文档和project内容
11.13 project文档更新
11.13-15 设计project架构
11.15 架构试验
11.15 分配任务，手动模式和脚本模式同时开始
11.19 优化架构
11.24 完成基础脚本模式
11.27 添加reset功能
11.28 完成手动模式
11.29 发布评分标准
11.29 再次优化架构
12.01 完成脚本模式异常处理
12.05 完成VGA


## 系统功能列表
系统分为自动模式和手动模式
### 自动模式
自动模式允许你载入一段已经编写好的符合规范的脚本，将脚本编译为对应的二进制编码后可直接运行，系统将自动完成脚本指定的所有操作。
### 手动模式
手动模式下，玩家可以通过操作开发板来完成一系列操作，通过控制开发板上的按钮与按键，实现target的转移和各种与target的交互。

## 系统使用说明
系统使用说明将分别从自动模式和手动模式两方面进行。
### 自动模式
![picture](/pic/script_mode_descript.png "script_mode_descript")
如图所示，若需要开启自动模式，需要将拨码开关SW6调至高电平，如果在开始前，厨房中非食材区存在物品，需要开启SW5以处理这些物品，避免引发错误。调整完毕后按下S2按钮即可开始脚本的运行。脚本运行过程中，八段数码显示管会显示当前状态的脚本内容，而LD1的八个LED灯则是显示目前的自动机状态，该功能仅为debug使用。

### 手动模式


## 系统结构说明



## 子模块功能说明
本部分将说明所有新增模块的功能和输入输出规格，demo中已给出的模块不作说明，出现多次的
输入输出仅作一次说明
### Automatic
    module Automatic (  
        input [0:0] clk,
        input [7:0] out_bits,//输出信号
        input [15:0] script,//脚本信号
        input [4:0] btn,//按钮绑定
        input [7:0] switch,//开关绑定
        output reg [7:0] pc,//左边八位LED灯，显示脚本储存地址
        output reg [7:0] in_bits,//八段数码显示管，显示16个0-1信号
        output [0:0] rst,//复位信号输出
        output [7:0] state_auto//自动模式状态输出
    );
该模块实现了自动模式（脚本模式）下的一个有限状态自动机。将对应开关调整到自动模式后，该模块将被启用。按下开始按钮后，有限状态自动机启动，并将读取到的脚本信号接收，设置相对应的next_state，进入choose阶段，根据脚本信号分别执行指向并交互，等待等操作，如此往复，直到接收到endgame指令，游戏结束。
此外，如果初始厨房为随机厨房，在执行输入脚本前，会先执行一系列预设的清空脚本，该脚本主要实现遍历所有操作台，如果发现某操作台存在物品，则指向并移动至对应操作台，并将操作台的物品弃置垃圾箱，并设置检查指令确保垃圾箱为空后再执行后续的遍历，直到所有物品清除完成，再开始执行输入的脚本内容。

### Constant
该模块定义了一系列之后所需要用到的参数，此处省略说明

### Manual
    module Manual (  
        input [0:0] clk,
        input [4:0] button,//操作按钮，分别控制拿取，放下，交互，移动，丢
        input [7:0] switches,//靠右五个拨码开关控制target指向，靠左两个负责游戏模式和游戏开始
        input [7:0] out_bits,//由OutbitsHandle模块给入的数据信息
        output reg [7:0] in_bits,//输出信息给Output模块
        output [3:0] state_manual//输出信息给Output模块
    );
该模块负责手动模式。通过控制拨码开关来完成对target的选择，选择的数字大小，由五个拨码开关组成的5位二进制数决定。选定target后，通过按下指定的按钮来完成游戏操作。

### OutbitsHandle
    module OutbitsHandle (
        input [0:0] clk,
        input [7:0] dataOut_bits,
        input [0:0] dataOut_valid,
        output reg [7:0] out_bits
    );
该模块负责控制输出流。如果dataOut_valid为0，则说明还未准备好，此时不能读取，如果dataOut_valid为1，说明可以读取，在下一时钟上升沿将会把dataOut_bits的值赋给out_bits

### Output
    module Output (
        input [0:0] clk,
        input [0:0] mode,  // mode, 0 for manual, 1 for auto
        input [7:0] out_bits,//由OutbitsHandle给入
        input [7:0] in_bits_manual,//手动模式下的输入数据
        input [3:0] state_manual,//手动模式下的状态
        input [7:0] state_auto,//自动模式下的状态
        input [7:0] pc,//脚本地址
        input [15:0] script,//脚本内容
        output [7:0] led,
        output [7:0] led2,
        output reg [7:0] tub_sel,//数码管
        output reg [7:0] tub_ctr1, tub_ctr2//数码管信息
    );
该模块负责处理输出信息的内容。

### QuickClock
    module QuickClock (
        input [0:0] clk,
        output reg [0:0] quick_clk
    );
该模块产生一个快时钟。

### SegTubClock
    module SegTubClock (
        input[0:0] clk, // 153600Hz
        output reg [0:0] tub_clk // 400Hz
    );
该模块产生一个400Hz的时钟。

### SlowClock
    module SlowClock (
        input [0:0] clk, // 153600Hz
        output reg [0:0] slow_clk // 10Hz
    );
该模块产生一个10Hz的时钟。

### UARTClock
    module UARTClock (
        input [0:0] clk,
        output reg [0:0] uart_clk_16
    );
该模块生成一个可用于UART的时钟。

### VGA
    module VGA (  // 640*480@60Hz
        input clk,
        input rst_n,
        input [15:0] script,
        input [7:0] in_bits,
        input [7:0] out_bits,
        output hsync,   // line synchronization signal
        output vsync,   // vertical synchronization signal
        // 3 color output
        output reg [3:0] red,
        output reg [3:0] green,
        output reg [3:0] blue
    );
该模块用于生成VGA信号。

## Bonus实现说明
### 错误脚本状态自动处理

### 高效的脚本设计

### 接入更丰富的外设
![picture](/pic/script_mode_descript.png "script_mode_descript")



## 项目总结



## 对Project的想法和建议



