import cocotb
import csv
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock
from cocotb.result import TestFailure

@cocotb.test()
async def test_ca_code(dut):
    # Create a clock and start it running
    c = Clock(dut.clk, 10, None)
    cocotb.fork(c.start())

    # reset the DUT
    dut.reset = 1
    dut.expanded = 1

    await RisingEdge(dut.clk)
    dut.reset = 0

    # Read input and expected output data from CSV file
    with open('test/prn_legacy.csv', 'r') as f:
        # Skip the header line
        next(f)

        # Read the data lines
        reader = csv.reader(f)
        for row in reader:
            prn, tap0, tap1, octal = row
            expected_output = int(octal, 8)  # convert octal to int

            # reset the DUT
            dut.reset = 1
            dut.expanded = 0

            # Set the input
            dut.tap0 = int(tap0)
            dut.tap1 = int(tap1)

            await RisingEdge(dut.clk)
            dut.reset = 0

            output_bits = []

            # Wait for 10 clock cycles
            for i in range(10):
                await RisingEdge(dut.clk)
                output_bits.append(int(dut.chip))  # add the current output bit to the deque

            # Convert binary array to number
            result = 0
            for digits in output_bits:
                result = (result << 1 ) | digits
            
            # Compare the collected output bits against the expected output
            if result != expected_output:
                raise TestFailure(f'Mismatch on PRN {prn}: expected {oct(expected_output)}, got {oct(result)}')
    
    # Test expanded PRN 37-63
    dut.expanded = 1

    # Read input and expected output data from CSV file
    with open('test/prn_expanded.csv', 'r') as f:
        # Skip the header line
        next(f)

        # Read the data lines
        reader = csv.reader(f)
        for row in reader:
            prn, init, octal = row
            init = int(init, 8)  # convert init (g2_init) to int
            expected_output = int(octal, 8)  # convert octal to int

            # reset the DUT
            dut.reset = 1
            dut.expanded = 1
            # Set the input
            dut.g2_init = init

            await RisingEdge(dut.clk)
            dut.reset = 0

            output_bits = []

            # Wait for 10 clock cycles
            for i in range(10):
                await RisingEdge(dut.clk)
                output_bits.append(int(dut.chip))  # add the current output bit to the deque

            # Convert binary array to number
            result = 0
            for digits in output_bits:
                result = (result << 1 ) | digits
            
            # Compare the collected output bits against the expected output
            if result != expected_output:
                raise TestFailure(f'Mismatch on PRN {prn}: expected {oct(expected_output)}, got {oct(result)}')
