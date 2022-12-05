from gpiozero import LED
from time import sleep

# Blink red LED for 60 sec
red = LED(13)
red.blink(2, 1)
sleep(60)
