----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2022/12/15 09:41:56
-- Design Name: 
-- Module Name: Mem_inst - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

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
