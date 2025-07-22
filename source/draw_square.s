#
# Function: draw_square
#
# Description:
#   Draws a 16x16 pixel square on a 320x240 grid. The screen is treated as a
#   20x15 grid of 16x16 squares. The function calculates the pixel memory
#   address from the grid coordinates. Assumes 8-bit (1-byte) color.
#
# Arguments:
#   a0: Packed grid coordinate. High byte is Y (0-14), Low byte is X (0-19).
#       Example: 0x0A05 means Y=10, X=5.
#   a1: The 8-bit color value for the square.
#
# Register Usage:
#   s0: Stores the grid X coordinate.
#   s1: Stores the color (from a1).
#   s2: Outer loop counter for the y-axis (rows).
#   s3: Inner loop counter for the x-axis (columns).
#   s4: Stores the memory address for the start of the current row being drawn.
#   s5: Stores the grid Y coordinate.
#   t0, t1, t2: Temporary registers for address calculation.
#   t3: Temporary register for screen stride.
#

.globl draw_square
draw_square:
    # --- Function Prologue ---
    # Save registers that will be modified.
    addi sp, sp, -32
    sw ra, 28(sp)
    sw s0, 24(sp)
    sw s1, 20(sp)
    sw s2, 16(sp)
    sw s3, 12(sp)
    sw s4, 8(sp)
    sw s5, 4(sp)

    # --- Unpack Arguments and Calculate Address ---
    andi s0, a0, 0xFF      # Extract low byte for grid X coordinate (s0 = grid_x)
    srli s5, a0, 8         # Shift right by 8 to get high byte for grid Y (s5 = grid_y)
    mv   s1, a1            # Move color into saved register s1

    # Calculate the starting memory address from grid coordinates.
    # Formula: address = base + (grid_y * 16 * 320) + (grid_x * 16)
    li   t0, 0xFF000000    # t0 = screen base address

    # Calculate Y offset in bytes: grid_y * (16 pixels/block * 320 bytes/row)
    li   t1, 5120          # t1 = 16 * 320
    mul  t2, s5, t1        # t2 = grid_y * 5120
    add  t0, t0, t2        # Add Y offset to base address

    # Calculate X offset in bytes: grid_x * 16 pixels/block
    slli t1, s0, 4         # t1 = grid_x * 16 (shift left by 4 is faster than mul)
    add  s4, t0, t1        # s4 = final start address. Store in s4 for the loops.

    # --- Drawing Loops ---
    li   s2, 16            # s2 = y_counter, for 16 rows

# --- Outer Loop (Y-axis / Rows) ---
drawsquare_outer_loop:
    li   s3, 16            # Reset x_counter for the inner loop (16 pixels wide)
    mv   t0, s4            # t0 = current pixel address, starting at the beginning of the current row

    # --- Inner Loop (X-axis / Columns) ---
    drawsquare_inner_loop:
        sb   s1, 0(t0)     # Store the single color byte
        addi t0, t0, 1     # Advance to the next pixel (1 byte)

        addi s3, s3, -1
        bnez s3, drawsquare_inner_loop

    # --- After Inner Loop ---
    # Move to the start of the next row down.
    # Stride = 320 pixels * 1 byte/pixel = 320 bytes.
    li   t3, 320
    add  s4, s4, t3        # Update the row's start address

    addi s2, s2, -1
    bnez s2, drawsquare_outer_loop

# --- Function Epilogue ---
drawsquare_epilogue:
    lw ra, 28(sp)
    lw s0, 24(sp)
    lw s1, 20(sp)
    lw s2, 16(sp)
    lw s3, 12(sp)
    lw s4, 8(sp)
    lw s5, 4(sp)
    addi sp, sp, 32

    ret