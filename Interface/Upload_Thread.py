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



class Upload_Thread(QtCore.QThread):
    load_signal = QtCore.pyqtSignal(str)
    done_signal = QtCore.pyqtSignal(str)
    def __init__(self,parent=None):
        super(Upload_Thread, self).__init__(parent)
        self.process = None
        


    def run(self):
        if platform == 'linux' or platform == 'linux2':
            print('Hello linux')
            self.process = subprocess.Popen(['/opt/intelFPGA_lite/16.1/quartus/bin/quartus_stp -t WriteData.tcl'], shell=True, stdout=subprocess.PIPE)
        elif platform == "darwin":
            pass
        elif platform == "win32":
            print("Hello Windows :'(" )
            self.process = subprocess.Popen(["WriteData.bat"],creationflags=subprocess.CREATE_NEW_CONSOLE)# creationflags=subprocess.CREATE_NEW_CONSOLE 
        while (self.process.poll() == None):
            time.sleep(1)
            self.load_signal.emit('Load')

        self.done_signal.emit('Done')
        self.disconnect


    def disconnect(self):
        if platform == 'linux' or platform == 'linux2':
            os.killpg(os.getpgid(self.process.pid), signal.SIGTERM)
        elif platform == "win32":
           os.system('taskkill /F /IM quartus_stp.exe')


        self.terminate()
        print('Thread Killed')



