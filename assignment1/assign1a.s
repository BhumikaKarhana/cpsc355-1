// assign string literals for later use when printing to stdout
outputXY:	.string "current X = %d, Y = %d \n"
outputMax:	.string "  maximum: %d \n"
result: .string "\nthe global max is %d\n"

// ensure instructions are properly aligned
// make "main" visible to linker
.balign 4
.global main

main:
    //save state
	stp x29, x30, [sp, -16]!
	mov x29, sp

	// x20: x value starting from -10 (it acts as a loop counter and used for calcaulations
	mov x20, -10
	// x21: current y value, starts at 0 and resets on every iteration
	mov x21, 0
	// current maximum y value, start at a small value and it gets updated on the first iteration
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
    // use temp register to calculate 11x and store it in another temporary (used in later calculations)
    mul x25, x20, x28

    // -22x^2
    mov x24, -22
    // use temporary value to store x^2
    mul x23, x20, x20
    // multiply and add the temporary variables to get the x term value for this polynomial term
    mul x24, x24, x23
    add x24, x24, x25

    // reset temporary regiters used in previous calculations
    mov x23, 0
    mov x28, 0

	// -2x^3
	mov x23, -2
    // store x^2 in temporary register 
	mul x28, x20, x20
    // combine all the x terms to get the final y value for the current x
	mul x28, x28, x20
    mul x23, x23, x28
    // add the previous x terms together
    add x23, x23, x24

    // add constant 57 to final value of y, after all the calculatios involving x
    add x23, x23, 57

    // x23 is the current y value for the corresponding x value over here
    
    // make current max as global max if it is greater than it
    cmp x23, x22
    b.gt newMaximum
    // branch to end of loop to execute the printf instructions
    b endLoop

endLoop: 
    // print current x,y values
    adrp x0, outputXY
    add x0, x0, :lo12:outputXY
    // value for first %d is the x value and the y value for the second %d
    mov x1, x20
    mov x2, x23
    // branch to and link printf
    bl printf
    // increment the current x value (used as a loop counter)
    add x20, x20, 1

	// print current maximum value so far
	adrp x0, outputMax
    add x0, x0, :lo12:outputMax
    // string literal %d is the current max 
    mov x1, x22
    bl printf
    // move to the next iteration of the loop after printing to stdout
    b test

newMaximum:
    // set the new maximum and branch to the end of the loop (printing to stdout)
    mov x22, x23
    b endLoop

printResult:
    // printing final result, the maximum value of the polynomial
    adrp x0, result
    add x0, x0, :lo12:result
    // value for string literal %d is current_max register
    mov x1, x22
    bl printf
    b done

done:
	// exit program with exit code 0
	mov x0, 0
    // restore state and return
	ldp x29, x30, [sp], 16
	ret
