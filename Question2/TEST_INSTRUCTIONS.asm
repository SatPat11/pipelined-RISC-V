addi s0, zero, 163
addi sp, sp, -4
sw s0, 0(sp)
add s0, zero, zero
addi t0, zero, 0
LOOP:
   slti t1, t0, 7
   beq t1, zero, EXIT
   addi t0, t0, 1
   beq zero, zero, LOOP
EXIT:
    ori t1, t1, 10
    lw s0, 0(sp)
    addi sp, sp, 4
    addi t2, zero, 32     // t0 = 8; 8 in binary is 1000
    ctz  s1, t2, 0    // Custom CTZ: t1 = count trailing zeros in t0 (3)