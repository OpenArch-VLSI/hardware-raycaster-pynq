# Phase 1 Documentation

## Workspace Git Status
```text
On branch main
Your branch is ahead of 'origin/main' by 2 commits.
  (use "git push" to publish your local commits)

nothing to commit, working tree clean
```
*(No output from `git diff --stat`)*

## Documentation Index

- [01 Architecture Overview](01_architecture_overview.md)
- [02 Module Dependency Graph](02_module_dependency_graph.md)
- [03 Clock Domains](03_clock_domains.md)
- [04 Memory Map](04_memory_map.md)
- [05 Rendering Pipeline](05_rendering_pipeline.md)
- [06 Control FSM](06_control_fsm.md)
- [07 Video Pipeline](07_video_pipeline.md)
- [08 Fixed Point Formats](08_fixed_point_formats.md)

## Open Questions

1. **Test Pattern Override**: The current top-level module `pynq_z2_top.sv` explicitly drives a test color bar pattern and completely bypasses the core `raycast_top` engine. Was this intentional for a temporary hardware test, or does the top-level need to be rewritten to instantiate `raycast_top` for actual raycaster usage?
2. **Button Synchronization**: The mechanical user inputs (`btn_i`, `sw_i`) are routed directly to the `controls` FSM without passing through any explicit synchronizers or debouncers on the `pixel_clk` domain. Could this lead to unpredictable input states or metastability during usage?
3. **Reset Synchronization**: The PLL lock signal (`pll_locked`) is used to generate the pixel clock domain reset, but it crosses into the domain without a 2-stage synchronizer. Should standard reset synchronizers be implemented for hardware stability?
4. **HPD Pull-up**: The `hdmi_out_hpd` is aggressively driven high (`1'b1`) by the FPGA rather than read as an input or driven through an open-drain/pull-up configuration. While it forces the monitor on, is this safe for all HDMI sinks connected to the PYNQ-Z2?
