import subprocess
import sys
import errno
import os

chipinit_file = "load"

# Start mbd
# mdb -digilent -connect_only -cl -cmd="read load"
try:
    os.system("mdb -digilent -connect_only -cl -cmd=\"read load\"")
    #subprocess.Popen(['mdb', '-digilent', '-connect_only', '-cl', r'-cmd="read load"'])
except OSError as process_error:
    if(process_error.errno == errno.ENOENT):
        print(str(process_error))
        print(chipinit_file + ": " + process_error.strerror)
    else:
        print("Some error occured when trying to start mdb: " + process_error.strerror)


