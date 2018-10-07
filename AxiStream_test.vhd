-- File: AxiStream_test.vhd
-- Generated by MyHDL 0.10
-- Date: Mon Oct  8 07:33:05 2018


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

use work.pck_myhdl_010.all;

entity AxiStream_test is
    port (
        clk: in std_logic;
        e_peak_AxFeatureOut_tlast: out std_logic;
        e_peak_AxFeatureOut_tdata: out signed (7 downto 0);
        e_peak_AxFeatureOut_tvalid: out std_logic;
        s_axPeak_tready: in std_logic
    );
end entity AxiStream_test;


architecture MyHDL of AxiStream_test is


signal e_peak_status: signed (7 downto 0);
signal e_peak_AxIn_tvalid: std_logic;
signal e_peak_maxValue: signed (7 downto 0);
signal e_peak_maxIndex: signed (7 downto 0);
signal e_peak_currentIndex: signed (7 downto 0);
signal e_peak_AxIn_tdata: signed (7 downto 0);
signal e_peak_AxIn_tready: std_logic;
signal e_peak_AxIn_tlast: std_logic;
signal e_axStim_multi: signed (7 downto 0);
signal e_axStim_Line: signed (7 downto 0);

procedure MYHDL2_reset_if(
    MAX_Index: in natural;
    signal Line: inout signed;
    signal tlast: out std_logic) is
begin
    if (Line > MAX_Index) then
        Line <= to_signed(0, 8);
        tlast <= '1';
    else
        tlast <= '0';
    end if;
end procedure MYHDL2_reset_if;

begin


e_axStim_multi <= to_signed(100, 8);


AXISTREAM_TEST_E_AXSTIM_LOGIC: process (clk) is
    variable ln: integer;
begin
    if rising_edge(clk) then
        ln := to_integer(e_axStim_Line);
        if (bool(e_peak_AxIn_tvalid) and bool(e_peak_AxIn_tready)) then
            e_axStim_Line <= (e_axStim_Line + 1);
            e_peak_AxIn_tdata <= to_signed(to_integer(((5 ** 2) * e_axStim_multi) / ((5 ** 2) + (((2 * 10) - (2 * ln)) ** 2))), 8);
        end if;
        if ((e_axStim_Line < 20) and (e_axStim_Line > 0)) then
            e_peak_AxIn_tvalid <= '1';
        elsif (e_axStim_Line = 0) then
            e_peak_AxIn_tvalid <= '0';
            e_axStim_Line <= (e_axStim_Line + 1);
        end if;
        MYHDL2_reset_if(20, e_axStim_Line, e_peak_AxIn_tlast);
    end if;
end process AXISTREAM_TEST_E_AXSTIM_LOGIC;

AXISTREAM_TEST_E_PEAK_LOGIC: process (clk) is
begin
    if rising_edge(clk) then
        if bool(e_peak_AxIn_tvalid) then
            if (e_peak_AxIn_tdata > e_peak_maxValue) then
                e_peak_maxValue <= e_peak_AxIn_tdata;
                e_peak_maxIndex <= e_peak_currentIndex;
            end if;
        end if;
        if (e_peak_status = 0) then
            e_peak_maxValue <= to_signed(0, 8);
            e_peak_maxIndex <= to_signed(0, 8);
        end if;
        if (e_peak_status = 3) then
            e_peak_currentIndex <= to_signed(0, 8);
            e_peak_AxFeatureOut_tdata <= e_peak_maxValue;
            e_peak_AxFeatureOut_tvalid <= '1';
            e_peak_AxFeatureOut_tlast <= '1';
        elsif (e_peak_status = 0) then
            e_peak_AxFeatureOut_tvalid <= '0';
            e_peak_AxFeatureOut_tlast <= '0';
        elsif (e_peak_status = 2) then
            e_peak_currentIndex <= (e_peak_currentIndex + 1);
        end if;
    end if;
end process AXISTREAM_TEST_E_PEAK_LOGIC;

AXISTREAM_TEST_E_PEAK_STATEMACHINE: process (clk) is
begin
    if rising_edge(clk) then
        if ((e_peak_status = 0) and bool(e_peak_AxIn_tvalid)) then
            e_peak_status <= to_signed(1, 8);
            e_peak_AxIn_tready <= '1';
        elsif ((e_peak_status = 1) and bool(e_peak_AxIn_tvalid)) then
            e_peak_status <= to_signed(2, 8);
        elsif (bool(e_peak_AxIn_tvalid) and bool(e_peak_AxIn_tlast)) then
            e_peak_status <= to_signed(3, 8);
        elsif (e_peak_status = 3) then
            e_peak_status <= to_signed(0, 8);
            e_peak_AxIn_tready <= '0';
        end if;
    end if;
end process AXISTREAM_TEST_E_PEAK_STATEMACHINE;

AXISTREAM_TEST_E_PEAK_FSM_CONTROL: process (clk) is
begin
    if rising_edge(clk) then
        null;
    end if;
end process AXISTREAM_TEST_E_PEAK_FSM_CONTROL;

end architecture MyHDL;
