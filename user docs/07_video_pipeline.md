# Video Pipeline

The video pipeline takes standard RGB signals, generates the appropriate synchronization timings, encodes the data into HDMI-compatible TMDS symbols, and transmits them differentially to the physical pins.

## Stage 1: Synchronization (`dvi_sync.sv`)
- **Action**: A free-running set of horizontal and vertical counters generate standard VGA timings (HSYNC, VSYNC, Video Enable/Blanking) based on the 25 MHz `pixel_clk` (targeting 640x480 resolution). 
- **Outputs**: `hsync_o`, `vsync_o`, `pixel_x_o`, `pixel_y_o`, `video_en_o`.
- **Latency**: 0 (free-running relative to internal counters).

## Stage 2: Renderer Path (`render.sv`)
- **Action**: The `pixel_x_o` and `pixel_y_o` from the sync generator are passed back to the `render` engine to request the RGB pixel for the current screen location.
- **Latency**: 6 clock cycles (`render.sv` has a 6-stage pipeline).

## Stage 3: Delay Compensation (`delay.sv`)
- **Action**: Because the `render` engine takes 6 cycles to calculate the RGB color, the corresponding `hsync`, `vsync`, and `video_en` signals must also be delayed by exactly 6 cycles so they arrive at the encoder at the same time as the RGB data.
- **Implementation**: Three instances of `delay.sv` (with `DEL_CYCLES=6`) use a small ring-buffer memory to shift the 1-bit sync signals.
- **Latency**: 6 clock cycles.

## Stage 4: TMDS Encoding (`tmds_encoder.sv`)
- **Action**: The 8-bit R, G, and B color channels, along with the synchronized HSYNC/VSYNC/Enable signals, are fed into three parallel `tmds_encoder` instances.
- **Implementation**: The encoder performs 8b/10b encoding to minimize DC offset on the transmission line and reduce electromagnetic interference. It employs a DC-balancing state machine to flip bits if the running disparity drifts too high or low.
- **Bit Width Change**: 8-bit Color -> 10-bit TMDS symbol.
- **Latency**: 1 clock cycle (registered output).

## Stage 5: Serialization (`serializer.sv`)
- **Action**: Converts the 10-bit parallel TMDS symbol into a high-speed 1-bit serial stream.
- **Implementation**: Uses a Xilinx `OSERDESE2` primitive configured for a 10:1 gearing ratio. It captures the 10-bit parallel word on `pixel_clk` (25 MHz) and shifts it out as a 1-bit stream on the rising and falling edges of `serial_clk` (250 MHz DDR, effective 500 Mbps per lane).
- **Bit Width Change**: 10-bit Parallel -> 1-bit Serial.
- **Latency**: Negligible relative to the serial bit clock; internal cross-domain transfer latency.

## Stage 6: Differential Output (`ds_buf.sv`)
- **Action**: Converts the single-ended high-speed serial stream into a differential signal capable of traversing the physical HDMI cable.
- **Implementation**: Wraps the Xilinx `OBUFDS` (Output Buffer Differential Signaling) primitive.
- **Bit Width Change**: 1-bit Single-ended -> 1-pair Differential (+ / -).
- **Latency**: Combinational logic (propagation delay only).
