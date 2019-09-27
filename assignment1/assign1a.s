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
    
    // start the first iteration of the loop
	b test

test:
	// domain: {x | -10 <= x <= 4}
	// check if current x is = 4
	// if so, print final result which then branches to done
	cmp x20, 4
	b.gt printResult
    
    // BEGIN LOOP BODY

    // reset temporary registers before doing calculations
    mov x21, 0
    mov x23, 0
    mov x24, 0
    mov x25, 0
	mov x28, 0

    // 11x
    mov x28, 11
    mul x25, x20, x28
    //add x25, x25, 0

    // -22x^2
    mov x24, -22
    mul x23, x20, x20
    mul x24, x24, x23
    add x24, x24, x25

    // reset temporary regiters used in previous calculations
    mov x23, 0
    mov x28, 0

	// -2x^3
	mov x23, -2
	mul x28, x20, x20
	mul x28, x28, x20
    mul x23, x23, x28
    add x23, x23, x24

    // add constant 57 to final value of y, after all the calculatios involving x
    add x23, x23, 57
    
    // make current max as global max if it is greater than it
    cmp x23, x22
    b.gt newMaximum
    b endLoop

endLoop: 
    // print current x,y and max so far
    adrp x0, outputXY
    add x0, x0, :lo12:outputXY
    mov x1, x20
    mov x2, x23
    bl printf
    add x20, x20, 1

	// printf for current maximum value
	adrp x0, outputMax
    add x0, x0, :lo12:outputMax
    mov x1, x22
    bl printf
    b test

newMaximum:
    mov x22, x23
    b endLoop

printResult:
    adrp x0, result
    add x0, x0, :lo12:result
    mov x1, x22
    //mov x2, x26
    bl printf
    b done

done:
	// exit program
	mov x0, 0
	ldp x29, x30, [sp], 16
	ret
