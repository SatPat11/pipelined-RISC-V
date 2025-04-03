Q3: 
Wishbone

Simple shared bus protocol, single clock domain

Basic handshake signals (STB, ACK, ERR, RTY)

No pipelining - blocks bus during transactions

Minimal control logic, easy to implement in FPGAs

No QoS, burst support limited to linear increments

Used in legacy systems and small FPGA designs

AXI (AMBA 4/5)

Separate address/data channels for pipelining

Supports burst transfers, out-of-order completion

Three variants: Lite (registers), Full (DMA), Stream (dataflow)

QoS signals for priority scheduling

Multiple outstanding transactions with ID tagging

Dominant in modern SoCs and processors

CHI (AMBA 5)

Packet-based protocol (flit-level granularity)

Built-in cache coherency (snoop filters, home nodes)

Distributed shared memory support

Optimized for multi-core NUMA architectures

Advanced power management features

Used in high-performance compute clusters and servers
