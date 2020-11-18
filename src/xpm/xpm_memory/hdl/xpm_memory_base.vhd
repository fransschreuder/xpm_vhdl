library ieee;
use ieee.std_logic_1164.all;
library std;
use std.env.all;
use ieee.math_real.all;

entity xpm_memory_base is
  generic (

  -- Common module parameters
    MEMORY_TYPE             : integer := 2;
    MEMORY_SIZE             : integer := 2048;
    MEMORY_PRIMITIVE        : integer := 0;
    CLOCKING_MODE           : integer := 0;
    ECC_MODE                : integer := 0;
    MEMORY_INIT_FILE        : string  := "none";
    MEMORY_INIT_PARAM       : string  := "";
    USE_MEM_INIT_MMI        : integer := 0;
    USE_MEM_INIT            : integer := 1;
    MEMORY_OPTIMIZATION     : string  := "true";
    WAKEUP_TIME             : integer := 0;
    AUTO_SLEEP_TIME         : integer := 0;
    MESSAGE_CONTROL         : integer := 0;
    USE_EMBEDDED_CONSTRAINT : integer := 0;
    CASCADE_HEIGHT          : integer := 0;
    SIM_ASSERT_CHK          : integer := 0;
    WRITE_PROTECT           : integer := 1;
  -- Port A module s
    WRITE_DATA_WIDTH_A      : integer   := 32;
    READ_DATA_WIDTH_A       : integer   := WRITE_DATA_WIDTH_A;
    BYTE_WRITE_WIDTH_A      : integer   := WRITE_DATA_WIDTH_A;
    ADDR_WIDTH_A            : integer   := integer(ceil(log2(real(MEMORY_SIZE/WRITE_DATA_WIDTH_A))));
    READ_RESET_VALUE_A      : string    := "0";
    READ_LATENCY_A          : integer   := 2;
    WRITE_MODE_A            : integer   := 2;
    RST_MODE_A              : string    := "SYNC";

  -- Port B module s
    WRITE_DATA_WIDTH_B      : integer  := WRITE_DATA_WIDTH_A;
    READ_DATA_WIDTH_B       : integer  := WRITE_DATA_WIDTH_B;
    BYTE_WRITE_WIDTH_B      : integer  := WRITE_DATA_WIDTH_B;
    ADDR_WIDTH_B            : integer  := integer(ceil(log2(real(MEMORY_SIZE/WRITE_DATA_WIDTH_B))));
    READ_RESET_VALUE_B      : string   := "0";
    READ_LATENCY_B          : integer  := READ_LATENCY_A;
    WRITE_MODE_B            : integer  := WRITE_MODE_A;
    RST_MODE_B              : string   := "SYNC"
);
port (
 
  -- Common module ports
  sleep          : in  std_logic;
                                                                              
     -- Port A module ports                                                   
  clka           : in  std_logic;
  rsta           : in  std_logic;
  ena            : in  std_logic;
  regcea         : in  std_logic;
  wea            : in  std_logic_vector((WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A)-1 downto 0);
  addra          : in  std_logic_vector(ADDR_WIDTH_A-1 downto 0);
  dina           : in  std_logic_vector(WRITE_DATA_WIDTH_A-1 downto 0);
  injectsbiterra : in  std_logic;
  injectdbiterra : in  std_logic;
  douta          : out std_logic_vector(READ_DATA_WIDTH_A-1 downto 0);
  sbiterra       : out std_logic;
  dbiterra       : out std_logic;
                                                                              
     -- Port B module ports                                                   
  clkb           : in  std_logic;
  rstb           : in  std_logic;
  enb            : in  std_logic;
  regceb         : in  std_logic;
  web            : in  std_logic_vector((WRITE_DATA_WIDTH_B/BYTE_WRITE_WIDTH_B)-1 downto 0);
  addrb          : in  std_logic_vector(ADDR_WIDTH_B-1 downto 0);
  dinb           : in  std_logic_vector(WRITE_DATA_WIDTH_B-1 downto 0);
  injectsbiterrb : in  std_logic;
  injectdbiterrb : in  std_logic;
  doutb          : out std_logic_vector(READ_DATA_WIDTH_B-1 downto 0);
  sbiterrb       : out std_logic;
  dbiterrb       : out std_logic                                                            
);
end xpm_memory_base;

architecture rtl of xpm_memory_base is
    signal rst_n : std_logic;
    signal wea_or : std_logic;
    signal web_or : std_logic;
begin

    rst_n <= not rsta;
    wea_or <= or wea;
    web_or <= or web;

generic_dpram0: entity work.generic_dpram_dualclock
  generic map(
    -- standard parameters
    g_data_width => WRITE_DATA_WIDTH_A,
    g_size       => MEMORY_SIZE/WRITE_DATA_WIDTH_A,

    g_with_byte_enable         => true,
    g_addr_conflict_resolution => "read_first",
    g_init_file                => MEMORY_INIT_FILE,
    g_fail_if_file_not_found   => false
    )
  port map(
    rst_n_i => rst_n,

    -- Port A
    clka_i => clka,
    bwea_i => wea,
    wea_i  => wea_or,
    aa_i   => addra,
    da_i   => dina,
    qa_o   => douta,
    -- Port B

    clkb_i => clkb,
    bweb_i => web,
    web_i  => web_or,
    ab_i   => addrb,
    db_i   => dinb,
    qb_o   => doutb
    );

end rtl;
