outputXY:	.string "current X = %d, Y = %d \n"
outputMax:	.string "  maximum: %d \n"

result: .string "\nthe global max is %d\n"

.balign 4
.global main

main:
	stp x29, x30, [sp, -16]!
	mov x29, sp

	// x20: x value starting from -10
	mov x20, -10
	// x21: y value
	mov x21, 0
	// maximum y value
	mov x22, -500

    // loop counter (from -10 to 4)
    mov x27, -10
	b test

test:
	// domain: {x | -10 <= x <= 4}
	// check if current x is = 4
	// if so, print final result which branches to done
	cmp x27, 4
	b.gt printResult
    
    // reset current y before doing calculations
    mov x21, 0

	// -2x^3
	mov x23, -2
	mul x23, x20, x20
	mul x23, x20, x20
	//mul x23, x20, x20
	
    // -22x^2
	mov x24, -22
	mul x24, x20, x20
	//mul x24, x20, x20
	
    // 11x
	mov x28, 11
	mul x25, x20, x28

	// add the polynomial terms together to get the current y
	//add x21, x21, x28

	mov x28, 0
    
    // -2x^3 + (-22x^2)
	add x21, x23, x24
    // + 11x
	// add constant 57 using temp register
	add x21, x28, x25

	// reset temp register
	mov x28, 57

    // increment the loop counter
    add x27, x27, 1
	
    // print current x,y and max so far
    adrp x0, outputXY
    add x0, x0, :lo12:outputXY
    mov x1, x20
	mov x2, x21
    bl printf
    add x20, x20, 1
    b printMax

	cmp x21, x22
	b.gt newMaximum

printMax:
	// printf for current maximum value
	adrp x0, outputMax
    add x0, x0, :lo12:outputMax
    mov x1, x26
    bl printf
    b test

newMaximum:
    // make current max as global max
	mov x26, x22 

printResult:
    adrp x0, result
    add x0, x0, :lo12:result
    mov x1, x28
    mov x2, x26
    bl printf
    b done

done:
	// exit program
	mov x0, 0
	ldp x29, x30, [sp], 16
	ret
