----------------------------------------------------------------------------------
-- Name:	Prof Jeff Falkinburg
-- Date:	Fall 2020
-- Course:	CSCE 230
-- File:	ControlUnit.vhd
-- HW:		Group Project
-- Purp:	Implements a 16-Bit Control Unit for our processor
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

entity ControlUnit is
	port(
		clock	: in  std_logic;
		reset	: in  std_logic;
		status: in  std_logic_vector(15 downto 0);
		MFC	: in  std_logic;
		IR		: in  std_logic_vector(15 downto 0);
		
		RF_write	: out std_logic;
		C_select	: out std_logic_vector(1 downto 0);
		B_select : out std_logic;
		Y_select	: out std_logic_vector(1 downto 0);
		ALU_op	: out std_logic_vector(1 downto 0);
		A_inv		: out std_logic;
		B_inv		: out std_logic;
		C_in		: out std_logic;
		MEM_read	: out std_logic;
		MEM_write: out std_logic;
		MA_select: out std_logic;
		IR_enable: out std_logic;
		PC_select: out std_logic_vector(1 downto 0);
		PC_enable: out std_logic;
		INC_select: out std_logic;
		extend	: out std_logic_vector(2 downto 0);
		Status_enable : out std_logic;
		-- for ModelSim debugging only
		debug_state	: out std_logic_vector(2 downto 0)
	);
end ControlUnit;

architecture implementation of ControlUnit is
	signal current_state : std_logic_vector(2 downto 0);
	signal next_state   	: std_logic_vector(2 downto 0);
	signal WMFC				: std_logic;
	signal OP_code			: std_logic_vector(2 downto 0);
	signal OPX				: std_logic_vector(3 downto 0);
	signal N,C,V,Z			: std_logic;
begin
	OP_code <= IR(2 downto 0);
	OPX <= IR(6 downto 3);
	N <= status(3);
	C <= status(2);
	V <= status(1);
	Z <= status(0);
	
	-- for debugging only
	debug_state <= current_state;

	-- current state logic
	process(clock, reset)
	begin
		if (reset = '1') then
			current_state <= "000";
		elsif rising_edge(clock) then
			current_state <= next_state;
		end if;
	end process;

	-- next state logic
	process(current_state, WMFC, MFC)
	begin
	case current_state is
	       when "000"  =>  
					next_state <= "001";		-- start with stage 1
	       when "001"  =>  
				if (WMFC='0') then 
					next_state <= "010";   	-- not wait for mem (for clarity, not necessary)
		      elsif (MFC='1') then 
					next_state <= "010";   	-- mem ready
		      else 		
					next_state <= "001";		-- mem not ready
				end if; 
	       when "010"  =>  
					next_state <= "011";
	       when "011"  =>  
					next_state <= "100";
	       when "100"  =>  
				if (WMFC='0') then 
					next_state <= "101";    -- not wait for mem
		      elsif (MFC='1') then 
					next_state <= "101";    -- mem ready
		      else 		
					next_state <= "100"; 	-- mem not ready
				end if;  
	       when "101"  =>  
					next_state <= "001";
	       when others =>  
					next_state <= "000"; 	-- something wrong, reset
	end case;
	end process;

	
	-- Mealy output logic
	process(current_state, MFC, OP_code, OPX, N, C, V, Z)
	begin
		-- set all output signals to the default 0
		RF_write <= '0'; C_select <= "00";  B_select <= '0'; Y_select <= "00";
		ALU_op <= "00"; A_inv <= '0'; B_inv <= '0'; C_in <= '0';
		MEM_read <= '0'; MEM_write <= '0'; MA_select <= '0'; IR_enable <= '0';
		PC_select <= "00"; PC_enable <= '0'; INC_select <= '0'; extend <= "000";
		Status_enable <= '0';
		-- set internal WMFC signal to the default 0
		WMFC <= '0'; 

		-- Student Code:  set output signals and WMFC for each instruction and each stage
		
		
	if (current_state = "001") then
			MA_select <= '1'; 
			MEM_read <= '1';
			MEM_write <= '0'; -- for clarity, same as default
			WMFC <= '1';
			if (MFC = '1') then
				IR_enable <= '1';
			else
				IR_enable <= '0'; --for clarity
			end if;
				INC_select <= '0';   -- for clarity 
				PC_select <= "01";
			if (MFC = '1') then
				PC_enable <= '1';
			else
				PC_enable <= '0'; --for clarity
			end if;
	end if;
	--R-type add
	if((OP_code = "000") and OPX = "0000") then
			if(current_state = "010") then
			elsif(current_state = "011") then
				B_select <= '0';
				ALU_op <= "11";
				A_inv <= '0'; B_inv <= '0'; C_in <= '0';
			elsif (current_state = "100") then
				Y_select <= "00";
			elsif (current_state = "101") then
				RF_write <= '1'; 
				C_select <= "01";
			end if;
	end if;

		--R-type sub
	if((OP_code = "000") and (OPX = "0001")) then
			if(current_state = "010") then
			elsif(current_state = "011") then
				B_select <= '0';
				ALU_op <= "11";
				A_inv <= '0'; B_inv <= '1'; C_in <= '1';
			elsif (current_state = "100") then
				Y_select <= "00";
			elsif (current_state = "101") then
				RF_write <= '1'; 
				C_select <= "01";
			end if;
	end if;
	
		--R-type and
	if((OP_code = "000") and (OPX = "0010")) then
			if(current_state = "010") then
			elsif(current_state = "011") then
				B_select <= '0';
				ALU_op <= "00";
				A_inv <= '0'; B_inv <= '0'; C_in <= '0';
			elsif (current_state = "100") then
				Y_select <= "00";
			elsif (current_state = "101") then
				RF_write <= '1'; 
				C_select <= "01";
			end if;
	end if;
		--R-type or
	if((OP_code = "000") and (OPX = "0011")) then
			if(current_state = "010") then
			elsif(current_state = "011") then
				B_select <= '0';
				ALU_op <= "01";
				A_inv <= '0'; B_inv <= '0'; C_in <= '0';
			elsif (current_state = "100") then
				Y_select <= "00";
			elsif (current_state = "101") then
				RF_write <= '1'; 
				C_select <= "01";
			end if;
	end if;
		--R-type xor
	if((OP_code = "000") and (OPX = "0100")) then
			if(current_state = "010") then
			elsif(current_state = "011") then
				B_select <= '0';
				ALU_op <= "10";
				A_inv <= '0'; B_inv <= '0'; C_in <= '0';
			elsif (current_state = "100") then
				Y_select <= "00";
			elsif (current_state = "101") then
				RF_write <= '1'; 
				C_select <= "01";
			end if;
	end if;
		--R-type nand 
	if((OP_code = "000") and (OPX = "0101")) then
			if(current_state = "010") then
			elsif(current_state = "011") then
				B_select <= '0';
				ALU_op <= "01";
				A_inv <= '1'; B_inv <= '1'; C_in <= '0';
			elsif (current_state = "100") then
				Y_select <= "00";
			elsif (current_state = "101") then
				RF_write <= '1'; 
				C_select <= "01";
			end if;
	end if;
		--R-type nor
	if((OP_code = "000") and (OPX = "0110")) then
			if(current_state = "010") then
			elsif(current_state = "011") then
				B_select <= '0';
				ALU_op <= "00";
				A_inv <= '1'; B_inv <= '1'; C_in <= '0';
			elsif (current_state = "100") then
				Y_select <= "00";
			elsif (current_state = "101") then
				RF_write <= '1'; 
				C_select <= "01";
			end if;
	end if;
		--R-type nxor TODO: maybe works??
	if((OP_code = "000") and (OPX = "0111")) then
			if(current_state = "010") then
			elsif(current_state = "011") then
				B_select <= '0';
				ALU_op <= "10";
				A_inv <= '1'; B_inv <= '0'; C_in <= '0';
			elsif (current_state = "100") then
				Y_select <= "00";
			elsif (current_state = "101") then
				RF_write <= '1'; 
				C_select <= "01";
			end if;
	end if;
			--R-type cmp
	if((OP_code = "000") and (OPX = "1000")) then
			if(current_state = "010") then
			elsif(current_state = "011") then
				B_select <= '0';
				ALU_op <= "11";
				A_inv <= '0'; B_inv <= '1'; C_in <= '1';
				Status_enable <= '1';
			elsif (current_state = "100") then
			elsif (current_state = "101") then
			end if;
	end if;
				--R-type jmp
	if((OP_code = "000") and (OPX = "1001")) then
			if(current_state = "010") then
			elsif(current_state = "011") then
				PC_select<="00";
				PC_enable<='1';
			elsif (current_state = "100") then

			elsif (current_state = "101") then

			end if;
	end if;
				--R-type callr
	if((OP_code = "000") and (OPX = "1010")) then
			if(current_state = "010") then
			elsif(current_state = "011") then
				PC_select<="00";
				PC_enable<='1';
			elsif (current_state = "100") then
				Y_select <= "10";
			elsif (current_state = "101") then
				RF_write <= '1'; 
				C_select <= "01";
			end if;
	end if;
				--R-type ret
	if((OP_code = "000") and (OPX = "1011")) then
			if(current_state = "010") then
			elsif(current_state = "011") then
				PC_select<="00";
				PC_enable<='1';
			elsif (current_state = "100") then
			elsif (current_state = "101") then
			end if;
	end if;	
	
	
	
	--I type addi
	if (OP_code="011") then
		if (current_state = "010") then
		elsif (current_state = "011") then
			extend <= "000";
			B_select <= '1'; 
			ALU_op   <= "11"; 
			A_inv <= '0'; B_inv <= '0'; C_in <= '0';
		elsif (current_state = "100") then
			Y_select <= "00";
		elsif (current_state = "101") then
			RF_write <= '1'; 
			C_select <= "00";
		end if;
	end if;
	--I type ori
	if (OP_code="100") then
		if (current_state = "010") then
		elsif (current_state = "011") then
			extend <= "000";
			B_select <= '1'; 
			ALU_op   <= "01"; 
			A_inv <= '0'; B_inv <= '0'; C_in <= '0';
		elsif (current_state = "100") then
			Y_select <= "00";
		elsif (current_state = "101") then
			RF_write <= '1'; 
			C_select <= "00";
		end if;
	end if;
	--I type orhi
	if (OP_code="101") then
		if (current_state = "010") then
		elsif (current_state = "011") then
			extend <= "010";
			B_select <= '1'; 
			ALU_op   <= "01"; 
			A_inv <= '0'; B_inv <= '0'; C_in <= '0';
		elsif (current_state = "100") then
			Y_select <= "00";
		elsif (current_state = "101") then
			RF_write <= '1'; 
			C_select <= "00";
		end if;
	end if;
	--I type ldw
	if (OP_code="001") then
		if (current_state = "010") then
		elsif (current_state = "011") then
			extend <= "000";
			B_select <= '1'; 
			ALU_op   <= "11"; 
			A_inv <= '0'; B_inv <= '0'; C_in <= '0';
		elsif (current_state = "100") then
			MA_select <= '0'; 
			MEM_read <= '1'; MEM_write <= '0';
			WMFC <= '1';
			Y_select <= "01";
		elsif (current_state = "101") then
			RF_write <= '1'; 
			C_select <= "00";
		end if;
	end if;
	--I type stw
	if (OP_code="010") then
		if (current_state = "010") then
		elsif (current_state = "011") then
			extend <= "000";
			B_select <= '1'; 
			ALU_op   <= "11"; 
			A_inv <= '0'; B_inv <= '0'; C_in <= '0';
		elsif (current_state = "100") then
			MA_select <= '0'; 
			MEM_read <= '0'; MEM_write <= '1'; 
			WMFC <= '1';
		elsif (current_state = "101") then
		end if;
	end if;	
	
	
	
	--B type br
	if ((OP_code="110" ) and (OPX = "0000")) then
		if (current_state = "010") then
		 elsif (current_state = "011") then
			extend <= "011";
			INC_select <= '1'; 
			PC_select   <= "01"; 
			PC_enable <= '1';
		elsif (current_state = "100") then
		elsif (current_state = "101") then
		end if;
	end if;
	--B type beq
	if ((OP_code="110" ) and (OPX = "0001")) then
		if (current_state = "010") then
		elsif (current_state = "011") then
			B_select <= '0';
			ALU_op <= "11";
			A_inv<='0'; B_inv<='1'; C_in<='1';
			if (Z='1') then
				extend <= "011";
				INC_select <= '1'; 
				PC_select   <= "01"; 
				PC_enable <= '1';
		end if;
		elsif (current_state = "100") then
		elsif (current_state = "101") then
		end if;
	end if;
	--B type bne
	if ((OP_code="110" ) and (OPX = "0010")) then
		if (current_state = "010") then
		elsif (current_state = "011") then
			B_select <= '0';
			ALU_op <= "11";
			A_inv<='0'; B_inv<='1'; C_in<='1';
			if (Z='0') then
				extend <= "011";
				INC_select <= '1'; 
				PC_select   <= "01"; 
				PC_enable <= '1';
		end if;
		elsif (current_state = "100") then
		elsif (current_state = "101") then
		end if;
	end if;
	--B type bgeu
	if ((OP_code="110" ) and (OPX = "0011")) then
		if (current_state = "010") then
		elsif (current_state = "011") then
			B_select <= '0';
			ALU_op <= "11";
			A_inv<='0'; B_inv<='1'; C_in<='1';
			if (C='1') then
				extend <= "001";
				INC_select <= '1'; 
				PC_select   <= "01"; 
				PC_enable <= '1';
		end if;
		elsif (current_state = "100") then
		elsif (current_state = "101") then
		end if;
	end if;
	--B type bltu
	if ((OP_code="110" ) and (OPX = "0100")) then
		if (current_state = "010") then
		elsif (current_state = "011") then
			B_select <= '0';
			ALU_op <= "11";
			A_inv<='0'; B_inv<='1'; C_in<='1';
			if (C='0') then
				extend <= "001";
				INC_select <= '1'; 
				PC_select   <= "01"; 
				PC_enable <= '1';
		end if;
		elsif (current_state = "100") then
		elsif (current_state = "101") then
		end if;
	end if;
	--B type bgtu
	if ((OP_code="110" ) and (OPX = "0101")) then
		if (current_state = "010") then
		elsif (current_state = "011") then
			B_select <= '0';
			ALU_op <= "11";
			A_inv<='0'; B_inv<='1'; C_in<='1';
			if ((C='1') AND (Z = '0')) then
				extend <= "001";
				INC_select <= '1'; 
				PC_select   <= "01"; 
				PC_enable <= '1';
		end if;
		elsif (current_state = "100") then
		elsif (current_state = "101") then
		end if;
	end if;
	--B type bleu
	if ((OP_code="110" ) and (OPX = "0110")) then
		if (current_state = "010") then
		elsif (current_state = "011") then
			B_select <= '0';
			ALU_op <= "11";
			A_inv<='0'; B_inv<='1'; C_in<='1';
			if ((C='0') OR (Z = '1')) then
				extend <= "001";
				INC_select <= '1'; 
				PC_select   <= "01"; 
				PC_enable <= '1';
		end if;
		elsif (current_state = "100") then
		elsif (current_state = "101") then
		end if;
	end if;
	--B type bge
	if ((OP_code="110" ) and (OPX = "0111")) then
		if (current_state = "010") then
		elsif (current_state = "011") then
			if (N = V) then
				extend <= "011";
				INC_select <= '1'; 
				PC_select   <= "01"; 
				PC_enable <= '1';
			end if;
		elsif (current_state = "100") then
		elsif (current_state = "101") then
		end if;
	end if;
	--B type blt
	if ((OP_code="110" ) and (OPX = "1000")) then
		if (current_state = "010") then
		elsif (current_state = "011") then
			B_select <= '0';
			ALU_op <= "11";
			A_inv<='0'; B_inv<='1'; C_in<='1';
			if (NOT(N=V)) then
				extend <= "011";
				INC_select <= '1'; 
				PC_select   <= "01"; 
				PC_enable <= '1';
		end if;
		elsif (current_state = "100") then
		elsif (current_state = "101") then
		end if;
	end if;
	--B type bgt
	if ((OP_code="110" ) and (OPX = "1001")) then
		if (current_state = "010") then
		elsif (current_state = "011") then
			B_select <= '0';
			ALU_op <= "11";
			A_inv<='0'; B_inv<='1'; C_in<='1';
			if ((N=V) AND (Z='0')) then
				extend <= "011";
				INC_select <= '1'; 
				PC_select   <= "01"; 
				PC_enable <= '1';
		end if;
		elsif (current_state = "100") then
		elsif (current_state = "101") then
		end if;
	end if;
	--B type ble
	if ((OP_code="110" ) and (OPX = "1010")) then
		if (current_state = "010") then
		elsif (current_state = "011") then
			B_select <= '0';
			ALU_op <= "11";
			A_inv<='0'; B_inv<='1'; C_in<='1';
			if (NOT(N=V) OR Z='1') then
				extend <= "011";
				INC_select <= '1'; 
				PC_select   <= "01"; 
				PC_enable <= '1';
		end if;
		elsif (current_state = "100") then
		elsif (current_state = "101") then
		end if;
	end if;
	
	
	
	--J type call
	if (OP_code="111") then
		if (current_state = "010") then
		elsif (current_state = "011") then
			extend <= "111";
			PC_select   <= "10"; 
			PC_enable <= '1';
		elsif (current_state = "100") then
			Y_select <= "10";
		elsif (current_state = "101") then
			RF_write <= '1';
			C_select <= "10";
		end if;
	end if;
	end process;
	
end implementation;
	
