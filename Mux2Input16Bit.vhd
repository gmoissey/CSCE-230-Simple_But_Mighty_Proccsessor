----------------------------------------------------------------------------------
-- Name:	Prof Jeff Falkinburg
-- Date:	Fall 2020
-- Course:	CSCE 230
-- File:	Mux2Input16Bit.vhd
-- HW:		Group Project
-- Purp:	Implements a 2 Input by 16-Bit Multiplexer for our project 
--
-- Doc:		Lecture Notes
-- 	
-- Academic Integrity Statement: I certify that, while others may have 
-- assisted me in brain storming, debugging and validating this program, 
-- the program itself is my own work. I understand that submitting code 
-- which is the work of other individuals is a violation of the honor   
-- code.  I also understand that if I knowingly give my original work to 
-- another individual is also a violation of the honor code. 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity Mux2Input16Bit is
	port(
		s : in  std_logic;
		input0, input1 : in  std_logic_vector(15 downto 0);
		result : out std_logic_vector(15 downto 0));
end Mux2Input16Bit;

architecture implementation of mux2Input16Bit is
begin
	with s select
		result <=   input0 when '0',
						input1 when others;
end implementation;
