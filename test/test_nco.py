import cocotb
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock
from cocotb.result import TestFailure

@cocotb.test()
async def test_nco(dut):
    # Create a clock and start it running
    c = Clock(dut.clk, 10, None)
    cocotb.fork(c.start())

    # reset the DUT
    dut.reset = 1

    dut.enable = 1

    dut.phase_in = 4294967290
    dut.step = 1073741824

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.reset = 0

    for i in range(100):
        await RisingEdge(dut.clk)
