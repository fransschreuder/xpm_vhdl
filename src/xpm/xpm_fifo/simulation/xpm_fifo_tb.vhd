library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;
library std;
use std.env.all;
--
entity xpm_fifo_tb is
end xpm_fifo_tb;

architecture tb of xpm_fifo_tb is

  --testbench constants
  constant FREEZEON_ERROR : integer := 0;
  constant TB_STOP_CNT    : integer := 2;
  constant TB_SEED        : integer := 20;

  -- Common module constants
  constant CLOCK_DOMAIN        : string := "INDEPENDENT"; -- CLOCK_DOMAIN must be "COMMON" for synchronous fifo, "INDEPENDENT" for asynchronous fifo
  constant RELATED_CLOCKS      : integer := 0;
  constant FIFO_MEMORY_TYPE    : string := "BRAM";
  constant ECC_MODE            : string := "NO_ECC";
  constant FIFO_WRITE_DEPTH    : integer := 512;
  constant WRITE_DATA_WIDTH    : integer := 288;
  constant WR_DATA_COUNT_WIDTH : integer := 10;
  constant PROG_FULL_THRESH    : integer := 450;
  constant FULL_RESET_VALUE    : integer := 0;
  constant READ_MODE           : string := "FWFT";
  constant FIFO_READ_LATENCY   : integer := 0;
  constant READ_DATA_WIDTH     : integer := 288;
  constant RD_DATA_COUNT_WIDTH : integer := 10;
  constant PROG_EMPTY_THRESH   : integer := 5; 
  constant DOUT_RESET_VALUE    : string := "0";
  constant CDC_SYNC_STAGES     : integer := 2;
  constant WAKEUP_TIME         : integer := 0;

 signal  status    : std_logic_vector(7 downto 0); 
 signal  wr_clk    : std_logic; 
 signal  rd_clk    : std_logic; 
 signal  reset     : std_logic; 
 signal  sim_done  : std_logic; 
 
 constant wr_clk_period : time := 40 ns;
 constant rd_clk_period : time := 20 ns;
 
begin
  
 -- Generation of clock
 process
 begin
    wr_clk <= '1';
    wait for wr_clk_period/2;
    wr_clk <= '0';
    wait for wr_clk_period/2;
 end process;
 
 process
 begin
    rd_clk <= '1';
    wait for rd_clk_period/2;
    rd_clk <= '0';
    wait for rd_clk_period/2;
 end process;
 
 process
 begin
   reset <= '1';
   wait for 4000 ns;
   reset <= '0';
   wait;
 end process;

 process(status)
 begin
   if(status(7) = '1') then
       report ("Data mismatch found") severity error; 
   end if;
   if(status(5) = '1') then 
       report("Empty flag Mismatch/timeout") severity error;
   end if;
   if(status(6) = '1') then
       report("Full Flag Mismatch/timeout") severity error;
   end if;
 end process;

 process
 begin
   wait until(sim_done = '1');
   if((status /= x"00")  and  (status /= x"01")) then
         report("xpm_fifo_tb: Simulation failed") severity error;
   else 
         report("xpm_fifo_tb: Test Completed Successfully") severity note;
   end if;
   std.env.finish;
   wait;
 end process;

 process
 begin
    wait for 900 ms;
    report("Test bench timed out") severity warning;
    std.env.finish(1);
    wait;
 end process;
  
  xpm_fifo_ex_inst: entity work.xpm_fifo_ex generic map
  (
    FREEZEON_ERROR       => FREEZEON_ERROR      ,
    TB_STOP_CNT          => TB_STOP_CNT         ,
    TB_SEED              => TB_SEED             ,
    CLOCK_DOMAIN         => CLOCK_DOMAIN        ,
    RELATED_CLOCKS       => RELATED_CLOCKS      ,
    FIFO_MEMORY_TYPE     => FIFO_MEMORY_TYPE    ,
    ECC_MODE             => ECC_MODE            ,
    FIFO_WRITE_DEPTH     => FIFO_WRITE_DEPTH    ,
    WRITE_DATA_WIDTH     => WRITE_DATA_WIDTH    ,
    WR_DATA_COUNT_WIDTH  => WR_DATA_COUNT_WIDTH ,
    PROG_FULL_THRESH     => PROG_FULL_THRESH    ,
    FULL_RESET_VALUE     => FULL_RESET_VALUE    ,
    READ_MODE            => READ_MODE           ,
    FIFO_READ_LATENCY    => FIFO_READ_LATENCY   ,
    READ_DATA_WIDTH      => READ_DATA_WIDTH     ,
    RD_DATA_COUNT_WIDTH  => RD_DATA_COUNT_WIDTH ,
    PROG_EMPTY_THRESH    => PROG_EMPTY_THRESH   ,
    DOUT_RESET_VALUE     => DOUT_RESET_VALUE    ,
    CDC_SYNC_STAGES      => CDC_SYNC_STAGES     ,
    WAKEUP_TIME          => WAKEUP_TIME         
  )  
  port map(
    rst                  => reset,
    wr_clk               => wr_clk,
    rd_clk               => rd_clk,
    sim_done             => sim_done,
    status               => status
  );

end tb;-- xpm_fifo_tb
  
