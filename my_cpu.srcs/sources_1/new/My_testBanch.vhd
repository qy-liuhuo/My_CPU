
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
