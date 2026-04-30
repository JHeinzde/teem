# Demo AES programs

In case you can't follow the instructions or don't get any working programs by compiling
the AES implementation referenced by this emulator this directory contains mulitiple demo 
programs with different behaviour. We have documented them each with their name and their actual
functionality in this document. 

1. aes-no-delay-first-byte-varies.s This program executes AES ECB where only the first byte of the input varies. It outputs 256 different traces (one for each possible byte value) and contains no counter measures against side channels. The trace recording also only contains the SubBytes operation for the first round and the first byte of the plaintext to make any attack as easy as possible and as simple as possible to understand
2. aes-delay-first-byte-varies.s Exhibits all of the characteristics of the first programm but contains cally to the trace_delay syscall of the emulator. This serves as emulation of the most basic counter measure which can be implemented into AES implementations to make power-based side channel attacks like DPA and CPA harder to excute. 
3. aes-no-delay-custom-plain-text.s This programm can be executed within the emulator but before each run it expects you to provide a plain text of 16 bytes (128 bit) which will be encrypted. This can be used to create your own attack on the AES implementation.

The keys for all of these implementations are set to the same value. TODO: make the key variable somehow to make the implementations more interesting. 

