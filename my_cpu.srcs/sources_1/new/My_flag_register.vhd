----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2022/12/16 12:44:38
-- Design Name: 
-- Module Name: My_flag_register - Behavioral
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

entity My_flag_register is
    Port (
        clk : in STD_LOGIC;
        fi  : in STD_LOGIC_VECTOR(3 downto 0);
        fwe : in STD_LOGIC;
        fo  : out STD_LOGIC_VECTOR(3 downto 0)
     );
end My_flag_register;

architecture Behavioral of My_flag_register is

-- 四位标志寄存器
signal flag_reg : STD_LOGIC_VECTOR(3 downto 0);

begin
    process (clk) is
    begin 
        if clk'event and clk = '1' then
            if fwe = '1' then
                flag_reg <= fi;
            end if;
        end if;
    end process;
    fo <= flag_reg;
end Behavioral;
