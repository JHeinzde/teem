	.attribute	4, 16
	.attribute	5, "rv32i2p1_m2p0_zicbom1p0_zmmul1p0_xtheadcmo1p0"
	.file	"main.c"
                                        # Start of file scope inline assembly
	.text
_start:
	lui	sp, 65536
	call	main
	addi	a7, zero, -1
	ecall
_HALT:
	jal	zero, _HALT

                                        # End of file scope inline assembly
	.globl	AES_ECB_encrypt                 # -- Begin function AES_ECB_encrypt
	.p2align	2
	.type	AES_ECB_encrypt,@function
AES_ECB_encrypt:                        # @AES_ECB_encrypt
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	sw	a3, -24(s0)
	lw	a0, -20(s0)
	srli	a0, a0, 4
	sw	a0, -32(s0)
	lw	a0, -24(s0)
	lw	a1, -16(s0)
	lw	a2, -20(s0)
	call	memcpy
	lw	a0, -12(s0)
	call	KeyExpansion
	lw	a0, -24(s0)
	sw	a0, -28(s0)
	jal	zero, .LBB0_1
.LBB0_1:                                # =>This Inner Loop Header: Depth=1
	lw	a0, -32(s0)
	addi	a1, a0, -1
	sw	a1, -32(s0)
	beq	a0, zero, .LBB0_4
	jal	zero, .LBB0_2
.LBB0_2:                                #   in Loop: Header=BB0_1 Depth=1
	lw	a1, -28(s0)
	addi	a0, a1, 0
	call	rijndaelEncrypt
	jal	zero, .LBB0_3
.LBB0_3:                                #   in Loop: Header=BB0_1 Depth=1
	lw	a0, -28(s0)
	addi	a0, a0, 16
	sw	a0, -28(s0)
	jal	zero, .LBB0_1
.LBB0_4:
	lw	a0, -20(s0)
	andi	a0, a0, 15
	lw	a1, -28(s0)
	call	padBlock
	beq	a0, zero, .LBB0_6
	jal	zero, .LBB0_5
.LBB0_5:
	lw	a1, -28(s0)
	addi	a0, a1, 0
	call	rijndaelEncrypt
	jal	zero, .LBB0_6
.LBB0_6:
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	jalr	zero, 0(ra)
.Lfunc_end0:
	.size	AES_ECB_encrypt, .Lfunc_end0-AES_ECB_encrypt
                                        # -- End function
	.p2align	2                               # -- Begin function memcpy
	.type	memcpy,@function
memcpy:                                 # @memcpy
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	lw	a0, -16(s0)
	sw	a0, -24(s0)
	lw	a0, -12(s0)
	sw	a0, -28(s0)
	jal	zero, .LBB1_1
.LBB1_1:                                # =>This Inner Loop Header: Depth=1
	lw	a1, -20(s0)
	addi	a0, a1, -1
	sw	a0, -20(s0)
	addi	a0, zero, 0
	bge	a0, a1, .LBB1_3
	jal	zero, .LBB1_2
.LBB1_2:                                #   in Loop: Header=BB1_1 Depth=1
	lw	a0, -24(s0)
	lw	a2, -20(s0)
	add	a0, a0, a2
	lbu	a0, 0(a0)
	lw	a1, -28(s0)
	add	a1, a1, a2
	sb	a0, 0(a1)
	jal	zero, .LBB1_1
.LBB1_3:
	lw	a0, -12(s0)
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	jalr	zero, 0(ra)
.Lfunc_end1:
	.size	memcpy, .Lfunc_end1-memcpy
                                        # -- End function
	.p2align	2                               # -- Begin function KeyExpansion
	.type	KeyExpansion,@function
KeyExpansion:                           # @KeyExpansion
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -12(s0)
	addi	a0, zero, 1
	sb	a0, -13(s0)
	lw	a1, -12(s0)
	lui	a0, %hi(RoundKey)
	addi	a0, a0, %lo(RoundKey)
	addi	a2, zero, 16
	sw	a2, -20(s0)                     # 4-byte Folded Spill
	call	memcpy
                                        # kill: def $x11 killed $x10
	lw	a0, -20(s0)                     # 4-byte Folded Reload
	sb	a0, -14(s0)
	jal	zero, .LBB2_1
.LBB2_1:                                # =>This Inner Loop Header: Depth=1
	lbu	a1, -14(s0)
	addi	a0, zero, 175
	blt	a0, a1, .LBB2_9
	jal	zero, .LBB2_2
.LBB2_2:                                #   in Loop: Header=BB2_1 Depth=1
	lbu	a0, -14(s0)
	andi	a0, a0, 15
	bne	a0, zero, .LBB2_6
	jal	zero, .LBB2_3
.LBB2_3:                                #   in Loop: Header=BB2_1 Depth=1
	lbu	a1, -14(s0)
	lui	a0, %hi(RoundKey)
	addi	a0, a0, %lo(RoundKey)
	add	a0, a0, a1
	addi	a1, a0, -16
	addi	a2, zero, 16
	call	memcpy
	lbu	a0, -13(s0)
	bne	a0, zero, .LBB2_5
	jal	zero, .LBB2_4
.LBB2_4:                                #   in Loop: Header=BB2_1 Depth=1
	addi	a0, zero, 27
	sb	a0, -13(s0)
	jal	zero, .LBB2_5
.LBB2_5:                                #   in Loop: Header=BB2_1 Depth=1
	lbu	a0, -14(s0)
	lui	a2, %hi(RoundKey)
	addi	a2, a2, %lo(RoundKey)
	add	a3, a2, a0
	lbu	a1, -3(a3)
	lui	a0, %hi(sbox)
	addi	a0, a0, %lo(sbox)
	add	a1, a0, a1
	lbu	a1, 0(a1)
	lbu	a4, -13(s0)
	xor	a4, a1, a4
	lbu	a1, 0(a3)
	xor	a1, a1, a4
	sb	a1, 0(a3)
	lbu	a1, -14(s0)
	add	a3, a1, a2
	lbu	a1, -2(a3)
	add	a1, a0, a1
	lbu	a4, 0(a1)
	lbu	a1, 1(a3)
	xor	a1, a1, a4
	sb	a1, 1(a3)
	lbu	a1, -14(s0)
	add	a3, a1, a2
	lbu	a1, -1(a3)
	add	a1, a0, a1
	lbu	a4, 0(a1)
	lbu	a1, 2(a3)
	xor	a1, a1, a4
	sb	a1, 2(a3)
	lbu	a1, -14(s0)
	add	a1, a1, a2
	lbu	a2, -4(a1)
	add	a0, a0, a2
	lbu	a2, 0(a0)
	lbu	a0, 3(a1)
	xor	a0, a0, a2
	sb	a0, 3(a1)
	lbu	a0, -13(s0)
	slli	a0, a0, 1
	sb	a0, -13(s0)
	jal	zero, .LBB2_7
.LBB2_6:                                #   in Loop: Header=BB2_1 Depth=1
	lbu	a1, -14(s0)
	lui	a0, %hi(RoundKey)
	addi	a0, a0, %lo(RoundKey)
	add	a1, a0, a1
	sw	a1, -24(s0)                     # 4-byte Folded Spill
	lbu	a2, -4(a1)
	lbu	a0, -3(a1)
	slli	a0, a0, 8
	or	a2, a0, a2
	lbu	a0, -2(a1)
	slli	a3, a0, 16
	lbu	a0, -1(a1)
	slli	a0, a0, 24
	or	a0, a0, a3
	or	a2, a0, a2
	lbu	a3, 0(a1)
	lbu	a0, 1(a1)
	slli	a0, a0, 8
	or	a3, a0, a3
	lbu	a0, 2(a1)
	slli	a4, a0, 16
	lbu	a0, 3(a1)
	slli	a0, a0, 24
	or	a0, a0, a4
	or	a0, a0, a3
	xor	a0, a0, a2
	srli	a2, a0, 24
	sb	a2, 3(a1)
	srli	a2, a0, 16
	sb	a2, 2(a1)
	sb	a0, 0(a1)
	srli	a0, a0, 8
	sb	a0, 1(a1)
	jal	zero, .LBB2_7
.LBB2_7:                                #   in Loop: Header=BB2_1 Depth=1
	jal	zero, .LBB2_8
.LBB2_8:                                #   in Loop: Header=BB2_1 Depth=1
	lbu	a0, -14(s0)
	addi	a0, a0, 4
	sb	a0, -14(s0)
	jal	zero, .LBB2_1
.LBB2_9:
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	jalr	zero, 0(ra)
.Lfunc_end2:
	.size	KeyExpansion, .Lfunc_end2-KeyExpansion
                                        # -- End function
	.p2align	2                               # -- Begin function rijndaelEncrypt
	.type	rijndaelEncrypt,@function
rijndaelEncrypt:                        # @rijndaelEncrypt
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	lw	a0, -16(s0)
	sw	a0, -24(s0)
	lw	a0, -12(s0)
	lw	a1, -16(s0)
	beq	a0, a1, .LBB3_2
	jal	zero, .LBB3_1
.LBB3_1:
	lw	a0, -24(s0)
	lw	a1, -12(s0)
	addi	a2, zero, 16
	call	memcpy
	jal	zero, .LBB3_2
.LBB3_2:
	addi	a0, zero, 0
	sb	a0, -17(s0)
	jal	zero, .LBB3_3
.LBB3_3:                                # =>This Inner Loop Header: Depth=1
	lbu	a0, -17(s0)
	addi	a1, zero, 10
	beq	a0, a1, .LBB3_12
	jal	zero, .LBB3_4
.LBB3_4:                                #   in Loop: Header=BB3_3 Depth=1
	lbu	a0, -17(s0)
	lw	a1, -16(s0)
	call	AddRoundKey
	lbu	a0, -17(s0)
	bne	a0, zero, .LBB3_6
	jal	zero, .LBB3_5
.LBB3_5:                                #   in Loop: Header=BB3_3 Depth=1
	call	trace_start
	jal	zero, .LBB3_6
.LBB3_6:                                #   in Loop: Header=BB3_3 Depth=1
	lw	a0, -16(s0)
	call	SubBytes
	lbu	a0, -17(s0)
	bne	a0, zero, .LBB3_8
	jal	zero, .LBB3_7
.LBB3_7:                                #   in Loop: Header=BB3_3 Depth=1
	call	trace_stop
	jal	zero, .LBB3_8
.LBB3_8:                                #   in Loop: Header=BB3_3 Depth=1
	lw	a0, -24(s0)
	call	ShiftRows
	lbu	a0, -17(s0)
	addi	a1, a0, 1
	andi	a0, a1, 255
	sb	a1, -17(s0)
	addi	a1, zero, 10
	beq	a0, a1, .LBB3_10
	jal	zero, .LBB3_9
.LBB3_9:                                #   in Loop: Header=BB3_3 Depth=1
	lw	a0, -24(s0)
	call	MixColumns
	jal	zero, .LBB3_11
.LBB3_10:                               #   in Loop: Header=BB3_3 Depth=1
	lw	a1, -16(s0)
	addi	a0, zero, 10
	call	AddRoundKey
	jal	zero, .LBB3_11
.LBB3_11:                               #   in Loop: Header=BB3_3 Depth=1
	jal	zero, .LBB3_3
.LBB3_12:
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	jalr	zero, 0(ra)
.Lfunc_end3:
	.size	rijndaelEncrypt, .Lfunc_end3-rijndaelEncrypt
                                        # -- End function
	.p2align	2                               # -- Begin function padBlock
	.type	padBlock,@function
padBlock:                               # @padBlock
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
                                        # kill: def $x12 killed $x10
	sb	a0, -9(s0)
	sw	a1, -16(s0)
	lbu	a1, -9(s0)
	addi	a0, zero, 16
	sub	a0, a0, a1
	sb	a0, -17(s0)
	lw	a0, -16(s0)
	lbu	a1, -9(s0)
	add	a0, a0, a1
	sw	a0, -24(s0)
	lw	a0, -24(s0)
	lbu	a1, -17(s0)
	andi	a2, a1, 15
	addi	a1, zero, 0
	call	memset
	lbu	a0, -9(s0)
	addi	a1, zero, 1
	sw	a1, -28(s0)                     # 4-byte Folded Spill
	bne	a0, zero, .LBB4_2
	jal	zero, .LBB4_1
.LBB4_1:
	addi	a0, zero, 0
	sw	a0, -28(s0)                     # 4-byte Folded Spill
	jal	zero, .LBB4_2
.LBB4_2:
	lw	a0, -28(s0)                     # 4-byte Folded Reload
	andi	a0, a0, 1
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	jalr	zero, 0(ra)
.Lfunc_end4:
	.size	padBlock, .Lfunc_end4-padBlock
                                        # -- End function
	.globl	AES_ECB_decrypt                 # -- Begin function AES_ECB_decrypt
	.p2align	2
	.type	AES_ECB_decrypt,@function
AES_ECB_decrypt:                        # @AES_ECB_decrypt
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	sw	a3, -24(s0)
	lw	a0, -20(s0)
	srli	a0, a0, 4
	sw	a0, -32(s0)
	lw	a0, -24(s0)
	lw	a1, -16(s0)
	lw	a2, -20(s0)
	call	memcpy
	lw	a0, -12(s0)
	call	KeyExpansion
	lw	a0, -24(s0)
	sw	a0, -28(s0)
	jal	zero, .LBB5_1
.LBB5_1:                                # =>This Inner Loop Header: Depth=1
	lw	a0, -32(s0)
	addi	a1, a0, -1
	sw	a1, -32(s0)
	beq	a0, zero, .LBB5_4
	jal	zero, .LBB5_2
.LBB5_2:                                #   in Loop: Header=BB5_1 Depth=1
	lw	a1, -28(s0)
	addi	a0, a1, 0
	call	rijndaelDecrypt
	jal	zero, .LBB5_3
.LBB5_3:                                #   in Loop: Header=BB5_1 Depth=1
	lw	a0, -28(s0)
	addi	a0, a0, 16
	sw	a0, -28(s0)
	jal	zero, .LBB5_1
.LBB5_4:
	lbu	a0, -20(s0)
	andi	a0, a0, 15
	sltiu	a0, a0, 1
	addi	a0, a0, -1
	andi	a0, a0, 29
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	jalr	zero, 0(ra)
.Lfunc_end5:
	.size	AES_ECB_decrypt, .Lfunc_end5-AES_ECB_decrypt
                                        # -- End function
	.p2align	2                               # -- Begin function rijndaelDecrypt
	.type	rijndaelDecrypt,@function
rijndaelDecrypt:                        # @rijndaelDecrypt
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	lw	a0, -16(s0)
	sw	a0, -24(s0)
	lw	a0, -12(s0)
	lw	a1, -16(s0)
	beq	a0, a1, .LBB6_2
	jal	zero, .LBB6_1
.LBB6_1:
	lw	a0, -24(s0)
	lw	a1, -12(s0)
	addi	a2, zero, 16
	call	memcpy
	jal	zero, .LBB6_2
.LBB6_2:
	addi	a0, zero, 10
	sb	a0, -17(s0)
	jal	zero, .LBB6_3
.LBB6_3:                                # =>This Inner Loop Header: Depth=1
	lbu	a0, -17(s0)
	beq	a0, zero, .LBB6_8
	jal	zero, .LBB6_4
.LBB6_4:                                #   in Loop: Header=BB6_3 Depth=1
	lbu	a0, -17(s0)
	addi	a1, a0, -1
	sb	a1, -17(s0)
	addi	a1, zero, 10
	beq	a0, a1, .LBB6_6
	jal	zero, .LBB6_5
.LBB6_5:                                #   in Loop: Header=BB6_3 Depth=1
	lw	a0, -24(s0)
	call	InvMixColumns
	jal	zero, .LBB6_7
.LBB6_6:                                #   in Loop: Header=BB6_3 Depth=1
	lw	a1, -16(s0)
	addi	a0, zero, 10
	call	AddRoundKey
	jal	zero, .LBB6_7
.LBB6_7:                                #   in Loop: Header=BB6_3 Depth=1
	lw	a0, -24(s0)
	call	InvShiftRows
	lw	a0, -16(s0)
	call	InvSubBytes
	lbu	a0, -17(s0)
	lw	a1, -16(s0)
	call	AddRoundKey
	jal	zero, .LBB6_3
.LBB6_8:
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	jalr	zero, 0(ra)
.Lfunc_end6:
	.size	rijndaelDecrypt, .Lfunc_end6-rijndaelDecrypt
                                        # -- End function
	.globl	AES_CBC_encrypt                 # -- Begin function AES_CBC_encrypt
	.p2align	2
	.type	AES_CBC_encrypt,@function
AES_CBC_encrypt:                        # @AES_CBC_encrypt
# %bb.0:
	addi	sp, sp, -80
	sw	ra, 76(sp)                      # 4-byte Folded Spill
	sw	s0, 72(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 80
	sw	a0, -16(s0)
	sw	a1, -20(s0)
	sw	a2, -24(s0)
	sw	a3, -28(s0)
	sw	a4, -32(s0)
	lw	a0, -20(s0)
	sw	a0, -36(s0)
	lw	a0, -28(s0)
	andi	a0, a0, 15
	sb	a0, -37(s0)
	lw	a0, -28(s0)
	srli	a0, a0, 4
	sw	a0, -48(s0)
	lw	a0, -48(s0)
	addi	a1, zero, 2
	bltu	a0, a1, .LBB7_4
	jal	zero, .LBB7_1
.LBB7_1:
	lbu	a0, -37(s0)
	bne	a0, zero, .LBB7_4
	jal	zero, .LBB7_2
.LBB7_2:
	lw	a0, -48(s0)
	addi	a0, a0, -1
	sw	a0, -48(s0)
	beq	a0, zero, .LBB7_4
	jal	zero, .LBB7_3
.LBB7_3:
	addi	a0, zero, 16
	sb	a0, -37(s0)
	jal	zero, .LBB7_4
.LBB7_4:
	lw	a0, -48(s0)
	bne	a0, zero, .LBB7_6
	jal	zero, .LBB7_5
.LBB7_5:
	addi	a0, zero, 1
	sb	a0, -9(s0)
	jal	zero, .LBB7_13
.LBB7_6:
	lw	a0, -32(s0)
	lw	a1, -24(s0)
	lw	a2, -28(s0)
	call	memcpy
	lw	a0, -16(s0)
	call	KeyExpansion
	lw	a0, -32(s0)
	sw	a0, -44(s0)
	jal	zero, .LBB7_7
.LBB7_7:                                # =>This Inner Loop Header: Depth=1
	lw	a0, -48(s0)
	addi	a1, a0, -1
	sw	a1, -48(s0)
	beq	a0, zero, .LBB7_10
	jal	zero, .LBB7_8
.LBB7_8:                                #   in Loop: Header=BB7_7 Depth=1
	lw	a0, -36(s0)
	lw	a1, -44(s0)
	call	xorBlock
	lw	a1, -44(s0)
	addi	a0, a1, 0
	call	rijndaelEncrypt
	lw	a0, -44(s0)
	sw	a0, -36(s0)
	jal	zero, .LBB7_9
.LBB7_9:                                #   in Loop: Header=BB7_7 Depth=1
	lw	a0, -44(s0)
	addi	a0, a0, 16
	sw	a0, -44(s0)
	jal	zero, .LBB7_7
.LBB7_10:
	lbu	a0, -37(s0)
	beq	a0, zero, .LBB7_12
	jal	zero, .LBB7_11
.LBB7_11:
	addi	a0, zero, 0
	sw	a0, -52(s0)
	sw	a0, -56(s0)
	sw	a0, -60(s0)
	sw	a0, -64(s0)
	lw	a1, -44(s0)
	lbu	a2, -37(s0)
	addi	a0, s0, -64
	sw	a0, -68(s0)                     # 4-byte Folded Spill
	call	memcpy
	lw	a0, -44(s0)
	addi	a1, a0, -16
	lbu	a2, -37(s0)
	call	memcpy
                                        # kill: def $x11 killed $x10
	lw	a0, -68(s0)                     # 4-byte Folded Reload
	lw	a1, -44(s0)
	addi	a1, a1, -16
	sw	a1, -44(s0)
	sw	a0, -36(s0)
	lw	a0, -36(s0)
	lw	a1, -44(s0)
	call	xorBlock
	lw	a1, -44(s0)
	addi	a0, a1, 0
	call	rijndaelEncrypt
	jal	zero, .LBB7_12
.LBB7_12:
	addi	a0, zero, 0
	sb	a0, -9(s0)
	jal	zero, .LBB7_13
.LBB7_13:
	lbu	a0, -9(s0)
	lw	ra, 76(sp)                      # 4-byte Folded Reload
	lw	s0, 72(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 80
	jalr	zero, 0(ra)
.Lfunc_end7:
	.size	AES_CBC_encrypt, .Lfunc_end7-AES_CBC_encrypt
                                        # -- End function
	.p2align	2                               # -- Begin function xorBlock
	.type	xorBlock,@function
xorBlock:                               # @xorBlock
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	addi	a0, zero, 0
	sb	a0, -17(s0)
	jal	zero, .LBB8_1
.LBB8_1:                                # =>This Inner Loop Header: Depth=1
	lbu	a1, -17(s0)
	addi	a0, zero, 15
	blt	a0, a1, .LBB8_4
	jal	zero, .LBB8_2
.LBB8_2:                                #   in Loop: Header=BB8_1 Depth=1
	lw	a0, -12(s0)
	lbu	a1, -17(s0)
	add	a0, a0, a1
	lbu	a2, 0(a0)
	lw	a0, -16(s0)
	add	a1, a0, a1
	lbu	a0, 0(a1)
	xor	a0, a0, a2
	sb	a0, 0(a1)
	jal	zero, .LBB8_3
.LBB8_3:                                #   in Loop: Header=BB8_1 Depth=1
	lbu	a0, -17(s0)
	addi	a0, a0, 1
	sb	a0, -17(s0)
	jal	zero, .LBB8_1
.LBB8_4:
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	jalr	zero, 0(ra)
.Lfunc_end8:
	.size	xorBlock, .Lfunc_end8-xorBlock
                                        # -- End function
	.globl	AES_CBC_decrypt                 # -- Begin function AES_CBC_decrypt
	.p2align	2
	.type	AES_CBC_decrypt,@function
AES_CBC_decrypt:                        # @AES_CBC_decrypt
# %bb.0:
	addi	sp, sp, -64
	sw	ra, 60(sp)                      # 4-byte Folded Spill
	sw	s0, 56(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 64
	sw	a0, -16(s0)
	sw	a1, -20(s0)
	sw	a2, -24(s0)
	sw	a3, -28(s0)
	sw	a4, -32(s0)
	lw	a0, -24(s0)
	sw	a0, -36(s0)
	lw	a0, -20(s0)
	sw	a0, -40(s0)
	lw	a0, -28(s0)
	andi	a0, a0, 15
	sb	a0, -41(s0)
	lw	a0, -28(s0)
	srli	a0, a0, 4
	sw	a0, -52(s0)
	lw	a0, -52(s0)
	addi	a1, zero, 2
	bltu	a0, a1, .LBB9_4
	jal	zero, .LBB9_1
.LBB9_1:
	lbu	a0, -41(s0)
	bne	a0, zero, .LBB9_4
	jal	zero, .LBB9_2
.LBB9_2:
	lw	a0, -52(s0)
	addi	a0, a0, -1
	sw	a0, -52(s0)
	beq	a0, zero, .LBB9_4
	jal	zero, .LBB9_3
.LBB9_3:
	addi	a0, zero, 16
	sb	a0, -41(s0)
	jal	zero, .LBB9_4
.LBB9_4:
	lw	a0, -52(s0)
	bne	a0, zero, .LBB9_6
	jal	zero, .LBB9_5
.LBB9_5:
	addi	a0, zero, 1
	sb	a0, -9(s0)
	jal	zero, .LBB9_13
.LBB9_6:
	lbu	a1, -41(s0)
	addi	a0, zero, 0
	slt	a1, a0, a1
	lw	a0, -52(s0)
	sub	a0, a0, a1
	sw	a0, -52(s0)
	lw	a0, -16(s0)
	call	KeyExpansion
	lw	a0, -32(s0)
	sw	a0, -48(s0)
	jal	zero, .LBB9_7
.LBB9_7:                                # =>This Inner Loop Header: Depth=1
	lw	a0, -52(s0)
	addi	a1, a0, -1
	sw	a1, -52(s0)
	beq	a0, zero, .LBB9_10
	jal	zero, .LBB9_8
.LBB9_8:                                #   in Loop: Header=BB9_7 Depth=1
	lw	a0, -36(s0)
	lw	a1, -48(s0)
	call	rijndaelDecrypt
	lw	a0, -40(s0)
	lw	a1, -48(s0)
	call	xorBlock
	lw	a0, -36(s0)
	sw	a0, -40(s0)
	lw	a0, -36(s0)
	addi	a0, a0, 16
	sw	a0, -36(s0)
	jal	zero, .LBB9_9
.LBB9_9:                                #   in Loop: Header=BB9_7 Depth=1
	lw	a0, -48(s0)
	addi	a0, a0, 16
	sw	a0, -48(s0)
	jal	zero, .LBB9_7
.LBB9_10:
	lbu	a0, -41(s0)
	beq	a0, zero, .LBB9_12
	jal	zero, .LBB9_11
.LBB9_11:
	lw	a0, -36(s0)
	addi	a0, a0, 16
	sw	a0, -56(s0)
	lw	a1, -36(s0)
	lw	a2, -48(s0)
	lw	a3, -56(s0)
	lbu	a4, -41(s0)
	addi	a5, a2, 16
	lui	a0, %hi(rijndaelDecrypt)
	addi	a0, a0, %lo(rijndaelDecrypt)
	call	mixThenXor
	lw	a0, -48(s0)
	lw	a1, -56(s0)
	lbu	a2, -41(s0)
	call	memcpy
	lw	a1, -48(s0)
	addi	a0, a1, 0
	call	rijndaelDecrypt
	lw	a0, -40(s0)
	lw	a1, -48(s0)
	call	xorBlock
	jal	zero, .LBB9_12
.LBB9_12:
	addi	a0, zero, 0
	sb	a0, -9(s0)
	jal	zero, .LBB9_13
.LBB9_13:
	lbu	a0, -9(s0)
	lw	ra, 60(sp)                      # 4-byte Folded Reload
	lw	s0, 56(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 64
	jalr	zero, 0(ra)
.Lfunc_end9:
	.size	AES_CBC_decrypt, .Lfunc_end9-AES_CBC_decrypt
                                        # -- End function
	.p2align	2                               # -- Begin function mixThenXor
	.type	mixThenXor,@function
mixThenXor:                             # @mixThenXor
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
                                        # kill: def $x16 killed $x14
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	sw	a3, -24(s0)
	sb	a4, -25(s0)
	sw	a5, -32(s0)
	lbu	a0, -25(s0)
	bne	a0, zero, .LBB10_2
	jal	zero, .LBB10_1
.LBB10_1:
	jal	zero, .LBB10_5
.LBB10_2:
	lw	a2, -12(s0)
	lw	a0, -16(s0)
	lw	a1, -20(s0)
	jalr	ra, 0(a2)
	jal	zero, .LBB10_3
.LBB10_3:                               # =>This Inner Loop Header: Depth=1
	lbu	a0, -25(s0)
	addi	a1, a0, -1
	sb	a1, -25(s0)
	beq	a0, zero, .LBB10_5
	jal	zero, .LBB10_4
.LBB10_4:                               #   in Loop: Header=BB10_3 Depth=1
	lw	a0, -20(s0)
	lbu	a2, -25(s0)
	add	a0, a0, a2
	lbu	a0, 0(a0)
	lw	a1, -24(s0)
	add	a1, a1, a2
	lbu	a1, 0(a1)
	xor	a0, a0, a1
	lw	a1, -32(s0)
	add	a1, a1, a2
	sb	a0, 0(a1)
	jal	zero, .LBB10_3
.LBB10_5:
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	jalr	zero, 0(ra)
.Lfunc_end10:
	.size	mixThenXor, .Lfunc_end10-mixThenXor
                                        # -- End function
	.globl	AES_CFB_encrypt                 # -- Begin function AES_CFB_encrypt
	.p2align	2
	.type	AES_CFB_encrypt,@function
AES_CFB_encrypt:                        # @AES_CFB_encrypt
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	sw	a3, -24(s0)
	sw	a4, -28(s0)
	lw	a0, -12(s0)
	lw	a1, -16(s0)
	lw	a3, -20(s0)
	lw	a4, -24(s0)
	lw	a5, -28(s0)
	addi	a2, zero, 1
	call	CFB_cipher
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	jalr	zero, 0(ra)
.Lfunc_end11:
	.size	AES_CFB_encrypt, .Lfunc_end11-AES_CFB_encrypt
                                        # -- End function
	.p2align	2                               # -- Begin function CFB_cipher
	.type	CFB_cipher,@function
CFB_cipher:                             # @CFB_cipher
# %bb.0:
	addi	sp, sp, -80
	sw	ra, 76(sp)                      # 4-byte Folded Spill
	sw	s0, 72(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 80
                                        # kill: def $x16 killed $x12
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sb	a2, -17(s0)
	sw	a3, -24(s0)
	sw	a4, -28(s0)
	sw	a5, -32(s0)
	lw	a0, -16(s0)
	sw	a0, -36(s0)
	lw	a0, -24(s0)
	sw	a0, -40(s0)
	lw	a0, -28(s0)
	srli	a0, a0, 4
	sw	a0, -64(s0)
	lw	a0, -12(s0)
	call	KeyExpansion
	lw	a0, -32(s0)
	sw	a0, -44(s0)
	jal	zero, .LBB12_1
.LBB12_1:                               # =>This Inner Loop Header: Depth=1
	lw	a0, -64(s0)
	addi	a1, a0, -1
	sw	a1, -64(s0)
	beq	a0, zero, .LBB12_7
	jal	zero, .LBB12_2
.LBB12_2:                               #   in Loop: Header=BB12_1 Depth=1
	lw	a0, -36(s0)
	lw	a1, -44(s0)
	call	rijndaelEncrypt
	lw	a0, -40(s0)
	lw	a1, -44(s0)
	call	xorBlock
	lbu	a0, -17(s0)
	beq	a0, zero, .LBB12_4
	jal	zero, .LBB12_3
.LBB12_3:                               #   in Loop: Header=BB12_1 Depth=1
	lw	a0, -44(s0)
	sw	a0, -68(s0)                     # 4-byte Folded Spill
	jal	zero, .LBB12_5
.LBB12_4:                               #   in Loop: Header=BB12_1 Depth=1
	lw	a0, -40(s0)
	sw	a0, -68(s0)                     # 4-byte Folded Spill
	jal	zero, .LBB12_5
.LBB12_5:                               #   in Loop: Header=BB12_1 Depth=1
	lw	a0, -68(s0)                     # 4-byte Folded Reload
	sw	a0, -36(s0)
	lw	a0, -40(s0)
	addi	a0, a0, 16
	sw	a0, -40(s0)
	jal	zero, .LBB12_6
.LBB12_6:                               #   in Loop: Header=BB12_1 Depth=1
	lw	a0, -44(s0)
	addi	a0, a0, 16
	sw	a0, -44(s0)
	jal	zero, .LBB12_1
.LBB12_7:
	lw	a1, -36(s0)
	lw	a3, -40(s0)
	lw	a0, -28(s0)
	andi	a4, a0, 15
	lw	a5, -44(s0)
	lui	a0, %hi(rijndaelEncrypt)
	addi	a0, a0, %lo(rijndaelEncrypt)
	addi	a2, s0, -60
	call	mixThenXor
	lw	ra, 76(sp)                      # 4-byte Folded Reload
	lw	s0, 72(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 80
	jalr	zero, 0(ra)
.Lfunc_end12:
	.size	CFB_cipher, .Lfunc_end12-CFB_cipher
                                        # -- End function
	.globl	AES_CFB_decrypt                 # -- Begin function AES_CFB_decrypt
	.p2align	2
	.type	AES_CFB_decrypt,@function
AES_CFB_decrypt:                        # @AES_CFB_decrypt
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	sw	a3, -24(s0)
	sw	a4, -28(s0)
	lw	a0, -12(s0)
	lw	a1, -16(s0)
	lw	a3, -20(s0)
	lw	a4, -24(s0)
	lw	a5, -28(s0)
	addi	a2, zero, 0
	call	CFB_cipher
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	jalr	zero, 0(ra)
.Lfunc_end13:
	.size	AES_CFB_decrypt, .Lfunc_end13-AES_CFB_decrypt
                                        # -- End function
	.globl	AES_OFB_encrypt                 # -- Begin function AES_OFB_encrypt
	.p2align	2
	.type	AES_OFB_encrypt,@function
AES_OFB_encrypt:                        # @AES_OFB_encrypt
# %bb.0:
	addi	sp, sp, -64
	sw	ra, 60(sp)                      # 4-byte Folded Spill
	sw	s0, 56(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 64
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	sw	a3, -24(s0)
	sw	a4, -28(s0)
	lw	a0, -24(s0)
	srli	a0, a0, 4
	sw	a0, -32(s0)
	lw	a1, -16(s0)
	addi	a0, s0, -52
	addi	a2, zero, 16
	call	memcpy
	lw	a0, -28(s0)
	lw	a1, -20(s0)
	lw	a2, -24(s0)
	call	memcpy
	lw	a0, -12(s0)
	call	KeyExpansion
	lw	a0, -28(s0)
	sw	a0, -36(s0)
	jal	zero, .LBB14_1
.LBB14_1:                               # =>This Inner Loop Header: Depth=1
	lw	a0, -32(s0)
	addi	a1, a0, -1
	sw	a1, -32(s0)
	beq	a0, zero, .LBB14_4
	jal	zero, .LBB14_2
.LBB14_2:                               #   in Loop: Header=BB14_1 Depth=1
	addi	a1, s0, -52
	sw	a1, -56(s0)                     # 4-byte Folded Spill
	addi	a0, a1, 0
	call	rijndaelEncrypt
	lw	a0, -56(s0)                     # 4-byte Folded Reload
	lw	a1, -36(s0)
	call	xorBlock
	jal	zero, .LBB14_3
.LBB14_3:                               #   in Loop: Header=BB14_1 Depth=1
	lw	a0, -36(s0)
	addi	a0, a0, 16
	sw	a0, -36(s0)
	jal	zero, .LBB14_1
.LBB14_4:
	lw	a5, -36(s0)
	lw	a0, -24(s0)
	andi	a4, a0, 15
	lui	a0, %hi(rijndaelEncrypt)
	addi	a0, a0, %lo(rijndaelEncrypt)
	addi	a2, s0, -52
	addi	a1, a2, 0
	addi	a3, a5, 0
	call	mixThenXor
	lw	ra, 60(sp)                      # 4-byte Folded Reload
	lw	s0, 56(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 64
	jalr	zero, 0(ra)
.Lfunc_end14:
	.size	AES_OFB_encrypt, .Lfunc_end14-AES_OFB_encrypt
                                        # -- End function
	.globl	AES_OFB_decrypt                 # -- Begin function AES_OFB_decrypt
	.p2align	2
	.type	AES_OFB_decrypt,@function
AES_OFB_decrypt:                        # @AES_OFB_decrypt
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	sw	a3, -24(s0)
	sw	a4, -28(s0)
	lw	a0, -12(s0)
	lw	a1, -16(s0)
	lw	a2, -20(s0)
	lw	a3, -24(s0)
	lw	a4, -28(s0)
	call	AES_OFB_encrypt
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	jalr	zero, 0(ra)
.Lfunc_end15:
	.size	AES_OFB_decrypt, .Lfunc_end15-AES_OFB_decrypt
                                        # -- End function
	.globl	AES_CTR_encrypt                 # -- Begin function AES_CTR_encrypt
	.p2align	2
	.type	AES_CTR_encrypt,@function
AES_CTR_encrypt:                        # @AES_CTR_encrypt
# %bb.0:
	addi	sp, sp, -64
	sw	ra, 60(sp)                      # 4-byte Folded Spill
	sw	s0, 56(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 64
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	sw	a3, -24(s0)
	sw	a4, -28(s0)
	addi	a0, zero, 0
	sw	a0, -48(s0)                     # 4-byte Folded Spill
	sw	a0, -32(s0)
	sw	a0, -36(s0)
	sw	a0, -40(s0)
	sw	a0, -44(s0)
	lw	a1, -16(s0)
	addi	a0, s0, -44
	sw	a0, -52(s0)                     # 4-byte Folded Spill
	addi	a2, zero, 12
	call	memcpy
                                        # kill: def $x11 killed $x10
	lw	a0, -52(s0)                     # 4-byte Folded Reload
	addi	a1, zero, 1
	addi	a2, zero, 15
	call	xorBEint
	lw	a0, -12(s0)
	call	KeyExpansion
	lw	a0, -52(s0)                     # 4-byte Folded Reload
	lw	a1, -48(s0)                     # 4-byte Folded Reload
	lw	a2, -20(s0)
	lw	a3, -24(s0)
	lw	a4, -28(s0)
	call	CTR_cipher
	lw	ra, 60(sp)                      # 4-byte Folded Reload
	lw	s0, 56(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 64
	jalr	zero, 0(ra)
.Lfunc_end16:
	.size	AES_CTR_encrypt, .Lfunc_end16-AES_CTR_encrypt
                                        # -- End function
	.p2align	2                               # -- Begin function xorBEint
	.type	xorBEint,@function
xorBEint:                               # @xorBEint
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
                                        # kill: def $x13 killed $x12
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sb	a2, -17(s0)
	jal	zero, .LBB17_1
.LBB17_1:                               # =>This Inner Loop Header: Depth=1
	lw	a2, -16(s0)
	lw	a0, -12(s0)
	lbu	a1, -17(s0)
	addi	a3, a1, -1
	sb	a3, -17(s0)
	add	a1, a0, a1
	lbu	a0, 0(a1)
	xor	a0, a0, a2
	sb	a0, 0(a1)
	jal	zero, .LBB17_2
.LBB17_2:                               #   in Loop: Header=BB17_1 Depth=1
	lw	a0, -16(s0)
	srli	a0, a0, 8
	sw	a0, -16(s0)
	bne	a0, zero, .LBB17_1
	jal	zero, .LBB17_3
.LBB17_3:
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	jalr	zero, 0(ra)
.Lfunc_end17:
	.size	xorBEint, .Lfunc_end17-xorBEint
                                        # -- End function
	.p2align	2                               # -- Begin function CTR_cipher
	.type	CTR_cipher,@function
CTR_cipher:                             # @CTR_cipher
# %bb.0:
	addi	sp, sp, -96
	sw	ra, 92(sp)                      # 4-byte Folded Spill
	sw	s0, 88(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 96
                                        # kill: def $x15 killed $x11
	sw	a0, -12(s0)
	sb	a1, -13(s0)
	sw	a2, -20(s0)
	sw	a3, -24(s0)
	sw	a4, -28(s0)
	lw	a0, -24(s0)
	srli	a0, a0, 4
	sw	a0, -64(s0)
	addi	a0, zero, 15
	sb	a0, -65(s0)
	lw	a0, -28(s0)
	lw	a1, -20(s0)
	lw	a2, -24(s0)
	call	memcpy
	lw	a1, -12(s0)
	addi	a0, s0, -44
	addi	a2, zero, 16
	call	memcpy
	lbu	a0, -13(s0)
	sw	a0, -76(s0)                     # 4-byte Folded Spill
	addi	a1, zero, 2
	beq	a0, a1, .LBB18_5
	jal	zero, .LBB18_1
.LBB18_1:
	lw	a0, -76(s0)                     # 4-byte Folded Reload
	addi	a1, zero, 5
	beq	a0, a1, .LBB18_3
	jal	zero, .LBB18_2
.LBB18_2:
	lw	a0, -76(s0)                     # 4-byte Folded Reload
	addi	a1, zero, 8
	beq	a0, a1, .LBB18_4
	jal	zero, .LBB18_6
.LBB18_3:
	lbu	a0, -36(s0)
	andi	a0, a0, 127
	sb	a0, -36(s0)
	lbu	a0, -32(s0)
	andi	a0, a0, 127
	sb	a0, -32(s0)
	jal	zero, .LBB18_6
.LBB18_4:
	lbu	a0, -29(s0)
	ori	a0, a0, 128
	sb	a0, -29(s0)
	addi	a0, zero, 0
	sb	a0, -65(s0)
	jal	zero, .LBB18_6
.LBB18_5:
	lbu	a1, -65(s0)
	addi	a0, s0, -44
	call	incBlock
	jal	zero, .LBB18_6
.LBB18_6:
	lw	a0, -28(s0)
	sw	a0, -72(s0)
	jal	zero, .LBB18_7
.LBB18_7:                               # =>This Inner Loop Header: Depth=1
	lw	a0, -64(s0)
	addi	a1, a0, -1
	sw	a1, -64(s0)
	beq	a0, zero, .LBB18_10
	jal	zero, .LBB18_8
.LBB18_8:                               #   in Loop: Header=BB18_7 Depth=1
	addi	a0, s0, -44
	sw	a0, -80(s0)                     # 4-byte Folded Spill
	addi	a1, s0, -60
	sw	a1, -84(s0)                     # 4-byte Folded Spill
	call	rijndaelEncrypt
	lw	a0, -84(s0)                     # 4-byte Folded Reload
	lw	a1, -72(s0)
	call	xorBlock
	lw	a0, -80(s0)                     # 4-byte Folded Reload
	lbu	a1, -65(s0)
	call	incBlock
	jal	zero, .LBB18_9
.LBB18_9:                               #   in Loop: Header=BB18_7 Depth=1
	lw	a0, -72(s0)
	addi	a0, a0, 16
	sw	a0, -72(s0)
	jal	zero, .LBB18_7
.LBB18_10:
	lw	a5, -72(s0)
	lw	a0, -24(s0)
	andi	a4, a0, 15
	lui	a0, %hi(rijndaelEncrypt)
	addi	a0, a0, %lo(rijndaelEncrypt)
	addi	a2, s0, -44
	addi	a1, a2, 0
	addi	a3, a5, 0
	call	mixThenXor
	lw	ra, 92(sp)                      # 4-byte Folded Reload
	lw	s0, 88(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 96
	jalr	zero, 0(ra)
.Lfunc_end18:
	.size	CTR_cipher, .Lfunc_end18-CTR_cipher
                                        # -- End function
	.globl	AES_CTR_decrypt                 # -- Begin function AES_CTR_decrypt
	.p2align	2
	.type	AES_CTR_decrypt,@function
AES_CTR_decrypt:                        # @AES_CTR_decrypt
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	sw	a3, -24(s0)
	sw	a4, -28(s0)
	lw	a0, -12(s0)
	lw	a1, -16(s0)
	lw	a2, -20(s0)
	lw	a3, -24(s0)
	lw	a4, -28(s0)
	call	AES_CTR_encrypt
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	jalr	zero, 0(ra)
.Lfunc_end19:
	.size	AES_CTR_decrypt, .Lfunc_end19-AES_CTR_decrypt
                                        # -- End function
	.globl	AES_XTS_encrypt                 # -- Begin function AES_XTS_encrypt
	.p2align	2
	.type	AES_XTS_encrypt,@function
AES_XTS_encrypt:                        # @AES_XTS_encrypt
# %bb.0:
	addi	sp, sp, -48
	sw	ra, 44(sp)                      # 4-byte Folded Spill
	sw	s0, 40(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 48
	sw	a0, -16(s0)
	sw	a1, -20(s0)
	sw	a2, -24(s0)
	sw	a3, -28(s0)
	sw	a4, -32(s0)
	lw	a1, -28(s0)
	addi	a0, zero, 15
	bltu	a0, a1, .LBB20_2
	jal	zero, .LBB20_1
.LBB20_1:
	addi	a0, zero, 1
	sb	a0, -9(s0)
	jal	zero, .LBB20_3
.LBB20_2:
	lw	a0, -32(s0)
	lw	a1, -24(s0)
	lw	a2, -28(s0)
	call	memcpy
	lw	a0, -16(s0)
	lw	a2, -20(s0)
	lw	a4, -28(s0)
	lw	a5, -32(s0)
	addi	a1, zero, 1
	addi	a3, zero, 0
	sw	a3, -36(s0)                     # 4-byte Folded Spill
	call	XTS_cipher
	lw	a0, -36(s0)                     # 4-byte Folded Reload
	sb	a0, -9(s0)
	jal	zero, .LBB20_3
.LBB20_3:
	lbu	a0, -9(s0)
	lw	ra, 44(sp)                      # 4-byte Folded Reload
	lw	s0, 40(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 48
	jalr	zero, 0(ra)
.Lfunc_end20:
	.size	AES_XTS_encrypt, .Lfunc_end20-AES_XTS_encrypt
                                        # -- End function
	.p2align	2                               # -- Begin function XTS_cipher
	.type	XTS_cipher,@function
XTS_cipher:                             # @XTS_cipher
# %bb.0:
	addi	sp, sp, -112
	sw	ra, 108(sp)                     # 4-byte Folded Spill
	sw	s0, 104(sp)                     # 4-byte Folded Spill
	addi	s0, sp, 112
                                        # kill: def $x16 killed $x11
	sw	a0, -12(s0)
	sb	a1, -13(s0)
	sw	a2, -20(s0)
	sw	a3, -24(s0)
	sw	a4, -28(s0)
	sw	a5, -32(s0)
	lbu	a0, -13(s0)
	lui	a1, %hi(rijndaelDecrypt)
	addi	a1, a1, %lo(rijndaelDecrypt)
	sw	a1, -88(s0)                     # 4-byte Folded Spill
	lui	a1, %hi(rijndaelEncrypt)
	addi	a1, a1, %lo(rijndaelEncrypt)
	sw	a1, -84(s0)                     # 4-byte Folded Spill
	bne	a0, zero, .LBB21_2
# %bb.1:
	lw	a0, -88(s0)                     # 4-byte Folded Reload
	sw	a0, -84(s0)                     # 4-byte Folded Spill
.LBB21_2:
	lw	a0, -84(s0)                     # 4-byte Folded Reload
	sw	a0, -36(s0)
	lw	a0, -28(s0)
	andi	a0, a0, 15
	sb	a0, -37(s0)
	lw	a0, -28(s0)
	srli	a0, a0, 4
	lbu	a2, -37(s0)
	addi	a1, zero, 0
	slt	a1, a1, a2
	sub	a0, a0, a1
	sw	a0, -48(s0)
	lw	a0, -20(s0)
	bne	a0, zero, .LBB21_4
	jal	zero, .LBB21_3
.LBB21_3:
	addi	a0, s0, -64
	sw	a0, -96(s0)                     # 4-byte Folded Spill
	addi	a1, zero, 0
	sw	a1, -92(s0)                     # 4-byte Folded Spill
	addi	a2, zero, 16
	call	memset
	lw	a0, -96(s0)                     # 4-byte Folded Reload
	lw	a2, -92(s0)                     # 4-byte Folded Reload
	lw	a1, -24(s0)
	call	copyLint
	jal	zero, .LBB21_5
.LBB21_4:
	lw	a1, -20(s0)
	addi	a0, s0, -64
	addi	a2, zero, 16
	call	memcpy
	jal	zero, .LBB21_5
.LBB21_5:
	lw	a0, -12(s0)
	addi	a0, a0, 16
	call	KeyExpansion
	addi	a1, s0, -64
	addi	a0, a1, 0
	call	rijndaelEncrypt
	lw	a0, -12(s0)
	call	KeyExpansion
	lw	a0, -32(s0)
	sw	a0, -44(s0)
	jal	zero, .LBB21_6
.LBB21_6:                               # =>This Inner Loop Header: Depth=1
	lw	a0, -48(s0)
	addi	a1, a0, -1
	sw	a1, -48(s0)
	beq	a0, zero, .LBB21_9
	jal	zero, .LBB21_7
.LBB21_7:                               #   in Loop: Header=BB21_6 Depth=1
	lw	a1, -44(s0)
	addi	a0, s0, -64
	sw	a0, -100(s0)                    # 4-byte Folded Spill
	call	xorBlock
	lw	a2, -36(s0)
	lw	a1, -44(s0)
	addi	a0, a1, 0
	jalr	ra, 0(a2)
	lw	a0, -100(s0)                    # 4-byte Folded Reload
	lw	a1, -44(s0)
	call	xorBlock
	lw	a0, -100(s0)                    # 4-byte Folded Reload
	call	doubleLblock
	jal	zero, .LBB21_8
.LBB21_8:                               #   in Loop: Header=BB21_6 Depth=1
	lw	a0, -44(s0)
	addi	a0, a0, 16
	sw	a0, -44(s0)
	jal	zero, .LBB21_6
.LBB21_9:
	lbu	a0, -37(s0)
	beq	a0, zero, .LBB21_14
	jal	zero, .LBB21_10
.LBB21_10:
	addi	a0, s0, -80
	addi	a1, s0, -64
	addi	a2, zero, 16
	call	memcpy
	lbu	a0, -13(s0)
	beq	a0, zero, .LBB21_12
	jal	zero, .LBB21_11
.LBB21_11:
	addi	a0, s0, -64
	sw	a0, -104(s0)                    # 4-byte Folded Spill
	jal	zero, .LBB21_13
.LBB21_12:
	addi	a0, s0, -80
	sw	a0, -104(s0)                    # 4-byte Folded Spill
	jal	zero, .LBB21_13
.LBB21_13:
	lw	a0, -104(s0)                    # 4-byte Folded Reload
	call	doubleLblock
	lw	a1, -44(s0)
	addi	a0, s0, -80
	sw	a0, -112(s0)                    # 4-byte Folded Spill
	call	xorBlock
	lw	a2, -36(s0)
	lw	a1, -44(s0)
	addi	a0, a1, 0
	jalr	ra, 0(a2)
	lw	a0, -112(s0)                    # 4-byte Folded Reload
	lw	a1, -44(s0)
	call	xorBlock
	lw	a0, -112(s0)                    # 4-byte Folded Reload
	lw	a1, -44(s0)
	addi	a2, zero, 16
	call	memcpy
	lw	a0, -44(s0)
	addi	a1, a0, 16
	lbu	a2, -37(s0)
	call	memcpy
	lw	a1, -112(s0)                    # 4-byte Folded Reload
	lw	a0, -44(s0)
	addi	a0, a0, 16
	lbu	a2, -37(s0)
	call	memcpy
	lw	a1, -44(s0)
	addi	a0, s0, -64
	sw	a0, -108(s0)                    # 4-byte Folded Spill
	call	xorBlock
	lw	a2, -36(s0)
	lw	a1, -44(s0)
	addi	a0, a1, 0
	jalr	ra, 0(a2)
	lw	a0, -108(s0)                    # 4-byte Folded Reload
	lw	a1, -44(s0)
	call	xorBlock
	jal	zero, .LBB21_14
.LBB21_14:
	lw	ra, 108(sp)                     # 4-byte Folded Reload
	lw	s0, 104(sp)                     # 4-byte Folded Reload
	addi	sp, sp, 112
	jalr	zero, 0(ra)
.Lfunc_end21:
	.size	XTS_cipher, .Lfunc_end21-XTS_cipher
                                        # -- End function
	.globl	AES_XTS_decrypt                 # -- Begin function AES_XTS_decrypt
	.p2align	2
	.type	AES_XTS_decrypt,@function
AES_XTS_decrypt:                        # @AES_XTS_decrypt
# %bb.0:
	addi	sp, sp, -48
	sw	ra, 44(sp)                      # 4-byte Folded Spill
	sw	s0, 40(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 48
	sw	a0, -16(s0)
	sw	a1, -20(s0)
	sw	a2, -24(s0)
	sw	a3, -28(s0)
	sw	a4, -32(s0)
	lw	a1, -28(s0)
	addi	a0, zero, 15
	bltu	a0, a1, .LBB22_2
	jal	zero, .LBB22_1
.LBB22_1:
	addi	a0, zero, 1
	sb	a0, -9(s0)
	jal	zero, .LBB22_3
.LBB22_2:
	lw	a0, -32(s0)
	lw	a1, -24(s0)
	lw	a2, -28(s0)
	call	memcpy
	lw	a0, -16(s0)
	lw	a2, -20(s0)
	lw	a4, -28(s0)
	lw	a5, -32(s0)
	addi	a3, zero, 0
	sw	a3, -36(s0)                     # 4-byte Folded Spill
	addi	a1, a3, 0
	call	XTS_cipher
	lw	a0, -36(s0)                     # 4-byte Folded Reload
	sb	a0, -9(s0)
	jal	zero, .LBB22_3
.LBB22_3:
	lbu	a0, -9(s0)
	lw	ra, 44(sp)                      # 4-byte Folded Reload
	lw	s0, 40(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 48
	jalr	zero, 0(ra)
.Lfunc_end22:
	.size	AES_XTS_decrypt, .Lfunc_end22-AES_XTS_decrypt
                                        # -- End function
	.globl	AES_CMAC                        # -- Begin function AES_CMAC
	.p2align	2
	.type	AES_CMAC,@function
AES_CMAC:                               # @AES_CMAC
# %bb.0:
	addi	sp, sp, -64
	sw	ra, 60(sp)                      # 4-byte Folded Spill
	sw	s0, 56(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 64
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	sw	a3, -24(s0)
	addi	a0, zero, 0
	sw	a0, -28(s0)
	sw	a0, -32(s0)
	sw	a0, -36(s0)
	sw	a0, -40(s0)
	lw	a0, -24(s0)
	addi	a1, s0, -40
	sw	a1, -64(s0)                     # 4-byte Folded Spill
	addi	a2, zero, 16
	call	memcpy
	lw	a3, -64(s0)                     # 4-byte Folded Reload
	lw	a2, -12(s0)
	lui	a0, %hi(doubleBblock)
	addi	a0, a0, %lo(doubleBblock)
	addi	a1, zero, 1
	addi	a4, s0, -56
	sw	a4, -60(s0)                     # 4-byte Folded Spill
	call	getSubkeys
	lw	a0, -64(s0)                     # 4-byte Folded Reload
	lw	a1, -60(s0)                     # 4-byte Folded Reload
	lw	a2, -16(s0)
	lw	a3, -20(s0)
	lw	a4, -24(s0)
	call	cMac
	lw	ra, 60(sp)                      # 4-byte Folded Reload
	lw	s0, 56(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 64
	jalr	zero, 0(ra)
.Lfunc_end23:
	.size	AES_CMAC, .Lfunc_end23-AES_CMAC
                                        # -- End function
	.p2align	2                               # -- Begin function getSubkeys
	.type	getSubkeys,@function
getSubkeys:                             # @getSubkeys
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
                                        # kill: def $x15 killed $x11
	sw	a0, -12(s0)
	sb	a1, -13(s0)
	sw	a2, -20(s0)
	sw	a3, -24(s0)
	sw	a4, -28(s0)
	lw	a0, -20(s0)
	call	KeyExpansion
	lw	a1, -24(s0)
	addi	a0, a1, 0
	call	rijndaelEncrypt
	lbu	a0, -13(s0)
	beq	a0, zero, .LBB24_2
	jal	zero, .LBB24_1
.LBB24_1:
	lw	a1, -12(s0)
	lw	a0, -24(s0)
	jalr	ra, 0(a1)
	jal	zero, .LBB24_2
.LBB24_2:
	lw	a0, -28(s0)
	lw	a1, -24(s0)
	addi	a2, zero, 16
	call	memcpy
	lw	a1, -12(s0)
	lw	a0, -28(s0)
	jalr	ra, 0(a1)
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	jalr	zero, 0(ra)
.Lfunc_end24:
	.size	getSubkeys, .Lfunc_end24-getSubkeys
                                        # -- End function
	.p2align	2                               # -- Begin function doubleBblock
	.type	doubleBblock,@function
doubleBblock:                           # @doubleBblock
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -12(s0)
	addi	a0, zero, 0
	sw	a0, -16(s0)
	addi	a0, zero, 16
	sw	a0, -20(s0)
	jal	zero, .LBB25_1
.LBB25_1:                               # =>This Inner Loop Header: Depth=1
	lw	a1, -20(s0)
	addi	a0, zero, 0
	bge	a0, a1, .LBB25_4
	jal	zero, .LBB25_2
.LBB25_2:                               #   in Loop: Header=BB25_1 Depth=1
	lw	a0, -12(s0)
	lw	a1, -20(s0)
	addi	a1, a1, -1
	sw	a1, -20(s0)
	add	a0, a0, a1
	lbu	a0, 0(a0)
	slli	a1, a0, 1
	lw	a0, -16(s0)
	or	a0, a0, a1
	sw	a0, -16(s0)
	lw	a0, -16(s0)
	lw	a1, -12(s0)
	lw	a2, -20(s0)
	add	a1, a1, a2
	sb	a0, 0(a1)
	jal	zero, .LBB25_3
.LBB25_3:                               #   in Loop: Header=BB25_1 Depth=1
	lw	a0, -16(s0)
	srai	a0, a0, 8
	sw	a0, -16(s0)
	jal	zero, .LBB25_1
.LBB25_4:
	lw	a0, -16(s0)
	addi	a1, zero, 135
	mul	a2, a0, a1
	lw	a1, -12(s0)
	lbu	a0, 15(a1)
	xor	a0, a0, a2
	sb	a0, 15(a1)
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	jalr	zero, 0(ra)
.Lfunc_end25:
	.size	doubleBblock, .Lfunc_end25-doubleBblock
                                        # -- End function
	.p2align	2                               # -- Begin function cMac
	.type	cMac,@function
cMac:                                   # @cMac
# %bb.0:
	addi	sp, sp, -48
	sw	ra, 44(sp)                      # 4-byte Folded Spill
	sw	s0, 40(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 48
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	sw	a3, -24(s0)
	sw	a4, -28(s0)
	lw	a0, -24(s0)
	beq	a0, zero, .LBB26_2
	jal	zero, .LBB26_1
.LBB26_1:
	lw	a0, -24(s0)
	addi	a0, a0, -1
	andi	a0, a0, 15
	addi	a0, a0, 1
	sw	a0, -44(s0)                     # 4-byte Folded Spill
	jal	zero, .LBB26_3
.LBB26_2:
	addi	a0, zero, 0
	sw	a0, -44(s0)                     # 4-byte Folded Spill
	jal	zero, .LBB26_3
.LBB26_3:
	lw	a0, -44(s0)                     # 4-byte Folded Reload
	sb	a0, -29(s0)
	lw	a0, -12(s0)
	sw	a0, -36(s0)
	lbu	a0, -29(s0)
	beq	a0, zero, .LBB26_5
	jal	zero, .LBB26_4
.LBB26_4:
	lw	a0, -20(s0)
	lw	a1, -24(s0)
	add	a0, a0, a1
	lbu	a1, -29(s0)
	sub	a0, a0, a1
	sw	a0, -48(s0)                     # 4-byte Folded Spill
	jal	zero, .LBB26_6
.LBB26_5:
	addi	a0, s0, -29
	sw	a0, -48(s0)                     # 4-byte Folded Spill
	jal	zero, .LBB26_6
.LBB26_6:
	lw	a0, -48(s0)                     # 4-byte Folded Reload
	sw	a0, -40(s0)
	lw	a0, -20(s0)
	lw	a1, -24(s0)
	lbu	a2, -29(s0)
	sub	a1, a1, a2
	lw	a4, -28(s0)
	lui	a3, %hi(rijndaelEncrypt)
	addi	a3, a3, %lo(rijndaelEncrypt)
	addi	a2, a4, 0
	call	xMac
	lbu	a1, -29(s0)
	addi	a0, zero, 15
	blt	a0, a1, .LBB26_8
	jal	zero, .LBB26_7
.LBB26_7:
	lw	a0, -28(s0)
	lbu	a1, -29(s0)
	add	a1, a0, a1
	lbu	a0, 0(a1)
	xori	a0, a0, 128
	sb	a0, 0(a1)
	lw	a0, -16(s0)
	sw	a0, -36(s0)
	jal	zero, .LBB26_8
.LBB26_8:
	lw	a0, -36(s0)
	lw	a1, -28(s0)
	call	xorBlock
	lw	a0, -40(s0)
	lbu	a1, -29(s0)
	sltiu	a2, a1, 1
	add	a1, a1, a2
	lw	a4, -28(s0)
	lui	a3, %hi(rijndaelEncrypt)
	addi	a3, a3, %lo(rijndaelEncrypt)
	addi	a2, a4, 0
	call	xMac
	lw	ra, 44(sp)                      # 4-byte Folded Reload
	lw	s0, 40(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 48
	jalr	zero, 0(ra)
.Lfunc_end26:
	.size	cMac, .Lfunc_end26-cMac
                                        # -- End function
	.globl	AES_GCM_encrypt                 # -- Begin function AES_GCM_encrypt
	.p2align	2
	.type	AES_GCM_encrypt,@function
AES_GCM_encrypt:                        # @AES_GCM_encrypt
# %bb.0:
	addi	sp, sp, -112
	sw	ra, 108(sp)                     # 4-byte Folded Spill
	sw	s0, 104(sp)                     # 4-byte Folded Spill
	addi	s0, sp, 112
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	sw	a3, -24(s0)
	sw	a4, -28(s0)
	sw	a5, -32(s0)
	sw	a6, -36(s0)
	lw	a0, -36(s0)
	lw	a1, -32(s0)
	add	a0, a0, a1
	sw	a0, -40(s0)
	addi	a0, zero, 0
	sw	a0, -44(s0)
	sw	a0, -48(s0)
	sw	a0, -52(s0)
	sw	a0, -56(s0)
	sw	a0, -60(s0)
	sw	a0, -64(s0)
	sw	a0, -68(s0)
	sw	a0, -72(s0)
	sw	a0, -76(s0)
	sw	a0, -80(s0)
	sw	a0, -84(s0)
	sw	a0, -88(s0)
	lw	a0, -12(s0)
	lw	a1, -16(s0)
	addi	a2, s0, -72
	sw	a2, -100(s0)                    # 4-byte Folded Spill
	addi	a3, s0, -56
	sw	a3, -96(s0)                     # 4-byte Folded Spill
	call	GCMsetup
	lw	a0, -96(s0)                     # 4-byte Folded Reload
	lw	a2, -28(s0)
	lw	a3, -32(s0)
	lw	a4, -36(s0)
	addi	a1, zero, 2
	call	CTR_cipher
	lw	a1, -96(s0)                     # 4-byte Folded Reload
	addi	a0, a1, 0
	call	rijndaelEncrypt
	lw	a0, -100(s0)                    # 4-byte Folded Reload
	lw	a1, -20(s0)
	lw	a2, -36(s0)
	lw	a3, -24(s0)
	lw	a4, -32(s0)
	addi	a5, s0, -88
	sw	a5, -92(s0)                     # 4-byte Folded Spill
	call	gHash
	lw	a0, -96(s0)                     # 4-byte Folded Reload
	lw	a1, -92(s0)                     # 4-byte Folded Reload
	call	xorBlock
	lw	a1, -92(s0)                     # 4-byte Folded Reload
	lw	a0, -40(s0)
	addi	a2, zero, 16
	call	memcpy
	lw	ra, 108(sp)                     # 4-byte Folded Reload
	lw	s0, 104(sp)                     # 4-byte Folded Reload
	addi	sp, sp, 112
	jalr	zero, 0(ra)
.Lfunc_end27:
	.size	AES_GCM_encrypt, .Lfunc_end27-AES_GCM_encrypt
                                        # -- End function
	.p2align	2                               # -- Begin function GCMsetup
	.type	GCMsetup,@function
GCMsetup:                               # @GCMsetup
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	sw	a3, -24(s0)
	lw	a0, -12(s0)
	call	KeyExpansion
	lw	a1, -20(s0)
	addi	a0, a1, 0
	call	rijndaelEncrypt
	lw	a0, -24(s0)
	lw	a1, -16(s0)
	addi	a2, zero, 12
	call	memcpy
	lw	a1, -24(s0)
	addi	a0, zero, 1
	sb	a0, 15(a1)
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	jalr	zero, 0(ra)
.Lfunc_end28:
	.size	GCMsetup, .Lfunc_end28-GCMsetup
                                        # -- End function
	.p2align	2                               # -- Begin function gHash
	.type	gHash,@function
gHash:                                  # @gHash
# %bb.0:
	addi	sp, sp, -64
	sw	ra, 60(sp)                      # 4-byte Folded Spill
	sw	s0, 56(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 64
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	sw	a3, -24(s0)
	sw	a4, -28(s0)
	sw	a5, -32(s0)
	addi	a0, zero, 0
	sw	a0, -36(s0)
	sw	a0, -40(s0)
	sw	a0, -44(s0)
	sw	a0, -48(s0)
	lw	a0, -24(s0)
	slli	a1, a0, 3
	addi	a0, s0, -48
	sw	a0, -56(s0)                     # 4-byte Folded Spill
	addi	a2, zero, 7
	call	xorBEint
	lw	a0, -56(s0)                     # 4-byte Folded Reload
	lw	a1, -28(s0)
	slli	a1, a1, 3
	addi	a2, zero, 15
	call	xorBEint
	lw	a0, -16(s0)
	lw	a1, -24(s0)
	lw	a2, -12(s0)
	lw	a4, -32(s0)
	lui	a3, %hi(mulGF128)
	addi	a3, a3, %lo(mulGF128)
	sw	a3, -52(s0)                     # 4-byte Folded Spill
	call	xMac
	lw	a3, -52(s0)                     # 4-byte Folded Reload
	lw	a0, -20(s0)
	lw	a1, -28(s0)
	lw	a2, -12(s0)
	lw	a4, -32(s0)
	call	xMac
	lw	a0, -56(s0)                     # 4-byte Folded Reload
	lw	a3, -52(s0)                     # 4-byte Folded Reload
	lw	a2, -12(s0)
	lw	a4, -32(s0)
	addi	a1, zero, 16
	call	xMac
	lw	ra, 60(sp)                      # 4-byte Folded Reload
	lw	s0, 56(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 64
	jalr	zero, 0(ra)
.Lfunc_end29:
	.size	gHash, .Lfunc_end29-gHash
                                        # -- End function
	.globl	AES_GCM_decrypt                 # -- Begin function AES_GCM_decrypt
	.p2align	2
	.type	AES_GCM_decrypt,@function
AES_GCM_decrypt:                        # @AES_GCM_decrypt
# %bb.0:
	addi	sp, sp, -112
	sw	ra, 108(sp)                     # 4-byte Folded Spill
	sw	s0, 104(sp)                     # 4-byte Folded Spill
	addi	s0, sp, 112
	sw	a0, -16(s0)
	sw	a1, -20(s0)
	sw	a2, -24(s0)
	sw	a3, -28(s0)
	sw	a4, -32(s0)
	sw	a5, -36(s0)
	sw	a6, -40(s0)
	lw	a0, -32(s0)
	lw	a1, -36(s0)
	add	a0, a0, a1
	sw	a0, -44(s0)
	addi	a0, zero, 0
	sw	a0, -108(s0)                    # 4-byte Folded Spill
	sw	a0, -48(s0)
	sw	a0, -52(s0)
	sw	a0, -56(s0)
	sw	a0, -60(s0)
	sw	a0, -64(s0)
	sw	a0, -68(s0)
	sw	a0, -72(s0)
	sw	a0, -76(s0)
	sw	a0, -80(s0)
	sw	a0, -84(s0)
	sw	a0, -88(s0)
	sw	a0, -92(s0)
	lw	a0, -16(s0)
	lw	a1, -20(s0)
	addi	a2, s0, -60
	sw	a2, -100(s0)                    # 4-byte Folded Spill
	addi	a3, s0, -76
	sw	a3, -104(s0)                    # 4-byte Folded Spill
	call	GCMsetup
	lw	a0, -100(s0)                    # 4-byte Folded Reload
	lw	a1, -24(s0)
	lw	a2, -32(s0)
	lw	a3, -28(s0)
	lw	a4, -36(s0)
	addi	a5, s0, -92
	sw	a5, -96(s0)                     # 4-byte Folded Spill
	call	gHash
	lw	a0, -104(s0)                    # 4-byte Folded Reload
	lw	a1, -100(s0)                    # 4-byte Folded Reload
	call	rijndaelEncrypt
	lw	a0, -100(s0)                    # 4-byte Folded Reload
	lw	a1, -96(s0)                     # 4-byte Folded Reload
	call	xorBlock
	lw	a1, -96(s0)                     # 4-byte Folded Reload
	lw	a0, -44(s0)
	addi	a2, zero, 16
	call	memcmp
	beq	a0, zero, .LBB30_2
	jal	zero, .LBB30_1
.LBB30_1:
	addi	a0, zero, 26
	sb	a0, -9(s0)
	jal	zero, .LBB30_3
.LBB30_2:
	lw	a2, -32(s0)
	lw	a3, -36(s0)
	lw	a4, -40(s0)
	addi	a0, s0, -76
	addi	a1, zero, 2
	call	CTR_cipher
	addi	a0, zero, 0
	sb	a0, -9(s0)
	jal	zero, .LBB30_3
.LBB30_3:
	lbu	a0, -9(s0)
	lw	ra, 108(sp)                     # 4-byte Folded Reload
	lw	s0, 104(sp)                     # 4-byte Folded Reload
	addi	sp, sp, 112
	jalr	zero, 0(ra)
.Lfunc_end30:
	.size	AES_GCM_decrypt, .Lfunc_end30-AES_GCM_decrypt
                                        # -- End function
	.p2align	2                               # -- Begin function memcmp
	.type	memcmp,@function
memcmp:                                 # @memcmp
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -16(s0)
	sw	a1, -20(s0)
	sw	a2, -24(s0)
	lw	a0, -16(s0)
	sw	a0, -28(s0)
	lw	a0, -20(s0)
	sw	a0, -32(s0)
	jal	zero, .LBB31_1
.LBB31_1:                               # =>This Inner Loop Header: Depth=1
	lw	a1, -24(s0)
	addi	a0, a1, -1
	sw	a0, -24(s0)
	addi	a0, zero, 0
	bge	a0, a1, .LBB31_5
	jal	zero, .LBB31_2
.LBB31_2:                               #   in Loop: Header=BB31_1 Depth=1
	lw	a0, -28(s0)
	lw	a2, -24(s0)
	add	a0, a0, a2
	lbu	a0, 0(a0)
	lw	a1, -32(s0)
	add	a1, a1, a2
	lbu	a1, 0(a1)
	beq	a0, a1, .LBB31_4
	jal	zero, .LBB31_3
.LBB31_3:
	addi	a0, zero, 1
	sw	a0, -12(s0)
	jal	zero, .LBB31_6
.LBB31_4:                               #   in Loop: Header=BB31_1 Depth=1
	jal	zero, .LBB31_1
.LBB31_5:
	addi	a0, zero, 0
	sw	a0, -12(s0)
	jal	zero, .LBB31_6
.LBB31_6:
	lw	a0, -12(s0)
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	jalr	zero, 0(ra)
.Lfunc_end31:
	.size	memcmp, .Lfunc_end31-memcmp
                                        # -- End function
	.globl	AES_CCM_encrypt                 # -- Begin function AES_CCM_encrypt
	.p2align	2
	.type	AES_CCM_encrypt,@function
AES_CCM_encrypt:                        # @AES_CCM_encrypt
# %bb.0:
	addi	sp, sp, -80
	sw	ra, 76(sp)                      # 4-byte Folded Spill
	sw	s0, 72(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 80
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	sw	a3, -24(s0)
	sw	a4, -28(s0)
	sw	a5, -32(s0)
	sw	a6, -36(s0)
	lw	a0, -36(s0)
	lw	a1, -32(s0)
	add	a0, a0, a1
	sw	a0, -40(s0)
	addi	a0, zero, 0
	sw	a0, -44(s0)
	sw	a0, -48(s0)
	sw	a0, -52(s0)
	addi	a0, zero, 3
	sw	a0, -56(s0)
	addi	a0, s0, -55
	lw	a1, -16(s0)
	addi	a2, zero, 11
	call	memcpy
	lw	a0, -12(s0)
	call	KeyExpansion
	lw	a1, -20(s0)
	lw	a2, -28(s0)
	lw	a3, -24(s0)
	lw	a4, -32(s0)
	addi	a0, s0, -56
	sw	a0, -80(s0)                     # 4-byte Folded Spill
	addi	a5, s0, -72
	sw	a5, -76(s0)                     # 4-byte Folded Spill
	call	CCMtag
	lw	a0, -80(s0)                     # 4-byte Folded Reload
	lw	a2, -28(s0)
	lw	a3, -32(s0)
	lw	a4, -36(s0)
	addi	a1, zero, 2
	call	CTR_cipher
	lw	a1, -76(s0)                     # 4-byte Folded Reload
	lw	a0, -40(s0)
	addi	a2, zero, 16
	call	memcpy
	lw	ra, 76(sp)                      # 4-byte Folded Reload
	lw	s0, 72(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 80
	jalr	zero, 0(ra)
.Lfunc_end32:
	.size	AES_CCM_encrypt, .Lfunc_end32-AES_CCM_encrypt
                                        # -- End function
	.p2align	2                               # -- Begin function CCMtag
	.type	CCMtag,@function
CCMtag:                                 # @CCMtag
# %bb.0:
	addi	sp, sp, -80
	sw	ra, 76(sp)                      # 4-byte Folded Spill
	sw	s0, 72(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 80
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	sw	a3, -24(s0)
	sw	a4, -28(s0)
	sw	a5, -32(s0)
	addi	a0, zero, 0
	sw	a0, -36(s0)
	sw	a0, -40(s0)
	sw	a0, -44(s0)
	sw	a0, -48(s0)
	addi	a1, zero, 1
	sb	a1, -49(s0)
	sb	a0, -50(s0)
	lw	a0, -32(s0)
	lw	a1, -12(s0)
	addi	a2, zero, 16
	call	memcpy
	lw	a1, -32(s0)
	lbu	a0, 0(a1)
	ori	a0, a0, 56
	sb	a0, 0(a1)
	lw	a0, -32(s0)
	lw	a1, -28(s0)
	addi	a2, zero, 15
	call	xorBEint
	lw	a0, -24(s0)
	beq	a0, zero, .LBB33_7
	jal	zero, .LBB33_1
.LBB33_1:
	lw	a1, -32(s0)
	lbu	a0, 0(a1)
	ori	a0, a0, 64
	sb	a0, 0(a1)
	lw	a1, -32(s0)
	addi	a0, a1, 0
	call	rijndaelEncrypt
	lw	a0, -24(s0)
	srli	a0, a0, 8
	addi	a1, zero, 255
	bltu	a0, a1, .LBB33_3
	jal	zero, .LBB33_2
.LBB33_2:
	lbu	a0, -49(s0)
	addi	a0, a0, 4
	sb	a0, -49(s0)
	addi	a0, zero, -1
	sb	a0, -48(s0)
	addi	a0, zero, -2
	sb	a0, -47(s0)
	jal	zero, .LBB33_3
.LBB33_3:
	lw	a1, -24(s0)
	lbu	a2, -49(s0)
	addi	a0, s0, -48
	sw	a0, -64(s0)                     # 4-byte Folded Spill
	call	xorBEint
	lw	a0, -64(s0)                     # 4-byte Folded Reload
	lbu	a2, -49(s0)
	addi	a1, a2, 1
	sb	a1, -49(s0)
	addi	a1, zero, 15
	sub	a1, a1, a2
	sb	a1, -50(s0)
	lbu	a1, -49(s0)
	add	a0, a0, a1
	sw	a0, -60(s0)                     # 4-byte Folded Spill
	lw	a0, -16(s0)
	sw	a0, -56(s0)                     # 4-byte Folded Spill
	lw	a0, -24(s0)
	lbu	a1, -50(s0)
	bgeu	a0, a1, .LBB33_5
	jal	zero, .LBB33_4
.LBB33_4:
	lw	a0, -24(s0)
	sw	a0, -68(s0)                     # 4-byte Folded Spill
	jal	zero, .LBB33_6
.LBB33_5:
	lbu	a0, -50(s0)
	sw	a0, -68(s0)                     # 4-byte Folded Spill
	jal	zero, .LBB33_6
.LBB33_6:
	lw	a1, -56(s0)                     # 4-byte Folded Reload
	lw	a0, -60(s0)                     # 4-byte Folded Reload
	lw	a2, -68(s0)                     # 4-byte Folded Reload
	call	memcpy
	jal	zero, .LBB33_7
.LBB33_7:
	lw	a4, -32(s0)
	lui	a3, %hi(rijndaelEncrypt)
	addi	a3, a3, %lo(rijndaelEncrypt)
	addi	a0, s0, -48
	addi	a1, zero, 16
	addi	a2, a4, 0
	call	xMac
	lw	a1, -24(s0)
	lbu	a0, -50(s0)
	bgeu	a0, a1, .LBB33_9
	jal	zero, .LBB33_8
.LBB33_8:
	lw	a0, -16(s0)
	lbu	a2, -50(s0)
	add	a0, a0, a2
	lw	a1, -24(s0)
	sub	a1, a1, a2
	lw	a4, -32(s0)
	lui	a3, %hi(rijndaelEncrypt)
	addi	a3, a3, %lo(rijndaelEncrypt)
	addi	a2, a4, 0
	call	xMac
	jal	zero, .LBB33_9
.LBB33_9:
	lw	a0, -20(s0)
	lw	a1, -28(s0)
	lw	a4, -32(s0)
	lui	a3, %hi(rijndaelEncrypt)
	addi	a3, a3, %lo(rijndaelEncrypt)
	addi	a2, a4, 0
	call	xMac
	lw	a0, -12(s0)
	addi	a1, s0, -48
	sw	a1, -72(s0)                     # 4-byte Folded Spill
	call	rijndaelEncrypt
	lw	a0, -72(s0)                     # 4-byte Folded Reload
	lw	a1, -32(s0)
	call	xorBlock
	lw	ra, 76(sp)                      # 4-byte Folded Reload
	lw	s0, 72(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 80
	jalr	zero, 0(ra)
.Lfunc_end33:
	.size	CCMtag, .Lfunc_end33-CCMtag
                                        # -- End function
	.globl	AES_CCM_decrypt                 # -- Begin function AES_CCM_decrypt
	.p2align	2
	.type	AES_CCM_decrypt,@function
AES_CCM_decrypt:                        # @AES_CCM_decrypt
# %bb.0:
	addi	sp, sp, -96
	sw	ra, 92(sp)                      # 4-byte Folded Spill
	sw	s0, 88(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 96
	sw	a0, -16(s0)
	sw	a1, -20(s0)
	sw	a2, -24(s0)
	sw	a3, -28(s0)
	sw	a4, -32(s0)
	sw	a5, -36(s0)
	sw	a6, -40(s0)
	lw	a0, -32(s0)
	lw	a1, -36(s0)
	add	a0, a0, a1
	sw	a0, -44(s0)
	addi	a0, zero, 0
	sw	a0, -48(s0)
	sw	a0, -52(s0)
	sw	a0, -56(s0)
	addi	a0, zero, 3
	sw	a0, -60(s0)
	addi	a0, s0, -59
	lw	a1, -20(s0)
	addi	a2, zero, 11
	call	memcpy
	lw	a0, -16(s0)
	call	KeyExpansion
	lw	a2, -32(s0)
	lw	a3, -36(s0)
	lw	a4, -40(s0)
	addi	a0, s0, -60
	sw	a0, -84(s0)                     # 4-byte Folded Spill
	addi	a1, zero, 2
	call	CTR_cipher
	lw	a0, -84(s0)                     # 4-byte Folded Reload
	lw	a1, -24(s0)
	lw	a2, -40(s0)
	lw	a3, -28(s0)
	lw	a4, -36(s0)
	addi	a5, s0, -76
	sw	a5, -80(s0)                     # 4-byte Folded Spill
	call	CCMtag
	lw	a1, -80(s0)                     # 4-byte Folded Reload
	lw	a0, -44(s0)
	addi	a2, zero, 16
	call	memcmp
	beq	a0, zero, .LBB34_2
	jal	zero, .LBB34_1
.LBB34_1:
	addi	a0, zero, 26
	sb	a0, -9(s0)
	jal	zero, .LBB34_3
.LBB34_2:
	addi	a0, zero, 0
	sb	a0, -9(s0)
	jal	zero, .LBB34_3
.LBB34_3:
	lbu	a0, -9(s0)
	lw	ra, 92(sp)                      # 4-byte Folded Reload
	lw	s0, 88(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 96
	jalr	zero, 0(ra)
.Lfunc_end34:
	.size	AES_CCM_decrypt, .Lfunc_end34-AES_CCM_decrypt
                                        # -- End function
	.globl	AES_SIV_encrypt                 # -- Begin function AES_SIV_encrypt
	.p2align	2
	.type	AES_SIV_encrypt,@function
AES_SIV_encrypt:                        # @AES_SIV_encrypt
# %bb.0:
	addi	sp, sp, -48
	sw	ra, 44(sp)                      # 4-byte Folded Spill
	sw	s0, 40(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 48
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	sw	a3, -24(s0)
	sw	a4, -28(s0)
	sw	a5, -32(s0)
	sw	a6, -36(s0)
	lw	a0, -12(s0)
	lw	a1, -16(s0)
	lw	a2, -24(s0)
	lw	a3, -20(s0)
	lw	a4, -28(s0)
	lw	a5, -32(s0)
	call	S2V
	lw	a0, -12(s0)
	addi	a0, a0, 16
	call	KeyExpansion
	lw	a0, -32(s0)
	lw	a2, -24(s0)
	lw	a3, -28(s0)
	lw	a4, -36(s0)
	addi	a1, zero, 5
	call	CTR_cipher
	lw	ra, 44(sp)                      # 4-byte Folded Reload
	lw	s0, 40(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 48
	jalr	zero, 0(ra)
.Lfunc_end35:
	.size	AES_SIV_encrypt, .Lfunc_end35-AES_SIV_encrypt
                                        # -- End function
	.p2align	2                               # -- Begin function S2V
	.type	S2V,@function
S2V:                                    # @S2V
# %bb.0:
	addi	sp, sp, -112
	sw	ra, 108(sp)                     # 4-byte Folded Spill
	sw	s0, 104(sp)                     # 4-byte Folded Spill
	addi	s0, sp, 112
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	sw	a3, -24(s0)
	sw	a4, -28(s0)
	sw	a5, -32(s0)
	addi	a0, zero, 0
	sw	a0, -96(s0)                     # 4-byte Folded Spill
	sw	a0, -36(s0)
	sw	a0, -40(s0)
	sw	a0, -44(s0)
	sw	a0, -48(s0)
	sw	a0, -52(s0)
	sw	a0, -56(s0)
	sw	a0, -60(s0)
	sw	a0, -64(s0)
	addi	a0, s0, -48
	sw	a0, -88(s0)
	lw	a0, -32(s0)
	addi	a1, s0, -64
	sw	a1, -92(s0)                     # 4-byte Folded Spill
	addi	a2, zero, 16
	call	memcpy
	lw	a3, -92(s0)                     # 4-byte Folded Reload
	lw	a2, -12(s0)
	lw	a4, -88(s0)
	lui	a0, %hi(doubleBblock)
	addi	a0, a0, %lo(doubleBblock)
	addi	a1, zero, 1
	call	getSubkeys
	lw	a0, -92(s0)                     # 4-byte Folded Reload
	addi	a1, s0, -80
	call	rijndaelEncrypt
	lw	a0, -24(s0)
	beq	a0, zero, .LBB36_2
	jal	zero, .LBB36_1
.LBB36_1:
	lw	a1, -88(s0)
	lw	a2, -16(s0)
	lw	a3, -24(s0)
	lw	a4, -32(s0)
	addi	a0, s0, -64
	call	cMac
	addi	a0, s0, -80
	sw	a0, -100(s0)                    # 4-byte Folded Spill
	call	doubleBblock
	lw	a1, -100(s0)                    # 4-byte Folded Reload
	lw	a0, -32(s0)
	call	xorBlock
	lw	a0, -32(s0)
	addi	a1, zero, 0
	addi	a2, zero, 16
	call	memset
	jal	zero, .LBB36_2
.LBB36_2:
	lw	a1, -28(s0)
	addi	a0, zero, 15
	bltu	a0, a1, .LBB36_4
	jal	zero, .LBB36_3
.LBB36_3:
	addi	a0, s0, -80
	call	doubleBblock
	addi	a0, zero, 0
	sb	a0, -81(s0)
	jal	zero, .LBB36_7
.LBB36_4:
	lw	a0, -28(s0)
	andi	a1, a0, 15
	sb	a1, -81(s0)
	addi	a0, zero, 0
	bge	a0, a1, .LBB36_6
	jal	zero, .LBB36_5
.LBB36_5:
	addi	a0, s0, -64
	addi	a1, zero, 0
	addi	a2, zero, 16
	call	memset
	jal	zero, .LBB36_6
.LBB36_6:
	jal	zero, .LBB36_7
.LBB36_7:
	lbu	a1, -81(s0)
	addi	a0, s0, -64
	sw	a0, -104(s0)                    # 4-byte Folded Spill
	add	a1, a0, a1
	addi	a0, s0, -80
	call	xorBlock
	lw	a1, -104(s0)                    # 4-byte Folded Reload
	lw	a2, -20(s0)
	lw	a0, -28(s0)
	lbu	a3, -81(s0)
	sub	a3, a0, a3
	lw	a4, -32(s0)
	addi	a0, a1, 0
	call	cMac
	lbu	a0, -81(s0)
	bne	a0, zero, .LBB36_9
	jal	zero, .LBB36_8
.LBB36_8:
	jal	zero, .LBB36_10
.LBB36_9:
	lw	a1, -88(s0)
	lw	a0, -20(s0)
	lw	a2, -28(s0)
	add	a0, a0, a2
	lbu	a3, -81(s0)
	sub	a2, a0, a3
	lw	a4, -32(s0)
	addi	a0, zero, 0
	call	cMac
	jal	zero, .LBB36_10
.LBB36_10:
	lw	ra, 108(sp)                     # 4-byte Folded Reload
	lw	s0, 104(sp)                     # 4-byte Folded Reload
	addi	sp, sp, 112
	jalr	zero, 0(ra)
.Lfunc_end36:
	.size	S2V, .Lfunc_end36-S2V
                                        # -- End function
	.globl	AES_SIV_decrypt                 # -- Begin function AES_SIV_decrypt
	.p2align	2
	.type	AES_SIV_decrypt,@function
AES_SIV_decrypt:                        # @AES_SIV_decrypt
# %bb.0:
	addi	sp, sp, -64
	sw	ra, 60(sp)                      # 4-byte Folded Spill
	sw	s0, 56(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 64
	sw	a0, -16(s0)
	sw	a1, -20(s0)
	sw	a2, -24(s0)
	sw	a3, -28(s0)
	sw	a4, -32(s0)
	sw	a5, -36(s0)
	sw	a6, -40(s0)
	lw	a0, -16(s0)
	addi	a0, a0, 16
	call	KeyExpansion
	lw	a0, -20(s0)
	lw	a2, -32(s0)
	lw	a3, -36(s0)
	lw	a4, -40(s0)
	addi	a1, zero, 5
	call	CTR_cipher
	lw	a0, -16(s0)
	lw	a1, -24(s0)
	lw	a2, -40(s0)
	lw	a3, -28(s0)
	lw	a4, -36(s0)
	addi	a5, s0, -56
	sw	a5, -60(s0)                     # 4-byte Folded Spill
	call	S2V
	lw	a0, -60(s0)                     # 4-byte Folded Reload
	lw	a1, -20(s0)
	addi	a2, zero, 16
	call	memcmp
	beq	a0, zero, .LBB37_2
	jal	zero, .LBB37_1
.LBB37_1:
	addi	a0, zero, 26
	sb	a0, -9(s0)
	jal	zero, .LBB37_3
.LBB37_2:
	addi	a0, zero, 0
	sb	a0, -9(s0)
	jal	zero, .LBB37_3
.LBB37_3:
	lbu	a0, -9(s0)
	lw	ra, 60(sp)                      # 4-byte Folded Reload
	lw	s0, 56(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 64
	jalr	zero, 0(ra)
.Lfunc_end37:
	.size	AES_SIV_decrypt, .Lfunc_end37-AES_SIV_decrypt
                                        # -- End function
	.globl	GCM_SIV_encrypt                 # -- Begin function GCM_SIV_encrypt
	.p2align	2
	.type	GCM_SIV_encrypt,@function
GCM_SIV_encrypt:                        # @GCM_SIV_encrypt
# %bb.0:
	addi	sp, sp, -64
	sw	ra, 60(sp)                      # 4-byte Folded Spill
	sw	s0, 56(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 64
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	sw	a3, -24(s0)
	sw	a4, -28(s0)
	sw	a5, -32(s0)
	sw	a6, -36(s0)
	addi	a0, zero, 0
	sw	a0, -40(s0)
	sw	a0, -44(s0)
	sw	a0, -48(s0)
	sw	a0, -52(s0)
	lw	a0, -36(s0)
	lw	a1, -32(s0)
	add	a0, a0, a1
	sw	a0, -60(s0)
	lw	a0, -60(s0)
	sw	a0, -56(s0)
	lw	a0, -12(s0)
	lw	a1, -16(s0)
	lw	a2, -56(s0)
	call	GCM_SIVsetup
	lw	a0, -56(s0)
	lw	a1, -20(s0)
	lw	a2, -28(s0)
	lw	a3, -24(s0)
	lw	a4, -32(s0)
	addi	a5, s0, -52
	sw	a5, -64(s0)                     # 4-byte Folded Spill
	call	polyval
	lw	a1, -64(s0)                     # 4-byte Folded Reload
	lw	a0, -16(s0)
	lw	a2, -60(s0)
	call	GCM_SIVtag
	lw	a0, -60(s0)
	lw	a2, -28(s0)
	lw	a3, -32(s0)
	lw	a4, -36(s0)
	addi	a1, zero, 8
	call	CTR_cipher
	lw	ra, 60(sp)                      # 4-byte Folded Reload
	lw	s0, 56(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 64
	jalr	zero, 0(ra)
.Lfunc_end38:
	.size	GCM_SIV_encrypt, .Lfunc_end38-GCM_SIV_encrypt
                                        # -- End function
	.p2align	2                               # -- Begin function GCM_SIVsetup
	.type	GCM_SIVsetup,@function
GCM_SIVsetup:                           # @GCM_SIVsetup
# %bb.0:
	addi	sp, sp, -96
	sw	ra, 92(sp)                      # 4-byte Folded Spill
	sw	s0, 88(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 96
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	addi	a0, s0, -60
	sw	a0, -80(s0)
	sw	a0, -84(s0)
	addi	a0, s0, -72
	lw	a1, -16(s0)
	addi	a2, zero, 12
	call	memcpy
	lw	a0, -12(s0)
	call	KeyExpansion
	addi	a0, zero, 0
	sb	a0, -73(s0)
	sb	a0, -74(s0)
	sb	a0, -75(s0)
	sb	a0, -76(s0)
	jal	zero, .LBB39_1
.LBB39_1:                               # =>This Inner Loop Header: Depth=1
	lbu	a1, -76(s0)
	addi	a0, zero, 3
	blt	a0, a1, .LBB39_4
	jal	zero, .LBB39_2
.LBB39_2:                               #   in Loop: Header=BB39_1 Depth=1
	lw	a1, -84(s0)
	addi	a0, s0, -76
	call	rijndaelEncrypt
	lw	a0, -84(s0)
	addi	a0, a0, 8
	sw	a0, -84(s0)
	jal	zero, .LBB39_3
.LBB39_3:                               #   in Loop: Header=BB39_1 Depth=1
	lbu	a0, -76(s0)
	addi	a0, a0, 1
	sb	a0, -76(s0)
	jal	zero, .LBB39_1
.LBB39_4:
	lw	a0, -84(s0)
	addi	a0, a0, -16
	call	KeyExpansion
	lw	a0, -20(s0)
	lw	a1, -80(s0)
	addi	a2, zero, 16
	call	memcpy
	lw	ra, 92(sp)                      # 4-byte Folded Reload
	lw	s0, 88(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 96
	jalr	zero, 0(ra)
.Lfunc_end39:
	.size	GCM_SIVsetup, .Lfunc_end39-GCM_SIVsetup
                                        # -- End function
	.p2align	2                               # -- Begin function polyval
	.type	polyval,@function
polyval:                                # @polyval
# %bb.0:
	addi	sp, sp, -64
	sw	ra, 60(sp)                      # 4-byte Folded Spill
	sw	s0, 56(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 64
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	sw	a3, -24(s0)
	sw	a4, -28(s0)
	sw	a5, -32(s0)
	addi	a2, zero, 0
	sw	a2, -36(s0)
	sw	a2, -40(s0)
	sw	a2, -44(s0)
	sw	a2, -48(s0)
	lw	a0, -24(s0)
	slli	a1, a0, 3
	addi	a0, s0, -48
	sw	a0, -56(s0)                     # 4-byte Folded Spill
	call	copyLint
	lw	a0, -56(s0)                     # 4-byte Folded Reload
	lw	a1, -28(s0)
	slli	a1, a1, 3
	addi	a2, zero, 8
	call	copyLint
	lw	a0, -16(s0)
	lw	a1, -24(s0)
	lw	a2, -12(s0)
	lw	a4, -32(s0)
	lui	a3, %hi(dotGF128)
	addi	a3, a3, %lo(dotGF128)
	sw	a3, -52(s0)                     # 4-byte Folded Spill
	call	xMac
	lw	a3, -52(s0)                     # 4-byte Folded Reload
	lw	a0, -20(s0)
	lw	a1, -28(s0)
	lw	a2, -12(s0)
	lw	a4, -32(s0)
	call	xMac
	lw	a0, -56(s0)                     # 4-byte Folded Reload
	lw	a3, -52(s0)                     # 4-byte Folded Reload
	lw	a2, -12(s0)
	lw	a4, -32(s0)
	addi	a1, zero, 16
	call	xMac
	lw	ra, 60(sp)                      # 4-byte Folded Reload
	lw	s0, 56(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 64
	jalr	zero, 0(ra)
.Lfunc_end40:
	.size	polyval, .Lfunc_end40-polyval
                                        # -- End function
	.p2align	2                               # -- Begin function GCM_SIVtag
	.type	GCM_SIVtag,@function
GCM_SIVtag:                             # @GCM_SIVtag
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	lw	a0, -12(s0)
	lw	a2, 0(a0)
	lw	a1, -16(s0)
	lw	a0, 0(a1)
	xor	a0, a0, a2
	sw	a0, 0(a1)
	lw	a0, -12(s0)
	lw	a2, 4(a0)
	lw	a1, -16(s0)
	lw	a0, 4(a1)
	xor	a0, a0, a2
	sw	a0, 4(a1)
	lw	a0, -12(s0)
	lw	a2, 8(a0)
	lw	a1, -16(s0)
	lw	a0, 8(a1)
	xor	a0, a0, a2
	sw	a0, 8(a1)
	lw	a1, -16(s0)
	lbu	a0, 15(a1)
	andi	a0, a0, 127
	sb	a0, 15(a1)
	lw	a0, -16(s0)
	lw	a1, -20(s0)
	call	rijndaelEncrypt
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	jalr	zero, 0(ra)
.Lfunc_end41:
	.size	GCM_SIVtag, .Lfunc_end41-GCM_SIVtag
                                        # -- End function
	.globl	GCM_SIV_decrypt                 # -- Begin function GCM_SIV_decrypt
	.p2align	2
	.type	GCM_SIV_decrypt,@function
GCM_SIV_decrypt:                        # @GCM_SIV_decrypt
# %bb.0:
	addi	sp, sp, -96
	sw	ra, 92(sp)                      # 4-byte Folded Spill
	sw	s0, 88(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 96
	sw	a0, -16(s0)
	sw	a1, -20(s0)
	sw	a2, -24(s0)
	sw	a3, -28(s0)
	sw	a4, -32(s0)
	sw	a5, -36(s0)
	sw	a6, -40(s0)
	addi	a0, zero, 0
	sw	a0, -60(s0)
	sw	a0, -64(s0)
	sw	a0, -68(s0)
	sw	a0, -72(s0)
	lw	a0, -32(s0)
	lw	a1, -36(s0)
	add	a0, a0, a1
	sw	a0, -76(s0)
	lw	a0, -16(s0)
	lw	a1, -20(s0)
	addi	a2, s0, -56
	sw	a2, -84(s0)                     # 4-byte Folded Spill
	call	GCM_SIVsetup
	lw	a0, -76(s0)
	lw	a2, -32(s0)
	lw	a3, -36(s0)
	lw	a4, -40(s0)
	addi	a1, zero, 8
	call	CTR_cipher
	lw	a0, -84(s0)                     # 4-byte Folded Reload
	lw	a1, -24(s0)
	lw	a2, -40(s0)
	lw	a3, -28(s0)
	lw	a4, -36(s0)
	addi	a5, s0, -72
	sw	a5, -80(s0)                     # 4-byte Folded Spill
	call	polyval
	lw	a2, -80(s0)                     # 4-byte Folded Reload
	lw	a0, -20(s0)
	addi	a1, a2, 0
	call	GCM_SIVtag
	lw	a1, -80(s0)                     # 4-byte Folded Reload
	lw	a0, -76(s0)
	addi	a2, zero, 16
	call	memcmp
	beq	a0, zero, .LBB42_2
	jal	zero, .LBB42_1
.LBB42_1:
	addi	a0, zero, 26
	sb	a0, -9(s0)
	jal	zero, .LBB42_3
.LBB42_2:
	addi	a0, zero, 0
	sb	a0, -9(s0)
	jal	zero, .LBB42_3
.LBB42_3:
	lbu	a0, -9(s0)
	lw	ra, 92(sp)                      # 4-byte Folded Reload
	lw	s0, 88(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 96
	jalr	zero, 0(ra)
.Lfunc_end42:
	.size	GCM_SIV_decrypt, .Lfunc_end42-GCM_SIV_decrypt
                                        # -- End function
	.globl	AES_EAX_encrypt                 # -- Begin function AES_EAX_encrypt
	.p2align	2
	.type	AES_EAX_encrypt,@function
AES_EAX_encrypt:                        # @AES_EAX_encrypt
# %bb.0:
	addi	sp, sp, -144
	sw	ra, 140(sp)                     # 4-byte Folded Spill
	sw	s0, 136(sp)                     # 4-byte Folded Spill
	addi	s0, sp, 144
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	sw	a3, -24(s0)
	sw	a4, -28(s0)
	sw	a5, -32(s0)
	sw	a6, -36(s0)
	addi	a0, zero, 0
	sw	a0, -132(s0)                    # 4-byte Folded Spill
	sw	a0, -40(s0)
	sw	a0, -44(s0)
	sw	a0, -48(s0)
	sw	a0, -52(s0)
	lw	a0, -36(s0)
	lw	a1, -32(s0)
	add	a0, a0, a1
	sw	a0, -104(s0)
	lw	a2, -12(s0)
	lui	a0, %hi(doubleBblock)
	addi	a0, a0, %lo(doubleBblock)
	addi	a1, zero, 1
	sw	a1, -128(s0)                    # 4-byte Folded Spill
	addi	a3, s0, -52
	sw	a3, -124(s0)                    # 4-byte Folded Spill
	addi	a4, s0, -68
	sw	a4, -120(s0)                    # 4-byte Folded Spill
	call	getSubkeys
	lw	a0, -132(s0)                    # 4-byte Folded Reload
	lw	a1, -124(s0)                    # 4-byte Folded Reload
	lw	a2, -120(s0)                    # 4-byte Folded Reload
	lw	a3, -16(s0)
	addi	a4, zero, 16
	sw	a4, -108(s0)                    # 4-byte Folded Spill
	addi	a5, s0, -84
	sw	a5, -116(s0)                    # 4-byte Folded Spill
	call	oMac
	lw	a1, -132(s0)                    # 4-byte Folded Reload
	lw	a0, -116(s0)                    # 4-byte Folded Reload
	lw	a2, -28(s0)
	lw	a3, -32(s0)
	lw	a4, -36(s0)
	call	CTR_cipher
	lw	a0, -128(s0)                    # 4-byte Folded Reload
	lw	a1, -124(s0)                    # 4-byte Folded Reload
	lw	a2, -120(s0)                    # 4-byte Folded Reload
	lw	a3, -20(s0)
	lw	a4, -24(s0)
	addi	a5, s0, -100
	sw	a5, -112(s0)                    # 4-byte Folded Spill
	call	oMac
	lw	a0, -116(s0)                    # 4-byte Folded Reload
	lw	a1, -112(s0)                    # 4-byte Folded Reload
	call	xorBlock
	lw	a1, -124(s0)                    # 4-byte Folded Reload
	lw	a2, -120(s0)                    # 4-byte Folded Reload
	lw	a5, -116(s0)                    # 4-byte Folded Reload
	lw	a3, -36(s0)
	lw	a4, -32(s0)
	addi	a0, zero, 2
	call	oMac
	lw	a0, -116(s0)                    # 4-byte Folded Reload
	lw	a1, -112(s0)                    # 4-byte Folded Reload
	call	xorBlock
	lw	a1, -112(s0)                    # 4-byte Folded Reload
	lw	a2, -108(s0)                    # 4-byte Folded Reload
	lw	a0, -104(s0)
	call	memcpy
	lw	ra, 140(sp)                     # 4-byte Folded Reload
	lw	s0, 136(sp)                     # 4-byte Folded Reload
	addi	sp, sp, 144
	jalr	zero, 0(ra)
.Lfunc_end43:
	.size	AES_EAX_encrypt, .Lfunc_end43-AES_EAX_encrypt
                                        # -- End function
	.p2align	2                               # -- Begin function oMac
	.type	oMac,@function
oMac:                                   # @oMac
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
                                        # kill: def $x16 killed $x10
	sb	a0, -9(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	sw	a3, -24(s0)
	sw	a4, -28(s0)
	sw	a5, -32(s0)
	lw	a0, -28(s0)
	beq	a0, zero, .LBB44_2
	jal	zero, .LBB44_1
.LBB44_1:
	lw	a0, -32(s0)
	addi	a1, zero, 0
	addi	a2, zero, 16
	call	memset
	jal	zero, .LBB44_3
.LBB44_2:
	lw	a0, -32(s0)
	lw	a1, -16(s0)
	addi	a2, zero, 16
	call	memcpy
	jal	zero, .LBB44_3
.LBB44_3:
	lbu	a2, -9(s0)
	lw	a1, -32(s0)
	lbu	a0, 15(a1)
	xor	a0, a0, a2
	sb	a0, 15(a1)
	lw	a1, -32(s0)
	addi	a0, a1, 0
	call	rijndaelEncrypt
	lw	a0, -28(s0)
	bne	a0, zero, .LBB44_5
	jal	zero, .LBB44_4
.LBB44_4:
	jal	zero, .LBB44_6
.LBB44_5:
	lw	a0, -16(s0)
	lw	a1, -20(s0)
	lw	a2, -24(s0)
	lw	a3, -28(s0)
	lw	a4, -32(s0)
	call	cMac
	jal	zero, .LBB44_6
.LBB44_6:
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	jalr	zero, 0(ra)
.Lfunc_end44:
	.size	oMac, .Lfunc_end44-oMac
                                        # -- End function
	.globl	AES_EAX_decrypt                 # -- Begin function AES_EAX_decrypt
	.p2align	2
	.type	AES_EAX_decrypt,@function
AES_EAX_decrypt:                        # @AES_EAX_decrypt
# %bb.0:
	addi	sp, sp, -144
	sw	ra, 140(sp)                     # 4-byte Folded Spill
	sw	s0, 136(sp)                     # 4-byte Folded Spill
	addi	s0, sp, 144
	sw	a0, -16(s0)
	sw	a1, -20(s0)
	sw	a2, -24(s0)
	sw	a3, -28(s0)
	sw	a4, -32(s0)
	sw	a5, -36(s0)
	sw	a6, -40(s0)
	addi	a0, zero, 0
	sw	a0, -132(s0)                    # 4-byte Folded Spill
	sw	a0, -44(s0)
	sw	a0, -48(s0)
	sw	a0, -52(s0)
	sw	a0, -56(s0)
	lw	a0, -32(s0)
	lw	a1, -36(s0)
	add	a0, a0, a1
	sw	a0, -108(s0)
	lw	a2, -16(s0)
	lui	a0, %hi(doubleBblock)
	addi	a0, a0, %lo(doubleBblock)
	addi	a1, zero, 1
	sw	a1, -136(s0)                    # 4-byte Folded Spill
	addi	a3, s0, -56
	sw	a3, -128(s0)                    # 4-byte Folded Spill
	addi	a4, s0, -72
	sw	a4, -124(s0)                    # 4-byte Folded Spill
	call	getSubkeys
	lw	a1, -128(s0)                    # 4-byte Folded Reload
	lw	a2, -124(s0)                    # 4-byte Folded Reload
	lw	a3, -32(s0)
	lw	a4, -36(s0)
	addi	a0, zero, 2
	addi	a5, s0, -104
	sw	a5, -116(s0)                    # 4-byte Folded Spill
	call	oMac
	lw	a0, -136(s0)                    # 4-byte Folded Reload
	lw	a1, -128(s0)                    # 4-byte Folded Reload
	lw	a2, -124(s0)                    # 4-byte Folded Reload
	lw	a3, -24(s0)
	lw	a4, -28(s0)
	addi	a5, s0, -88
	sw	a5, -120(s0)                    # 4-byte Folded Spill
	call	oMac
	lw	a0, -120(s0)                    # 4-byte Folded Reload
	lw	a1, -116(s0)                    # 4-byte Folded Reload
	call	xorBlock
	lw	a0, -132(s0)                    # 4-byte Folded Reload
	lw	a1, -128(s0)                    # 4-byte Folded Reload
	lw	a2, -124(s0)                    # 4-byte Folded Reload
	lw	a5, -120(s0)                    # 4-byte Folded Reload
	lw	a3, -20(s0)
	addi	a4, zero, 16
	sw	a4, -112(s0)                    # 4-byte Folded Spill
	call	oMac
	lw	a0, -120(s0)                    # 4-byte Folded Reload
	lw	a1, -116(s0)                    # 4-byte Folded Reload
	call	xorBlock
	lw	a1, -116(s0)                    # 4-byte Folded Reload
	lw	a2, -112(s0)                    # 4-byte Folded Reload
	lw	a0, -108(s0)
	call	memcmp
	beq	a0, zero, .LBB45_2
	jal	zero, .LBB45_1
.LBB45_1:
	addi	a0, zero, 26
	sb	a0, -9(s0)
	jal	zero, .LBB45_3
.LBB45_2:
	lw	a2, -32(s0)
	lw	a3, -36(s0)
	lw	a4, -40(s0)
	addi	a0, s0, -88
	addi	a1, zero, 0
	sw	a1, -140(s0)                    # 4-byte Folded Spill
	call	CTR_cipher
	lw	a0, -140(s0)                    # 4-byte Folded Reload
	sb	a0, -9(s0)
	jal	zero, .LBB45_3
.LBB45_3:
	lbu	a0, -9(s0)
	lw	ra, 140(sp)                     # 4-byte Folded Reload
	lw	s0, 136(sp)                     # 4-byte Folded Reload
	addi	sp, sp, 144
	jalr	zero, 0(ra)
.Lfunc_end45:
	.size	AES_EAX_decrypt, .Lfunc_end45-AES_EAX_decrypt
                                        # -- End function
	.globl	AES_OCB_encrypt                 # -- Begin function AES_OCB_encrypt
	.p2align	2
	.type	AES_OCB_encrypt,@function
AES_OCB_encrypt:                        # @AES_OCB_encrypt
# %bb.0:
	addi	sp, sp, -64
	sw	ra, 60(sp)                      # 4-byte Folded Spill
	sw	s0, 56(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 64
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	sw	a3, -24(s0)
	sw	a4, -28(s0)
	sw	a5, -32(s0)
	sw	a6, -36(s0)
	addi	a0, zero, 0
	sw	a0, -40(s0)
	sw	a0, -44(s0)
	sw	a0, -48(s0)
	sw	a0, -52(s0)
	lw	a0, -36(s0)
	lw	a1, -32(s0)
	add	a0, a0, a1
	sw	a0, -56(s0)
	lw	a0, -36(s0)
	lw	a1, -28(s0)
	lw	a2, -32(s0)
	call	memcpy
	lw	a0, -12(s0)
	lw	a1, -16(s0)
	lw	a5, -32(s0)
	lw	a3, -20(s0)
	lw	a4, -24(s0)
	lw	a6, -36(s0)
	addi	a7, s0, -52
	sw	a7, -60(s0)                     # 4-byte Folded Spill
	addi	a2, a5, 0
	call	OCB_cipher
	lw	a1, -60(s0)                     # 4-byte Folded Reload
	lw	a0, -56(s0)
	addi	a2, zero, 16
	call	memcpy
	lw	ra, 60(sp)                      # 4-byte Folded Reload
	lw	s0, 56(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 64
	jalr	zero, 0(ra)
.Lfunc_end46:
	.size	AES_OCB_encrypt, .Lfunc_end46-AES_OCB_encrypt
                                        # -- End function
	.p2align	2                               # -- Begin function OCB_cipher
	.type	OCB_cipher,@function
OCB_cipher:                             # @OCB_cipher
# %bb.0:
	addi	sp, sp, -176
	sw	ra, 172(sp)                     # 4-byte Folded Spill
	sw	s0, 168(sp)                     # 4-byte Folded Spill
	addi	s0, sp, 176
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	sw	a3, -24(s0)
	sw	a4, -28(s0)
	sw	a5, -32(s0)
	sw	a6, -36(s0)
	sw	a7, -40(s0)
	lw	a0, -20(s0)
	lui	a1, %hi(rijndaelDecrypt)
	addi	a1, a1, %lo(rijndaelDecrypt)
	sw	a1, -152(s0)                    # 4-byte Folded Spill
	lui	a1, %hi(rijndaelEncrypt)
	addi	a1, a1, %lo(rijndaelEncrypt)
	sw	a1, -148(s0)                    # 4-byte Folded Spill
	bne	a0, zero, .LBB47_2
# %bb.1:
	lw	a0, -152(s0)                    # 4-byte Folded Reload
	sw	a0, -148(s0)                    # 4-byte Folded Spill
.LBB47_2:
	lw	a0, -148(s0)                    # 4-byte Folded Reload
	sw	a0, -44(s0)
	addi	a0, s0, -108
	sw	a0, -164(s0)                    # 4-byte Folded Spill
	addi	a1, zero, 0
	sw	a1, -156(s0)                    # 4-byte Folded Spill
	addi	a2, zero, 64
	call	memset
                                        # kill: def $x11 killed $x10
	lw	a0, -164(s0)                    # 4-byte Folded Reload
	sw	a0, -116(s0)
	addi	a0, s0, -92
	sw	a0, -120(s0)
	addi	a0, s0, -76
	sw	a0, -124(s0)
	addi	a0, s0, -60
	sw	a0, -128(s0)
	lw	a0, -16(s0)
	lbu	a0, 11(a0)
	andi	a0, a0, 63
	sw	a0, -132(s0)
	lw	a0, -132(s0)
	andi	a1, a0, 7
	addi	a0, zero, 8
	sw	a0, -160(s0)                    # 4-byte Folded Spill
	sub	a0, a0, a1
	sb	a0, -137(s0)
	lw	a0, -124(s0)
	lw	a1, -132(s0)
	srli	a1, a1, 3
	add	a0, a0, a1
	sw	a0, -144(s0)
	lw	a0, -124(s0)
	addi	a0, a0, 4
	lw	a1, -16(s0)
	addi	a2, zero, 12
	call	memcpy
	lw	a1, -156(s0)                    # 4-byte Folded Reload
	lw	a2, -124(s0)
	lbu	a0, 3(a2)
	ori	a0, a0, 1
	sb	a0, 3(a2)
	lw	a2, -124(s0)
	lbu	a0, 15(a2)
	andi	a0, a0, 192
	sb	a0, 15(a2)
	lw	a2, -12(s0)
	lw	a3, -120(s0)
	lw	a4, -116(s0)
	lui	a0, %hi(doubleBblock)
	addi	a0, a0, %lo(doubleBblock)
	call	getSubkeys
	lw	a1, -124(s0)
	addi	a0, a1, 0
	call	rijndaelEncrypt
	lw	a2, -160(s0)                    # 4-byte Folded Reload
	lw	a0, -128(s0)
	lw	a1, -124(s0)
	addi	a1, a1, 1
	call	memcpy
                                        # kill: def $x11 killed $x10
	lw	a0, -156(s0)                    # 4-byte Folded Reload
	sw	a0, -136(s0)
	jal	zero, .LBB47_3
.LBB47_3:                               # =>This Inner Loop Header: Depth=1
	lw	a1, -136(s0)
	addi	a0, zero, 15
	bltu	a0, a1, .LBB47_6
	jal	zero, .LBB47_4
.LBB47_4:                               #   in Loop: Header=BB47_3 Depth=1
	lw	a0, -124(s0)
	lw	a1, -136(s0)
	add	a0, a0, a1
	lbu	a2, 0(a0)
	lw	a0, -128(s0)
	add	a1, a0, a1
	lbu	a0, 0(a1)
	xor	a0, a0, a2
	sb	a0, 0(a1)
	lw	a0, -144(s0)
	lw	a2, -136(s0)
	add	a1, a0, a2
	lbu	a0, 0(a1)
	slli	a0, a0, 8
	lbu	a1, 1(a1)
	or	a0, a0, a1
	lbu	a1, -137(s0)
	srl	a0, a0, a1
	lw	a1, -124(s0)
	add	a1, a1, a2
	sb	a0, 0(a1)
	jal	zero, .LBB47_5
.LBB47_5:                               #   in Loop: Header=BB47_3 Depth=1
	lw	a0, -136(s0)
	addi	a0, a0, 1
	sw	a0, -136(s0)
	jal	zero, .LBB47_3
.LBB47_6:
	lw	a0, -36(s0)
	lw	a1, -20(s0)
	lw	a4, -40(s0)
	lui	a3, %hi(nop)
	addi	a3, a3, %lo(nop)
	addi	a2, zero, 0
	sw	a2, -168(s0)                    # 4-byte Folded Spill
	call	xMac
	lw	a0, -168(s0)                    # 4-byte Folded Reload
	sw	a0, -136(s0)
	lw	a0, -32(s0)
	srli	a0, a0, 4
	sw	a0, -132(s0)
	lw	a0, -36(s0)
	sw	a0, -112(s0)
	jal	zero, .LBB47_7
.LBB47_7:                               # =>This Inner Loop Header: Depth=1
	lw	a0, -136(s0)
	lw	a1, -132(s0)
	bgeu	a0, a1, .LBB47_10
	jal	zero, .LBB47_8
.LBB47_8:                               #   in Loop: Header=BB47_7 Depth=1
	lw	a0, -136(s0)
	addi	a0, a0, 1
	sw	a0, -136(s0)
	lw	a1, -116(s0)
	lw	a2, -124(s0)
	lw	a3, -128(s0)
	call	getDelta
	lw	a0, -128(s0)
	lw	a1, -112(s0)
	call	xorBlock
	lw	a2, -44(s0)
	lw	a1, -112(s0)
	addi	a0, a1, 0
	jalr	ra, 0(a2)
	lw	a0, -128(s0)
	lw	a1, -112(s0)
	call	xorBlock
	jal	zero, .LBB47_9
.LBB47_9:                               #   in Loop: Header=BB47_7 Depth=1
	lw	a0, -112(s0)
	addi	a0, a0, 16
	sw	a0, -112(s0)
	jal	zero, .LBB47_7
.LBB47_10:
	lw	a0, -132(s0)
	bne	a0, zero, .LBB47_12
	jal	zero, .LBB47_11
.LBB47_11:
	lw	a0, -124(s0)
	sw	a0, -128(s0)
	addi	a0, s0, -60
	sw	a0, -124(s0)
	jal	zero, .LBB47_12
.LBB47_12:
	lw	a0, -32(s0)
	andi	a0, a0, 15
	sw	a0, -136(s0)
	beq	a0, zero, .LBB47_14
	jal	zero, .LBB47_13
.LBB47_13:
	lw	a0, -40(s0)
	lw	a1, -136(s0)
	add	a1, a0, a1
	lbu	a0, 0(a1)
	xori	a0, a0, 128
	sb	a0, 0(a1)
	lw	a0, -120(s0)
	lw	a1, -128(s0)
	call	xorBlock
	lw	a1, -128(s0)
	lw	a2, -124(s0)
	lw	a5, -112(s0)
	lbu	a4, -136(s0)
	lui	a0, %hi(rijndaelEncrypt)
	addi	a0, a0, %lo(rijndaelEncrypt)
	addi	a3, a5, 0
	call	mixThenXor
	jal	zero, .LBB47_14
.LBB47_14:
	lw	a0, -36(s0)
	lw	a1, -32(s0)
	lw	a2, -20(s0)
	sub	a1, a1, a2
	lw	a4, -40(s0)
	lui	a3, %hi(nop)
	addi	a3, a3, %lo(nop)
	addi	a2, zero, 0
	sw	a2, -172(s0)                    # 4-byte Folded Spill
	call	xMac
	lw	a1, -172(s0)                    # 4-byte Folded Reload
	lw	a0, -116(s0)
	lw	a2, -128(s0)
	lw	a4, -40(s0)
	addi	a3, zero, 16
	call	cMac
	lw	a0, -172(s0)                    # 4-byte Folded Reload
	sw	a0, -136(s0)
	lw	a0, -28(s0)
	srli	a0, a0, 4
	sw	a0, -132(s0)
	lw	a0, -24(s0)
	sw	a0, -144(s0)
	jal	zero, .LBB47_15
.LBB47_15:                              # =>This Inner Loop Header: Depth=1
	lw	a0, -136(s0)
	lw	a1, -132(s0)
	bgeu	a0, a1, .LBB47_18
	jal	zero, .LBB47_16
.LBB47_16:                              #   in Loop: Header=BB47_15 Depth=1
	lw	a0, -136(s0)
	addi	a0, a0, 1
	sw	a0, -136(s0)
	lw	a1, -116(s0)
	lw	a2, -144(s0)
	lw	a3, -128(s0)
	call	getDelta
	lw	a1, -128(s0)
	addi	a0, a1, 0
	call	rijndaelEncrypt
	lw	a0, -128(s0)
	lw	a1, -40(s0)
	call	xorBlock
	jal	zero, .LBB47_17
.LBB47_17:                              #   in Loop: Header=BB47_15 Depth=1
	lw	a0, -144(s0)
	addi	a0, a0, 16
	sw	a0, -144(s0)
	jal	zero, .LBB47_15
.LBB47_18:
	lw	a0, -28(s0)
	andi	a0, a0, 15
	sw	a0, -136(s0)
	beq	a0, zero, .LBB47_20
	jal	zero, .LBB47_19
.LBB47_19:
	lw	a0, -124(s0)
	addi	a1, zero, 0
	sw	a1, -176(s0)                    # 4-byte Folded Spill
	addi	a2, zero, 16
	call	memset
	lw	a0, -132(s0)
	lw	a1, -116(s0)
	lw	a2, -124(s0)
	lw	a3, -128(s0)
	call	getDelta
	lw	a0, -176(s0)                    # 4-byte Folded Reload
	lw	a1, -120(s0)
	lw	a2, -144(s0)
	lw	a3, -136(s0)
	lw	a4, -128(s0)
	call	cMac
	lw	a0, -128(s0)
	lw	a1, -40(s0)
	call	xorBlock
	jal	zero, .LBB47_20
.LBB47_20:
	lw	ra, 172(sp)                     # 4-byte Folded Reload
	lw	s0, 168(sp)                     # 4-byte Folded Reload
	addi	sp, sp, 176
	jalr	zero, 0(ra)
.Lfunc_end47:
	.size	OCB_cipher, .Lfunc_end47-OCB_cipher
                                        # -- End function
	.globl	AES_OCB_decrypt                 # -- Begin function AES_OCB_decrypt
	.p2align	2
	.type	AES_OCB_decrypt,@function
AES_OCB_decrypt:                        # @AES_OCB_decrypt
# %bb.0:
	addi	sp, sp, -80
	sw	ra, 76(sp)                      # 4-byte Folded Spill
	sw	s0, 72(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 80
	sw	a0, -16(s0)
	sw	a1, -20(s0)
	sw	a2, -24(s0)
	sw	a3, -28(s0)
	sw	a4, -32(s0)
	sw	a5, -36(s0)
	sw	a6, -40(s0)
	addi	a0, zero, 0
	sw	a0, -68(s0)                     # 4-byte Folded Spill
	sw	a0, -44(s0)
	sw	a0, -48(s0)
	sw	a0, -52(s0)
	sw	a0, -56(s0)
	lw	a0, -32(s0)
	lw	a1, -36(s0)
	add	a0, a0, a1
	sw	a0, -60(s0)
	lw	a0, -40(s0)
	lw	a1, -32(s0)
	lw	a2, -36(s0)
	call	memcpy
	lw	a2, -68(s0)                     # 4-byte Folded Reload
	lw	a0, -16(s0)
	lw	a1, -20(s0)
	lw	a3, -24(s0)
	lw	a4, -28(s0)
	lw	a5, -36(s0)
	lw	a6, -40(s0)
	addi	a7, s0, -56
	sw	a7, -64(s0)                     # 4-byte Folded Spill
	call	OCB_cipher
	lw	a1, -64(s0)                     # 4-byte Folded Reload
	lw	a0, -60(s0)
	addi	a2, zero, 16
	call	memcmp
	beq	a0, zero, .LBB48_2
	jal	zero, .LBB48_1
.LBB48_1:
	addi	a0, zero, 26
	sb	a0, -9(s0)
	jal	zero, .LBB48_3
.LBB48_2:
	addi	a0, zero, 0
	sb	a0, -9(s0)
	jal	zero, .LBB48_3
.LBB48_3:
	lbu	a0, -9(s0)
	lw	ra, 76(sp)                      # 4-byte Folded Reload
	lw	s0, 72(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 80
	jalr	zero, 0(ra)
.Lfunc_end48:
	.size	AES_OCB_decrypt, .Lfunc_end48-AES_OCB_decrypt
                                        # -- End function
	.globl	AES_KEY_wrap                    # -- Begin function AES_KEY_wrap
	.p2align	2
	.type	AES_KEY_wrap,@function
AES_KEY_wrap:                           # @AES_KEY_wrap
# %bb.0:
	addi	sp, sp, -80
	sw	ra, 76(sp)                      # 4-byte Folded Spill
	sw	s0, 72(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 80
	sw	a0, -16(s0)
	sw	a1, -20(s0)
	sw	a2, -24(s0)
	sw	a3, -28(s0)
	lw	a0, -28(s0)
	sw	a0, -32(s0)
	lw	a0, -32(s0)
	addi	a0, a0, 8
	sw	a0, -36(s0)
	lw	a0, -32(s0)
	lw	a1, -24(s0)
	add	a0, a0, a1
	sw	a0, -40(s0)
	lw	a0, -24(s0)
	srli	a0, a0, 3
	sw	a0, -64(s0)
	lw	a0, -64(s0)
	addi	a1, zero, 2
	bltu	a0, a1, .LBB49_2
	jal	zero, .LBB49_1
.LBB49_1:
	lbu	a0, -24(s0)
	andi	a0, a0, 7
	beq	a0, zero, .LBB49_3
	jal	zero, .LBB49_2
.LBB49_2:
	addi	a0, zero, 1
	sb	a0, -9(s0)
	jal	zero, .LBB49_10
.LBB49_3:
	addi	a0, s0, -56
	addi	a1, zero, 166
	addi	a2, zero, 8
	call	memset
	lw	a0, -36(s0)
	lw	a1, -20(s0)
	lw	a2, -24(s0)
	call	memcpy
	lw	a0, -16(s0)
	call	KeyExpansion
	addi	a0, zero, 0
	sw	a0, -60(s0)
	lw	a0, -64(s0)
	slli	a1, a0, 1
	slli	a0, a0, 2
	add	a0, a0, a1
	sw	a0, -64(s0)
	jal	zero, .LBB49_4
.LBB49_4:                               # =>This Inner Loop Header: Depth=1
	lw	a0, -60(s0)
	addi	a1, a0, 1
	sw	a1, -60(s0)
	lw	a1, -64(s0)
	bgeu	a0, a1, .LBB49_9
	jal	zero, .LBB49_5
.LBB49_5:                               #   in Loop: Header=BB49_4 Depth=1
	addi	a0, s0, -48
	sw	a0, -76(s0)                     # 4-byte Folded Spill
	lw	a1, -36(s0)
	addi	a2, zero, 8
	sw	a2, -72(s0)                     # 4-byte Folded Spill
	call	memcpy
	addi	a1, s0, -56
	sw	a1, -68(s0)                     # 4-byte Folded Spill
	addi	a0, a1, 0
	call	rijndaelEncrypt
	lw	a1, -76(s0)                     # 4-byte Folded Reload
	lw	a2, -72(s0)                     # 4-byte Folded Reload
	lw	a0, -36(s0)
	call	memcpy
                                        # kill: def $x11 killed $x10
	lw	a0, -68(s0)                     # 4-byte Folded Reload
	lw	a1, -60(s0)
	addi	a2, zero, 7
	call	xorBEint
	lw	a0, -36(s0)
	lw	a1, -40(s0)
	bne	a0, a1, .LBB49_7
	jal	zero, .LBB49_6
.LBB49_6:                               #   in Loop: Header=BB49_4 Depth=1
	lw	a0, -32(s0)
	sw	a0, -80(s0)                     # 4-byte Folded Spill
	jal	zero, .LBB49_8
.LBB49_7:                               #   in Loop: Header=BB49_4 Depth=1
	lw	a0, -36(s0)
	sw	a0, -80(s0)                     # 4-byte Folded Spill
	jal	zero, .LBB49_8
.LBB49_8:                               #   in Loop: Header=BB49_4 Depth=1
	lw	a0, -80(s0)                     # 4-byte Folded Reload
	addi	a0, a0, 8
	sw	a0, -36(s0)
	jal	zero, .LBB49_4
.LBB49_9:
	lw	a0, -32(s0)
	addi	a1, s0, -56
	addi	a2, zero, 8
	call	memcpy
	addi	a0, zero, 0
	sb	a0, -9(s0)
	jal	zero, .LBB49_10
.LBB49_10:
	lbu	a0, -9(s0)
	lw	ra, 76(sp)                      # 4-byte Folded Reload
	lw	s0, 72(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 80
	jalr	zero, 0(ra)
.Lfunc_end49:
	.size	AES_KEY_wrap, .Lfunc_end49-AES_KEY_wrap
                                        # -- End function
	.p2align	2                               # -- Begin function memset
	.type	memset,@function
memset:                                 # @memset
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
                                        # kill: def $x13 killed $x11
	sw	a0, -12(s0)
	sb	a1, -13(s0)
	sw	a2, -20(s0)
	lw	a0, -12(s0)
	sw	a0, -24(s0)
	jal	zero, .LBB50_1
.LBB50_1:                               # =>This Inner Loop Header: Depth=1
	lw	a0, -20(s0)
	addi	a1, a0, -1
	sw	a1, -20(s0)
	beq	a0, zero, .LBB50_3
	jal	zero, .LBB50_2
.LBB50_2:                               #   in Loop: Header=BB50_1 Depth=1
	lbu	a0, -13(s0)
	lw	a1, -24(s0)
	lw	a2, -20(s0)
	add	a1, a1, a2
	sb	a0, 0(a1)
	jal	zero, .LBB50_1
.LBB50_3:
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	jalr	zero, 0(ra)
.Lfunc_end50:
	.size	memset, .Lfunc_end50-memset
                                        # -- End function
	.globl	AES_KEY_unwrap                  # -- Begin function AES_KEY_unwrap
	.p2align	2
	.type	AES_KEY_unwrap,@function
AES_KEY_unwrap:                         # @AES_KEY_unwrap
# %bb.0:
	addi	sp, sp, -80
	sw	ra, 76(sp)                      # 4-byte Folded Spill
	sw	s0, 72(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 80
	sw	a0, -16(s0)
	sw	a1, -20(s0)
	sw	a2, -24(s0)
	sw	a3, -28(s0)
	lw	a0, -20(s0)
	sw	a0, -32(s0)
	lw	a0, -28(s0)
	sw	a0, -36(s0)
	lw	a0, -28(s0)
	lw	a1, -24(s0)
	add	a0, a0, a1
	addi	a0, a0, -8
	sw	a0, -40(s0)
	lw	a0, -24(s0)
	srli	a0, a0, 3
	sw	a0, -64(s0)
	lw	a0, -64(s0)
	addi	a1, zero, 3
	bltu	a0, a1, .LBB51_2
	jal	zero, .LBB51_1
.LBB51_1:
	lbu	a0, -24(s0)
	andi	a0, a0, 7
	beq	a0, zero, .LBB51_3
	jal	zero, .LBB51_2
.LBB51_2:
	addi	a0, zero, 1
	sb	a0, -9(s0)
	jal	zero, .LBB51_14
.LBB51_3:
	lw	a1, -32(s0)
	addi	a0, s0, -56
	addi	a2, zero, 8
	call	memcpy
	lw	a0, -36(s0)
	lw	a1, -32(s0)
	addi	a1, a1, 8
	lw	a2, -24(s0)
	addi	a2, a2, -8
	call	memcpy
	lw	a0, -16(s0)
	call	KeyExpansion
	lw	a0, -64(s0)
	addi	a0, a0, -1
	sw	a0, -64(s0)
	lw	a0, -64(s0)
	slli	a1, a0, 1
	slli	a0, a0, 2
	add	a0, a0, a1
	sw	a0, -60(s0)
	jal	zero, .LBB51_4
.LBB51_4:                               # =>This Inner Loop Header: Depth=1
	lw	a0, -60(s0)
	beq	a0, zero, .LBB51_10
	jal	zero, .LBB51_5
.LBB51_5:                               #   in Loop: Header=BB51_4 Depth=1
	lw	a0, -36(s0)
	lw	a1, -28(s0)
	bne	a0, a1, .LBB51_7
	jal	zero, .LBB51_6
.LBB51_6:                               #   in Loop: Header=BB51_4 Depth=1
	lw	a0, -40(s0)
	sw	a0, -68(s0)                     # 4-byte Folded Spill
	jal	zero, .LBB51_8
.LBB51_7:                               #   in Loop: Header=BB51_4 Depth=1
	lw	a0, -36(s0)
	sw	a0, -68(s0)                     # 4-byte Folded Spill
	jal	zero, .LBB51_8
.LBB51_8:                               #   in Loop: Header=BB51_4 Depth=1
	lw	a0, -68(s0)                     # 4-byte Folded Reload
	addi	a0, a0, -8
	sw	a0, -36(s0)
	lw	a1, -60(s0)
	addi	a0, s0, -56
	sw	a0, -80(s0)                     # 4-byte Folded Spill
	addi	a2, zero, 7
	call	xorBEint
	addi	a0, s0, -48
	sw	a0, -76(s0)                     # 4-byte Folded Spill
	lw	a1, -36(s0)
	addi	a2, zero, 8
	sw	a2, -72(s0)                     # 4-byte Folded Spill
	call	memcpy
	lw	a1, -80(s0)                     # 4-byte Folded Reload
	addi	a0, a1, 0
	call	rijndaelDecrypt
	lw	a1, -76(s0)                     # 4-byte Folded Reload
	lw	a2, -72(s0)                     # 4-byte Folded Reload
	lw	a0, -36(s0)
	call	memcpy
	jal	zero, .LBB51_9
.LBB51_9:                               #   in Loop: Header=BB51_4 Depth=1
	lw	a0, -60(s0)
	addi	a0, a0, -1
	sw	a0, -60(s0)
	jal	zero, .LBB51_4
.LBB51_10:
	addi	a0, zero, 0
	sw	a0, -64(s0)
	addi	a0, zero, 8
	sw	a0, -60(s0)
	jal	zero, .LBB51_11
.LBB51_11:                              # =>This Inner Loop Header: Depth=1
	lw	a0, -60(s0)
	addi	a1, a0, -1
	sw	a1, -60(s0)
	beq	a0, zero, .LBB51_13
	jal	zero, .LBB51_12
.LBB51_12:                              #   in Loop: Header=BB51_11 Depth=1
	lw	a1, -60(s0)
	addi	a0, s0, -56
	add	a0, a0, a1
	lbu	a0, 0(a0)
	addi	a1, a0, -166
	lw	a0, -64(s0)
	or	a0, a0, a1
	sw	a0, -64(s0)
	jal	zero, .LBB51_11
.LBB51_13:
	lw	a0, -64(s0)
	sltiu	a0, a0, 1
	addi	a0, a0, -1
	andi	a0, a0, 26
	sb	a0, -9(s0)
	jal	zero, .LBB51_14
.LBB51_14:
	lbu	a0, -9(s0)
	lw	ra, 76(sp)                      # 4-byte Folded Reload
	lw	s0, 72(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 80
	jalr	zero, 0(ra)
.Lfunc_end51:
	.size	AES_KEY_unwrap, .Lfunc_end51-AES_KEY_unwrap
                                        # -- End function
	.globl	AES_Poly1305                    # -- Begin function AES_Poly1305
	.p2align	2
	.type	AES_Poly1305,@function
AES_Poly1305:                           # @AES_Poly1305
# %bb.0:
	addi	sp, sp, -144
	sw	ra, 140(sp)                     # 4-byte Folded Spill
	sw	s0, 136(sp)                     # 4-byte Folded Spill
	addi	s0, sp, 144
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	sw	a3, -24(s0)
	sw	a4, -28(s0)
	addi	a0, zero, 0
	sw	a0, -120(s0)                    # 4-byte Folded Spill
	sb	a0, -48(s0)
	sw	a0, -52(s0)
	sw	a0, -56(s0)
	sw	a0, -60(s0)
	addi	a1, zero, 1
	sw	a1, -64(s0)
	sb	a0, -68(s0)
	sw	a0, -72(s0)
	sw	a0, -76(s0)
	sw	a0, -80(s0)
	sw	a0, -84(s0)
	sb	a0, -88(s0)
	sw	a0, -92(s0)
	sw	a0, -96(s0)
	sw	a0, -100(s0)
	sw	a0, -104(s0)
	addi	a0, zero, 16
	sb	a0, -105(s0)
	lw	a0, -24(s0)
	addi	a0, a0, -1
	srli	a0, a0, 4
	sw	a0, -112(s0)
	lw	a0, -20(s0)
	lw	a1, -24(s0)
	add	a0, a0, a1
	sw	a0, -116(s0)
	lw	a0, -12(s0)
	call	KeyExpansion
	lw	a0, -16(s0)
	lw	a1, -28(s0)
	call	rijndaelEncrypt
	lw	a0, -24(s0)
	bne	a0, zero, .LBB52_2
	jal	zero, .LBB52_1
.LBB52_1:
	jal	zero, .LBB52_17
.LBB52_2:
	lw	a0, -12(s0)
	addi	a1, a0, 16
	lbu	a2, -105(s0)
	addi	a0, s0, -45
	sw	a0, -124(s0)                    # 4-byte Folded Spill
	call	memcpy
                                        # kill: def $x11 killed $x10
	lw	a0, -124(s0)                    # 4-byte Folded Reload
	lbu	a1, -105(s0)
	add	a1, a0, a1
	addi	a0, zero, 0
	sb	a0, 0(a1)
	jal	zero, .LBB52_3
.LBB52_3:                               # =>This Inner Loop Header: Depth=1
	lbu	a0, -105(s0)
	addi	a1, zero, 4
	blt	a0, a1, .LBB52_6
	jal	zero, .LBB52_4
.LBB52_4:                               #   in Loop: Header=BB52_3 Depth=1
	lbu	a1, -105(s0)
	addi	a0, a1, -1
	sb	a0, -105(s0)
	addi	a0, s0, -45
	add	a2, a0, a1
	lbu	a1, 0(a2)
	andi	a1, a1, 252
	sb	a1, 0(a2)
	lbu	a1, -105(s0)
	add	a1, a0, a1
	lbu	a0, 0(a1)
	andi	a0, a0, 15
	sb	a0, 0(a1)
	jal	zero, .LBB52_5
.LBB52_5:                               #   in Loop: Header=BB52_3 Depth=1
	lbu	a0, -105(s0)
	addi	a0, a0, -3
	sb	a0, -105(s0)
	jal	zero, .LBB52_3
.LBB52_6:
	lw	a0, -24(s0)
	lw	a1, -112(s0)
	slli	a1, a1, 4
	sub	a0, a0, a1
	sb	a0, -105(s0)
	jal	zero, .LBB52_7
.LBB52_7:                               # =>This Inner Loop Header: Depth=1
	lbu	a1, -105(s0)
	lw	a0, -116(s0)
	sub	a1, a0, a1
	sw	a1, -116(s0)
	lbu	a2, -105(s0)
	addi	a0, s0, -84
	sw	a0, -132(s0)                    # 4-byte Folded Spill
	call	memcpy
                                        # kill: def $x11 killed $x10
	lw	a0, -132(s0)                    # 4-byte Folded Reload
	lbu	a1, -105(s0)
	add	a1, a0, a1
	addi	a0, zero, 1
	sb	a0, 0(a1)
	addi	a0, zero, 16
	sb	a0, -105(s0)
	addi	a0, s0, -45
	addi	a1, s0, -64
	sw	a1, -136(s0)                    # 4-byte Folded Spill
	call	mulLblocks
	lw	a0, -136(s0)                    # 4-byte Folded Reload
	lw	a1, -132(s0)                    # 4-byte Folded Reload
	call	mulLblocks
	lw	a0, -132(s0)                    # 4-byte Folded Reload
	addi	a1, zero, 17
	addi	a2, s0, -104
	sw	a2, -128(s0)                    # 4-byte Folded Spill
	call	addLblocks
	lw	a0, -128(s0)                    # 4-byte Folded Reload
	lbu	a1, -105(s0)
	add	a1, a0, a1
	lbu	a1, 0(a1)
	call	modP1305
	jal	zero, .LBB52_8
.LBB52_8:                               #   in Loop: Header=BB52_7 Depth=1
	lw	a0, -112(s0)
	addi	a1, a0, -1
	sw	a1, -112(s0)
	bne	a0, zero, .LBB52_7
	jal	zero, .LBB52_9
.LBB52_9:
	lbu	a1, -105(s0)
	addi	a0, s0, -104
	add	a0, a0, a1
	lbu	a0, 0(a0)
	slli	a0, a0, 2
	sw	a0, -112(s0)
	lbu	a0, -104(s0)
	addi	a1, zero, 251
	blt	a0, a1, .LBB52_16
	jal	zero, .LBB52_10
.LBB52_10:
	lw	a0, -112(s0)
	addi	a1, zero, 12
	bne	a0, a1, .LBB52_16
	jal	zero, .LBB52_11
.LBB52_11:
	addi	a0, zero, 1
	sw	a0, -112(s0)
	jal	zero, .LBB52_12
.LBB52_12:                              # =>This Inner Loop Header: Depth=1
	lw	a1, -112(s0)
	addi	a0, s0, -104
	add	a0, a0, a1
	lbu	a0, 0(a0)
	addi	a1, zero, 255
	bne	a0, a1, .LBB52_15
	jal	zero, .LBB52_13
.LBB52_13:                              #   in Loop: Header=BB52_12 Depth=1
	jal	zero, .LBB52_14
.LBB52_14:                              #   in Loop: Header=BB52_12 Depth=1
	lw	a0, -112(s0)
	addi	a0, a0, 1
	sw	a0, -112(s0)
	jal	zero, .LBB52_12
.LBB52_15:
	jal	zero, .LBB52_16
.LBB52_16:
	lw	a0, -112(s0)
	srli	a1, a0, 2
	addi	a0, s0, -104
	sw	a0, -140(s0)                    # 4-byte Folded Spill
	call	modP1305
	lw	a0, -140(s0)                    # 4-byte Folded Reload
	lw	a2, -28(s0)
	addi	a1, zero, 16
	call	addLblocks
	jal	zero, .LBB52_17
.LBB52_17:
	lw	ra, 140(sp)                     # 4-byte Folded Reload
	lw	s0, 136(sp)                     # 4-byte Folded Reload
	addi	sp, sp, 144
	jalr	zero, 0(ra)
.Lfunc_end52:
	.size	AES_Poly1305, .Lfunc_end52-AES_Poly1305
                                        # -- End function
	.p2align	2                               # -- Begin function mulLblocks
	.type	mulLblocks,@function
mulLblocks:                             # @mulLblocks
# %bb.0:
	addi	sp, sp, -48
	sw	ra, 44(sp)                      # 4-byte Folded Spill
	sw	s0, 40(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 48
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	addi	a0, zero, 17
	sb	a0, -17(s0)
	addi	a0, zero, 0
	sb	a0, -20(s0)
	sw	a0, -24(s0)
	sw	a0, -28(s0)
	sw	a0, -32(s0)
	sw	a0, -36(s0)
	jal	zero, .LBB53_1
.LBB53_1:                               # =>This Loop Header: Depth=1
                                        #     Child Loop BB53_3 Depth 2
	lbu	a0, -17(s0)
	addi	a1, a0, -1
	sb	a1, -17(s0)
	beq	a0, zero, .LBB53_7
	jal	zero, .LBB53_2
.LBB53_2:                               #   in Loop: Header=BB53_1 Depth=1
	lbu	a0, -17(s0)
	sltu	a0, zero, a0
	slli	a0, a0, 3
	sb	a0, -37(s0)
	addi	a0, zero, 0
	sw	a0, -44(s0)
	lw	a1, -16(s0)
	lbu	a2, -17(s0)
	add	a1, a1, a2
	lbu	a1, 0(a1)
	sw	a1, -48(s0)
	sb	a0, -38(s0)
	jal	zero, .LBB53_3
.LBB53_3:                               #   Parent Loop BB53_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	lbu	a1, -38(s0)
	addi	a0, zero, 16
	bltu	a0, a1, .LBB53_6
	jal	zero, .LBB53_4
.LBB53_4:                               #   in Loop: Header=BB53_3 Depth=2
	lw	a0, -44(s0)
	srai	a0, a0, 8
	sw	a0, -44(s0)
	lw	a0, -48(s0)
	lw	a1, -12(s0)
	lbu	a2, -38(s0)
	add	a1, a1, a2
	lbu	a1, 0(a1)
	mul	a0, a0, a1
	addi	a1, s0, -36
	add	a2, a1, a2
	lbu	a2, 0(a2)
	add	a0, a0, a2
	lbu	a2, -37(s0)
	sll	a2, a0, a2
	lw	a0, -44(s0)
	add	a0, a0, a2
	sw	a0, -44(s0)
	lw	a0, -44(s0)
	lbu	a2, -38(s0)
	add	a1, a1, a2
	sb	a0, 0(a1)
	jal	zero, .LBB53_5
.LBB53_5:                               #   in Loop: Header=BB53_3 Depth=2
	lbu	a0, -38(s0)
	addi	a0, a0, 1
	sb	a0, -38(s0)
	jal	zero, .LBB53_3
.LBB53_6:                               #   in Loop: Header=BB53_1 Depth=1
	lw	a1, -44(s0)
	addi	a0, s0, -36
	call	modP1305
	jal	zero, .LBB53_1
.LBB53_7:
	lw	a0, -16(s0)
	addi	a1, s0, -36
	addi	a2, zero, 17
	call	memcpy
	lw	ra, 44(sp)                      # 4-byte Folded Reload
	lw	s0, 40(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 48
	jalr	zero, 0(ra)
.Lfunc_end53:
	.size	mulLblocks, .Lfunc_end53-mulLblocks
                                        # -- End function
	.p2align	2                               # -- Begin function addLblocks
	.type	addLblocks,@function
addLblocks:                             # @addLblocks
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
                                        # kill: def $x13 killed $x11
	sw	a0, -12(s0)
	sb	a1, -13(s0)
	sw	a2, -20(s0)
	addi	a0, zero, 0
	sw	a0, -24(s0)
	sw	a0, -28(s0)
	jal	zero, .LBB54_1
.LBB54_1:                               # =>This Inner Loop Header: Depth=1
	lw	a0, -28(s0)
	lbu	a1, -13(s0)
	bge	a0, a1, .LBB54_4
	jal	zero, .LBB54_2
.LBB54_2:                               #   in Loop: Header=BB54_1 Depth=1
	lw	a0, -12(s0)
	lw	a2, -28(s0)
	add	a0, a0, a2
	lbu	a0, 0(a0)
	lw	a1, -20(s0)
	add	a1, a1, a2
	lbu	a1, 0(a1)
	add	a1, a0, a1
	lw	a0, -24(s0)
	add	a0, a0, a1
	sw	a0, -24(s0)
	lw	a0, -24(s0)
	lw	a1, -20(s0)
	lw	a2, -28(s0)
	addi	a3, a2, 1
	sw	a3, -28(s0)
	add	a1, a1, a2
	sb	a0, 0(a1)
	jal	zero, .LBB54_3
.LBB54_3:                               #   in Loop: Header=BB54_1 Depth=1
	lw	a0, -24(s0)
	srai	a0, a0, 8
	sw	a0, -24(s0)
	jal	zero, .LBB54_1
.LBB54_4:
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	jalr	zero, 0(ra)
.Lfunc_end54:
	.size	addLblocks, .Lfunc_end54-addLblocks
                                        # -- End function
	.p2align	2                               # -- Begin function modP1305
	.type	modP1305,@function
modP1305:                               # @modP1305
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	lw	a1, -16(s0)
	addi	a0, zero, 3
	blt	a0, a1, .LBB55_2
	jal	zero, .LBB55_1
.LBB55_1:
	jal	zero, .LBB55_6
.LBB55_2:
	lw	a1, -12(s0)
	lbu	a0, 16(a1)
	andi	a0, a0, 3
	sb	a0, 16(a1)
	lw	a0, -16(s0)
	srai	a1, a0, 2
	andi	a0, a0, -4
	add	a0, a0, a1
	sw	a0, -16(s0)
	jal	zero, .LBB55_3
.LBB55_3:                               # =>This Inner Loop Header: Depth=1
	lw	a0, -16(s0)
	beq	a0, zero, .LBB55_6
	jal	zero, .LBB55_4
.LBB55_4:                               #   in Loop: Header=BB55_3 Depth=1
	lw	a0, -12(s0)
	lbu	a1, 0(a0)
	lw	a0, -16(s0)
	add	a0, a0, a1
	sw	a0, -16(s0)
	lw	a0, -16(s0)
	lw	a1, -12(s0)
	addi	a2, a1, 1
	sw	a2, -12(s0)
	sb	a0, 0(a1)
	jal	zero, .LBB55_5
.LBB55_5:                               #   in Loop: Header=BB55_3 Depth=1
	lw	a0, -16(s0)
	srai	a0, a0, 8
	sw	a0, -16(s0)
	jal	zero, .LBB55_3
.LBB55_6:
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	lw	s0, 8(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 16
	jalr	zero, 0(ra)
.Lfunc_end55:
	.size	modP1305, .Lfunc_end55-modP1305
                                        # -- End function
	.globl	main                            # -- Begin function main
	.p2align	2
	.type	main,@function
main:                                   # @main
# %bb.0:
	addi	sp, sp, -80
	sw	ra, 76(sp)                      # 4-byte Folded Spill
	sw	s0, 72(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 80
	addi	a0, zero, 0
	sw	a0, -68(s0)                     # 4-byte Folded Spill
	sw	a0, -12(s0)
	lui	a0, %hi(.L.str)
	addi	a0, a0, %lo(.L.str)
	addi	a1, s0, -28
	call	hex2bytes
	lui	a0, %hi(.L.str.1)
	addi	a0, a0, %lo(.L.str.1)
	addi	a1, s0, -44
	call	hex2bytes
	lw	a0, -68(s0)                     # 4-byte Folded Reload
	sb	a0, -61(s0)
	jal	zero, .LBB56_1
.LBB56_1:                               # =>This Inner Loop Header: Depth=1
	lbu	a1, -61(s0)
	addi	a0, zero, 254
	blt	a0, a1, .LBB56_4
	jal	zero, .LBB56_2
.LBB56_2:                               #   in Loop: Header=BB56_1 Depth=1
	lbu	a0, -61(s0)
	sb	a0, -44(s0)
	lui	a0, %hi(.L.str.2)
	addi	a0, a0, %lo(.L.str.2)
	addi	a1, zero, 6
	call	write
	addi	a0, s0, -28
	addi	a1, s0, -44
	addi	a2, zero, 16
	addi	a3, s0, -60
	call	AES_ECB_encrypt
	jal	zero, .LBB56_3
.LBB56_3:                               #   in Loop: Header=BB56_1 Depth=1
	lbu	a0, -61(s0)
	addi	a0, a0, 1
	sb	a0, -61(s0)
	jal	zero, .LBB56_1
.LBB56_4:
	lw	a0, -12(s0)
	lw	ra, 76(sp)                      # 4-byte Folded Reload
	lw	s0, 72(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 80
	jalr	zero, 0(ra)
.Lfunc_end56:
	.size	main, .Lfunc_end56-main
                                        # -- End function
	.p2align	2                               # -- Begin function hex2bytes
	.type	hex2bytes,@function
hex2bytes:                              # @hex2bytes
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	addi	a0, zero, 0
	sw	a0, -20(s0)
	lw	a0, -16(s0)
	addi	a0, a0, -1
	sw	a0, -16(s0)
	jal	zero, .LBB57_1
.LBB57_1:                               # =>This Inner Loop Header: Depth=1
	lw	a0, -12(s0)
	lbu	a0, 0(a0)
	beq	a0, zero, .LBB57_9
	jal	zero, .LBB57_2
.LBB57_2:                               #   in Loop: Header=BB57_1 Depth=1
	lw	a0, -12(s0)
	lbu	a0, 0(a0)
	addi	a1, zero, 48
	blt	a0, a1, .LBB57_4
	jal	zero, .LBB57_3
.LBB57_3:                               #   in Loop: Header=BB57_1 Depth=1
	lw	a0, -12(s0)
	lbu	a0, 0(a0)
	addi	a1, zero, 103
	blt	a0, a1, .LBB57_5
	jal	zero, .LBB57_4
.LBB57_4:                               #   in Loop: Header=BB57_1 Depth=1
	jal	zero, .LBB57_8
.LBB57_5:                               #   in Loop: Header=BB57_1 Depth=1
	lw	a0, -20(s0)
	xori	a0, a0, 4
	sw	a0, -20(s0)
	beq	a0, zero, .LBB57_7
	jal	zero, .LBB57_6
.LBB57_6:                               #   in Loop: Header=BB57_1 Depth=1
	lw	a1, -16(s0)
	addi	a0, a1, 1
	sw	a0, -16(s0)
	addi	a0, zero, 0
	sb	a0, 1(a1)
	jal	zero, .LBB57_7
.LBB57_7:                               #   in Loop: Header=BB57_1 Depth=1
	lw	a0, -12(s0)
	lbu	a1, 0(a0)
	andi	a0, a1, 15
	slti	a1, a1, 58
	xori	a2, a1, 1
	slli	a1, a2, 3
	or	a1, a1, a2
	add	a0, a0, a1
	lw	a1, -20(s0)
	sll	a2, a0, a1
	lw	a1, -16(s0)
	lbu	a0, 0(a1)
	or	a0, a0, a2
	sb	a0, 0(a1)
	jal	zero, .LBB57_8
.LBB57_8:                               #   in Loop: Header=BB57_1 Depth=1
	lw	a0, -12(s0)
	addi	a0, a0, 1
	sw	a0, -12(s0)
	jal	zero, .LBB57_1
.LBB57_9:
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	jalr	zero, 0(ra)
.Lfunc_end57:
	.size	hex2bytes, .Lfunc_end57-hex2bytes
                                        # -- End function
	.p2align	2                               # -- Begin function write
	.type	write,@function
write:                                  # @write
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	lw	a0, -12(s0)
	sw	a0, -20(s0)
	lw	a0, -16(s0)
	sw	a0, -24(s0)
	lw	a0, -20(s0)
	lw	a1, -24(s0)
	#APP
	addi	a7, zero, -2
	ecall
	#NO_APP
	sw	a0, -28(s0)
	lw	a0, -28(s0)
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	jalr	zero, 0(ra)
.Lfunc_end58:
	.size	write, .Lfunc_end58-write
                                        # -- End function
	.p2align	2                               # -- Begin function AddRoundKey
	.type	AddRoundKey,@function
AddRoundKey:                            # @AddRoundKey
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16
                                        # kill: def $x12 killed $x10
	sb	a0, -9(s0)
	sw	a1, -16(s0)
	lbu	a0, -9(s0)
	slli	a1, a0, 4
	lui	a0, %hi(RoundKey)
	addi	a0, a0, %lo(RoundKey)
	add	a0, a0, a1
	lw	a1, -16(s0)
	call	xorBlock
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	lw	s0, 8(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 16
	jalr	zero, 0(ra)
.Lfunc_end59:
	.size	AddRoundKey, .Lfunc_end59-AddRoundKey
                                        # -- End function
	.p2align	2                               # -- Begin function SubBytes
	.type	SubBytes,@function
SubBytes:                               # @SubBytes
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16
	sw	a0, -12(s0)
	addi	a0, zero, 0
	sb	a0, -13(s0)
	jal	zero, .LBB60_1
.LBB60_1:                               # =>This Inner Loop Header: Depth=1
	lbu	a1, -13(s0)
	addi	a0, zero, 15
	blt	a0, a1, .LBB60_4
	jal	zero, .LBB60_2
.LBB60_2:                               #   in Loop: Header=BB60_1 Depth=1
	lw	a0, -12(s0)
	lbu	a1, -13(s0)
	add	a1, a0, a1
	lbu	a2, 0(a1)
	lui	a0, %hi(sbox)
	addi	a0, a0, %lo(sbox)
	add	a0, a0, a2
	lbu	a0, 0(a0)
	sb	a0, 0(a1)
	jal	zero, .LBB60_3
.LBB60_3:                               #   in Loop: Header=BB60_1 Depth=1
	lbu	a0, -13(s0)
	addi	a0, a0, 1
	sb	a0, -13(s0)
	jal	zero, .LBB60_1
.LBB60_4:
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	lw	s0, 8(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 16
	jalr	zero, 0(ra)
.Lfunc_end60:
	.size	SubBytes, .Lfunc_end60-SubBytes
                                        # -- End function
	.p2align	2                               # -- Begin function ShiftRows
	.type	ShiftRows,@function
ShiftRows:                              # @ShiftRows
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16
	sw	a0, -12(s0)
	lw	a0, -12(s0)
	lbu	a0, 1(a0)
	sb	a0, -13(s0)
	lw	a1, -12(s0)
	lbu	a0, 5(a1)
	sb	a0, 1(a1)
	lw	a1, -12(s0)
	lbu	a0, 9(a1)
	sb	a0, 5(a1)
	lw	a1, -12(s0)
	lbu	a0, 13(a1)
	sb	a0, 9(a1)
	lbu	a0, -13(s0)
	lw	a1, -12(s0)
	sb	a0, 13(a1)
	lw	a0, -12(s0)
	lbu	a0, 2(a0)
	sb	a0, -13(s0)
	lw	a1, -12(s0)
	lbu	a0, 10(a1)
	sb	a0, 2(a1)
	lbu	a0, -13(s0)
	lw	a1, -12(s0)
	sb	a0, 10(a1)
	lw	a0, -12(s0)
	lbu	a0, 6(a0)
	sb	a0, -13(s0)
	lw	a1, -12(s0)
	lbu	a0, 14(a1)
	sb	a0, 6(a1)
	lbu	a0, -13(s0)
	lw	a1, -12(s0)
	sb	a0, 14(a1)
	lw	a0, -12(s0)
	lbu	a0, 3(a0)
	sb	a0, -13(s0)
	lw	a1, -12(s0)
	lbu	a0, 15(a1)
	sb	a0, 3(a1)
	lw	a1, -12(s0)
	lbu	a0, 11(a1)
	sb	a0, 15(a1)
	lw	a1, -12(s0)
	lbu	a0, 7(a1)
	sb	a0, 11(a1)
	lbu	a0, -13(s0)
	lw	a1, -12(s0)
	sb	a0, 7(a1)
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	lw	s0, 8(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 16
	jalr	zero, 0(ra)
.Lfunc_end61:
	.size	ShiftRows, .Lfunc_end61-ShiftRows
                                        # -- End function
	.p2align	2                               # -- Begin function MixColumns
	.type	MixColumns,@function
MixColumns:                             # @MixColumns
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -12(s0)
	addi	a0, zero, 0
	sb	a0, -17(s0)
	jal	zero, .LBB62_1
.LBB62_1:                               # =>This Inner Loop Header: Depth=1
	lbu	a1, -17(s0)
	addi	a0, zero, 3
	blt	a0, a1, .LBB62_4
	jal	zero, .LBB62_2
.LBB62_2:                               #   in Loop: Header=BB62_1 Depth=1
	lw	a0, -12(s0)
	lbu	a1, -17(s0)
	slli	a1, a1, 2
	add	a0, a0, a1
	lw	a0, 0(a0)
	srli	a1, a0, 24
	sb	a1, -13(s0)
	srli	a1, a0, 16
	sb	a1, -14(s0)
	sb	a0, -16(s0)
	srli	a0, a0, 8
	sb	a0, -15(s0)
	lbu	a1, -15(s0)
	lbu	a0, -13(s0)
	xor	a0, a0, a1
	sb	a0, -13(s0)
	lbu	a1, -16(s0)
	lbu	a0, -15(s0)
	xor	a0, a0, a1
	sb	a0, -15(s0)
	lbu	a1, -14(s0)
	lbu	a0, -16(s0)
	xor	a0, a0, a1
	sb	a0, -16(s0)
	lbu	a0, -16(s0)
	call	xtime
	sb	a0, -14(s0)
	lbu	a0, -15(s0)
	call	xtime
	addi	a1, a0, 0
	lbu	a0, -16(s0)
	xor	a0, a0, a1
	sb	a0, -16(s0)
	lbu	a0, -13(s0)
	call	xtime
	sb	a0, -15(s0)
	lbu	a1, -13(s0)
	lbu	a0, -16(s0)
	xor	a2, a0, a1
	sb	a2, -16(s0)
	lw	a0, -12(s0)
	lbu	a1, -17(s0)
	slli	a1, a1, 2
	add	a1, a0, a1
	lbu	a0, 0(a1)
	xor	a0, a0, a2
	sb	a0, 0(a1)
	lbu	a1, -14(s0)
	lbu	a0, -16(s0)
	xor	a2, a0, a1
	sb	a2, -16(s0)
	lw	a0, -12(s0)
	lbu	a1, -17(s0)
	slli	a1, a1, 2
	add	a1, a0, a1
	lbu	a0, 1(a1)
	xor	a0, a0, a2
	sb	a0, 1(a1)
	lbu	a1, -15(s0)
	lbu	a0, -16(s0)
	xor	a2, a0, a1
	sb	a2, -16(s0)
	lw	a0, -12(s0)
	lbu	a1, -17(s0)
	slli	a1, a1, 2
	add	a1, a0, a1
	lbu	a0, 2(a1)
	xor	a0, a0, a2
	sb	a0, 2(a1)
	lbu	a1, -14(s0)
	lbu	a0, -16(s0)
	xor	a2, a0, a1
	sb	a2, -16(s0)
	lw	a0, -12(s0)
	lbu	a1, -17(s0)
	slli	a1, a1, 2
	add	a1, a0, a1
	lbu	a0, 3(a1)
	xor	a0, a0, a2
	sb	a0, 3(a1)
	jal	zero, .LBB62_3
.LBB62_3:                               #   in Loop: Header=BB62_1 Depth=1
	lbu	a0, -17(s0)
	addi	a0, a0, 1
	sb	a0, -17(s0)
	jal	zero, .LBB62_1
.LBB62_4:
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	jalr	zero, 0(ra)
.Lfunc_end62:
	.size	MixColumns, .Lfunc_end62-MixColumns
                                        # -- End function
	.p2align	2                               # -- Begin function trace_start
	.type	trace_start,@function
trace_start:                            # @trace_start
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16
	#APP
	addi	a7, zero, -4
	ecall
	#NO_APP
	sw	a0, -12(s0)
	lw	a0, -12(s0)
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	lw	s0, 8(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 16
	jalr	zero, 0(ra)
.Lfunc_end63:
	.size	trace_start, .Lfunc_end63-trace_start
                                        # -- End function
	.p2align	2                               # -- Begin function trace_stop
	.type	trace_stop,@function
trace_stop:                             # @trace_stop
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16
	#APP
	addi	a7, zero, -5
	ecall
	#NO_APP
	sw	a0, -12(s0)
	lw	a0, -12(s0)
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	lw	s0, 8(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 16
	jalr	zero, 0(ra)
.Lfunc_end64:
	.size	trace_stop, .Lfunc_end64-trace_stop
                                        # -- End function
	.p2align	2                               # -- Begin function xtime
	.type	xtime,@function
xtime:                                  # @xtime
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16
                                        # kill: def $x11 killed $x10
	sb	a0, -9(s0)
	lbu	a1, -9(s0)
	slti	a0, a1, 128
	xori	a0, a0, 1
	addi	a2, zero, 27
	mul	a0, a0, a2
	slli	a1, a1, 1
	xor	a0, a0, a1
	andi	a0, a0, 255
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	lw	s0, 8(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 16
	jalr	zero, 0(ra)
.Lfunc_end65:
	.size	xtime, .Lfunc_end65-xtime
                                        # -- End function
	.p2align	2                               # -- Begin function InvMixColumns
	.type	InvMixColumns,@function
InvMixColumns:                          # @InvMixColumns
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -12(s0)
	addi	a0, zero, 0
	sb	a0, -17(s0)
	jal	zero, .LBB66_1
.LBB66_1:                               # =>This Inner Loop Header: Depth=1
	lbu	a1, -17(s0)
	addi	a0, zero, 3
	blt	a0, a1, .LBB66_4
	jal	zero, .LBB66_2
.LBB66_2:                               #   in Loop: Header=BB66_1 Depth=1
	lw	a0, -12(s0)
	lbu	a1, -17(s0)
	slli	a1, a1, 2
	add	a0, a0, a1
	lw	a0, 0(a0)
	srli	a1, a0, 24
	sb	a1, -13(s0)
	srli	a1, a0, 16
	sb	a1, -14(s0)
	sb	a0, -16(s0)
	srli	a0, a0, 8
	sb	a0, -15(s0)
	lbu	a0, -16(s0)
	lbu	a1, -15(s0)
	lbu	a2, -14(s0)
	lbu	a3, -13(s0)
	call	mixG8
	lw	a1, -12(s0)
	lbu	a2, -17(s0)
	slli	a2, a2, 2
	add	a1, a1, a2
	sb	a0, 0(a1)
	lbu	a0, -15(s0)
	lbu	a1, -14(s0)
	lbu	a2, -13(s0)
	lbu	a3, -16(s0)
	call	mixG8
	lw	a1, -12(s0)
	lbu	a2, -17(s0)
	slli	a2, a2, 2
	add	a1, a1, a2
	sb	a0, 1(a1)
	lbu	a0, -14(s0)
	lbu	a1, -13(s0)
	lbu	a2, -16(s0)
	lbu	a3, -15(s0)
	call	mixG8
	lw	a1, -12(s0)
	lbu	a2, -17(s0)
	slli	a2, a2, 2
	add	a1, a1, a2
	sb	a0, 2(a1)
	lbu	a0, -13(s0)
	lbu	a1, -16(s0)
	lbu	a2, -15(s0)
	lbu	a3, -14(s0)
	call	mixG8
	lw	a1, -12(s0)
	lbu	a2, -17(s0)
	slli	a2, a2, 2
	add	a1, a1, a2
	sb	a0, 3(a1)
	jal	zero, .LBB66_3
.LBB66_3:                               #   in Loop: Header=BB66_1 Depth=1
	lbu	a0, -17(s0)
	addi	a0, a0, 1
	sb	a0, -17(s0)
	jal	zero, .LBB66_1
.LBB66_4:
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	jalr	zero, 0(ra)
.Lfunc_end66:
	.size	InvMixColumns, .Lfunc_end66-InvMixColumns
                                        # -- End function
	.p2align	2                               # -- Begin function InvShiftRows
	.type	InvShiftRows,@function
InvShiftRows:                           # @InvShiftRows
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16
	sw	a0, -12(s0)
	lw	a0, -12(s0)
	lbu	a0, 13(a0)
	sb	a0, -13(s0)
	lw	a1, -12(s0)
	lbu	a0, 9(a1)
	sb	a0, 13(a1)
	lw	a1, -12(s0)
	lbu	a0, 5(a1)
	sb	a0, 9(a1)
	lw	a1, -12(s0)
	lbu	a0, 1(a1)
	sb	a0, 5(a1)
	lbu	a0, -13(s0)
	lw	a1, -12(s0)
	sb	a0, 1(a1)
	lw	a0, -12(s0)
	lbu	a0, 2(a0)
	sb	a0, -13(s0)
	lw	a1, -12(s0)
	lbu	a0, 10(a1)
	sb	a0, 2(a1)
	lbu	a0, -13(s0)
	lw	a1, -12(s0)
	sb	a0, 10(a1)
	lw	a0, -12(s0)
	lbu	a0, 6(a0)
	sb	a0, -13(s0)
	lw	a1, -12(s0)
	lbu	a0, 14(a1)
	sb	a0, 6(a1)
	lbu	a0, -13(s0)
	lw	a1, -12(s0)
	sb	a0, 14(a1)
	lw	a0, -12(s0)
	lbu	a0, 3(a0)
	sb	a0, -13(s0)
	lw	a1, -12(s0)
	lbu	a0, 7(a1)
	sb	a0, 3(a1)
	lw	a1, -12(s0)
	lbu	a0, 11(a1)
	sb	a0, 7(a1)
	lw	a1, -12(s0)
	lbu	a0, 15(a1)
	sb	a0, 11(a1)
	lbu	a0, -13(s0)
	lw	a1, -12(s0)
	sb	a0, 15(a1)
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	lw	s0, 8(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 16
	jalr	zero, 0(ra)
.Lfunc_end67:
	.size	InvShiftRows, .Lfunc_end67-InvShiftRows
                                        # -- End function
	.p2align	2                               # -- Begin function InvSubBytes
	.type	InvSubBytes,@function
InvSubBytes:                            # @InvSubBytes
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16
	sw	a0, -12(s0)
	addi	a0, zero, 0
	sb	a0, -13(s0)
	jal	zero, .LBB68_1
.LBB68_1:                               # =>This Inner Loop Header: Depth=1
	lbu	a1, -13(s0)
	addi	a0, zero, 15
	blt	a0, a1, .LBB68_4
	jal	zero, .LBB68_2
.LBB68_2:                               #   in Loop: Header=BB68_1 Depth=1
	lw	a0, -12(s0)
	lbu	a1, -13(s0)
	add	a1, a0, a1
	lbu	a2, 0(a1)
	lui	a0, %hi(rsbox)
	addi	a0, a0, %lo(rsbox)
	add	a0, a0, a2
	lbu	a0, 0(a0)
	sb	a0, 0(a1)
	jal	zero, .LBB68_3
.LBB68_3:                               #   in Loop: Header=BB68_1 Depth=1
	lbu	a0, -13(s0)
	addi	a0, a0, 1
	sb	a0, -13(s0)
	jal	zero, .LBB68_1
.LBB68_4:
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	lw	s0, 8(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 16
	jalr	zero, 0(ra)
.Lfunc_end68:
	.size	InvSubBytes, .Lfunc_end68-InvSubBytes
                                        # -- End function
	.p2align	2                               # -- Begin function mixG8
	.type	mixG8,@function
mixG8:                                  # @mixG8
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16
                                        # kill: def $x14 killed $x13
                                        # kill: def $x14 killed $x12
                                        # kill: def $x14 killed $x11
                                        # kill: def $x14 killed $x10
	sb	a0, -9(s0)
	sb	a1, -10(s0)
	sb	a2, -11(s0)
	sb	a3, -12(s0)
	lbu	a1, -9(s0)
	lbu	a0, -10(s0)
	xor	a0, a0, a1
	sb	a0, -10(s0)
	lbu	a0, -10(s0)
	lbu	a1, -11(s0)
	xor	a1, a0, a1
	lbu	a0, -12(s0)
	xor	a0, a0, a1
	sb	a0, -12(s0)
	lbu	a1, -9(s0)
	lbu	a0, -11(s0)
	xor	a0, a0, a1
	sb	a0, -11(s0)
	lbu	a1, -12(s0)
	lbu	a0, -9(s0)
	xor	a0, a0, a1
	sb	a0, -9(s0)
	lbu	a0, -12(s0)
	call	xtime
	addi	a1, a0, 0
	lbu	a0, -11(s0)
	xor	a0, a0, a1
	sb	a0, -11(s0)
	lbu	a0, -11(s0)
	call	xtime
	addi	a1, a0, 0
	lbu	a0, -10(s0)
	xor	a0, a0, a1
	sb	a0, -10(s0)
	lbu	a0, -10(s0)
	call	xtime
	addi	a1, a0, 0
	lbu	a0, -9(s0)
	xor	a0, a0, a1
	sb	a0, -9(s0)
	lbu	a0, -9(s0)
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	lw	s0, 8(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 16
	jalr	zero, 0(ra)
.Lfunc_end69:
	.size	mixG8, .Lfunc_end69-mixG8
                                        # -- End function
	.p2align	2                               # -- Begin function incBlock
	.type	incBlock,@function
incBlock:                               # @incBlock
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
                                        # kill: def $x12 killed $x11
	sw	a0, -12(s0)
	sb	a1, -13(s0)
	jal	zero, .LBB70_1
.LBB70_1:                               # =>This Inner Loop Header: Depth=1
	lw	a0, -12(s0)
	lbu	a1, -13(s0)
	add	a2, a0, a1
	lbu	a0, 0(a2)
	addi	a1, a0, 1
	andi	a0, a1, 255
	sb	a1, 0(a2)
	beq	a0, zero, .LBB70_3
	jal	zero, .LBB70_2
.LBB70_2:
	jal	zero, .LBB70_8
.LBB70_3:                               #   in Loop: Header=BB70_1 Depth=1
	jal	zero, .LBB70_4
.LBB70_4:                               #   in Loop: Header=BB70_1 Depth=1
	lbu	a1, -13(s0)
	addi	a0, zero, 3
	blt	a0, a1, .LBB70_6
	jal	zero, .LBB70_5
.LBB70_5:                               #   in Loop: Header=BB70_1 Depth=1
	lbu	a0, -13(s0)
	addi	a0, a0, 1
	sb	a0, -13(s0)
	andi	a0, a0, 255
	addi	a2, zero, 1
	addi	a1, zero, 4
	sw	a2, -20(s0)                     # 4-byte Folded Spill
	blt	a0, a1, .LBB70_7
	jal	zero, .LBB70_6
.LBB70_6:                               #   in Loop: Header=BB70_1 Depth=1
	lbu	a0, -13(s0)
	addi	a0, a0, -1
	sb	a0, -13(s0)
	andi	a0, a0, 255
	slti	a0, a0, 9
	xori	a0, a0, 1
	sw	a0, -20(s0)                     # 4-byte Folded Spill
	jal	zero, .LBB70_7
.LBB70_7:                               #   in Loop: Header=BB70_1 Depth=1
	lw	a0, -20(s0)                     # 4-byte Folded Reload
	andi	a0, a0, 1
	bne	a0, zero, .LBB70_1
	jal	zero, .LBB70_8
.LBB70_8:
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	jalr	zero, 0(ra)
.Lfunc_end70:
	.size	incBlock, .Lfunc_end70-incBlock
                                        # -- End function
	.p2align	2                               # -- Begin function copyLint
	.type	copyLint,@function
copyLint:                               # @copyLint
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
                                        # kill: def $x13 killed $x12
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sb	a2, -17(s0)
	jal	zero, .LBB71_1
.LBB71_1:                               # =>This Inner Loop Header: Depth=1
	lw	a0, -16(s0)
	lw	a1, -12(s0)
	lbu	a2, -17(s0)
	addi	a3, a2, 1
	sb	a3, -17(s0)
	add	a1, a1, a2
	sb	a0, 0(a1)
	jal	zero, .LBB71_2
.LBB71_2:                               #   in Loop: Header=BB71_1 Depth=1
	lw	a0, -16(s0)
	srli	a0, a0, 8
	sw	a0, -16(s0)
	bne	a0, zero, .LBB71_1
	jal	zero, .LBB71_3
.LBB71_3:
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	jalr	zero, 0(ra)
.Lfunc_end71:
	.size	copyLint, .Lfunc_end71-copyLint
                                        # -- End function
	.p2align	2                               # -- Begin function doubleLblock
	.type	doubleLblock,@function
doubleLblock:                           # @doubleLblock
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -12(s0)
	addi	a0, zero, 0
	sw	a0, -20(s0)
	sw	a0, -16(s0)
	jal	zero, .LBB72_1
.LBB72_1:                               # =>This Inner Loop Header: Depth=1
	lw	a1, -16(s0)
	addi	a0, zero, 15
	blt	a0, a1, .LBB72_4
	jal	zero, .LBB72_2
.LBB72_2:                               #   in Loop: Header=BB72_1 Depth=1
	lw	a0, -12(s0)
	lw	a1, -16(s0)
	add	a0, a0, a1
	lbu	a0, 0(a0)
	slli	a1, a0, 1
	lw	a0, -20(s0)
	or	a0, a0, a1
	sw	a0, -20(s0)
	lw	a0, -20(s0)
	lw	a1, -12(s0)
	lw	a2, -16(s0)
	addi	a3, a2, 1
	sw	a3, -16(s0)
	add	a1, a1, a2
	sb	a0, 0(a1)
	jal	zero, .LBB72_3
.LBB72_3:                               #   in Loop: Header=BB72_1 Depth=1
	lw	a0, -20(s0)
	srai	a0, a0, 8
	sw	a0, -20(s0)
	jal	zero, .LBB72_1
.LBB72_4:
	lw	a0, -20(s0)
	addi	a1, zero, 135
	mul	a2, a0, a1
	lw	a1, -12(s0)
	lbu	a0, 0(a1)
	xor	a0, a0, a2
	sb	a0, 0(a1)
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	jalr	zero, 0(ra)
.Lfunc_end72:
	.size	doubleLblock, .Lfunc_end72-doubleLblock
                                        # -- End function
	.p2align	2                               # -- Begin function xMac
	.type	xMac,@function
xMac:                                   # @xMac
# %bb.0:
	addi	sp, sp, -48
	sw	ra, 44(sp)                      # 4-byte Folded Spill
	sw	s0, 40(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 48
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	sw	a3, -24(s0)
	sw	a4, -28(s0)
	lw	a0, -16(s0)
	srli	a0, a0, 4
	sw	a0, -36(s0)
	lw	a0, -12(s0)
	sw	a0, -32(s0)
	jal	zero, .LBB73_1
.LBB73_1:                               # =>This Inner Loop Header: Depth=1
	lw	a0, -36(s0)
	addi	a1, a0, -1
	sw	a1, -36(s0)
	beq	a0, zero, .LBB73_4
	jal	zero, .LBB73_2
.LBB73_2:                               #   in Loop: Header=BB73_1 Depth=1
	lw	a0, -32(s0)
	lw	a1, -28(s0)
	call	xorBlock
	lw	a2, -24(s0)
	lw	a0, -20(s0)
	lw	a1, -28(s0)
	jalr	ra, 0(a2)
	jal	zero, .LBB73_3
.LBB73_3:                               #   in Loop: Header=BB73_1 Depth=1
	lw	a0, -32(s0)
	addi	a0, a0, 16
	sw	a0, -32(s0)
	jal	zero, .LBB73_1
.LBB73_4:
	lw	a0, -16(s0)
	andi	a0, a0, 15
	sw	a0, -36(s0)
	beq	a0, zero, .LBB73_9
	jal	zero, .LBB73_5
.LBB73_5:
	jal	zero, .LBB73_6
.LBB73_6:                               # =>This Inner Loop Header: Depth=1
	lw	a0, -36(s0)
	addi	a1, a0, -1
	sw	a1, -36(s0)
	beq	a0, zero, .LBB73_8
	jal	zero, .LBB73_7
.LBB73_7:                               #   in Loop: Header=BB73_6 Depth=1
	lw	a0, -32(s0)
	lw	a1, -36(s0)
	add	a0, a0, a1
	lbu	a2, 0(a0)
	lw	a0, -28(s0)
	add	a1, a0, a1
	lbu	a0, 0(a1)
	xor	a0, a0, a2
	sb	a0, 0(a1)
	jal	zero, .LBB73_6
.LBB73_8:
	lw	a2, -24(s0)
	lw	a0, -20(s0)
	lw	a1, -28(s0)
	jalr	ra, 0(a2)
	jal	zero, .LBB73_9
.LBB73_9:
	lw	ra, 44(sp)                      # 4-byte Folded Reload
	lw	s0, 40(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 48
	jalr	zero, 0(ra)
.Lfunc_end73:
	.size	xMac, .Lfunc_end73-xMac
                                        # -- End function
	.p2align	2                               # -- Begin function mulGF128
	.type	mulGF128,@function
mulGF128:                               # @mulGF128
# %bb.0:
	addi	sp, sp, -48
	sw	ra, 44(sp)                      # 4-byte Folded Spill
	sw	s0, 40(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 48
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	addi	a0, zero, 0
	sw	a0, -24(s0)
	sw	a0, -28(s0)
	sw	a0, -32(s0)
	sw	a0, -36(s0)
	sb	a0, -18(s0)
	jal	zero, .LBB74_1
.LBB74_1:                               # =>This Loop Header: Depth=1
                                        #     Child Loop BB74_3 Depth 2
	lbu	a1, -18(s0)
	addi	a0, zero, 15
	blt	a0, a1, .LBB74_10
	jal	zero, .LBB74_2
.LBB74_2:                               #   in Loop: Header=BB74_1 Depth=1
	addi	a0, zero, 128
	sb	a0, -17(s0)
	jal	zero, .LBB74_3
.LBB74_3:                               #   Parent Loop BB74_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	lbu	a0, -17(s0)
	beq	a0, zero, .LBB74_8
	jal	zero, .LBB74_4
.LBB74_4:                               #   in Loop: Header=BB74_3 Depth=2
	lw	a0, -12(s0)
	lbu	a1, -18(s0)
	add	a0, a0, a1
	lbu	a0, 0(a0)
	lbu	a1, -17(s0)
	and	a0, a0, a1
	beq	a0, zero, .LBB74_6
	jal	zero, .LBB74_5
.LBB74_5:                               #   in Loop: Header=BB74_3 Depth=2
	lw	a0, -16(s0)
	addi	a1, s0, -36
	call	xorBlock
	jal	zero, .LBB74_6
.LBB74_6:                               #   in Loop: Header=BB74_3 Depth=2
	lw	a0, -16(s0)
	call	divideBblock
	jal	zero, .LBB74_7
.LBB74_7:                               #   in Loop: Header=BB74_3 Depth=2
	lbu	a0, -17(s0)
	srli	a0, a0, 1
	sb	a0, -17(s0)
	jal	zero, .LBB74_3
.LBB74_8:                               #   in Loop: Header=BB74_1 Depth=1
	jal	zero, .LBB74_9
.LBB74_9:                               #   in Loop: Header=BB74_1 Depth=1
	lbu	a0, -18(s0)
	addi	a0, a0, 1
	sb	a0, -18(s0)
	jal	zero, .LBB74_1
.LBB74_10:
	lw	a0, -16(s0)
	addi	a1, s0, -36
	addi	a2, zero, 16
	call	memcpy
	lw	ra, 44(sp)                      # 4-byte Folded Reload
	lw	s0, 40(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 48
	jalr	zero, 0(ra)
.Lfunc_end74:
	.size	mulGF128, .Lfunc_end74-mulGF128
                                        # -- End function
	.p2align	2                               # -- Begin function divideBblock
	.type	divideBblock,@function
divideBblock:                           # @divideBblock
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -12(s0)
	addi	a0, zero, 0
	sw	a0, -20(s0)
	sw	a0, -16(s0)
	jal	zero, .LBB75_1
.LBB75_1:                               # =>This Inner Loop Header: Depth=1
	lw	a1, -16(s0)
	addi	a0, zero, 15
	bltu	a0, a1, .LBB75_4
	jal	zero, .LBB75_2
.LBB75_2:                               #   in Loop: Header=BB75_1 Depth=1
	lw	a0, -20(s0)
	slli	a0, a0, 8
	lw	a1, -12(s0)
	lw	a2, -16(s0)
	add	a1, a1, a2
	lbu	a1, 0(a1)
	or	a0, a0, a1
	sw	a0, -20(s0)
	lw	a0, -20(s0)
	srli	a0, a0, 1
	lw	a1, -12(s0)
	lw	a2, -16(s0)
	add	a1, a1, a2
	sb	a0, 0(a1)
	jal	zero, .LBB75_3
.LBB75_3:                               #   in Loop: Header=BB75_1 Depth=1
	lw	a0, -16(s0)
	addi	a0, a0, 1
	sw	a0, -16(s0)
	jal	zero, .LBB75_1
.LBB75_4:
	lbu	a0, -20(s0)
	andi	a0, a0, 1
	beq	a0, zero, .LBB75_6
	jal	zero, .LBB75_5
.LBB75_5:
	lw	a1, -12(s0)
	lbu	a0, 0(a1)
	xori	a0, a0, 225
	sb	a0, 0(a1)
	jal	zero, .LBB75_6
.LBB75_6:
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	jalr	zero, 0(ra)
.Lfunc_end75:
	.size	divideBblock, .Lfunc_end75-divideBblock
                                        # -- End function
	.p2align	2                               # -- Begin function dotGF128
	.type	dotGF128,@function
dotGF128:                               # @dotGF128
# %bb.0:
	addi	sp, sp, -48
	sw	ra, 44(sp)                      # 4-byte Folded Spill
	sw	s0, 40(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 48
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	addi	a0, zero, 0
	sw	a0, -24(s0)
	sw	a0, -28(s0)
	sw	a0, -32(s0)
	sw	a0, -36(s0)
	addi	a0, zero, 16
	sb	a0, -18(s0)
	jal	zero, .LBB76_1
.LBB76_1:                               # =>This Loop Header: Depth=1
                                        #     Child Loop BB76_3 Depth 2
	lbu	a0, -18(s0)
	addi	a1, a0, -1
	sb	a1, -18(s0)
	beq	a0, zero, .LBB76_9
	jal	zero, .LBB76_2
.LBB76_2:                               #   in Loop: Header=BB76_1 Depth=1
	addi	a0, zero, 128
	sb	a0, -17(s0)
	jal	zero, .LBB76_3
.LBB76_3:                               #   Parent Loop BB76_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	lbu	a0, -17(s0)
	beq	a0, zero, .LBB76_8
	jal	zero, .LBB76_4
.LBB76_4:                               #   in Loop: Header=BB76_3 Depth=2
	lw	a0, -16(s0)
	call	divideLblock
	lw	a0, -12(s0)
	lbu	a1, -18(s0)
	add	a0, a0, a1
	lbu	a0, 0(a0)
	lbu	a1, -17(s0)
	and	a0, a0, a1
	beq	a0, zero, .LBB76_6
	jal	zero, .LBB76_5
.LBB76_5:                               #   in Loop: Header=BB76_3 Depth=2
	lw	a0, -16(s0)
	addi	a1, s0, -36
	call	xorBlock
	jal	zero, .LBB76_6
.LBB76_6:                               #   in Loop: Header=BB76_3 Depth=2
	jal	zero, .LBB76_7
.LBB76_7:                               #   in Loop: Header=BB76_3 Depth=2
	lbu	a0, -17(s0)
	srli	a0, a0, 1
	sb	a0, -17(s0)
	jal	zero, .LBB76_3
.LBB76_8:                               #   in Loop: Header=BB76_1 Depth=1
	jal	zero, .LBB76_1
.LBB76_9:
	lw	a0, -16(s0)
	addi	a1, s0, -36
	addi	a2, zero, 16
	call	memcpy
	lw	ra, 44(sp)                      # 4-byte Folded Reload
	lw	s0, 40(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 48
	jalr	zero, 0(ra)
.Lfunc_end76:
	.size	dotGF128, .Lfunc_end76-dotGF128
                                        # -- End function
	.p2align	2                               # -- Begin function divideLblock
	.type	divideLblock,@function
divideLblock:                           # @divideLblock
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -12(s0)
	addi	a0, zero, 0
	sw	a0, -16(s0)
	addi	a0, zero, 16
	sw	a0, -20(s0)
	jal	zero, .LBB77_1
.LBB77_1:                               # =>This Inner Loop Header: Depth=1
	lw	a0, -20(s0)
	addi	a1, a0, -1
	sw	a1, -20(s0)
	beq	a0, zero, .LBB77_3
	jal	zero, .LBB77_2
.LBB77_2:                               #   in Loop: Header=BB77_1 Depth=1
	lw	a0, -16(s0)
	slli	a0, a0, 8
	lw	a1, -12(s0)
	lw	a2, -20(s0)
	add	a1, a1, a2
	lbu	a1, 0(a1)
	or	a0, a0, a1
	sw	a0, -16(s0)
	lw	a0, -16(s0)
	srli	a0, a0, 1
	lw	a1, -12(s0)
	lw	a2, -20(s0)
	add	a1, a1, a2
	sb	a0, 0(a1)
	jal	zero, .LBB77_1
.LBB77_3:
	lbu	a0, -16(s0)
	andi	a0, a0, 1
	beq	a0, zero, .LBB77_5
	jal	zero, .LBB77_4
.LBB77_4:
	lw	a1, -12(s0)
	lbu	a0, 15(a1)
	xori	a0, a0, 225
	sb	a0, 15(a1)
	jal	zero, .LBB77_5
.LBB77_5:
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	jalr	zero, 0(ra)
.Lfunc_end77:
	.size	divideLblock, .Lfunc_end77-divideLblock
                                        # -- End function
	.p2align	2                               # -- Begin function nop
	.type	nop,@function
nop:                                    # @nop
# %bb.0:
	addi	sp, sp, -16
	sw	ra, 12(sp)                      # 4-byte Folded Spill
	sw	s0, 8(sp)                       # 4-byte Folded Spill
	addi	s0, sp, 16
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	lw	ra, 12(sp)                      # 4-byte Folded Reload
	lw	s0, 8(sp)                       # 4-byte Folded Reload
	addi	sp, sp, 16
	jalr	zero, 0(ra)
.Lfunc_end78:
	.size	nop, .Lfunc_end78-nop
                                        # -- End function
	.p2align	2                               # -- Begin function getDelta
	.type	getDelta,@function
getDelta:                               # @getDelta
# %bb.0:
	addi	sp, sp, -64
	sw	ra, 60(sp)                      # 4-byte Folded Spill
	sw	s0, 56(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 64
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	sw	a3, -24(s0)
	addi	a0, zero, 1
	sw	a0, -32(s0)
	lw	a1, -16(s0)
	addi	a0, s0, -48
	addi	a2, zero, 16
	sw	a2, -52(s0)                     # 4-byte Folded Spill
	call	memcpy
	lw	a2, -52(s0)                     # 4-byte Folded Reload
	lw	a0, -24(s0)
	lw	a1, -20(s0)
	call	memcpy
	jal	zero, .LBB79_1
.LBB79_1:                               # =>This Inner Loop Header: Depth=1
	lw	a0, -12(s0)
	lw	a1, -32(s0)
	sub	a0, a0, a1
	sw	a0, -28(s0)
	lw	a1, -12(s0)
	bgeu	a0, a1, .LBB79_5
	jal	zero, .LBB79_2
.LBB79_2:                               #   in Loop: Header=BB79_1 Depth=1
	addi	a0, s0, -48
	call	doubleBblock
	lw	a0, -32(s0)
	slli	a1, a0, 1
	sw	a1, -32(s0)
	lw	a0, -28(s0)
	and	a0, a0, a1
	sw	a0, -28(s0)
	lw	a0, -28(s0)
	bne	a0, zero, .LBB79_4
	jal	zero, .LBB79_3
.LBB79_3:                               #   in Loop: Header=BB79_1 Depth=1
	lw	a1, -24(s0)
	addi	a0, s0, -48
	call	xorBlock
	jal	zero, .LBB79_4
.LBB79_4:                               #   in Loop: Header=BB79_1 Depth=1
	jal	zero, .LBB79_1
.LBB79_5:
	lw	ra, 60(sp)                      # 4-byte Folded Reload
	lw	s0, 56(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 64
	jalr	zero, 0(ra)
.Lfunc_end79:
	.size	getDelta, .Lfunc_end79-getDelta
                                        # -- End function
	.type	RoundKey,@object                # @RoundKey
	.local	RoundKey
	.comm	RoundKey,176,1
	.type	.L__const.AES_CCM_encrypt.iv,@object # @__const.AES_CCM_encrypt.iv
	.section	.rodata.cst16,"aM",@progbits,16
.L__const.AES_CCM_encrypt.iv:
	.byte	3                               # 0x3
	.zero	15
	.size	.L__const.AES_CCM_encrypt.iv, 16

	.type	.L__const.AES_CCM_decrypt.iv,@object # @__const.AES_CCM_decrypt.iv
.L__const.AES_CCM_decrypt.iv:
	.byte	3                               # 0x3
	.zero	15
	.size	.L__const.AES_CCM_decrypt.iv, 16

	.type	.L__const.AES_Poly1305.rk,@object # @__const.AES_Poly1305.rk
	.section	.rodata,"a",@progbits
.L__const.AES_Poly1305.rk:
	.byte	1                               # 0x1
	.zero	16
	.size	.L__const.AES_Poly1305.rk, 17

	.type	.L.str,@object                  # @.str
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str:
	.asciz	"ffffffffffffffffffffffffffffffff"
	.size	.L.str, 33

	.type	.L.str.1,@object                # @.str.1
.L.str.1:
	.asciz	"00ffffffffffffffffffffffffffffff"
	.size	.L.str.1, 33

	.type	.L.str.2,@object                # @.str.2
.L.str.2:
	.asciz	"round\n"
	.size	.L.str.2, 7

	.type	sbox,@object                    # @sbox
	.section	.rodata,"a",@progbits
sbox:
	.ascii	"c|w{\362ko\3050\001g+\376\327\253v\312\202\311}\372YG\360\255\324\242\257\234\244r\300\267\375\223&6?\367\3144\245\345\361q\3301\025\004\307#\303\030\226\005\232\007\022\200\342\353'\262u\t\203,\032\033nZ\240R;\326\263)\343/\204S\321\000\355 \374\261[j\313\2769JLX\317\320\357\252\373CM3\205E\371\002\177P<\237\250Q\243@\217\222\2358\365\274\266\332!\020\377\363\322\315\f\023\354_\227D\027\304\247~=d]\031s`\201O\334\"*\220\210F\356\270\024\336^\013\333\3402:\nI\006$\\\302\323\254b\221\225\344y\347\3107m\215\325N\251lV\364\352ez\256\b\272x%.\034\246\264\306\350\335t\037K\275\213\212p>\265fH\003\366\016a5W\271\206\301\035\236\341\370\230\021i\331\216\224\233\036\207\351\316U(\337\214\241\211\r\277\346BhA\231-\017\260T\273\026"
	.size	sbox, 256

	.type	rsbox,@object                   # @rsbox
rsbox:
	.ascii	"R\tj\32506\2458\277@\243\236\201\363\327\373|\3439\202\233/\377\2074\216CD\304\336\351\313T{\2242\246\302#=\356L\225\013B\372\303N\b.\241f(\331$\262v[\242Im\213\321%r\370\366d\206h\230\026\324\244\\\314]e\266\222lpHP\375\355\271\332^\025FW\247\215\235\204\220\330\253\000\214\274\323\n\367\344X\005\270\263E\006\320,\036\217\312?\017\002\301\257\275\003\001\023\212k:\221\021AOg\334\352\227\362\317\316\360\264\346s\226\254t\"\347\2555\205\342\3717\350\034u\337nG\361\032q\035)\305\211o\267b\016\252\030\276\033\374V>K\306\322y \232\333\300\376x\315Z\364\037\335\2503\210\007\3071\261\022\020Y'\200\354_`Q\177\251\031\265J\r-\345z\237\223\311\234\357\240\340;M\256*\365\260\310\353\273<\203S\231a\027+\004~\272w\326&\341i\024cU!\f}"
	.size	rsbox, 256

	.ident	"clang version 22.1.1"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym AES_ECB_encrypt
	.addrsig_sym memcpy
	.addrsig_sym KeyExpansion
	.addrsig_sym rijndaelEncrypt
	.addrsig_sym padBlock
	.addrsig_sym rijndaelDecrypt
	.addrsig_sym xorBlock
	.addrsig_sym mixThenXor
	.addrsig_sym CFB_cipher
	.addrsig_sym AES_OFB_encrypt
	.addrsig_sym AES_CTR_encrypt
	.addrsig_sym xorBEint
	.addrsig_sym CTR_cipher
	.addrsig_sym XTS_cipher
	.addrsig_sym getSubkeys
	.addrsig_sym doubleBblock
	.addrsig_sym cMac
	.addrsig_sym GCMsetup
	.addrsig_sym gHash
	.addrsig_sym memcmp
	.addrsig_sym CCMtag
	.addrsig_sym S2V
	.addrsig_sym GCM_SIVsetup
	.addrsig_sym polyval
	.addrsig_sym GCM_SIVtag
	.addrsig_sym oMac
	.addrsig_sym OCB_cipher
	.addrsig_sym memset
	.addrsig_sym mulLblocks
	.addrsig_sym addLblocks
	.addrsig_sym modP1305
	.addrsig_sym hex2bytes
	.addrsig_sym write
	.addrsig_sym AddRoundKey
	.addrsig_sym SubBytes
	.addrsig_sym ShiftRows
	.addrsig_sym MixColumns
	.addrsig_sym trace_start
	.addrsig_sym trace_stop
	.addrsig_sym xtime
	.addrsig_sym InvMixColumns
	.addrsig_sym InvShiftRows
	.addrsig_sym InvSubBytes
	.addrsig_sym mixG8
	.addrsig_sym incBlock
	.addrsig_sym copyLint
	.addrsig_sym doubleLblock
	.addrsig_sym xMac
	.addrsig_sym mulGF128
	.addrsig_sym divideBblock
	.addrsig_sym dotGF128
	.addrsig_sym divideLblock
	.addrsig_sym nop
	.addrsig_sym getDelta
	.addrsig_sym RoundKey
	.addrsig_sym sbox
	.addrsig_sym rsbox
