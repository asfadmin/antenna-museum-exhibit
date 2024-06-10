from machine import Pin
from stepper import Stepper
import time

# Create the train stepper motor object
STR_TRAIN = (
    26.85 * 200 * 2 * 100 / 48
)  # rough calculated steps per revolution of the train axis
train = Stepper(2, 3, steps_per_rev=STR_TRAIN)
train.speed(STR_TRAIN * 0.05)

# Create the azimuth stepper motor object
STR_AZ = 200 * 32 * 100 / 48  # rough calculated steps per revolution of the train axis
az = Stepper(4, 5, steps_per_rev=STR_AZ)
az.speed(STR_AZ * 0.05)

# Set the train axis switches as inputs with pullup resistors
sw_1 = machine.Pin(21, machine.Pin.IN, machine.Pin.PULL_UP)
sw_2 = machine.Pin(20, machine.Pin.IN, machine.Pin.PULL_UP)

# Set the azimuth axis switches as inputs with pullup resistors
sw_3 = machine.Pin(19, machine.Pin.IN, machine.Pin.PULL_UP)
sw_4 = machine.Pin(18, machine.Pin.IN, machine.Pin.PULL_UP)

# Start an optional counter to track button hits
sw_1_count = 0
sw_2_count = 0
sw_3_count = 0
sw_4_count = 0

# Timer for simple debouncing
time_old = time.ticks_ms()


# Interrupts for the switches
def sw_1_interrupt(sw_1):
    global time_old, sw_1_count, train, az
    time_new = time.ticks_ms()
    if (time_new - time_old) > 200:
        train.stop()
        train.overwrite_pos_deg(0)
        print("Switch 1 Hit!")
        sw_1_count += 1
        print(sw_1_count)
        time_old = time_new
        train.free_run(1)  # Positive is clockwise, negative CCW


def sw_2_interrupt(sw_2):
    global time_old, sw_2_count, train, az
    time_new = time.ticks_ms()
    if (time_new - time_old) > 200:
        train.stop()
        print("Switch 2 Hit!")
        sw_2_count += 1
        print(sw_2_count)
        time_old = time_new
        print("Train steps measured: " + str(train.get_pos()))
        print("Train range of motion estimated: " + str(train.get_pos_deg()))
        train.target_deg(train.get_pos_deg() - 20)
        train.track_target()
        # train.free_run(-1)


def sw_3_interrupt(sw_3):
    global time_old, sw_3_count, train, az
    time_new = time.ticks_ms()
    if (time_new - time_old) > 200:
        az.stop()
        print("Switch 3 Hit!")
        sw_3_count += 1
        print(sw_3_count)
        time_old = time_new
        az.free_run(1)  # Positive is clockwise, negative CCW
        az.overwrite_pos_deg(0)


def sw_4_interrupt(sw_4):
    global time_old, sw_4_count, train, az
    time_new = time.ticks_ms()
    if (time_new - time_old) > 200:
        az.stop()
        print("Switch 4 Hit!")
        sw_4_count += 1
        print(sw_4_count)
        time_old = time_new
        print("Az steps measured: " + str(az.get_pos()))
        print("Az range of motion estimated: " + str(az.get_pos_deg()))
        az.target_deg(az.get_pos_deg() - 20)
        az.track_target()
        # az.free_run(-1)


# Activate the switch interrupt handlers
sw_1.irq(trigger=Pin.IRQ_FALLING, handler=sw_1_interrupt)
sw_2.irq(trigger=Pin.IRQ_FALLING, handler=sw_2_interrupt)
sw_3.irq(trigger=Pin.IRQ_FALLING, handler=sw_3_interrupt)
sw_4.irq(trigger=Pin.IRQ_FALLING, handler=sw_4_interrupt)

train.free_run(-1)
az.free_run(-1)
