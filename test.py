import time

from machine import Pin
from stepper import Stepper

# Create the train stepper motor object
STR_TRAIN = 26.85 * 200 * 2 * 100 / 48  # rough calculated steps per revolution of the train axis
train = Stepper(2, 3, steps_per_rev=STR_TRAIN)
train.speed(STR_TRAIN * 0.05)

# Create the azimuth stepper motor object
STR_AZ = 200 * 32 * 100 / 48  # rough calculated steps per revolution of the train axis
az = Stepper(4, 5, steps_per_rev=STR_AZ)
az.speed(STR_AZ * 0.05)

# TODO(mperry37): Pulled from spec in mattermost need to verify once they are installed
# Create the elevation stepper motor object
# STR_ELE = 200 * 32 * 100 / 48  # rough calculated steps per revolution of the train axis
# ele = Stepper(6, 7, steps_per_rev=STR_ELE)
# ele.speed(STR_ELE * 0.05)

# Set the train axis switches as inputs with pullup resistors
sw_1 = machine.Pin(21, machine.Pin.IN, machine.Pin.PULL_UP)
sw_2 = machine.Pin(20, machine.Pin.IN, machine.Pin.PULL_UP)

# Set the azimuth axis switches as inputs with pullup resistors
sw_3 = machine.Pin(19, machine.Pin.IN, machine.Pin.PULL_UP)
sw_4 = machine.Pin(18, machine.Pin.IN, machine.Pin.PULL_UP)

# TODO(mperry37): Pulled from spec in mattermost need to verify once they are installed
# Set the elevation axis switches as inputs with pullup resistors
# sw_5 = machine.Pin(16, machine.Pin.IN, machine.Pin.PULL_UP)
# sw_6 = machine.Pin(17, machine.Pin.IN, machine.Pin.PULL_UP)


# Zero Train
def home_train():
    train.free_run(-1)
    print("moving train")

    while sw_1.value():
        pass
    print("zeroing train")
    train.stop()
    train.overwrite_pos_deg(0)
    train.target_deg(0)
    train.track_target()


# Zero AZ
def home_az():
    az.free_run(-1)
    print("moving az")

    while sw_3.value():
        pass
    print("zeroing az")
    az.stop()
    az.overwrite_pos_deg(0)
    az.target_deg(0)
    az.track_target()


# Zero Elevation
def home_elevation():
    ele.free_run(-1)
    print("moving ev")

    while sw_5.value():
        pass
    print("zeroing ez")
    ele.stop()
    ele.overwrite_pos_deg(0)
    ele.target_deg(0)
    ele.track_target()


# TODO(mperry37): ele_deg set to None for the time being
def track_sat(train_deg: int, az_deg: int, ele_deg: int = None):
    train.target_deg(train_deg)
    az.target_deg(az_deg)
    az_bool = False
    train_bool = False
    # TODO(mperry37): Need to set this to False once Elevation is online
    ele_bool = True
    while True:
        if train.get_pos_deg() < train_deg + 1 and train.get_pos_deg() >= train_deg - 1:
            train.stop()
            print(train.get_pos_deg())
            train_bool = True
        if az.get_pos_deg() < az_deg + 1 and az.get_pos_deg() >= az_deg - 1:
            az.stop()
            print(az.get_pos_deg())
            az_bool = True
        if (train_bool and az_bool and ele_bool) == True:
            break

home_train()
home_az()
# TODO(mperry37): elevation steppers and limit switches are not yet installed
# home_ele()

# Need to wait for direction from the rpi
time.sleep(2)
# need a serial read here
# Decode serial bus
# call track based on what users request
track_sat(45, 90)
# TODO(mperry37): logic is maybe bad on the while loop, the system not doing next loop
track_sat(10, 30)
print("Done")
