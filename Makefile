# COCOTB variables
export COCOTB_REDUCED_LOG_FMT=1
export PYTHONPATH := test:$(PYTHONPATH)
export LIBPYTHON_LOC=$(shell cocotb-config --libpython)

all: test_ca_code test_nco test_channel

test_ca_code:
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/sim.vvp -s ca_code -s dump -g2012 src/ca_code.v test/dump_ca_code.v
	PYTHONOPTIMIZE=${NOASSERT} MODULE=test.test_ca_code vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/sim.vvp
	! grep failure results.xml

test_nco:
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/sim.vvp -s nco -s dump -g2012 src/nco.v test/dump_nco.v
	PYTHONOPTIMIZE=${NOASSERT} MODULE=test.test_nco vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/sim.vvp
	! grep failure results.xml


test_channel:
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/sim.vvp -s channel -s dump -g2012 src/channel.v test/dump_channel.v src/ca_code.v src/nco.v
	PYTHONOPTIMIZE=${NOASSERT} MODULE=test.test_channel vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/sim.vvp
	! grep failure results.xml

show_%: %.vcd %.gtkw
	gtkwave $^


# general recipes

lint:
	verible-verilog-lint src/*v --rules_config verible.rules

clean:
	rm -rf *vcd sim_build fpga/*log fpga/*bin test/__pycache__

.PHONY: clean
