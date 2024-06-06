from stepper import Stepper

STR_TRAIN = int(200*32*72/150)
train = Stepper(2,3,steps_per_rev = STR_TRAIN)
train.speed(int(float(STR_TRAIN)*0.25))
train.free_run(-1)