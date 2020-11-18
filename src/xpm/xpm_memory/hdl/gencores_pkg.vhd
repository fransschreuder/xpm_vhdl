--------------------------------------------------------------------------------
-- CERN BE-CO-HT
-- General Cores Library
-- https://www.ohwr.org/projects/general-cores
--------------------------------------------------------------------------------
--
-- unit name:   gencores_pkg
--
-- description: Package incorporating simple VHDL modules and functions,
-- which are used in OHWR projects.
--
--------------------------------------------------------------------------------
-- Copyright CERN 2009-2018
--------------------------------------------------------------------------------
-- Copyright and related rights are licensed under the Solderpad Hardware
-- License, Version 2.0 (the "License"); you may not use this file except
-- in compliance with the License. You may obtain a copy of the License at
-- http://solderpad.org/licenses/SHL-2.0.
-- Unless required by applicable law or agreed to in writing, software,
-- hardware and materials distributed under this License is distributed on an
-- "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
-- or implied. See the License for the specific language governing permissions
-- and limitations under the License.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package gencores_pkg is

  --============================================================================
  -- Procedures and functions
  --============================================================================

  procedure f_rr_arbitrate (
    signal req       : in  std_logic_vector;
    signal pre_grant : in  std_logic_vector;
    signal grant     : out std_logic_vector);

  function f_onehot_decode(x : std_logic_vector; size : integer) return std_logic_vector;

  function f_big_ripple(a, b : std_logic_vector; c : std_logic) return std_logic_vector;

  function f_gray_encode(x : std_logic_vector) return std_logic_vector;
  function f_gray_decode(x : std_logic_vector; step : natural) return std_logic_vector;

  function f_log2_ceil(N : natural) return positive;
  -- kept for backwards compatibility, same as f_log2_ceil()
  function log2_ceil(N : natural) return positive;

  function f_bool2int (b : boolean) return natural;
  function f_int2bool (n : natural) return boolean;

  --  Convert a boolean to std_logic ('1' for True, '0' for False).
  function f_to_std_logic(b : boolean) return std_logic;

  -- Reduce-OR an std_logic_vector to std_logic
  function f_reduce_or (x : std_logic_vector) return std_logic;

  -- Character/String to std_logic_vector
  function f_to_std_logic_vector (c : character) return std_logic_vector;
  function f_to_std_logic_vector (s : string) return std_logic_vector;

  -- Functions for short-hand if assignments
  function f_pick (cond : boolean; if_1 : std_logic; if_0 : std_logic)
    return std_logic;
  function f_pick (cond : boolean; if_1 : std_logic_vector; if_0 : std_logic_vector)
    return std_logic_vector;
  function f_pick (cond : std_logic; if_1 : std_logic; if_0 : std_logic)
    return std_logic;
  function f_pick (cond : std_logic; if_1 : std_logic_vector; if_0 : std_logic_vector)
    return std_logic_vector;

  -- Functions to convert characters and strings to upper/lower case
  function to_upper(c : character) return character;
  function to_lower(c : character) return character;
  function to_upper(s : string) return string;
  function to_lower(s : string) return string;

  -- Bit reversal function
  function f_reverse_vector (a : in std_logic_vector) return std_logic_vector;

end package;

package body gencores_pkg is

  ------------------------------------------------------------------------------
  -- Simple round-robin arbiter:
  --  req = requests (1 = pending request),
  --  pre_grant = previous grant vector (1 cycle delay)
  --  grant = new grant vector
  ------------------------------------------------------------------------------
  procedure f_rr_arbitrate (
    signal req       : in  std_logic_vector;
    signal pre_grant : in  std_logic_vector;
    signal grant     : out std_logic_vector)is

    variable reqs  : std_logic_vector(req'length - 1 downto 0);
    variable gnts  : std_logic_vector(req'length - 1 downto 0);
    variable gnt   : std_logic_vector(req'length - 1 downto 0);
    variable gntM  : std_logic_vector(req'length - 1 downto 0);
    variable zeros : std_logic_vector(req'length - 1 downto 0);

  begin
    zeros := (others => '0');

    -- bit twiddling magic :
    gnt  := req and std_logic_vector(unsigned(not req) + 1);
    reqs := req and not (std_logic_vector(unsigned(pre_grant) - 1) or pre_grant);
    gnts := reqs and std_logic_vector(unsigned(not reqs)+1);

    if(reqs = zeros) then
      gntM := gnt;
    else
      gntM := gnts;
    end if;

    if((req and pre_grant) = zeros) then
      grant <= gntM;
    else
      grant <= pre_grant;
    end if;

  end f_rr_arbitrate;

  function f_onehot_decode(x : std_logic_vector; size : integer) return std_logic_vector is
  begin
    for j in 0 to x'left loop
      if x(j) /= '0' then
        return std_logic_vector(to_unsigned(j, size));
      end if;
    end loop;  -- i
    return std_logic_vector(to_unsigned(0, size));
  end f_onehot_decode;



  ------------------------------------------------------------------------------
  -- Carry ripple
  ------------------------------------------------------------------------------
  function f_big_ripple(a, b : std_logic_vector; c : std_logic) return std_logic_vector is
    constant len        : natural := a'length;
    variable aw, bw, rw : std_logic_vector(len+1 downto 0);
    variable x          : std_logic_vector(len downto 0);
  begin
    aw := "0" & a & c;
    bw := "0" & b & c;
    rw := std_logic_vector(unsigned(aw) + unsigned(bw));
    x  := rw(len+1 downto 1);
    return x;
  end f_big_ripple;


  ------------------------------------------------------------------------------
  -- Gray encoder
  ------------------------------------------------------------------------------
  function f_gray_encode(x : std_logic_vector) return std_logic_vector is
    variable o : std_logic_vector(x'length downto 0);
  begin
    o := (x & '0') xor ('0' & x);
    return o(x'length downto 1);
  end f_gray_encode;

  ------------------------------------------------------------------------------
  -- Gray decoder
  --  call with step=1
  ------------------------------------------------------------------------------
  function f_gray_decode(x : std_logic_vector; step : natural) return std_logic_vector is
    constant len : natural                          := x'length;
    alias y      : std_logic_vector(len-1 downto 0) is x;
    variable z   : std_logic_vector(len-1 downto 0) := (others => '0');
  begin
    if step >= len then
      return y;
    else
      z(len-step-1 downto 0) := y(len-1 downto step);
      return f_gray_decode(y xor z, step+step);
    end if;
  end f_gray_decode;

  ------------------------------------------------------------------------------
  -- Returns log of 2 of a natural number
  ------------------------------------------------------------------------------
  function f_log2_ceil(N : natural) return positive is
  begin
    if N <= 2 then
      return 1;
    elsif N mod 2 = 0 then
      return 1 + f_log2_ceil(N/2);
    else
      return 1 + f_log2_ceil((N+1)/2);
    end if;
  end;

  -- kept for backwards compatibility
  function log2_ceil(N : natural) return positive is
  begin
    return f_log2_ceil(N);
  end;

  ------------------------------------------------------------------------------
  -- Converts a boolean to natural integer (false -> 0, true -> 1)
  ------------------------------------------------------------------------------
  function f_bool2int (b : boolean) return natural is
  begin
    if b then
      return 1;
    else
      return 0;
    end if;
  end;

  ------------------------------------------------------------------------------
  -- Converts a natural integer to boolean (0 -> false, any positive -> true)
  ------------------------------------------------------------------------------
  function f_int2bool (n : natural) return boolean is
  begin
    if n = 0 then
      return false;
    else
      return true;
    end if;
  end;

  function f_to_std_logic(b : boolean) return std_logic is
  begin
    if b then
      return '1';
    else
      return '0';
    end if;
  end f_to_std_logic;

  ------------------------------------------------------------------------------
  -- Perform reduction-OR on an std_logic_vector, return std_logic
  ------------------------------------------------------------------------------
  function f_reduce_or (x : std_logic_vector) return std_logic is
    variable rv : std_logic;
  begin
    rv := '0';
    for n in x'range loop
      rv := rv or x(n);
    end loop;
    return rv;
  end f_reduce_or;

  ------------------------------------------------------------------------------
  -- Convert a character to an 8-bit std_logic_vector
  ------------------------------------------------------------------------------
  function f_to_std_logic_vector (c : character) return std_logic_vector
  is
    variable rv : std_logic_vector(7 downto 0);
  begin
    rv := std_logic_vector(to_unsigned(character'pos(c), 8));
    return rv;
  end function f_to_std_logic_vector;

  ------------------------------------------------------------------------------
  -- Convert a string of characters to a std_logic_vector of bytes.
  -- NOTE: right-most character is stored at rv(7 downto 0).
  ------------------------------------------------------------------------------
  function f_to_std_logic_vector (s : string) return std_logic_vector
  is
    variable rv : std_logic_vector(s'length*8-1 downto 0);
    variable k  : natural;
  begin
    for i in s'range loop
      -- calculate offset within rv
      k := 8*(4-i);

      -- do the character conversion and write to proper offset
      rv(k+7 downto k) := f_to_std_logic_vector(s(i));
    end loop;
    return rv;
  end function f_to_std_logic_vector;

  ------------------------------------------------------------------------------
  -- Functions for short-hand if assignments
  ------------------------------------------------------------------------------
  function f_pick (cond : std_logic; if_1 : std_logic; if_0 : std_logic)
    return std_logic
  is
  begin
    if cond = '1' then
      return if_1;
    else
      return if_0;
    end if;
  end function f_pick;

  function f_pick (cond : std_logic; if_1 : std_logic_vector; if_0 : std_logic_vector)
    return std_logic_vector
  is
  begin
    if cond = '1' then
      return if_1;
    else
      return if_0;
    end if;
  end function f_pick;

  function f_pick (cond : boolean; if_1 : std_logic; if_0 : std_logic)
    return std_logic
  is
  begin
    return f_pick (f_to_std_logic(cond), if_1, if_0);
  end function f_pick;

  function f_pick (cond : boolean; if_1 : std_logic_vector; if_0 : std_logic_vector)
    return std_logic_vector
  is
  begin
    return f_pick (f_to_std_logic(cond), if_1, if_0);
  end function f_pick;

  ------------------------------------------------------------------------------
  -- Functions to convert characters and strings to upper/lower case
  ------------------------------------------------------------------------------

  function to_upper(c : character) return character is
    variable i : integer;
  begin
    i := character'pos(c);
    if (i > 96 and i < 123) then
      i := i - 32;
    end if;
    return character'val(i);
  end function to_upper;

  function to_lower(c : character) return character is
    variable i : integer;
  begin
    i := character'pos(c);
    if (i > 64 and i < 91) then
      i := i + 32;
    end if;
    return character'val(i);
  end function to_lower;

  function to_upper(s : string) return string is
    variable uppercase : string (s'range);
  begin
    for i in s'range loop
      uppercase(i) := to_upper(s(i));
    end loop;
    return uppercase;
  end to_upper;

  function to_lower(s : string) return string is
    variable lowercase : string (s'range);
  begin
    for i in s'range loop
      lowercase(i) := to_lower(s(i));
    end loop;
    return lowercase;
  end to_lower;

  ------------------------------------------------------------------------------
  -- Vector bit reversal
  ------------------------------------------------------------------------------

  function f_reverse_vector (a : in std_logic_vector) return std_logic_vector is
    variable v_result : std_logic_vector(a'reverse_range);
  begin
    for i in a'range loop
      v_result(i) := a(i);
    end loop;
    return v_result;
  end function f_reverse_vector;

end gencores_pkg;
