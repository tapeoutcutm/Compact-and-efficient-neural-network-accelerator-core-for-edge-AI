# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
import os.path
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
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    test_vectors = load_test_vectors(os.path.join('test_vectors', vector_file))
    expected_vectors = load_expected_vectors(os.path.join('test_vectors', expected_file))

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


    await ClockCycles(dut.clk, 10)

@cocotb.test()
async def test_accum(dut):
    await run_test(dut, "test_accum.hex", "test_accum_expected.hex")

@cocotb.test()
async def test_ascii(dut):
    await run_test(dut, "test_ascii.hex", "test_ascii_expected.hex")

@cocotb.test()
async def test_convolve(dut):
    await run_test(dut, "test_convolve.hex", "test_convolve_expected.hex")

@cocotb.test()
async def test_count(dut):
    await run_test(dut, "test_count.hex", "test_count_expected.hex")

@cocotb.test()
async def test_mul_acc_1(dut):
    await run_test(dut, "test_mul_acc_1.hex", "test_mul_acc_1_expected.hex")

@cocotb.test()
async def test_mul_acc_2(dut):
    await run_test(dut, "test_mul_acc_2.hex", "test_mul_acc_2_expected.hex")

@cocotb.test()
async def test_pulse(dut):
    await run_test(dut, "test_pulse.hex", "test_pulse_expected.hex")

@cocotb.test()
async def test_simple_2_accumulate(dut):
    await run_test(dut, "test_simple_2_accumulate.hex",
            "test_simple_2_accumulate_expected.hex")

@cocotb.test()
async def test_simple_4_accumulate(dut):
    await run_test(dut, "test_simple_4_accumulate.hex",
            "test_simple_4_accumulate_expected.hex")

@cocotb.test()
async def test_simple_convolve(dut):
    await run_test(dut, "test_simple_convolve.hex",
            "test_simple_convolve_expected.hex")

@cocotb.test()
async def test_simple_mul_acc(dut):
    await run_test(dut, "test_simple_mul_acc.hex",
            "test_simple_mul_acc_expected.hex")
