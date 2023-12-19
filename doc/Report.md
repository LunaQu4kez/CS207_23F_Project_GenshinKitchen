# CS207课程项目GenshinKitchen报告

## 团队分工

| 学号     | 姓名   | 分工                              | 贡献比 |
| -------- | ------ | --------------------------------- | ------ |
| 12211026 | 冯秋皓 | 报告攥写、项目测试                | 33.33% |
| 12211655 | 于斯瑶 | 手动模式、算法设计                | 33.33% |
| 12110120 | 赵钊   | 脚本模式及异常处理、项目架构、VGA | 33.33% |

## 计划日程安排和实施情况

11.06 project发布<br>
11.06-13 熟悉文档和project内容<br>
11.13 project文档更新<br> 
11.13-15 设计project架构<br>
11.15 架构试验<br>
11.15 分配任务，手动模式和脚本模式同时开始<br>
11.19 优化架构<br>
11.24 完成基础脚本模式<br>
11.27 添加reset功能<br>
11.28 完成手动模式<br>
11.29 发布评分标准<br>
11.29 再次优化架构<br>
12.01 完成脚本模式异常处理<br>
12.05 完成VGA<br>
12.10 代码最终检查，小组集体讨论<br>
12.17 完成一半报告撰写<br>
12.24 完成全部报告撰写

任务均按照计划顺利执行完成


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
![picture](/pic/manual_mode_descrip.png "manual_mode_descript")
如图所示，若需要开启自动模式，需要将拨码开关SW6调至低电平。拨动start开关开始游戏，调整如图所示的五个target开关来选择需要选中的目标，右边的五个按钮则是负责控制游戏的各种操作。除H标识的作用为提醒玩家当前模式外，其余输出指示灯主要用于debug使用，玩家游玩时无需仔细关注。


## 系统结构说明
系统结构有Top模块给出，Top模块的部分代码描述如下

    module Top(  // top module
        input [4:0] button,
        input [7:0] switches,

        output [7:0] led,
        output [7:0] led2,

        // 7seg_tub
        output [7:0] tub_sel,
        output [7:0] tub_ctr1, tub_ctr2,

        // vga related
        output hsync,
        output vsync,
        output [3:0] red,
        output [3:0] green,
        output [3:0] blue,
    
        input clk,
        input rx,
        output tx
    );

        wire uart_clk_16; // 153600Hz
        wire quick_clk;   // fast enough
        wire slow_clk;    // 10Hz
        wire tub_clk;     // 400Hz

        wire [7:0] dataIn_bits;         // data_in to UART
        wire [7:0] dataIn_bits_manual;  // data_in of manual mode
        wire [7:0] dataIn_bits_auto;    // data_in of auto mode
        wire dataIn_ready;

        wire [7:0] dataOut_bits;  // receive from UART
        wire [7:0] out_bits;      // out_bits every valid time
        wire dataOut_valid;
    
        wire script_mode;
        wire [7:0] pc;
        wire [15:0] script;

        wire rst;       // reset signal
        wire rst_auto;  // reset signal in auto mode

        wire [3:0] state_manual;  // state in manual mode
        wire [7:0] state_auto;    // state in auto mode

        assign dataIn_bits = switches[6] ? dataIn_bits_auto : dataIn_bits_manual;
        assign rst = switches[6] ? rst_auto : 0;

时钟模块:

uart_clk_16: 用于UART模块的时钟信号。

quick_clk: 用于快速操作的时钟信号。

slow_clk: 用于慢速操作的时钟信号。

tub_clk: 用于7段显示的时钟信号。

数据和控制信号:

dataIn_bits: 从开关输入的数据，根据条件选择手动或自动模式的输入。提供给uart和vga，根据开关被assign为manual或auto

dataIn_bits_manual: 手动模式下的数据输入。提供给output和manual模块，output负责显示输出，manual负责内部处理。

dataIn_bits_auto: 自动模式下的数据输入。提供给output和auto模块，output负责显示输出，auto负责内部处理。

dataIn_ready: 数据输入就绪信号。提供给UART。

dataOut_bits: 从UART接收到的数据。提供给OutbitsHandle进一步处理。

out_bits: OutbitsHandle处理后的有效输出数据。提供给output，vga（若使用）进行输出显示；给auto或manual进行内部处理，具体提供方向由拨码开关模式选择决定。

dataOut_valid: 表示接收到有效数据的信号。

script_mode: 脚本模式信号，指示是否正在从UART加载脚本。

pc: 程序计数器，用于指示脚本内的位置。

script: 存储脚本指令的变量。

复位信号:

rst: 通用复位信号。

rst_auto: 自动模式下的复位信号。

模式选择:

switches[6]: 控制手动和自动模式的开关。 




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
该模块负责手动模式。通过控制拨码开关来完成对target的选择，选择的数字大小，由五个拨码开关组成的5位二进制数决定。选定target后，通过按下指定的按钮来完成游戏操作。同时，该模块加入了错误检查，对于不正确的操作，列出相应的情况并将这些情况归为不做处理（指不进行玩家给出的错误操作）。同时也考虑了持续交互以及单击交互等多种情况的设计。

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
该模块负责处理输出信息的内容。其中mode控制了当前是处理自动状态还是手动状态，因此这个模块自动与手动可以共用。该模块构建了一个有限状态自动机，并根据状态和脚本内容决定数码管的输出信息，以显示output的内容。

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
完成了描述中的要求：手里有东西则先把它丢到垃圾桶；执行投掷指令时，如果目标不可被投掷则改为移动过去放置。

### 高效的脚本设计
小组成员根据菜谱设计出了针对指定三道菜的脚本，主要设计思路如下：

1.对于需要等待，但是不需要一直交互的操作台，可以在操作交互之后，立马切换到其他地方进行其他操作<br>
2.由于来回移动需要耗费时间，因此可以先在食材区将需要的食材throw至需要put的操作台旁边的桌子上（由于throw操作不需要移动至桌子处，因此可以省时间）<br>
3.合理地利用各个等待的间隙，也可以在完成一道菜的过程中，完成另一道菜的部分中间过程，进行"多线程操作"，也能在一定程度上节省时间
最终耗费的时间显示如下

![picture](/pic/46s.jpg ".")


### 接入更丰富的外设
![picture](/pic/VGA_pic.jpg "vga")

如图所示，外接显示屏的上面一行的16位二进制码代表 script，下面一行左边8位和右边8位二进制码分别代表 UART 向客户端传输和接受的数据。



## 项目总结
本项目综合运用了多种数字逻辑的基础设计，包括基础门电路，触发器，有限状态机，时钟的分频等，还大量使用时序逻辑和由状态机控制的组合逻辑。除此之外，还要求规范使用了参数的声明以及模块化设计的标准，使得代码更加整洁易读。本项目的难点在于自动模式和手动模式两个主要模块的设计，自动模块的设计难点在于对脚本的分析以及状态机的设计，需要对接收到的脚本信息进行不同的选择处理，对于不同的指令，是否需要等待，移动，交互是否需要保持，都是要考虑到的问题，且对于出现的异常情况也要避免。手动模块的设计难点在于更加复杂的异常情况避免，玩家在手动操作的时候，经常会出现错误按下按钮导致非法操作，此时需要对当前状态有明确的分析，通过参数列出所有非法情况，并将非法情况阻拦在程序之外，避免引发错误。

小组成员的相互交流也是非常重要的一环，在项目进行的过程中，也遇到了各种技术难题和困难。小组成员通过及时而有效的交流，共同分析问题，提出各自的见解，既巩固了课程知识，也极大推进了项目的正常进行。

此外，最想说的一点是，异常处理是一件繁琐且需要耐心和仔细的工作，小组在进行设计时，对于异常情况的处理花费了大量的精力，也认识到想要准确地找到每一个细微的bug是一件无比困难的事情。

## 对Project的想法和建议
可以设计一个国际象棋游戏，其中六个拨码开关控制相应的格数（国际象棋共64格，2^6可实现所有target），其余按钮可以控制选中棋子，取消选中棋子，确定移动棋子，以及在兵要升变时，四个按钮可用于选择升变棋子的类型。同时要加入异常处理，对于非法移动要加以截断。同时可以要求在EGO1上显示当前步数，子力对比（这个可能有点难），当前未吃子移动步数等。


