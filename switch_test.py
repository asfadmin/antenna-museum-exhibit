from machine import Pin
import time

sw_1 = machine.Pin(21, machine.Pin.IN, machine.Pin.PULL_UP)
sw_2 = machine.Pin(20, machine.Pin.IN, machine.Pin.PULL_UP)
sw_3 = machine.Pin(19, machine.Pin.IN, machine.Pin.PULL_UP)
sw_4 = machine.Pin(18, machine.Pin.IN, machine.Pin.PULL_UP)

sw_1_count = 0
sw_2_count = 0
sw_3_count = 0
sw_4_count = 0

time_old = time.ticks_ms()


def sw_1_interrupt(sw_1):
    global time_old, sw_1_count
    time_new = time.ticks_ms()
    if (time_new - time_old) > 200:
        print("Switch 1 Hit!")
        sw_1_count += 1
        print(sw_1_count)
        time_old = time_new


def sw_2_interrupt(sw_2):
    global time_old, sw_2_count
    time_new = time.ticks_ms()
    if (time_new - time_old) > 200:
        print("Switch 2 Hit!")
        sw_2_count += 1
        print(sw_2_count)
        time_old = time_new


def sw_3_interrupt(sw_3):
    global time_old, sw_3_count
    time_new = time.ticks_ms()
    if (time_new - time_old) > 200:
        print("Switch 3 Hit!")
        sw_3_count += 1
        print(sw_3_count)
        time_old = time_new


def sw_4_interrupt(sw_4):
    global time_old, sw_4_count
    time_new = time.ticks_ms()
    if (time_new - time_old) > 200:
        print("Switch 4 Hit!")
        sw_4_count += 1
        print(sw_4_count)
        time_old = time_new


sw_1.irq(trigger=Pin.IRQ_FALLING, handler=sw_1_interrupt)
sw_2.irq(trigger=Pin.IRQ_FALLING, handler=sw_2_interrupt)
sw_3.irq(trigger=Pin.IRQ_FALLING, handler=sw_3_interrupt)
sw_4.irq(trigger=Pin.IRQ_FALLING, handler=sw_4_interrupt)
