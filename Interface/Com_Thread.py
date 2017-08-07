import sys
import socket
from pyqtgraph.Qt import QtGui, QtCore
import glob
import time
import subprocess
import os
import signal



fsm = ['0000000000000000000000000000000000000000000000000','0000000000000000000000000000000000000001000000000','0000000000000000000000000000010000000000000000000','0000000000000000000100000000000000000000000000000','0100000000000000000000000000000000000000000000000']


class Com_Thread(QtCore.QThread):
    sent_signal = QtCore.pyqtSignal(str)
    def __init__(self,parent):
        super(Com_Thread, self).__init__(parent)
        self.host               = None
        self.port               = None
        self.state_no           = None
        self.vals               = None
        self.conn               = None
        self.status             = False



       
#0000000000000000000000000000000000000001000000000 delay
#0000000000000000000000000000010000000000000000000 doppler
#0000000000000000000100000000000000000000000000000 scale
#0100000000000000000000000000000000000000000000000 load
    def Setup(self,host,port,state_no,vals):
        self.host               = host
        self.port               = port
        self.state_no           = state_no
        self.vals               = vals
        if(self.status == False):
            self.conn               = self.Open()
            self.status             = True
        self.conn.send(fsm[0] + "\n") 


    def Open(self):
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect(( self.host,self.port))
        return s


    def updateState(self,new_state,vals):
        self.state_no           = new_state
        self.vals               = vals
        if (self.state_no == 0):
            data = fsm[self.state_no]
        elif (self.state_no != 4):
            data = bin(int(fsm[self.state_no],2) | 2**(10*(self.state_no-1)) *self.vals[self.state_no]).split('0b')[1].zfill(49)
        else:
            data = bin(int(fsm[self.state_no],2) | 2**(31) *65535).split('0b')[1].zfill(49)

        print(data)
        self.conn.send(data + "\n") 




    def disconnect(self):
        
        print('Process Killed')     
        self.terminate()
        self.conn.close()
        print('Thread Killed')



