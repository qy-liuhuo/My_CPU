基于Vivado平台使用VHDL设计实现一个单周期CPU(HBU硬件描述语言实验大作业)
<!-- more -->

## CPU架构

### 基本架构
> 参考课程给出的推荐架构，具体如下：

+ 哈佛结构RISC，字长为16位
+ 单周期
+ 指令字长为16位
+ 数据字长为16位
+ 程序存储空间为65536字
+ 数据存储空间为65536字

### 寄存器

+ 16个16位通用寄存器r0-r15 ，r0总为零，r15为链接寄存器；
+ 1个4位标志寄存器，V溢出，C进位，N负，Z零；

## 指令集说明

指令集分类如下：

+ 立即寻址加载指令
+ 寄存器寻址运算指令
+ 立即寻址跳转指令
+ 偏移寻址条件分支指令
+ 寄存器间接寻址加载/存储指令
+ 链接寄存器寻址跳转指令

### 立即寻址加载指令

> 指令中的8位立即数加载到指定的通用寄存器低8位。 Imm8为8位立即数，rd为通用寄存器。


`LI rd, Imm8`

![](https://img.qylh.xyz/blog/1671347485766.png)

### 寄存器寻址运算指令

> 通用寄存器rs和rd中的两个操作数进行运算操作码alu_op指定运算Fx ，结果赋值到寄存器rd中。寄存器寻址运算指令的运算操作码为4位，可以指定16种运算。每种运算都将改变标志位寄存器的内容。

`Fx rd, rs`

![](https://img.qylh.xyz/blog/1671347534659.png)


| 运算指令 | 操作码 | 说明                   |
| -------- | ------ | ---------------------- |
| ADD      | 0000   | 加法                   |
| SUB      | 0001   | 减法                   |
| MOV      | 0100   | 拷贝                   |
| AND      | 0101   | 与运算                 |
| OR       | 1010   | 或运算                 |
| NOT      | 0111   | 非运算                 |
| XOR      | 1000   | 异或运算               |
| SLL      | 1001   | 逻辑左移               |
| SRL      | 1010   | 逻辑右移               |
| SRA      | 1011   | 算数右移               |
| SCC      | 1100   | 带进位循环一位右移     |
| TST      | 1101   | 比较运算，仅改变标志位 |
| RDF      | 1110   | 读标志位               |
| WRF      | 1111   | 写标志位               |


### 立即寻址跳转指令

#### 跳转指令
> 14位立即数地址送PC低14位(程序跳转)， PC高2位不变。

`JMP addr14`

![](https://img.qylh.xyz/blog/1671347973398.png)

#### 带链接的跳转指令


> 当前 PC值送r15 ，14为立即数地址送 PC低14位。

`JL addr14`

![](https://img.qylh.xyz/blog/1671348044531.png)

### 偏移寻址条件分支指令

> 若指定条件为真，当前 PC 值加上有符号相对偏移地址立即数 addr8 送给 PC，程序跳转。条件码为4位，对应4位标志位，产生4个执行跳转条件。条件码某位为1，所对应的标志位为1，则该执行跳转条件为真。条件码某位为0，则该执行跳转条件总为真。

`BX addr8`

![](https://img.qylh.xyz/blog/1671348974672.png)

| 条件码 | 说明                              |
| ------ | --------------------------------- |
| 0000   | 直接跳转                          |
| 0001   | Z为1（相等）则跳转                |
| 0010   | 标志位 N为1（小于）则跳转         |
| 0100   | 标志位 C为1（有进位或借位）则跳转 |
| 1000   | 标志位 V为1（溢出）则跳转         |

### 寄存器间接寻址

#### 寄存器间接寻址加载指令

> 将 rs 所存的地址值指定的数据存储器单元中的数据加载到 rd

`LM rd, rs`

![](https://img.qylh.xyz/blog/1671349198347.png)

#### 存器间接寻址存储指令

> 将 rd 中的数据保存到 rs 所存的地址值指定的数据存储器单元。

`SM rd, rs`

![](https://img.qylh.xyz/blog/1671349233863.png)

### 链接寄存器寻址跳转指令

> r15送 PC，程序跳转


`JR`

![](https://img.qylh.xyz/blog/1671350320848.png)


## 设计框架

该CPU主要组成部件如下：

+ 寄存器堆
+ 标志寄存器
+ ALU
+ 译码器
+ 数据存储器
+ 指令存储器

![](https://img.qylh.xyz/blog/1671350057398.png)


## 组件设计

### 寄存器组

共16个16位寄存器，设置一个读端口和一个读写端口


![](https://img.qylh.xyz/blog/1671350240298.png)

```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity My_register is
    Port ( 
        clk : in STD_LOGIC;
        ra1 : in STD_LOGIC_VECTOR(3 downto 0); -- 端口1 地址
        ra2 : in STD_LOGIC_VECTOR(3 downto 0); -- 端口2 地址
        rwd2 : in STD_LOGIC_VECTOR(15 downto 0); -- 端口2 写数据
        rwe2 : in  STD_LOGIC;                       -- 端口2 写数据使能
        rrd1 : out STD_LOGIC_VECTOR(15 downto 0); -- 端口1 读数据
        rrd2 : out STD_LOGIC_VECTOR(15 downto 0) -- 端口2 读数据
    );
end My_register;

architecture Behavioral of My_register is
    -- 16个16位通用寄存器
    type type_reg is array (15 downto 0) of std_logic_vector(15 downto 0);
    signal reg : type_reg;
begin
    process (clk) is
    begin 
        if clk'event and clk = '1' then
            if rwe2 = '1' then
                reg(conv_integer(ra2)) <= rwd2;
            end if;
        end if;
    end process;
    rrd1 <= X"0000" when ra1="0000" else reg(conv_integer(ra1));
    rrd2 <= X"0000" when ra2="0000" else reg(conv_integer(ra2));
end Behavioral;

```

### 标志位寄存器

![](https://img.qylh.xyz/blog/1671350702852.png)

### ALU 算数逻辑运算单元

![](https://img.qylh.xyz/blog/1671350347074.png)

```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity My_alu is
    Port ( 
        vcnz    : in STD_LOGIC_VECTOR(3 downto 0);
        aluop   : in STD_LOGIC_VECTOR(3 downto 0);
        od1     : in STD_LOGIC_VECTOR(15 downto 0);
        od2     : in STD_LOGIC_VECTOR(15 downto 0);
        aluout : inout STD_LOGIC_VECTOR(15 downto 0);
        fout    : out STD_LOGIC_VECTOR(3 downto 0)
    );
end My_alu;

architecture Behavioral of My_alu is
    signal add_result : STD_LOGIC_VECTOR(16 downto 0);
    signal minus_result : STD_LOGIC_VECTOR(16 downto 0);
    signal shift_number : integer range 0 to 31;
    signal sll_result : STD_LOGIC_VECTOR(15 downto 0);
    signal srl_result : STD_LOGIC_VECTOR(15 downto 0);
    signal sra_result : STD_LOGIC_VECTOR(15 downto 0);
    signal scc_result : STD_LOGIC_VECTOR(15 downto 0);
    signal flag_v : STD_LOGIC;
    signal c_result : STD_LOGIC;
    signal flag_c : STD_LOGIC;
    signal flag_n : STD_LOGIC;
    signal flag_z : STD_LOGIC;
    signal temp_fout:STD_LOGIC_VECTOR(3 downto 0);
begin
-- 加法  
add_result <= ("0" & od1) + ("0" & od2);
-- 减法
minus_result <= ("0" & od1) - ("0" & od2);
-- 移位数目
shift_number <= conv_integer(od2);
-- 逻辑左移
sll_result <= to_stdlogicvector(to_bitvector(od1) sll Shift_Number);

-- 逻辑右移
srl_result <= to_stdlogicvector(to_bitvector(od1) srl Shift_Number);

-- 算数右移
sra_result <= to_stdlogicvector(to_bitvector(od1) sra Shift_Number);

-- 带进位循环一位右移
scc_result(15) <= od1(0);
scc_result(14 downto 0) <= od1(15 downto 1) ;

-- 标志位输出
temp_fout(3) <= add_result(16); -- 溢出标志
temp_fout(2) <= add_result(16); -- 进位标志
temp_fout(1) <= aluout(15) ; -- 负数标志
temp_fout(0) <= '1' when minus_result(15 downto 0) = X"000" else
            '0' ;  -- 零标志

fout <= od1(3 downto 0) when aluop="1111" else
        temp_fout;

aluout <= add_result(15 downto 0)     when aluop = "0000" else  -- ADD
            minus_result(15 downto 0)  when aluop = "0001" else   -- SUB
            od2                            when aluop = "0100" else   -- MOV  ？
            od1 and od2                   when aluop = "0101" else   -- AND
            od1 or od2                    when aluop = "0110" else -- OR
            not od2                       when aluop = "0111" else -- NOT
            od1 xor od2                  when aluop = "1000" else -- XOR
            sll_result                   when aluop = "1001" else
            srl_result                   when aluop = "1010" else
            sra_result                   when aluop = "1011" else
            scc_result                   when aluop = "1100" else
            od1                           when aluop = "1101" else -- TST 比较
            X"000" & vcnz               when aluop = "1110" else 
            od2;
end Behavioral;

```


### 数据存储器

基于IP核`blk_mem_gen_0`封装

```VHDL

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Mem_data is
    port(
                clk		:	in	STD_LOGIC;
                ma 		:	in	STD_LOGIC_VECTOR(15 downto 0);
                mrd		:	out	STD_LOGIC_VECTOR(15 downto 0);
                mwe		:	in	STD_LOGIC;
                mwd		:	in	STD_LOGIC_VECTOR(15 downto 0)
        );
end Mem_data;

architecture Behavioral of Mem_data is
    component blk_mem_gen_0 is
	  Port ( 
	    clka : in STD_LOGIC;
	    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
	    addra : in STD_LOGIC_VECTOR ( 15 downto 0 );
	    dina : in STD_LOGIC_VECTOR ( 15 downto 0 );
	    douta : out STD_LOGIC_VECTOR ( 15 downto 0 )
	  );
	end component blk_mem_gen_0;

	signal	wea		:	STD_LOGIC_VECTOR ( 0 to 0 );

begin
    wea		<=	(others => mwe);
	u0:	blk_mem_gen_0	port map(
									clka	=>	clk,
									wea		=>	wea,
									addra	=>	ma,
									dina	=>	mwd,
									douta	=>	mrd	
								);
end Behavioral;

```

### 指令存储器

基于IP核`dist_mem_gen_0`封装

```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Mem_inst is
    port(
                pc		:	in	STD_LOGIC_VECTOR(15 downto 0);
                instr	:	out	STD_LOGIC_VECTOR(15 downto 0)
        );
end Mem_inst;

architecture Behavioral of Mem_inst is
    component dist_mem_gen_0 is
	  Port ( 
	    a : in STD_LOGIC_VECTOR ( 15 downto 0 );
	    spo : out STD_LOGIC_VECTOR ( 15 downto 0 )
	  );
	end component dist_mem_gen_0;
begin

u0:	dist_mem_gen_0	port map(
									a	=>	pc,
									spo	=>	instr	
								);

end Behavioral;
```



### 控制器

主要完成指令译码，生成控制信号，计算PC值等任务

```VHDL
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity My_cpu is
	port(
			clk			:	in STD_LOGIC; -- 时钟信号
			rst			:	in STD_LOGIC; -- 复位信号

			pc			:	buffer	STD_LOGIC_VECTOR(15 downto 0); -- 程序指针
			instr		:	in	STD_LOGIC_VECTOR(15 downto 0); -- 指令

			ma 			:	out	STD_LOGIC_VECTOR(15 downto 0); -- 地址
			mrd			:	in	STD_LOGIC_VECTOR(15 downto 0); -- 读数据
			mwe			:	out	STD_LOGIC; -- 写使能
			mwd			:	out	STD_LOGIC_VECTOR(15 downto 0) -- 写数据
	);
end My_cpu;

architecture Behavioral of My_cpu is
    signal	ra1			:	STD_LOGIC_VECTOR(3 downto 0);
	signal	ra2			:	STD_LOGIC_VECTOR(3 downto 0);
	signal	rrd1		:	STD_LOGIC_VECTOR(15 downto 0);
	signal	rrd2		:	STD_LOGIC_VECTOR(15 downto 0);
	signal	rwd2		:	STD_LOGIC_VECTOR(15 downto 0);
	signal	rwe2		:	STD_LOGIC; -- rd寄存器写使能

	signal	fi			:	STD_LOGIC_VECTOR(3 downto 0);
	signal	fwe			:	STD_LOGIC; -- 标志寄存器写使能

	signal	npcs		: STD_LOGIC_VECTOR(1 downto 0);  -- 下一条程序地址选择
	signal	rdas		: STD_LOGIC; -- rd寄存器地址选择
	signal	rdwds		: STD_LOGIC_VECTOR(1 downto 0); -- rd寄存器写数据选择

	signal	fo		: STD_LOGIC_VECTOR(3 downto 0); -- 标志位寄存器输出
	signal	rs			: STD_LOGIC_VECTOR(3 downto 0);
	signal	rd			: STD_LOGIC_VECTOR(3 downto 0); -- 目标寄存器
	signal	imm8		: STD_LOGIC_VECTOR(7 downto 0); -- 8位立即数
	signal	op			: STD_LOGIC_VECTOR(3 downto 0); -- 操作码
	signal	aluop		: STD_LOGIC_VECTOR(3 downto 0); -- alu操作码
	signal	fcond		: STD_LOGIC_VECTOR(3 downto 0); -- 条件码
	signal	aluout		: STD_LOGIC_VECTOR(15 downto 0);
	signal	fout		: STD_LOGIC_VECTOR(3 downto 0);
	signal	od1			: STD_LOGIC_VECTOR(16 downto 0);
	signal	od2			: STD_LOGIC_VECTOR(16 downto 0);
	signal	addr8		: STD_LOGIC_VECTOR(7 downto 0); -- 目的地址（指令）	
	signal	addr14		: STD_LOGIC_VECTOR(13 downto 0);
	signal	ja			: STD_LOGIC_VECTOR(15 downto 0);
	signal	ba			: STD_LOGIC_VECTOR(15 downto 0);
	signal flag         : STD_LOGIC; -- 标志寄存器flag

	component	My_register	is
		port(
				clk : in STD_LOGIC;
				ra1 : in STD_LOGIC_VECTOR(3 downto 0); -- 端口1 地址
				ra2 : in STD_LOGIC_VECTOR(3 downto 0); -- 端口2 地址
				rwd2 : in STD_LOGIC_VECTOR(15 downto 0); -- 端口2 写数据
				rwe2 : in  STD_LOGIC; -- 端口2 写数据使能
				rrd1 : out STD_LOGIC_VECTOR(15 downto 0); -- 端口1 读数据
				rrd2 : out STD_LOGIC_VECTOR(15 downto 0) -- 端口2 读数据
			);
	end component My_register;

	component	My_flag_register	is
		Port ( 
			clk : in STD_LOGIC;
			fi  : in STD_LOGIC_VECTOR(3 downto 0);
			fwe : in STD_LOGIC;
			fo  : out STD_LOGIC_VECTOR(3 downto 0)
    	);
	end component My_flag_register;	

	component	My_alu	is
		port (
			vcnz    : in STD_LOGIC_VECTOR(3 downto 0);
			aluop   : in STD_LOGIC_VECTOR(3 downto 0);
			od1     : in STD_LOGIC_VECTOR(15 downto 0);
			od2     : in STD_LOGIC_VECTOR(15 downto 0);
			aluout : inout STD_LOGIC_VECTOR(15 downto 0);
			fout    : out STD_LOGIC_VECTOR(3 downto 0)
		);
	end component My_alu;	

begin
	-- 寄存器堆
	register1:	My_register		port map(
									clk			=>	clk,
									ra1			=>	ra1,
									ra2			=>	ra2,
									rwd2		=>	rwd2,
									rwe2 			=>	rwe2,
									rrd1			=>	rrd1,
									rrd2			=>	rrd2
								);
	-- 标志寄存器
	flag_register: My_flag_register 	port map(
									clk			=>	clk,
									fi			=>	fi,
									fwe			=>	fwe,
									fo		=>	fo
								);
	-- alu
	alu: My_alu port map(
			vcnz    => fo,
			aluop   => aluop,
			od1     => rrd2,
			od2     => rrd1,
			aluout  => aluout,
			fout    => fi
	);
-- ——————————————————————————————————————————————
-- 译码
	op <= instr(15 downto 12);
	rs <= instr(7 downto 4);
	rd <= instr(3 downto 0);
	imm8 <= instr(11 downto 4);
	aluop <= instr(11 downto 8);
	addr8 <= instr(7 downto 0);
	fcond <= instr(11 downto 8);
	addr14 <= instr(13 downto 0);
-- ——————————————————————————————————————————————


-- begin——————————————————————————————————————————————
-- 寄存区写数据选择
	-- 寄存器写数据来源选择
	rdwds <= "00" when op = "0000" else
			  "01" when op = "0001" else
			  "10" when op(3 downto 2) = "11" else
			  "11" when op = "0100" else 
			  "XX";


	rwd2 <= X"00" & imm8 when rdwds = "00" else
			aluout 	   	   when rdwds = "01" else
			pc              when rdwds = "10" else
			mrd             when rdwds = "11" else
			X"0000";

	-- 寄存器写使能
	rwe2 <= '1' when op ="0000" or op="0001" or op(3 downto 2) = "11" or op= "0100" else
			 '0' when op(3 downto 2) = "10" or op = "0010" or op = "0101" or op = "0011" else
			 'X';

-- end——————————————————————————————————————————————


	-- 读写寄存器端口地址选择
	rdas <= '1' when op = "0000" or op ="0001" or op = "0100" or op ="0101" else 
			 '0' when op(3 downto 2) = "11" or op = "0011" else
			 'X';

	ra2 <=  rd when rdas = '1' else
			 "1111" when rdas = '0' else
			 "XXXX";
	-- 读寄存器端口地址选择
	ra1 <= rs;

	-- 标志寄存器写使能
	fwe <= '1' when op = "0001" else
			'0';
	
	flag <= '1' when fcond = "0000" else
			 fo(0) when fcond = "0001" else
			fo(1) when fcond = "0010" else
			fo(2) when fcond = "0100" else
			fo(3) when fcond = "1000" else
			'0';

	mwe <= '1' when op = "0101" else
			'0';

	mwd<=rrd2;

	ma<=rrd1;
-- begin——————————————————————————————————————————————
-- 下一条指令选择
	ja <="00" & instr(13 downto 0);
	ba <= X"00" & instr(7 downto 0) when instr(7)='0' else
		   X"ff" & instr(7 downto 0);

	npcs <= "00" when op = "0000" or op ="0001" or op = "0100" or op="0101" else
			 "01" when op(3 downto 2) = "10" or  op(3 downto 2) = "11" else
			 "10" when op = "0010" and flag = '1' else
			 "00" when op = "0010" and flag = '0' else
			 "11" when op = "0011"  else
			 "XX";
	process (clk) is
	begin
		if clk'event and clk='1' then
			if rst='1' then
				pc <= X"0000";
			else
		case npcs is
			when "00" => pc <= pc + '1'; -- 顺序执行
			when "01" => pc <= ja; -- 寻址跳转
			when "10" => pc <= pc + ba; -- 跳转
			when "11" => pc <= rrd2; -- 链接跳转
			when others => pc <= pc;
		end case;
		end if;
		end if;
end process;
-- end——————————————————————————————————————————————




end Behavioral;


```

### 整体封装


将CPU、数据存储器、指令存储器封装到一起


```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity My_computer is
    port(
            clk				:	in STD_LOGIC;
            rst				:	in STD_LOGIC;

            ma_io 			:	buffer	STD_LOGIC_VECTOR(15 downto 0);
            mrd_io			:	buffer		STD_LOGIC_VECTOR(15 downto 0);
            mwe_io			:	buffer	STD_LOGIC;
            mwd_io			:	buffer	STD_LOGIC_VECTOR(15 downto 0)
        );
end My_computer;

architecture Behavioral of My_computer is

    component	My_cpu	is
		port(
				clk			:	in STD_LOGIC;
				rst			:	in STD_LOGIC;

				pc			:	buffer	STD_LOGIC_VECTOR(15 downto 0);
				instr		:	in	STD_LOGIC_VECTOR(15 downto 0);

				ma 			:	out	STD_LOGIC_VECTOR(15 downto 0);
				mrd			:	in	STD_LOGIC_VECTOR(15 downto 0);
				mwe			:	out	STD_LOGIC;
				mwd			:	out	STD_LOGIC_VECTOR(15 downto 0)
		);
	end component My_CPU;

    component	Mem_inst	is
    port(
            pc		:	in	STD_LOGIC_VECTOR(15 downto 0);
            instr	:	out	STD_LOGIC_VECTOR(15 downto 0)
    );
	end component Mem_inst;

	component	Mem_data	is
		port(
				clk		:	in	STD_LOGIC;
				ma 		:	in	STD_LOGIC_VECTOR(15 downto 0);
				mrd		:	out	STD_LOGIC_VECTOR(15 downto 0);
				mwe		:	in	STD_LOGIC;
				mwd		:	in	STD_LOGIC_VECTOR(15 downto 0)
		);
	end component Mem_data;

	signal 			pc			:	STD_LOGIC_VECTOR(15 downto 0);
	signal 			instr		:	STD_LOGIC_VECTOR(15 downto 0);

	signal 			ma 			:	STD_LOGIC_VECTOR(15 downto 0);
	signal 			mrd			:	STD_LOGIC_VECTOR(15 downto 0);
	signal 			mwe			:	STD_LOGIC;
	signal 			mwd			:	STD_LOGIC_VECTOR(15 downto 0);

begin
	ma_io <=ma;
	mrd_io<=mrd;
	mwe_io<=mwe;
	mwd_io<=mwd;
    u0:	My_CPU		port map(
									clk			=>	clk,
									rst			=>	rst,

									pc			=>	pc,
									instr		=>	instr,

									ma 			=>	ma,
									mrd			=>	mrd,
									mwe			=>	mwe,
									mwd			=>	mwd
								);

	u1:	Mem_inst	port map(
									pc		=>	pc,
									instr	=>	instr
								);

	u2:	Mem_data	port map(
									clk		=>	clk,
									ma		=>	ma,
									mrd		=>	mrd,
									mwe		=>	mwe,
									mwd		=>	mwd
								);

end Behavioral;
```

## 测试验证

### 编写顶层仿真模块

```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity First_TestBanch is
end First_TestBanch;

architecture Behavioral of First_TestBanch is
	component My_computer is
		port(
				clk				:	in STD_LOGIC;
				rst				:	in STD_LOGIC;

				ma_io 			:	buffer	STD_LOGIC_VECTOR(15 downto 0);
				mrd_io			:	buffer		STD_LOGIC_VECTOR(15 downto 0);
				mwe_io			:	buffer	STD_LOGIC;
				mwd_io			:	buffer	STD_LOGIC_VECTOR(15 downto 0)
		);
	end component My_computer;

	signal	clk				:	STD_LOGIC;
	signal	rst				:	STD_LOGIC;

	signal	ma_io 			:	STD_LOGIC_VECTOR(15 downto 0);
	signal	mrd_io			:	STD_LOGIC_VECTOR(15 downto 0);
	signal	mwe_io			:	STD_LOGIC;
	signal	mwd_io			:	STD_LOGIC_VECTOR(15 downto 0);
begin
	computer:	My_computer	port map(
									clk			=>	clk,			
									rst			=>	rst,

									ma_io 		=>	ma_io,
									mrd_io		=>	mrd_io,
									mwe_io		=>	mwe_io,
									mwd_io		=>	mwd_io			
								);

	process is
	begin
		rst		<=	'1';
		wait for	5 ps;
		rst		<=	'0';
		wait;
	end process;

	process is
	begin
		clk		<=	'0';
		wait for	1 ps;
		clk		<=	'1';
		wait for	1 ps;
	end process;
end Behavioral;

```

### 初步仿真测试

使用老师给出的测试指令进行仿真

```
memory_initialization_radix = 16;
memory_initialization_vector =
0121    ;   LI      r1, #12h
0082    ;   LI      r2, #08h
1921    ;   SLL     r1, r2 
0343    ;   LI      r3, #34h
1631    ;   OR      r1, r3
1414    ;   MOV     r4, r1
0561    ;   LI      r1, #56h
1921    ;   SLL     r1, r2 
0783    ;   LI      r3, #78h
1631    ;   OR      r1, r3
1415    ;   MOV     r5, r1
1154    ;   SUB     r4, r5              ;sub
0121    ;   LI      r1, #12h
1921    ;   SLL     r1, r2 
0343    ;   LI      r3, #34h
1631    ;   OR      r1, r3
1414    ;   MOV     r4, r1
0561    ;   LI      r1, #56h
1921    ;   SLL     r1, r2 
0783    ;   LI      r3, #78h
1631    ;   OR      r1, r3
1415    ;   MOV     r5, r1
1145    ;   SUB     r5, r4             ;sub
07f1    ;   LI      r1, #7fh
1921    ;   SLL     r1, r2 
0ff3    ;   LI      r3, #ffh
1631    ;   OR      r1, r3
1414    ;   MOV     r4, r1
0001    ;   LI      r1, #00h
1921    ;   SLL     r1, r2 
0023    ;   LI      r3, #02h
1631    ;   OR      r1, r3
1415    ;   MOV     r5, r1
1054    ;   ADD     r4, r5             ;add
c028    ;   JL      0028h
0000    ;   LI      r0, #00h
0000    ;   LI      r0, #00h
0000    ;   LI      r0, #00h
0000    ;   LI      r0, #00h
0000    ;   LI      r0, #00h
0046    ;   LI      r6, #04h
1f06    ;   WRF     r6
0a07    ;   LI      r7, #a0h
1c07    ;   SCC     r7
0018    ;   LI      r8, #01h
108f    ;   ADD     r15, r8             ;add
3000    ;   JR

```


经过不断地调试改错后，完成了此测试，整个测试过程中的寄存器值变化如下表：

| 寄存器 | 数据                                                                                                    |
| ------ | ------------------------------------------------------------------------------------------------------- |
| 0      | 00h                                                                                                     |
| 1      | 12h->1200h->1234h->56h->5600h->5678h->12h->1200h->1234h->56h->5600h->5678h->7fh->7f00h->7fffh->00h->02h |
| 2      | 08h                                                                                                     |
| 3      | 34h->78h->34h->78h->ffh->02h                                                                            |
| 4      | 1234h->bbbch->1234h->7fffh->8001h                                                                       |
| 5      | 5678h->5678h->4444h->02h                                                                                |
| 6      | 04h                                                                                                     |
| 7      | a0h->50h                                                                                                |
| 8      | 01h                                                                                                     |
| 9      |                                                                                                         |
| 10     |                                                                                                         |
| 11     |                                                                                                         |
| 12     |                                                                                                         |
| 13     |                                                                                                         |
| 14     |                                                                                                         |
| 15     | 22h->23h                                                                                                |



仿真结果与人工计算结果完全一致，仿真如下：

![](https://img.qylh.xyz/blog/Snipaste_2022-12-18_14-00-41.png)

但分析发现，此测试集中缺少分支跳转、数据存储等指令，因此在此基础上进行了修改，增加了`TST`,`BS`,`SM` 指令，以测试相关指令的执行。

### 改进仿真测试

```
memory_initialization_radix = 16;
memory_initialization_vector =
0121    ;   LI      r1, #12h
0082    ;   LI      r2, #08h
1921    ;   SLL     r1, r2  左移八位
0343    ;   LI      r3, #34h
1631    ;   OR      r1, r3
1414    ;   MOV     r4, r1
0561    ;   LI      r1, #56h
1921    ;   SLL     r1, r2 
0783    ;   LI      r3, #78h
1631    ;   OR      r1, r3
1415    ;   MOV     r5, r1
1154    ;   SUB     r4, r5              ;sub
0121    ;   LI      r1, #12h
1921    ;   SLL     r1, r2 
0343    ;   LI      r3, #34h
1631    ;   OR      r1, r3
1414    ;   MOV     r4, r1
0561    ;   LI      r1, #56h
1921    ;   SLL     r1, r2 
0783    ;   LI      r3, #78h
1631    ;   OR      r1, r3
1415    ;   MOV     r5, r1
1145    ;   SUB     r5, r4             ;sub
07f1    ;   LI      r1, #7fh
1921    ;   SLL     r1, r2 
0ff3    ;   LI      r3, #ffh
1631    ;   OR      r1, r3
1414    ;   MOV     r4, r1
0001    ;   LI      r1, #00h
1921    ;   SLL     r1, r2 
0023    ;   LI      r3, #02h
1631    ;   OR      r1, r3
1415    ;   MOV     r5, r1
1054    ;   ADD     r4, r5             ;add
c028    ;   JL      0028h              
0ff3    ;   LI      r3, #ffh           ;跳到这里 pc:0023
0000    ;   LI      r0, #00h
0000    ;   LI      r0, #00h
0000    ;   LI      r0, #00h
0000    ;   LI      r0, #00h
0046    ;   LI      r6, #04h
1f06    ;   WRF     r6
0a07    ;   LI      r7, #a0h
1c07    ;   SCC     r7
0018    ;   LI      r8, #01h
108f    ;   ADD     r15, r8            ;add
1d35    ;   TST     r3,r5  ;002e
21f4    ;   BX      #f4                 ;pc：002f -13
5013    ;   SM      r3,r1               ;存储指令
```

在`1d35`指令处，进行相等判断，写入标志寄存器，`21f4`处根据标志位寄存器进行跳转，第一次经过时由于`r3`与`r5`均为`02h` 所以进行跳转，PC在原基础上`减13`实际是加上`-13`（注意应该写成补码！），跳转到`0ff3`指令处
，修改`r3`为ffh。第二次经过分支跳转时，不满足相等条件，继续执行最后一条存储指令。

仿真结果与预期一致，如下:

![](https://img.qylh.xyz/blog/Snipaste_2022-12-18_14-28-13.png)


## 代码地址

[https://github.com/qy-liuhuo/My_CPU](https://github.com/qy-liuhuo/My_CPU)