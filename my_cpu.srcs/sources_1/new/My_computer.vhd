----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2022/12/15 19:36:46
-- Design Name: 
-- Module Name: My_computer - Behavioral
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
