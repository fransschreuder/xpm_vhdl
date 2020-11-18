library ieee;
use ieee.std_logic_1164.all;
library std;
use std.env.all;
use work.gencores_pkg.all;

entity xpm_memory_spram is
  generic (

    -- Common module generics
    MEMORY_SIZE         : integer := 2048            ;
    MEMORY_PRIMITIVE    : string  := "auto"          ;
    ECC_MODE            : string  := "no_ecc"        ;
    MEMORY_INIT_FILE    : string  := "none"          ;
    MEMORY_INIT_PARAM   : string  := ""              ;
    USE_MEM_INIT        : integer := 1               ;
    USE_MEM_INIT_MMI    : integer := 0               ;
    WAKEUP_TIME         : string  := "disable_sleep" ;
    AUTO_SLEEP_TIME     : integer := 0               ;
    MESSAGE_CONTROL     : integer := 0               ;
    MEMORY_OPTIMIZATION : string  := "true" ;
    CASCADE_HEIGHT      : integer := 0               ;
    SIM_ASSERT_CHK      : integer := 0               ;
    WRITE_PROTECT       : integer := 1               ;

    -- Port A module generics
    WRITE_DATA_WIDTH_A  : integer := 32           ;
    READ_DATA_WIDTH_A   : integer := 32           ;
    BYTE_WRITE_WIDTH_A  : integer := 32           ;
    ADDR_WIDTH_A        : integer := 6            ;
    READ_RESET_VALUE_A  : string  := "0"          ;
    READ_LATENCY_A      : integer := 2            ;
    WRITE_MODE_A        : string  := "read_first" ;
    RST_MODE_A          : string  := "SYNC"

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
    dbiterra       : out std_logic
  );
end xpm_memory_spram;


architecture rtl of xpm_memory_spram is
  -- Define local parameters for mapping with base file
  constant P_MEMORY_PRIMITIVE     : integer := 2; --block ram
  constant P_CLOCKING_MODE        : integer := 1;
  constant P_ECC_MODE             : integer := 0;
  constant P_WAKEUP_TIME          : integer := 0;
  constant P_WRITE_MODE_A         : integer := 1;
  constant P_MEMORY_OPTIMIZATION  : integer := 0;

begin
  
  
  -- -------------------------------------------------------------------------------------------------------------------
  -- Base module instantiation with single port RAM configuration
  -- -------------------------------------------------------------------------------------------------------------------

  xpm_memory_base_inst: entity work.xpm_memory_base 
  generic map (

    -- Common module parameters
    MEMORY_OPTIMIZATION      => MEMORY_OPTIMIZATION,
    MEMORY_TYPE        => 0,
    MEMORY_SIZE        => MEMORY_SIZE,
    MEMORY_PRIMITIVE   => P_MEMORY_PRIMITIVE,
    CLOCKING_MODE      => P_CLOCKING_MODE,
    ECC_MODE           => P_ECC_MODE,
    SIM_ASSERT_CHK     => SIM_ASSERT_CHK,
    MEMORY_INIT_FILE   => MEMORY_INIT_FILE,
    MEMORY_INIT_PARAM  => MEMORY_INIT_PARAM,
    USE_MEM_INIT       => USE_MEM_INIT,
    USE_MEM_INIT_MMI   => USE_MEM_INIT_MMI,
    WAKEUP_TIME        => P_WAKEUP_TIME,
    AUTO_SLEEP_TIME    => AUTO_SLEEP_TIME,
    MESSAGE_CONTROL    => MESSAGE_CONTROL,
    USE_EMBEDDED_CONSTRAINT  => 0,
    CASCADE_HEIGHT     => CASCADE_HEIGHT,
    WRITE_PROTECT      => WRITE_PROTECT,

    -- Port A module parameters
    WRITE_DATA_WIDTH_A => WRITE_DATA_WIDTH_A,
    READ_DATA_WIDTH_A  => READ_DATA_WIDTH_A,
    BYTE_WRITE_WIDTH_A => BYTE_WRITE_WIDTH_A,
    ADDR_WIDTH_A       => ADDR_WIDTH_A,
    READ_RESET_VALUE_A => READ_RESET_VALUE_A,
    READ_LATENCY_A     => READ_LATENCY_A,
    WRITE_MODE_A       => P_WRITE_MODE_A,
    RST_MODE_A         => RST_MODE_A,

    -- Port B module parameters
    WRITE_DATA_WIDTH_B => WRITE_DATA_WIDTH_A,
    READ_DATA_WIDTH_B  => READ_DATA_WIDTH_A,
    BYTE_WRITE_WIDTH_B => WRITE_DATA_WIDTH_A,
    ADDR_WIDTH_B       => f_log2_ceil(MEMORY_SIZE/WRITE_DATA_WIDTH_A),
    READ_RESET_VALUE_B => "0",
    READ_LATENCY_B     => READ_LATENCY_A,
    WRITE_MODE_B       => P_WRITE_MODE_A                        
  )  
  port map(

    -- Common module ports
    sleep          => sleep,

    -- Port A module ports
    clka           => clka,
    rsta           => rsta,
    ena            => ena,
    regcea         => regcea,
    wea            => wea,
    addra          => addra,
    dina           => dina,
    injectsbiterra => injectsbiterra,
    injectdbiterra => injectdbiterra,
    douta          => douta,
    sbiterra       => sbiterra,
    dbiterra       => dbiterra,

    -- Port B module ports
    clkb           => '0',
    rstb           => '0',
    enb            => '0',
    regceb         => '0',
    web            => (others => '0'),
    addrb          => (others => '0'),
    dinb           => (others => '0'),
    injectsbiterrb => '0',
    injectdbiterrb => '0',
    doutb          => open,
    sbiterrb       => open,
    dbiterrb       => open
  );
end rtl;
