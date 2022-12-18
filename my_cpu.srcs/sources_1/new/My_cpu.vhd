----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2022/12/15 19:44:56
-- Design Name: 
-- Module Name: My_cpu - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

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
