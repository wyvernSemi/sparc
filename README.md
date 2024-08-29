#  Sparc version 8 Instruction Set Simulator

<p align="center">
<img src="https://github.com/user-attachments/assets/527f6ade-8de3-4f1e-a118-6f349be9df01" width=337>
</p>

A Sparc v8 Instruction Set Simulator (ISS) written in C, with hooks for external software models and co-simulation. 
The supported instructions are shown below:

```
  Load:          LDSB LDSH LDUB LDUH LD LDD
  Store:         STB STH ST STD
  Atomic:        SWAP LDSTUB
  Misc:          SETHI NOP
  Logical:       AND ANDcc ANDN ANDNcc OR ORcc ORN ORNcc XOR XORcc XNOR XNORcc
  Shift:         SLL SRL SRA
  Add:           ADD ADDcc ADDX ADDXcc 
  Subtract:      SUB SUBcc SUBX SUBXcc
  Multiply:      UMUL UMULcc SMUL SMULcc 
  Divide:        UDIV UDIVcc SDIV SDIVcc
  Tagged add:    TADDcc TADDcc TSUBccTV TSUBccTV
  Multiply Step: MULScc
  Window:        SAVE RESTORE
  Branch:        Bicc
  Prog control:  CALL JMPL 
  Trap:          RETT Ticc
  Read Regs:     RDY RDPSR RDWIM RDTBR 
  Write Regs:    WRY WRPSR WRWIM WRTBR
  Mem Sync:      STBAR FLUSH
  Unimplemented: UNIMP
```

More details of this project can be found in <tt>doc/sparc_iss.pdf</tt> within this repository.
