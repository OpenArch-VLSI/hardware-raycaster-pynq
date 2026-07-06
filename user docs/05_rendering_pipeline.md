# Rendering Pipeline

The rendering pipeline translates camera coordinates and map layout into the final RGB colors output to the display. It operates in two main phases: a per-column calculation phase that finds wall intersections, and a per-pixel evaluation phase that maps textures and draws the screen.

## Phase 1: Column Calculation (`column_calc.sv`)
Because raycasting calculates horizontal slices, the expensive mathematical operations only need to happen once per vertical column of pixels on the screen, rather than for every single pixel.

1. **Ray Projection**: Calculates the ray's initial angle based on the screen's X coordinate and the camera's FOV plane.
2. **Delta Distance Calculation**: Uses the `newton_inv` module to calculate the reciprocal of the ray direction vectors. This gives the ray distance between consecutive X and Y map grid lines.
3. **DDA Execution**: The `dda` module iteratively steps through the map grid (`map_x`, `map_y`) along the ray vector. After each step, it checks `texture_i` from the Map ROM to see if it hit a wall.
4. **Distance and Height**: Once a wall is hit, it calculates the perpendicular distance to the camera plane (to avoid fisheye distortion). This distance is inverted (again via `newton_inv`) and scaled by the frame height to determine the visual height of the wall slice on the screen.
5. **Texture Parameters**: Calculates the specific X-coordinate of the texture to display (`tex_x`), the vertical step size through the texture per screen pixel (`tex_step`), and notes which side of the wall was hit for shading (`tex_shade`).

These calculated properties are written into a double-buffered dual-port RAM (`frame_buffer` in `render.sv`), ensuring the pixel pipeline never stalls waiting for ray calculations.

## Phase 2: Per-Pixel Pipeline (`render.sv`)
The actual screen drawing happens in a fully pipelined, 6-stage architecture that processes one pixel per clock cycle (`pixel_clk`), tracking the current screen coordinates (`px_x_i`, `px_y_i`).

| Stage | Latency | Operation Details |
| :---: | :---: | :--- |
| **Stage 0** | 1 clock | **Buffer Fetch**: Reads the pre-calculated column properties (`tex_height`, `texture`, `tex_shade`, `tex_x`, `tex_step`) from the `frame_buffer` for the current horizontal pixel `px_x_i`. It caches `px_y_i`. |
| **Stage 1** | 1 clock | **Vertical Bounds**: Calculates `tex_start` and `tex_end` to determine if the current `px_y_i` falls within the background (ceiling/floor) or the textured wall. Calculates the fractional zoom offset for scaling the texture. |
| **Stage 2** | 1 clock | **Texture Mapping**: Calculates the precise integer Y-coordinate within the 32x32 texture (`tex_y_p2`) corresponding to the current screen pixel. It handles clipping if the calculated coordinate overflows the texture boundary. |
| **Stage 3** | 1 clock | **Texture ROM Fetch**: Calculates the absolute memory address and reads the 4-bit compressed pixel code from the `textures` ROM (`textures.mem`). |
| **Stage 4** | 1 clock | **Color Palette Fetch**: Uses the 4-bit pixel code and the texture ID to fetch the full 24-bit RGB color from the `recode_lut` ROM (`recode_lut.mem`). |
| **Stage 5** | 1 clock | **Shading & Output**: Selects between the solid background colors (`BG_TOP_COLOR`, `BG_BOTTOM_COLOR`) or the fetched wall color. If the wall hit was on the Y-axis (`tex_shade`), it halves the RGB values (bitwise right shift `>> 1`) to simulate lighting, then outputs the final `red_o`, `green_o`, `blue_o`. |

**Total Pipeline Latency**: 6 clock cycles from `px_x_i`/`px_y_i` input to valid RGB output.
