--------------------------------------------------------------------------------
-- CERN BE-CO-HT
-- General Cores Library
-- https://www.ohwr.org/projects/general-cores
--------------------------------------------------------------------------------
--
-- unit name:   memory_loader_pkg
--
-- description: RAM initialization package
--
--------------------------------------------------------------------------------
-- Copyright CERN 2011-2018
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

library std;
use std.textio.all;

library work;
use work.genram_pkg.all;

package memory_loader_pkg is

  subtype t_meminit_array is t_generic_ram_init;

  function f_empty_file_name (
    file_name : in string)
    return boolean;

  procedure f_file_open_check (
    file_name        : in string;
    open_status      : in file_open_status;
    fail_if_notfound : in boolean);

  impure function f_load_mem_from_file
    (file_name : in string;
     mem_size  : in integer;
     mem_width : in integer;
     fail_if_notfound : boolean)
    return t_meminit_array;

  impure function f_load_mem32_from_file
    (file_name : in string; mem_size  : in integer; fail_if_notfound : boolean)
    return t_ram32_type;

  impure function f_load_mem16_from_file
    (file_name : in string; mem_size  : in integer; fail_if_notfound : boolean)
    return t_ram16_type;

  impure function f_load_mem8_from_file
    (file_name : in string; mem_size  : in integer; fail_if_notfound : boolean)
    return t_ram8_type;

  impure function f_load_mem32_from_file_split
    (file_name        : in string; mem_size : in integer;
     fail_if_notfound : boolean; byte_idx : in integer)
    return t_ram8_type;

end memory_loader_pkg;

package body memory_loader_pkg is

  function f_empty_file_name (
    file_name : in string)
    return boolean is
  begin
    if file_name = "" or file_name = "none" then
      return TRUE;
    end if;
    return FALSE;
  end function f_empty_file_name;

  procedure f_file_open_check (
    file_name        : in string;
    open_status      : in file_open_status;
    fail_if_notfound : in boolean) is
  begin
    if open_status /= OPEN_OK then

      if fail_if_notfound then
        report "f_load_mem_from_file(): can't open file '"&file_name&"'" severity FAILURE;
      else
        report "f_load_mem_from_file(): can't open file '"&file_name&"'" severity WARNING;
      end if;
    end if;
  end procedure f_file_open_check;

  impure function f_load_mem_from_file
    (file_name        : in string;
     mem_size         : in integer;
     mem_width        : in integer;
     fail_if_notfound : boolean)
    return t_meminit_array is

    FILE f_in  : text;
    variable l : line;
    variable tmp_bv : bit_vector(mem_width-1 downto 0);
    variable tmp_sv : std_logic_vector(mem_width-1 downto 0);
    variable mem: t_meminit_array(0 to mem_size-1, mem_width-1 downto 0) := (others => (others => '0'));
    variable status   : file_open_status;
  begin
    if f_empty_file_name(file_name) then
      return mem;
    end if;

    file_open(status, f_in, file_name, read_mode);

    f_file_open_check (file_name, status, fail_if_notfound);

    for I in 0 to mem_size-1 loop
      if not endfile(f_in) then
        readline (f_in, l);
        -- read function gives us bit_vector
        read (l, tmp_bv);
      else
        tmp_bv := (others => '0');
      end if;
      tmp_sv := to_stdlogicvector(tmp_bv);
      for J in 0 to mem_width-1 loop
        mem(i, j) := tmp_sv(j);
      end loop;
    end loop;

    if not endfile(f_in) then
      report "f_load_mem_from_file(): file '"&file_name&"' is bigger than available memory" severity FAILURE;
    end if;

    file_close(f_in);
    return mem;
  end f_load_mem_from_file;

  -------------------------------------------------------------------
  -- RAM initialization for most common sizes to speed-up synthesis
  -------------------------------------------------------------------

  impure function f_load_mem32_from_file
    (file_name        : in string;
     mem_size         : in integer;
     fail_if_notfound : boolean)
    return t_ram32_type is

    FILE f_in  : text;
    variable l : line;
    variable tmp_bv : bit_vector(31 downto 0);
    variable mem: t_ram32_type(0 to mem_size-1) := (others => (others => '0'));
    variable status   : file_open_status;
  begin
    if f_empty_file_name(file_name) then
      return mem;
    end if;

    file_open(status, f_in, file_name, read_mode);

    f_file_open_check (file_name, status, fail_if_notfound);

    for I in 0 to mem_size-1 loop
      if not endfile(f_in) then
        readline (f_in, l);
        -- read function gives us bit_vector
        read (l, tmp_bv);
      else
        tmp_bv := (others => '0');
      end if;
      mem(I) := to_stdlogicvector(tmp_bv);
    end loop;

    if not endfile(f_in) then
      report "f_load_mem_from_file(): file '"&file_name&"' is bigger than available memory" severity FAILURE;
    end if;

    file_close(f_in);
    return mem;
  end f_load_mem32_from_file;

  -------------------------------------------------------------------

  impure function f_load_mem16_from_file
    (file_name        : in string;
     mem_size         : in integer;
     fail_if_notfound : boolean)
    return t_ram16_type is

    FILE f_in  : text;
    variable l : line;
    variable tmp_bv : bit_vector(15 downto 0);
    variable mem: t_ram16_type(0 to mem_size-1) := (others => (others => '0'));
    variable status   : file_open_status;
  begin
    if f_empty_file_name(file_name) then
      return mem;
    end if;

    file_open(status, f_in, file_name, read_mode);

    f_file_open_check (file_name, status, fail_if_notfound);

    for I in 0 to mem_size-1 loop
      if not endfile(f_in) then
        readline (f_in, l);
        -- read function gives us bit_vector
        read (l, tmp_bv);
      else
        tmp_bv := (others => '0');
      end if;
      mem(I) := to_stdlogicvector(tmp_bv);
    end loop;

    if not endfile(f_in) then
      report "f_load_mem_from_file(): file '"&file_name&"' is bigger than available memory" severity FAILURE;
    end if;

    file_close(f_in);
    return mem;
  end f_load_mem16_from_file;

  -------------------------------------------------------------------

  impure function f_load_mem8_from_file
    (file_name        : in string;
     mem_size         : in integer;
     fail_if_notfound : boolean)
    return t_ram8_type is

    FILE f_in  : text;
    variable l : line;
    variable tmp_bv : bit_vector(7 downto 0);
    variable mem: t_ram8_type(0 to mem_size-1) := (others => (others => '0'));
    variable status   : file_open_status;
  begin
    if f_empty_file_name(file_name) then
      return mem;
    end if;

    file_open(status, f_in, file_name, read_mode);

    f_file_open_check (file_name, status, fail_if_notfound);

    for I in 0 to mem_size-1 loop
      if not endfile(f_in) then
        readline (f_in, l);
        -- read function gives us bit_vector
        read (l, tmp_bv);
      else
        tmp_bv := (others => '0');
      end if;
      mem(I) := to_stdlogicvector(tmp_bv);
    end loop;

    if not endfile(f_in) then
      report "f_load_mem_from_file(): file '"&file_name&"' is bigger than available memory" severity FAILURE;
    end if;

    file_close(f_in);
    return mem;
  end f_load_mem8_from_file;

  -------------------------------------------------------------------
  -- initialization for 32-bit RAM split into 4x 8-bit BRAM
  -------------------------------------------------------------------

  impure function f_load_mem32_from_file_split
    (file_name        : in string;
     mem_size         : in integer;
     fail_if_notfound : boolean;
     byte_idx         : in integer)
    return t_ram8_type is

    FILE f_in  : text;
    variable l : line;
    variable tmp_bv : bit_vector(31 downto 0);
    variable mem: t_ram8_type(0 to mem_size-1) := (others => (others => '0'));
    variable status   : file_open_status;
  begin
    if f_empty_file_name(file_name) then
      return mem;
    end if;

    file_open(status, f_in, file_name, read_mode);

    f_file_open_check (file_name, status, fail_if_notfound);

    for I in 0 to mem_size-1 loop
      if not endfile(f_in) then
        readline (f_in, l);
        -- read function gives us bit_vector
        read (l, tmp_bv);
      else
        tmp_bv := (others => '0');
      end if;
      mem(I) := to_stdlogicvector( tmp_bv((byte_idx+1)*8-1 downto byte_idx*8) );
    end loop;

    if not endfile(f_in) then
      report "f_load_mem_from_file(): file '"&file_name&"' is bigger than available memory" severity FAILURE;
    end if;

    file_close(f_in);
    return mem;
  end f_load_mem32_from_file_split;

end memory_loader_pkg;
