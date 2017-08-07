import sys
import socket
import math 
import subprocess
import os 
from Overlay import Overlay
from STP_Thread import STP_Thread
from Com_Thread import Com_Thread
from PyQt4 import QtGui, QtCore
import thread
import time

#GLOBALS

# host = 'localhost' 
# port = 2540


class Window(QtGui.QMainWindow):
    
    def __init__(self):
        super(Window, self).__init__()

        #Atrributes
        self.display     = QtGui.QWidget(self)
        self.layout      = QtGui.QGridLayout()
        self.state       = 0
        self.tcl         = False

        self.doppler_val = 0
        self.time_val    = 0
        self.amp_val     = 0

        self.com_thread = Com_Thread(self)


        self.initUI()
    def initUI(self): 
    	
    	self.layout.setSpacing(20)
              
        # Start Doppler Stuff
        self.doppler    = QtGui.QRadioButton("Doppler Shift")
        self.doppler.setChecked(False)

        self.doppler_sl = QtGui.QSlider(QtCore.Qt.Horizontal)
        self.doppler_sl.setMinimum(-255)
        self.doppler_sl.setMaximum(255)
        self.doppler_sl.setValue(0)
        self.doppler_sl.setTickPosition(QtGui.QSlider.TicksBelow)
        self.doppler_sl.setTickInterval(5)

        self.doppler_lbl = QtGui.QLabel(str(self.doppler_sl.value()) )

        self.layout.addWidget(self.doppler,0,0)
        self.layout.addWidget(self.doppler_sl,0,1)
        self.layout.addWidget(self.doppler_lbl,0,2)

        self.doppler.toggled.connect(self.DopplerShift)
        self.doppler_sl.valueChanged.connect(self.DopplerShift)                        
        #

        # Start Time Stuff
        self.time    = QtGui.QRadioButton("Time Delay")

        self.time_sl = QtGui.QSlider(QtCore.Qt.Horizontal)
        self.time_sl.setMinimum(0)
        self.time_sl.setMaximum(511)
        self.time_sl.setValue(0)
        self.time_sl.setTickPosition(QtGui.QSlider.TicksBelow)
        self.time_sl.setTickInterval(5)

        self.time_lbl = QtGui.QLabel(str(self.time_sl.value()) )

        self.layout.addWidget(self.time,1,0)
        self.layout.addWidget(self.time_sl,1,1)
        self.layout.addWidget(self.time_lbl,1,2)

        self.time.toggled.connect(self.TimeDelay)
        self.time_sl.valueChanged.connect(self.TimeDelay)    
        #     

        # Start Amplitude Stuff
        self.amp = QtGui.QRadioButton("Amplitude Scaling")

        self.amp_sl = QtGui.QSlider(QtCore.Qt.Horizontal)
        self.amp_sl.setMinimum(0)
        self.amp_sl.setMaximum(511)
        self.amp_sl.setValue(0)
        self.amp_sl.setTickPosition(QtGui.QSlider.TicksBelow)
        self.amp_sl.setTickInterval(5)

        self.amp_lbl = QtGui.QLabel(str(self.amp_sl.value()) )

        self.layout.addWidget(self.amp,2,0)
        self.layout.addWidget(self.amp_sl,2,1)
        self.layout.addWidget(self.amp_lbl,2,2)

        self.amp.toggled.connect(self.AmpScale)
        self.amp_sl.valueChanged.connect(self.AmpScale)    
        #
              
        #Menu Stuff.
        menubar = self.menuBar()
        fileMenu = menubar.addMenu('&File')

        import_Action = fileMenu.addAction('Connect to FPGA')
        import_Action.triggered.connect(self.Connect)
        import_Action.setShortcut('F2')
        import_Action.setToolTip('Connect to DE-10 Lite')

        import_Action = fileMenu.addAction('Upload Data')
        import_Action.triggered.connect(self.Upload)
        import_Action.setShortcut('F3')
        import_Action.setToolTip('Upload Data to DE-10 Lite')

        self.setGeometry(50, 50, 500,500)

        self.statusBar()
        self.display.setLayout(self.layout)
        self.setCentralWidget(self.display)
        self.overlay = Overlay(self.display,self.tcl)
        self.overlay.hide()



        # self.center
        self.setWindowTitle('DRFM Interface')
        self.show()

    def center(self):
        frameGm = self.frameGeometry()
        screen = QtGui.QApplication.desktop().screenNumber(QtGui.QApplication.desktop().cursor().pos())
        centerPoint = QtGui.QApplication.desktop().screenGeometry(screen).center()
        frameGm.moveCenter(centerPoint)
        self.move(frameGm.topLeft())


    #@TODO Timer that send states etc. 
    def resizeEvent(self, event):
        self.overlay.resize(event.size())
        event.accept()


    def Connect(self):
        self.overlay.show()

        print('spawning stp thread')
        self.STP_thread = STP_Thread()
        self.STP_thread.done_signal.connect(self.start_com)
        self.STP_thread.error_signal.connect(self.con_error)
        self.STP_thread.start()
      

        self.statusBar().showMessage('Connecting to DE-10 Lite')
      

    def con_error(self):
        msgBox = QtGui.QMessageBox()
        msgBox.setText('Connection Refused')
        # msgBox.setInformativeText('Ensure you have connected the DE-10 lite correctly.')
        msgBox.setWindowTitle("Connection Error")
        msgBox.setDefaultButton(QtGui.QMessageBox.Ok)
        ret = msgBox.exec_()

        if ret == QtGui.QMessageBox.Ok:
            pass

    def start_com(self):
        print('spawning communication object')
        vals = [0,self.time_val,self.doppler_val,self.amp_val]
        self.com_thread.Setup('localhost',2540,self.state,vals)
        self.statusBar().showMessage('Connected to DE-10 Lite')


    def Upload(self):
        self.statusBar().showMessage('Feature has been disabled.')
       
    def DopplerShift(self):
        self.doppler_val = self.doppler_sl.value()
        self.doppler_lbl.setText(str(self.doppler_val))
        if (self.doppler.isChecked()):
            try:
                self.statusBar().showMessage('Performing Doppler Shift by '+ str(self.doppler_sl.value()))
                print('Shift')
                self.state = 2
                print("Updating to state %5d" % self.state)
                self.com_thread.updateState(self.state,[0,self.time_val,self.doppler_val,self.amp_val])
               
            except:
                pass
        else:
            self.statusBar().showMessage("")

    def TimeDelay(self):
        self.time_val    = self.time_sl.value()
        self.time_lbl.setText(str(self.time_val))
        if(self.time.isChecked()):
            try:
                self.statusBar().showMessage('Performing Time Delay by '+str(self.time_sl.value()))
                print('Delay')
                self.state = 1
                print("Updating to state %5d" % self.state)
                self.com_thread.updateState(self.state,[0,self.time_val,self.doppler_val,self.amp_val])
            except:
                pass
            
        else:
            self.statusBar().showMessage("")

    def AmpScale(self):
        self.amp_val     = self.amp_sl.value()
        self.amp_lbl.setText(str(self.amp_val))
        if(self.amp.isChecked()):
            try:
                self.statusBar().showMessage('Performing Amplitude Scaling by ' +str(self.amp_sl.value()))
                print('Scale')
                self.state = 3
                print("Updating to state %5d" % self.state)
                self.com_thread.updateState(self.state,[0,self.time_val,self.doppler_val,self.amp_val])
               
            except:
                pass
        else:
            self.statusBar().showMessage("")


    def closeEvent(self, event):
        try:
            self.STP_thread.disconnect()
            self.com_thread.disconnect()
        except Exception, e:
            print(str(e))
def main():
    
    app = QtGui.QApplication(sys.argv)
    ex = Window()
    sys.exit(app.exec_())


if __name__ == '__main__':
    main()