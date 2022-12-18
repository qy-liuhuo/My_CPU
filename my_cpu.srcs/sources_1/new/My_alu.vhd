----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2022/12/17 19:51:59
-- Design Name: 
-- Module Name: My_alu - Behavioral
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
