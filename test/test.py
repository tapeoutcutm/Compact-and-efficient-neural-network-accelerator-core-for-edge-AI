# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, ReadWrite, FallingEdge

def load_test_vectors(test_vector_filename):
    with open(test_vector_filename, 'r') as test_vector_file:
        test_vector_lines = test_vector_file.readlines()
        test_vectors = [int(l, 16) for l in test_vector_lines]

    return test_vectors


def load_expected_vectors(expected_vector_filename):
    with open(expected_vector_filename, 'r') as expected_vector_file:
        expected_vector_lines = expected_vector_file.readlines()
        expected_vectors = [int(l, 16) if l != 'X\n' else None for l in expected_vector_lines]

    return expected_vectors

async def run_test(dut, vector_file, expected_file):
    test_vectors = load_test_vectors(vector_file)
    expected_vectors = load_expected_vectors(expected_file)

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info(f"Running {len(test_vectors)} inputs")

    for i, test_vec in enumerate(test_vectors):
        dut.ui_in.value = test_vec >> 8
        dut.uio_in.value = test_vec & 0xff

        await ClockCycles(dut.clk, 1)
        await FallingEdge(dut.clk)

        if i < len(expected_vectors) and expected_vectors[i] is not None:
            assert dut.uo_out.value == expected_vectors[i], \
                f"Expected output {i} to be {expected_vectors[i]:02x} " \
                f"saw {dut.uo_out.value}"

@cocotb.test()
async def test_convolve(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    await run_test(dut, "test_convolve.hex", "test_convolve_expected.hex")

@cocotb.test()
async def test_accum(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    await run_test(dut, "test_accum.hex", "test_accum_expected.hex")
