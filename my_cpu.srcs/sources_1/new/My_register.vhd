----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2022/12/16 11:28:56
-- Design Name: 
-- Module Name: My_register - Behavioral
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
