# 04 - Memory Map

## Memory arrays


| map ROM | raycast_top.sv:55 | W_NUM_TEX=3 | MAP_SIZE=1024 | 10-bit addr | readmemh(memfiles/map.mem) | async read | 32x32 wall texture index grid |
| frame_buffer | render.sv:90 | W_BUF_DATA | BUF_DEPTH=1280 | 11-bit addr | runtime writes only | 1W+1R sync read-first | per-column tex/shade/x/step/height |
| textures ROM | render.sv:180 | W_PX_CODE=4 | 7168 | 13-bit addr | readmemh(memfiles/textures.mem) | sync read | color palette indices per texel |
| recode_lut ROM | render.sv:181 | W_PX=24 | 105 | 7-bit addr | readmemh(memfiles/recode_lut.mem) | sync read | 24-bit RGB palette entries |
