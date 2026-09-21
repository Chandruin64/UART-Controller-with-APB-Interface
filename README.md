# UART Controller with APB Interface — UVM Verification

## Overview

This project implements and verifies a configurable **UART Controller with an APB interface** using **SystemVerilog and UVM**.

The APB interface is used for processor-style configuration and register access, while the UART interface handles serial data transmission and reception. The verification environment uses reusable UVM components, Register Abstraction Layer (RAL), constrained-random stimulus, functional coverage, and SystemVerilog Assertions to verify protocol and functional behavior.

## DUT Features

* APB-based register interface for configuration and data access
* UART transmit and receive functionality
* Configurable data width
* Configurable baud-rate generation
* Configurable parity support
* Configurable stop-bit operation
* TX/RX FIFO buffering
* Interrupt generation
* Error detection for UART communication
* Line control and modem control registers
* Processor-controlled UART configuration
* Loopback operation

## Verification Environment

The testbench is developed using a layered UVM architecture with separate APB and UART agents.

```text
                              +----------------------+
                              |       UVM TEST       |
                              +----------+-----------+
                                         |
                                         v
                    +-------------------------------------------+
                    |                ENVIRONMENT                |
                    |                                           |
                    |  +------------------+  +----------------+ |
                    |  | Virtual          |  | Register Model | |
                    |  | Sequencer        |  |     (RAL)      | |
                    |  +------------------+  +----------------+ |
                    |                                           |
                    |              +------------------+         |
                    |              |    Scoreboard    |         |
                    |              |                  |         |
                    |              |     APB FIFO     |         |
                    |              |     UART FIFO    |         |
                    |              |        |         |         |
                    |              |     Compare      |         |
                    |              +------------------+         |
                    +------------------+------------------------+
                                       |
                     +-----------------+-----------------+
                     |                                   |
                     v                                   v
            +-------------------+               +-------------------+
            |     APB AGENT     |               |     UART AGENT    |
            |                   |               |                   |
            |     Sequencer     |               |     Sequencer     |
            |        |          |               |        |          |
            |      Driver       |               |      Driver       |
            |        |          |               |        |          |
            |      Monitor      |               |      Monitor      |
            +---------+---------+               +---------+---------+
                      |                                   |
                      +-----------------+-----------------+
                                        |
                                        v
                 +------------------------------------------------+
                 |                      DUT                       |
                 |                                                |
                 |              UART Controller                   |
                 |                                                |
                 +------------------------------------------------+
```

## Testbench Components

### APB Agent

The APB agent drives and monitors APB transactions used to configure the UART controller and access its registers.

**Components:**

* APB Sequencer
* APB Driver
* APB Monitor
* APB Transaction
* APB Sequences
* APB Agent Configuration

### UART Agent

The UART agent generates and monitors UART-side serial transactions for verifying transmission and reception.

**Components:**

* UART Sequencer
* UART Driver
* UART Monitor
* UART Transaction
* UART Sequences
* UART Agent Configuration

### Virtual Sequencer

The virtual sequencer coordinates APB and UART sequences when stimulus needs to be synchronized across both interfaces.

Virtual sequences are used to control APB and UART transactions from a common test-level sequence.

The environment includes virtual sequences for:

* Half-duplex transmission
* Half-duplex reception
* Full-duplex operation
* Loopback operation

### Register Model

A UVM RAL-based register model is implemented to provide an abstract representation of the UART controller's programmable registers.

The register model includes fields for UART configuration and control registers and is connected to the verification environment during testbench configuration.

### Scoreboard

The scoreboard receives transactions from the APB and UART monitors through analysis connections and performs self-checking comparisons to verify expected DUT behavior.

The scoreboard maintains separate transaction queues for APB and UART activity and checks the relationship between processor-side configuration/access and UART-side behavior.

### Assertions

SystemVerilog Assertions are used at the interface level to check protocol-related conditions and identify invalid behavior during simulation.

Assertions are used to monitor APB access conditions and UART interface behavior.

### Functional Coverage

Functional coverage is used to measure verification progress across important UART configurations and scenarios, including:

* UART data-bit configurations
* Parity configurations
* Stop-bit configurations
* Baud-rate configurations
* APB register accesses
* UART transmission and reception
* Interrupt behavior
* UART error conditions
* Loopback operation

## Test Scenarios

The test suite contains tests for different UART operating modes and APB-controlled configurations.

| Test                     | Description                                                            |
| ------------------------ | ---------------------------------------------------------------------- |
| `half_duplex_trans_test` | Verifies UART transmission controlled through APB configuration        |
| `half_duplex_rcv_test`   | Verifies UART reception with APB-based configuration and status access |
| `full_duplex_test`       | Verifies simultaneous UART transmission and reception                  |
| `loopback_test`          | Verifies UART loopback operation                                       |

The tests configure the UART line-control settings and use virtual sequences to coordinate APB and UART activity.

The current test configuration includes:

* 8-bit UART data
* Configurable parity and stop-bit settings
* APB register configuration
* UART transmission and reception
* Status checking
* Full-duplex operation
* Loopback operation
* Coverage-driven verification

## UVM Test Flow

```text
Test
 |
 +--> Configure Environment
 |      |
 |      +--> APB Agent Configuration
 |      +--> UART Agent Configuration
 |      +--> Register Model
 |
 +--> Configure UART Registers
 |
 +--> Start APB / UART Virtual Sequence
 |
 +--> DUT Processes APB / UART Transactions
 |
 +--> Monitors Capture Activity
 |
 +--> Scoreboard Checks Results
 |
 +--> Functional Coverage Updated
 |
 +--> Assertions Check Protocol Behavior
 |
 +--> Test Completes
```

## Project Structure

```text
UART_Controller/
│
├── rtl/
│   ├── fifo.v
│   ├── transmitter.v
│   ├── receiver.v
│   ├── register.v
│   ├── uart_top.v
│   ├── uart_if.sv
│   ├── apb_if.sv
│   └── uart.sv
│
├── apb/
│   ├── apb_agent_config.sv
│   ├── apb_xtn.sv
│   ├── apb_seqs.sv
│   ├── apb_driver.sv
│   ├── apb_monitor.sv
│   ├── apb_sequencer.sv
│   ├── apb_agent.sv
│   └── apb_agt_top.sv
│
├── uart/
│   ├── uart_agent_config.sv
│   ├── uart_xtn.sv
│   ├── uart_seqs.sv
│   ├── uart_driver.sv
│   ├── uart_monitor.sv
│   ├── uart_sequencer.sv
│   ├── uart_agent.sv
│   └── uart_agt_top.sv
│
├── tb/
│   ├── reg.sv
│   ├── reg_block.sv
│   ├── env_config.sv
│   ├── virtual_sequencer.sv
│   ├── virtual_seqs.sv
│   ├── scoreboard.sv
│   ├── top.sv
│   └── env.sv
│
├── test/
│   ├── test.sv
│   └── pkg.sv
│
└── sim/
    └── Makefile
```

## Simulation

The project supports simulation using:

* **Siemens QuestaSim**
* **Synopsys VCS**

The Makefile provides commands for compilation, individual test execution, waveform viewing, regression, and coverage reporting.

### QuestaSim

Compile the testbench:

```bash
make sv_cmp
```

Run the transmission test:

```bash
make run_test
```

Run the reception test:

```bash
make run_test1
```

Run the full-duplex test:

```bash
make run_test2
```

Run the loopback test:

```bash
make run_test3
```

Run the complete regression:

```bash
make regress
```

Generate the merged coverage report:

```bash
make report
```

Open the coverage report:

```bash
make cov
```

### VCS

Compile the testbench:

```bash
make sv_cmp
```

Run the transmission test:

```bash
make run_test
```

Run the reception test:

```bash
make run_test1
```

Run the full-duplex test:

```bash
make run_test2
```

Run the loopback test:

```bash
make run_test3
```

Run the complete regression:

```bash
make regress
```

Generate the merged coverage report:

```bash
make report
```

## Verification Methodology

The verification environment combines multiple UVM and SystemVerilog verification techniques:

* **UVM-based layered testbench architecture**
* **Constrained-random stimulus**
* **APB protocol verification**
* **UART protocol verification**
* **Virtual sequences for multi-interface coordination**
* **UVM Register Abstraction Layer (RAL)**
* **Self-checking scoreboard**
* **SystemVerilog Assertions**
* **Functional coverage**
* **Coverage-driven verification**
* **Directed configuration-based tests**
* **TLM-based transaction communication**

## Key Verification Goals

The verification environment is designed to ensure:

1. Correct APB register access and configuration.
2. Correct UART data transmission and reception.
3. Correct configurable data-bit operation.
4. Correct parity generation and checking.
5. Correct stop-bit operation.
6. Correct baud-rate configuration.
7. Correct FIFO operation.
8. Correct interrupt and status behavior.
9. Correct full-duplex operation.
10. Correct loopback behavior.
11. Protocol violations are detected through assertions.
12. Functional scenarios are tracked through coverage.

## Tools and Technologies

* SystemVerilog
* UVM
* UVM RAL
* APB
* UART
* SystemVerilog Assertions
* Functional Coverage
* Constrained-Random Verification
* TLM
* QuestaSim
* Synopsys VCS
* Linux
* Makefile

## Author

**Chandirapriyan K**
RTL Design | Design Verification

**Skills:** Verilog, SystemVerilog, UVM, APB, UART, RAL, SVA, Functional Coverage, Constrained-Random Verification, TLM, QuestaSim, Synopsys VCS, Linux
