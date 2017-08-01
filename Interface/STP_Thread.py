import sys
import serial
from pyqtgraph.Qt import QtGui, QtCore
import glob
import time
import subprocess
import os
import signal



class STP_Thread(QtCore.QThread):
    done_signal = QtCore.pyqtSignal(str)
    error_signal = QtCore.pyqtSignal(str)
    def __init__(self,parent=None):
        super(STP_Thread, self).__init__(parent)
        self.process = subprocess.Popen(['/opt/intelFPGA_lite/16.1/quartus/bin/quartus_stp -t TCL_Server_vJTAG_SimpleTest.tcl'], shell=True, stdout=subprocess.PIPE,preexec_fn=os.setsid)
       


    def run(self):
        print('Running')
        time.sleep(2)
        self.done_signal.emit('Connected')
        print('Connected')

                    # self.updateSignal.emit(count)


    def disconnect(self):
        os.killpg(os.getpgid(self.process.pid), signal.SIGTERM) 
        print('Process Killed')     
        self.terminate()
        print('Thread Killed')



