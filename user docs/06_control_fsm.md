# Control State Machines

## `column_calc.sv` - Main FSM (`main_state`)
```mermaid
stateDiagram-v2
    ST_IDLE --> ST_CALC_RAY_X : start_i
    ST_CALC_RAY_X --> ST_CALC_RAY_DIR
    ST_CALC_RAY_DIR --> ST_CALC_DELTA_DIST_X : [Hardware: newton_inv (ray_dir_x)]
    ST_CALC_DELTA_DIST_X --> ST_CALC_DELTA_DIST_Y : inv_done
    ST_CALC_DELTA_DIST_Y --> ST_CALC_PERP_DIST : inv_done
    ST_CALC_PERP_DIST --> ST_CALC_SIDE_DIST
    ST_CALC_SIDE_DIST --> ST_RUN_DDA
    ST_RUN_DDA --> ST_CALC_WALL_DIST : dda_done [Hardware: dda]
    ST_CALC_WALL_DIST --> ST_INV_WALL_DIST : [Hardware: newton_inv (wall_dist)]
    ST_INV_WALL_DIST --> ST_CALC_LINE_HEIGHT : inv_done
    ST_CALC_LINE_HEIGHT --> ST_IDLE
```

## `column_calc.sv` - Texture FSM (`tex_state`)
```mermaid
stateDiagram-v2
    ST_TEX_IDLE --> ST_TEX_STEP : (main_state == ST_CALC_WALL_DIST)
    ST_TEX_STEP --> ST_TEX_DIST
    ST_TEX_DIST --> ST_TEX_X
    ST_TEX_X --> ST_TEX_MIRROR
    ST_TEX_MIRROR --> ST_TEX_IDLE
```

## `dda.sv` - DDA FSM (`state`)
```mermaid
stateDiagram-v2
    ST_IDLE --> ST_CALC_DDA : start_i
    ST_CALC_DDA --> ST_IDLE : valid_hit (wall_hit_i && !wait_rom_read)
    ST_CALC_DDA --> ST_CALC_DDA : !valid_hit [Wait for ROM delay and check map_x/y step]
```

## `newton_inv.sv` - Newton's Method FSM (`state`)
```mermaid
stateDiagram-v2
    ST_IDLE --> ST_CALC_SHIFT : start_i
    ST_CALC_SHIFT --> ST_SHIFT_INPUT
    ST_SHIFT_INPUT --> ST_ITERATE
    ST_ITERATE --> ST_SHIFT_OUTPUT : cnt_done (iter_cnt == N_ITER_CYCLES - 1)
    ST_SHIFT_OUTPUT --> ST_RES_OUT
    ST_RES_OUT --> ST_CALC_SHIFT : start_i
    ST_RES_OUT --> ST_IDLE : !start_i
```

## `position.sv` - Calculate State (`calc_state`)
```mermaid
stateDiagram-v2
    ST_IDLE --> ST_CALC_DIR : update_start_i
    ST_CALC_DIR --> ST_SCALE_DIR
    ST_SCALE_DIR --> ST_CALC_POS
    ST_CALC_POS --> ST_WAIT_LOOKUP
    ST_WAIT_LOOKUP --> ST_UPDATE_POS
    ST_UPDATE_POS --> ST_IDLE : update_done
    ST_UPDATE_POS --> ST_CALC_DIR : !update_done
```

## `position.sv` - Control & Axis State (`cntrl_state` & `axis_state`)
*Note: These act as nested iterators controlling `calc_state`. First it tests X axis forward, backward, left, right; then Y axis forward, backward, left, right.*
```mermaid
stateDiagram-v2
    state Axis_X {
        ST_FORWARD --> ST_BACKWARD : calc_done
        ST_BACKWARD --> ST_LEFT : calc_done
        ST_LEFT --> ST_RIGHT : calc_done
        ST_RIGHT --> ST_FORWARD : calc_done
    }
    state Axis_Y {
        ST_FORWARD_Y --> ST_BACKWARD_Y : calc_done
        ST_BACKWARD_Y --> ST_LEFT_Y : calc_done
        ST_LEFT_Y --> ST_RIGHT_Y : calc_done
        ST_RIGHT_Y --> ST_FORWARD_Y : calc_done
    }
    Axis_X --> Axis_Y : axis_done (Axis X completed)
    Axis_Y --> Axis_X : axis_done (Axis Y completed)
```

## `rotation.sv` - Calculate State (`calc_state`)
```mermaid
stateDiagram-v2
    ST_CALC_IDLE --> ST_X_MULT_COS : update_start_i
    ST_X_MULT_COS --> ST_X_MULT_SIN
    ST_X_MULT_SIN --> ST_X_SUB
    ST_X_SUB --> ST_Y_MULT_SIN
    ST_Y_MULT_SIN --> ST_Y_MULT_COS
    ST_Y_MULT_COS --> ST_Y_ADD
    ST_Y_ADD --> ST_X_MULT_COEFF
    ST_X_MULT_COEFF --> ST_Y_MULT_COEFF
    ST_Y_MULT_COEFF --> ST_CALC_IDLE
```
