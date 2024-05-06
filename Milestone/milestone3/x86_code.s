	.section		.rodata
.str2:
	.string	"__main__"
.str1:
	.string	"Sum of powers for base 3 up to the exponent 4 is: "
.str0:
	.string	"Fibonacci number at position 10 is: "
	.globl	main
.LC0:
	.string	"%d\n"
.LC1:
	.string	"%s\n"
	.text
	.globl	add
	.type	add, @function
add:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$16, %rsp
	movq	16(%rbp), %r12
	movq	%r12, -16(%rbp)
	movq	24(%rbp), %r12
	movq	%r12, -8(%rbp)
	subq	$8, %rsp
	movq	-8(%rbp), %r12
	movq	-16(%rbp), %r8
	addq	%r8, %r12
	movq	%r12, -24(%rbp)
	movq	-24(%rbp), %rax
	leave
	ret
	leave
	ret

	.globl	power
	.type	power, @function
power:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$16, %rsp
	movq	16(%rbp), %r12
	movq	%r12, -16(%rbp)
	movq	24(%rbp), %r12
	movq	%r12, -8(%rbp)
	subq	$8, %rsp
	movq	$1, -24(%rbp)
.L0:
	subq	$8, %rsp
	movq	$0, -32(%rbp)
	subq	$8, %rsp
	movq	-16(%rbp), %r12
	movq	-32(%rbp), %r8
	cmp		%r8, %r12
	setg	%cl
	movzbl	%cl, %ecx
	movq	%rcx, -40(%rbp)
	movq	$1, %r8
	and		%rcx, %r8
	jz		.L1
	movq	-24(%rbp), %rax
	movq	-8(%rbp), %r8
	imul	%r8, %rax
	movq	%rax, -24(%rbp)
	movq	-24(%rbp), %r12
	movq	%r12, -24(%rbp)
	subq	$8, %rsp
	movq	$1, -48(%rbp)
	subq	$8, %rsp
	movq	-16(%rbp), %r12
	movq	-48(%rbp), %r8
	subq	%r8, %r12
	movq	%r12, -56(%rbp)
	movq	-56(%rbp), %r12
	movq	%r12, -16(%rbp)
	jmp		.L0
.L1:
	movq	-24(%rbp), %rax
	leave
	ret
	leave
	ret

	.globl	sum_of_powers
	.type	sum_of_powers, @function
sum_of_powers:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$16, %rsp
	movq	16(%rbp), %r12
	movq	%r12, -16(%rbp)
	movq	24(%rbp), %r12
	movq	%r12, -8(%rbp)
	subq	$8, %rsp
	movq	$0, -24(%rbp)
	subq	$8, %rsp
	movq	$0, -32(%rbp)
	subq	$8, %rsp
	movq	$0, -40(%rbp)
	subq	$8, %rsp
	movq	$0, -48(%rbp)
	subq	$8, %rsp
	movq	-16(%rbp), %r12
	movq	-48(%rbp), %r8
	cmp		%r8, %r12
	sete	%cl
	movzbl	%cl, %ecx
	movq	%rcx, -56(%rbp)
	movq	$1, %r8
	and		%rcx, %r8
	jz		.L3
	subq	$8, %rsp
	movq	$0, -64(%rbp)
	movq	-64(%rbp), %rax
	leave
	ret
	jmp		.L2
.L3:
	movq	$8, %r14
	sub		%r14, %rsp
	subq	$8, %rsp
	movq	$1, -72(%rbp)
	subq	$8, %rsp
	movq	-16(%rbp), %r12
	movq	-72(%rbp), %r8
	subq	%r8, %r12
	movq	%r12, -80(%rbp)
	movq	-80(%rbp), %r12
	movq	%r12, -24(%rbp)
	subq	$8, %rsp
	movq	-8(%rbp), %r8
	movq	%r8, -88(%rbp)
	subq	$8, %rsp
	movq	-16(%rbp), %r8
	movq	%r8, -96(%rbp)
	call	power
	subq	$8, %rsp
	movq	%rax, -104(%rbp)
	movq	-104(%rbp), %r12
	movq	%r12, -32(%rbp)
	subq	$8, %rsp
	movq	-8(%rbp), %r8
	movq	%r8, -112(%rbp)
	subq	$8, %rsp
	movq	-24(%rbp), %r8
	movq	%r8, -120(%rbp)
	call	sum_of_powers
	subq	$8, %rsp
	movq	%rax, -128(%rbp)
	movq	-128(%rbp), %r12
	movq	%r12, -40(%rbp)
	subq	$8, %rsp
	movq	-32(%rbp), %r8
	movq	%r8, -136(%rbp)
	subq	$8, %rsp
	movq	-40(%rbp), %r8
	movq	%r8, -144(%rbp)
	call	add
	subq	$8, %rsp
	movq	%rax, -152(%rbp)
	movq	-152(%rbp), %rax
	leave
	ret
.L2:
	leave
	ret

	.globl	fibonacci
	.type	fibonacci, @function
fibonacci:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$8, %rsp
	movq	16(%rbp), %r12
	movq	%r12, -8(%rbp)
	subq	$8, %rsp
	movq	$2, -16(%rbp)
	subq	$8, %rsp
	movq	$3, -24(%rbp)
	subq	$8, %rsp
	movq	$0, -32(%rbp)
	subq	$8, %rsp
	movq	-8(%rbp), %r12
	movq	-32(%rbp), %r8
	cmp		%r8, %r12
	setl	%cl
	movzbl	%cl, %ecx
	movq	%rcx, -40(%rbp)
	movq	$1, %r8
	and		%rcx, %r8
	jz		.L6
	subq	$8, %rsp
	movq	$1, %r12
	movq	$0, %r8
	subq	%r12, %r8
	movq	%r8, -48(%rbp)
	movq	-48(%rbp), %rax
	leave
	ret
	jmp		.L5
.L6:
	movq	$8, %r14
	sub		%r14, %rsp
	subq	$8, %rsp
	movq	$0, -56(%rbp)
	subq	$8, %rsp
	movq	-8(%rbp), %r12
	movq	-56(%rbp), %r8
	cmp		%r8, %r12
	sete	%cl
	movzbl	%cl, %ecx
	movq	%rcx, -64(%rbp)
	movq	$1, %r8
	movq	%rcx, %r15
	and		%rcx, %r8
	jz		.L7
	subq	$8, %rsp
	movq	$0, -72(%rbp)
	movq	-72(%rbp), %rax
	leave
	ret
	jmp		.L5
.L7:
	movq	$8, %r14
	sub		%r14, %rsp
	subq	$8, %rsp
	movq	$1, -80(%rbp)
	subq	$8, %rsp
	movq	-8(%rbp), %r12
	movq	-80(%rbp), %r8
	cmp		%r8, %r12
	sete	%cl
	movzbl	%cl, %ecx
	movq	%rcx, -88(%rbp)
	movq	$1, %r8
	movq	%rcx, %r15
	and		%rcx, %r8
	jz		.L8
	subq	$8, %rsp
	movq	$1, -96(%rbp)
	movq	-96(%rbp), %rax
	leave
	ret
	jmp		.L5
.L8:
	movq	$8, %r14
	sub		%r14, %rsp
	subq	$8, %rsp
	movq	$2, -104(%rbp)
	subq	$8, %rsp
	movq	-8(%rbp), %r12
	movq	-104(%rbp), %r8
	cmp		%r8, %r12
	sete	%cl
	movzbl	%cl, %ecx
	movq	%rcx, -112(%rbp)
	movq	$1, %r8
	movq	%rcx, %r15
	and		%rcx, %r8
	jz		.L9
	subq	$8, %rsp
	movq	$1, -120(%rbp)
	movq	-120(%rbp), %rax
	leave
	ret
	jmp		.L5
.L9:
	movq	$8, %r14
	sub		%r14, %rsp
	subq	$8, %rsp
	movq	$1, -128(%rbp)
	subq	$8, %rsp
	movq	-8(%rbp), %r12
	movq	-128(%rbp), %r8
	subq	%r8, %r12
	movq	%r12, -136(%rbp)
	subq	$8, %rsp
	movq	-136(%rbp), %r8
	movq	%r8, -144(%rbp)
	call	fibonacci
	subq	$8, %rsp
	movq	%rax, -152(%rbp)
	subq	$8, %rsp
	movq	$2, -160(%rbp)
	subq	$8, %rsp
	movq	-8(%rbp), %r12
	movq	-160(%rbp), %r8
	subq	%r8, %r12
	movq	%r12, -168(%rbp)
	subq	$8, %rsp
	movq	-168(%rbp), %r8
	movq	%r8, -176(%rbp)
	call	fibonacci
	subq	$8, %rsp
	movq	%rax, -184(%rbp)
	subq	$8, %rsp
	movq	-152(%rbp), %r12
	movq	-184(%rbp), %r8
	addq	%r8, %r12
	movq	%r12, -192(%rbp)
	movq	-192(%rbp), %rax
	leave
	ret
.L5:
	leave
	ret

	.globl	main
	.type	main, @function
main:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$8, %rsp
	movq	$10, -8(%rbp)
	subq	$8, %rsp
	movq	-8(%rbp), %r8
	movq	%r8, -16(%rbp)
	call	fibonacci
	subq	$8, %rsp
	movq	%rax, -24(%rbp)
	leaq	.str0(%rip), %rsi
	movq	$0, %rax
	call	printstr
	movq	-24(%rbp), %rsi
	movq	$0, %rax
	call	print
	subq	$8, %rsp
	movq	$3, -32(%rbp)
	subq	$8, %rsp
	movq	$4, -40(%rbp)
	subq	$8, %rsp
	movq	-32(%rbp), %r8
	movq	%r8, -48(%rbp)
	subq	$8, %rsp
	movq	-40(%rbp), %r8
	movq	%r8, -56(%rbp)
	call	sum_of_powers
	subq	$8, %rsp
	movq	%rax, -64(%rbp)
	leaq	.str1(%rip), %rsi
	movq	$0, %rax
	call	printstr
	movq	-64(%rbp), %rsi
	movq	$0, %rax
	call	print
	leave
	ret

	subq	$8, %rsp
	movq	$., %rdi
	movq	$.str2, %rsi
	call	strcmp
	sete	 %cl
	movzbl	%cl, %ecx
	movq	%rcx, -72(%rbp)
	movq	$1, %r8
	and		%rcx, %r8
	jz		.L12
.L12:
.L11:
	movq	$1, %r8
	movq	%r15, %rcx
	and		 %r8, %rcx
	jnz		.rsp0
	movq	$0, %r14
	sub		%r14, %rsp
.rsp0:
memalloc:
	pushq	%rbp
	mov		%rsp, %rbp
	movq	16(%rbp), %rdi
	call malloc
	leave
	ret
print:
	pushq	%rbp
	mov		%rsp, %rbp
	testq	$15, %rsp
	jz		is_print_aligned
	pushq $0
	leaq	.LC0(%rip), %rdi
	xor		%rax, %rax
	call	printf
	addq	$8, %rsp
	leave
	ret
is_print_aligned:
	lea		.LC0(%rip), %rdi
	xor		%rax, %rax
	call	printf
	leave
	ret
printstr:
	pushq	%rbp
	mov		%rsp, %rbp
	testq	$15, %rsp
	jz		is_print_alignedstr
	pushq	$0
	leaq	.LC1(%rip), %rdi
	xor		%rax, %rax
	call	printf
	addq	$8, %rsp
	leave
	ret
is_print_alignedstr:
	lea		.LC1(%rip), %rdi
	xor		%rax, %rax
	call	printf
	leave
	ret
