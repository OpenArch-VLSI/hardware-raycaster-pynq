# Fixed Point Formats

The raycaster relies heavily on fixed-point arithmetic instead of floating-point to drastically reduce logic resource utilization and increase speed on the FPGA. The entire fixed-point math configuration is centralized in `rtl/include/fixp_pkg.svh`.

The design uses standard two's-complement arithmetic. Because addition and subtraction of fixed-point numbers with identical fractional scaling function exactly like integer arithmetic, the primary difficulty lies in multiplication and division (which shift the fractional point) and type casting. The package solves this through preprocessor macros (`FIXP_MULT`, `FIXP_MULT_TRUNC`, `FIXP_CAST`) which statically enforce correct bit-shifting and alignment during synthesis.

## Type Definitions

| Type | Bit Width | Integer Bits | Fractional Bits | Primary Producers/Users | Reasoning |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`pos_fixp_t`** | 20 bits | 10 bits (`POS_W_INT`) | 10 bits (`POS_W_FRAC`) | `position.sv`, `controls.sv`, `render.sv` | The core coordinate system. Maps the 32x32 world (requiring 5 bits, plus sign and headroom = 10 bits) and maintains enough sub-grid fractional precision for smooth movement. |
| **`ext_pos_fixp_t`** | 22 bits | 12 bits (`EXT_POS_W_INT`) | 10 bits (`POS_W_FRAC`) | `column_calc.sv`, `dda.sv` | Extended range coordinate type. Used during intermediate DDA distance calculations where the theoretical ray distance could temporarily exceed the map bounds before a wall is hit. |
| **`ray_fixp_t`** | 12 bits | 2 bits (`RAY_W_INT`) | 10 bits (`POS_W_FRAC`) | `rotation.sv`, `column_calc.sv` | Vectors defining ray directions and the camera plane. Values are tightly bounded (typically between -1.0 and 1.0, sometimes up to ~1.3 for FOV), requiring very few integer bits. |
| **`side_fixp_t`** | 12 bits | 2 bits | 10 bits (`POS_W_FRAC`) | `column_calc.sv` | Distance from the camera to the very first map grid intersection. Bounded because it never exceeds 1 cell unit. |
| **`inv_fixp_t`** | 22 bits | 8 bits (`INV_W_INT`) | 14 bits (`INV_W_FRAC`) | `newton_inv.sv`, `column_calc.sv` | Reciprocal outputs. Because dividing small fractions produces large numbers (and vice versa), the integer bounds and fractional precision are expanded. Truncated when cast back to `ext_pos_fixp_t`. |
| **`inv_dist_fixp_t`** | 16 bits | 2 bits | 14 bits (`INV_W_FRAC`) | `column_calc.sv` | The inverted distance to the wall. Used to calculate the visual height of the wall on screen. Bounded because the minimum distance is clamped to prevent divide-by-zero or giant heights. |
| **`proj_fixp_t`** | 24 bits | 10 bits (`POS_W_INT`) | 14 bits (`INV_W_FRAC`) | `column_calc.sv` | Projection math. Needs the large integer component from `pos_fixp_t` and the high fractional precision from the `inv_dist_fixp_t` multipliers. |
| **`tex_step_fixp_t`** | 23 bits | 9 bits (`TEX_STEP_W_INT`) | 14 bits (`TEX_STEP_W_FRAC`) | `column_calc.sv`, `render.sv` | Represents the step size in texture space per screen pixel. 9 bits integer easily covers stepping through a 32-pixel texture even if heavily zoomed out, while 14 fraction bits ensure smooth mapping on large walls. |
| **`tex_zoom_fixp_t`** | 21 bits | 6 bits (`TEX_ZOOM_W_INT`) | 15 bits (`TEX_ZOOM_W_FRAC`) | `render.sv` | Tracks the Y-offset of the texture when the wall is taller than the screen, requiring a clipping/zoom effect. |
| **`align_fixp_t`** | 31 bits | 17 bits | 14 bits | `render.sv` | The widest type, used in Stage 2 of the renderer to safely multiply the screen vertical alignment with the texture step size without overflowing. |
