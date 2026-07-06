import os
N=chr(10)
D=os.path.dirname(__file__)
def w(n,t): open(os.path.join(D,n),chr(97),encoding=chr(117)+chr(116)+chr(102)+chr(45)+chr(56)).write(t); print(n); print(len(t))
w('01_architecture_overview.md',N.join(['### column_calc (rtl/column_calc.sv)','','FSM-driven column ray calculator. For column X: ray_x=(px_x*2/640)-1 (line 250), ray_dir=dir+plane*ray_x (lines 256-257), delta_dist=1/abs(ray_dir) via newton_inv (lines 271-298), side distances (lines 305-330), DDA wall hit (line 352), wall distance (lines 376-381), invert wall_dist (lines 400-403), line height, tex_step, tex_x with mirror correction. Two concurrent FSMs: main_state_t (11 states) and tex_state_t (5 states). Contains dda and newton_inv submodules.']))
w('01_architecture_overview.md',N.join(['### controls (rtl/controls.sv)','Top-level control module triggered by frame_done. Instantiates position (movement + collision) and rotation (2D rotation matrix with elaboration-time sin/cos, plane recomputed as perpendicular(dir) * 0.66). Rotation starts after position finishes via pos_done signal (line 78).']))
