import sys
from pyqtgraph.Qt import QtGui, QtCore
import glob
import time
import subprocess
import os
import signal
from sys import platform

try:
    import win32api #pypiwin32
except ImportError:
    pass



class STP_Thread(QtCore.QThread):
    done_signal = QtCore.pyqtSignal(str)
    error_signal = QtCore.pyqtSignal(str)
    def __init__(self,parent=None):
        super(STP_Thread, self).__init__(parent)
        if platform == 'linux' or platform == 'linux2':
            print('Hello linux')
            self.process = subprocess.Popen(['/opt/intelFPGA_lite/16.1/quartus/bin/quartus_stp -t TCL_Server_vJTAG_SimpleTest.tcl'], shell=True, stdout=subprocess.PIPE)
        elif platform == "darwin":
            pass
        elif platform == "win32":
            print("Hello Windows :'(" )
            self.process = subprocess.Popen(["OpenCom.bat"])# creationflags=subprocess.CREATE_NEW_CONSOLE 
    


    def run(self):
        print('Running')
        time.sleep(2)
        self.done_signal.emit('Connected')
        print('Connected')

                    # self.updateSignal.emit(count)


    def disconnect(self):
        if platform == 'linux' or platform == 'linux2':
            os.killpg(os.getpgid(self.process.pid), signal.SIGTERM)
        elif platform == "win32":
           os.system('taskkill /F /IM quartus_stp.exe')


        self.terminate()
        print('Thread Killed')



