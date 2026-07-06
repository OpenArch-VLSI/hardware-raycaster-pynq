# 03 - Clock Domains

## Clock summary

| Domain | Frequency | Source | Used by |
|-----|-----|-----|-----|
| serial_clk | 252 MHz | rPLL (FCLKIN=27, IDIV=2, FBDIV=27, ODIV=4) | serializer (3x) in dvi_top |
| px_clk | 25.2 MHz | serial_clk / 2 / 5 via CLKDIV2+CLKDIV | ALL other logic |
| clk (board) | 27 MHz | External oscillator | rPLL input only |

## Domain analysis

The design has two clock domains: serial_clk (252 MHz) and px_clk (25.2 MHz).
domain analysis continued

### Same-domain logic
All FSM-based control and datapath are entirely within the px_clk domain. No signals cross between render FSM and controls FSM within the raycaster core, but they share the map ROM via a mux controlled by lookup_render (raycast_top.sv lines 113-118). Since the mux, map ROM, and both modules run on px_clk, this is same-domain.
