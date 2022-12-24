import cocotb
from cocotb.triggers import RisingEdge, ClockCycles
from cocotb.clock import Clock
from cocotb.result import TestFailure

async def reset(dut):
    # reset the DUT
    dut.reset = 1

    dut.lo_nco_enable = 0
    dut.ca_nco_enable = 0
    dut.ca_gen_enable = 0
    
    await ClockCycles(dut.clk, 5)
    dut.reset = 0

async def write_register(dut, address, value):
    dut.address = address
    dut.data_value = value
    await ClockCycles(dut.clk, 1)

@cocotb.test()
async def test_channel(dut):
    # Create a clock and start it running
    c = Clock(dut.clk, 2, "step")
    cocotb.fork(c.start())

    await reset(dut)

    dut.sample = 0
    dut.lo_nco_enable = 1
    dut.ca_nco_enable = 1
    dut.ca_gen_enable = 1
    
    await ClockCycles(dut.clk, 1000)
    # f_out = step * f_clk / (2^n)
    # f_0 = 10.23 MHz
    # L1 = 154 * 10.23 = 1575.42 MHz
    # IF = 2.6 MHz
    # CA = 10.23 / 10 = 1.023 MHz

    lo_nco_step = round(2.6 * pow(2,32) / 100)
    ca_nco_step = round(1.023 * pow(2, 32) / 100)

    lo_nco_phase_delay = 0
    ca_nco_phase_delay = 0

    prn_phase_init = 0o541

    await write_register(dut, 1, lo_nco_step)
    await write_register(dut, 2, lo_nco_phase_delay)
    await write_register(dut, 3, ca_nco_step)
    await write_register(dut, 4, ca_nco_phase_delay)
    await write_register(dut, 5, prn_phase_init)
    await write_register(dut, 0, 0)

    dut.lo_nco_enable = 1
    dut.ca_nco_enable = 1
    
    await ClockCycles(dut.clk, 1)
    dut.ca_gen_enable = 1

    # PRN 39, G2_init 0o541
    # First ten chips 0o1236
    # 1010011110

    await ClockCycles(dut.clk, 1000)
    
    ca_nco_phase_delay = 2113265920
    await write_register(dut, 4, ca_nco_phase_delay)
    await write_register(dut, 0, 0)

    await ClockCycles(dut.clk, 100)

    ca_nco_phase_delay = 0
    lo_nco_phase_delay = 0
    await write_register(dut, 4, ca_nco_phase_delay)
    await write_register(dut, 2, lo_nco_phase_delay)
    await write_register(dut, 0, 0)
    
    await reset(dut)

    await write_register(dut, 1, lo_nco_step)
    await write_register(dut, 2, lo_nco_phase_delay)
    await write_register(dut, 3, ca_nco_step)
    await write_register(dut, 4, ca_nco_phase_delay)
    await write_register(dut, 5, prn_phase_init)
    await write_register(dut, 0, 0)

    dut.lo_nco_enable = 1
    dut.ca_nco_enable = 1

    await ClockCycles(dut.clk, 1)
    dut.ca_gen_enable = 1

    await ClockCycles(dut.clk, 2000)