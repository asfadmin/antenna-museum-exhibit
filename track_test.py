from machine import Pin
from stepper import Stepper
import time

# Create the train stepper motor object
STR_EL = 200 * 2 * 32
el = Stepper(6, 7, steps_per_rev=STR_EL)
el.speed(STR_EL * 0.05)
# el.overwrite_pos_deg(0)
el.free_run(1)
# el.target_deg(180)
# el.track_target()
