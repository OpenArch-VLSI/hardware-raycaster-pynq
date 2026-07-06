# 02 - Module Dependency Graph

## Mermaid instantiation graph

```mermaid
graph TD
    primer20k_top -- instantiates -- rPLL
    primer20k_top -- instantiates -- CLKDIV2
    primer20k_top -- instantiates -- CLKDIV
    primer20k_top -- instantiates -- raycast_top
    raycast_top -- instantiates -- render
    raycast_top -- instantiates -- controls
    raycast_top -- instantiates -- dvi_top
    render -- instantiates -- column_calc
    column_calc -- instantiates -- newton_inv
    column_calc -- instantiates -- dda
    controls -- instantiates -- position
    controls -- instantiates -- rotation
    dvi_top -- instantiates -- dvi_sync
    dvi_top -- instantiates -- tmds_encoder
    dvi_top -- instantiates -- serializer
    dvi_top -- instantiates -- ds_buf
    dvi_top -- instantiates -- delay
```
## Module table

| Module | File | Purpose | Key Inputs | Key Outputs | Submodules |
|---|---|---|---|---|---|
| primer20k_top | rtl/primer20k_top.sv | Board wrapper, clock gen, POR | clk(27MHz), rst_n, keys_inv_i[5:0] | tmds_* diff pairs | rPLL, CLKDIV2, CLKDIV, raycast_top |
| raycast_top | rtl/raycast_top.sv | Top integration, map mux, frame detect | serial_clk, px_clk, rst, keys, in_range | r,g,b, tmds_*, pos/dir/plane | render, controls, dvi_top |

| render | rtl/render.sv | Column calc + 6-stage pixel pipeline | clk, rst, px_x/y_i, in_range_i, texture_i | r/g/b_o, lookup_map_x/y_o | column_calc |
| column_calc | rtl/column_calc.sv | Ray math FSM per screen column | clk, rst, start_i, px_x_i, pos/dir/plane | done_o, tex/tex_shade/tex_x/tex_step/tex_height | newton_inv, dda |
| controls | rtl/controls.sv | Position + rotation dispatch | clk, rst, keys, update_start_i, wall_hit_i | pos_x/y, dir_x/y, plane_x/y | position, rotation |
| position | rtl/position.sv | Movement FSM with collision detect | clk, rst, keys, dir_x/y_i, wall_hit_i | pos_x/y_o, lookup_map_x/y_o | none |
| rotation | rtl/rotation.sv | Camera rotation FSM | clk, rst, keys, update_start_i | dir_x/y_o, plane_x/y_o | none |
| dvi_top | rtl/dvi/dvi_top.sv | DVI output pipeline | serial_clk, pixel_clk, rst, r/g/b_i | x/y_o, tmds_* diff pairs | dvi_sync, tmds_encoder(3x), serializer(3x), ds_buf(4x), delay |
| dvi_sync | rtl/dvi/dvi_sync.sv | VESA 640x480 timing gen | clk_i, rst_i | hsync/vsync_o, pixel_x/y_o, visible_range | none |
| newton_inv | rtl/newton_inv.sv | Newton-Raphson reciprocal | clk, rst, start_i, num_i | done_o, num_o | none |
| dda | rtl/dda.sv | DDA wall-hit search | clk, rst, start_i, init_map, step, side_dist, delta_dist | map_x/y_o, side_dist_x/y_o, hit_side_o, done_o | none |
| tmds_encoder | rtl/dvi/tmds_encoder.sv | TMDS 8b/10b encoder | clk_i, rst_i, C0/1, DE, D[7:0] | q_out[9:0] | none |
| serializer | rtl/dvi/serializer.sv | 10:1 PISO at serial_clk | clk, rst, data_i | data_o | none |
| delay | rtl/dvi/delay.sv | Configurable delay line | clk, rst, data_i | data_o | none |
| ds_buf | rtl/dvi/ds_buf.sv | Differential output buffer | in | out, out_n | TLVDS_OBUF (Gowin) |
