from pynput.keyboard import Key, Controller
import time


keyboard = Controller()

_soal = int(input("Masukkan Jumlah Soal: "))
_paket = int(input("Masukkan Jumlah Paket : "))
delay = int(input("Masukkan Delay Sebelum Pindah ke Browser (detik): "))
total_soal = 1
total_paket = 0

print("")
print(f"Program Started\nYou now have {delay} second(s) to back to Browser")
time.sleep(delay)

while total_paket < _paket:
    while total_soal <= _soal:
        time.sleep(0.3)
        keyboard.type(str(total_soal))
        time.sleep(0.3)
        keyboard.tap(Key.tab)
        total_soal += 1
    total_paket += 1
    total_soal = total_soal - _soal
    
print("Done!")