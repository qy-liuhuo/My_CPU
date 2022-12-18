----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2022/12/15 09:57:59
-- Design Name: 
-- Module Name: Mem_data - Behavioral
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
