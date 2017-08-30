import sys
import socket
import math 
import subprocess
import os 
from Overlay import Overlay
from STP_Thread import STP_Thread
from Com_Thread import Com_Thread
from Upload_Thread import Upload_Thread
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
        self.display        = QtGui.QWidget(self)
        self.layout         = QtGui.QGridLayout()
        self.state          = 0
        self.tcl            = False

        self.doppler_val    = 0
        self.time_val       = 0
        self.amp_val        = 0
        self.load_string    = '.'

        self.com_thread = Com_Thread(self)


        self.initUI()
    def initUI(self): 
    	
    	self.layout.setSpacing(20)
              
        # Start Doppler Stuff
        self.doppler    = QtGui.QCheckBox("Doppler Shift")
        self.doppler.setChecked(False)

        self.doppler_sl = QtGui.QSlider(QtCore.Qt.Horizontal)
        self.doppler_sl.setMinimum(1)
        self.doppler_sl.setMaximum(99.999999e6)
        self.doppler_sl.setValue(5)
        self.doppler_sl.setTickPosition(QtGui.QSlider.TicksBelow)
        self.doppler_sl.setTickInterval(2**10)
        self.doppler_sl.setSingleStep(2**10)

        self.doppler_lbl = QtGui.QLabel(str(float(self.doppler_sl.value())/1e3 ) +' kHz')

        self.layout.addWidget(self.doppler,0,0)
        self.layout.addWidget(self.doppler_sl,0,1)
        self.layout.addWidget(self.doppler_lbl,0,2)

        self.doppler.toggled.connect(self.checked_connect)
        self.doppler_sl.valueChanged.connect(self.checked_connect)                        
        #

        # Start Time Stuff
        self.time    = QtGui.QCheckBox("Time Delay")

        self.time_sl = QtGui.QSlider(QtCore.Qt.Horizontal)
        self.time_sl.setMinimum(0)
        self.time_sl.setMaximum(1023)
        self.time_sl.setValue(0)
        self.time_sl.setTickPosition(QtGui.QSlider.TicksBelow)
        self.time_sl.setTickInterval(5)

        self.time_lbl = QtGui.QLabel(str(self.time_sl.value()) + ' Samples')

        self.layout.addWidget(self.time,1,0)
        self.layout.addWidget(self.time_sl,1,1)
        self.layout.addWidget(self.time_lbl,1,2)

        self.time.toggled.connect(self.checked_connect)
        self.time_sl.valueChanged.connect(self.checked_connect)    
        #     

        # Start Amplitude Stuff
        self.amp = QtGui.QCheckBox("Amplitude Scaling")

        self.amp_sl = QtGui.QSlider(QtCore.Qt.Horizontal)
        self.amp_sl.setMinimum(0)
        self.amp_sl.setMaximum(65535)
        self.amp_sl.setValue(65535)
        self.amp_sl.setTickPosition(QtGui.QSlider.TicksBelow)
        self.amp_sl.setTickInterval(2**10)
        self.amp_sl.setSingleStep(2**10)


        self.amp_lbl = QtGui.QLabel(str(round(float(self.amp_sl.value())/2**16,4)))

        self.layout.addWidget(self.amp,2,0)
        self.layout.addWidget(self.amp_sl,2,1)
        self.layout.addWidget(self.amp_lbl,2,2)

        self.amp.toggled.connect(self.checked_connect)
        self.amp_sl.valueChanged.connect(self.checked_connect)    
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

    def load_screen(self):
        self.overlay.show()
        if (self.load_string == '.'):
            self.load_string = self.load_string +'.'
        elif (self.load_string == '..'):
            self.load_string = self.load_string +'.'
        else:
            self.load_string = '.'
        self.statusBar().showMessage('Uploading Data to DE-10 Lite' + self.load_string)
        
    def load_done(self):
        self.statusBar().showMessage('')


    def Upload(self):
        # 
        msgBox = QtGui.QMessageBox()
        msgBox.setText('Ensure SW0 is set.')
        # msgBox.setInformativeText('Ensure you have connected the DE-10 lite correctly.')
        msgBox.setWindowTitle("Upload Reminder")
        msgBox.setDefaultButton(QtGui.QMessageBox.Ok)
        ret = msgBox.exec_()

        if ret == QtGui.QMessageBox.Ok:
            pass
        
        self.statusBar().showMessage('Uploading Data to DE-10 Lite')
        upload_thread = Upload_Thread()
        upload_thread.load_signal.connect(self.load_screen)
        upload_thread.done_signal.connect(self.load_done)
        upload_thread.start()



    def checked_connect(self):
        self.doppler_lbl.setText(str(float(self.doppler_sl.value())/1e3 ) +' kHz')
        self.time_lbl.setText(str( self.time_sl.value()) + ' Samples')
        self.amp_lbl.setText(str(round(float(self.amp_sl.value())/2**16,4)))
        state_string = ''
        change = False        
        if (self.doppler.isChecked()):
            
            if(self.time.isChecked()):
                    if (self.amp.isChecked()):
                        self.state = 7
                        self.doppler_val    =        self.doppler_sl.value()
                        self.time_val       =        self.time_sl.value()
                        self.amp_val        =        self.amp_sl.value()
                        state_string = 'Time Delay, Doppler Shift and Amplitude Scale'
                        change = True
                    else:
                        self.state = 5
                        self.doppler_val   =        self.doppler_sl.value()
                        self.time_val       =        self.time_sl.value()
                        state_string = 'Time Delay and Doppler Shift'
                        change = True
            elif (self.amp.isChecked()):
                self.state = 6
                self.doppler_val   =        self.doppler_sl.value()
                self.amp_val        =        self.amp_sl.value()
                state_string = 'Amplitude Scaling and Doppler Shift'
                change = True
            else:    
                self.state = 2
                self.doppler_val   =        self.doppler_sl.value()
                state_string = 'Doppler Shift'
                change = True
        if(self.time.isChecked()):
            if(self.doppler.isChecked()):
                    if (self.amp.isChecked()):
                        self.state = 7
                        self.doppler_val   =        self.doppler_sl.value()
                        self.time_val       =        self.time_sl.value()
                        self.amp_val        =        self.amp_sl.value()
                        state_string = 'Time Delay, Doppler Shift and Amplitude Scale'
                        change = True
                    else:
                        self.state = 5
                        self.doppler_val   =        self.doppler_sl.value()
                        self.time_val       =        self.time_sl.value()
                        state_string = 'Time Delay and Doppler Shift'
                        change = True
            elif (self.amp.isChecked()):
                self.state = 4
                self.time_val       =        self.time_sl.value()
                self.amp_val        =        self.amp_sl.value()
                state_string = 'Time Delay and Amplitude Scale'
                change = True
            else:    
                self.state = 1
                self.time_val       =        self.time_sl.value()
                state_string = 'Time Delay'
                change = True

        if(self.amp.isChecked()):  
            if(self.doppler.isChecked()):
                    if (self.time.isChecked()):
                        self.state = 7
                        self.doppler_val   =        self.doppler_sl.value()
                        self.time_val       =        self.time_sl.value()
                        self.amp_val        =        self.amp_sl.value()
                        state_string = 'Time Delay, Doppler Shift and Amplitude Scale'
                        change = True
                    else:
                        self.state = 6
                        self.doppler_val   =        self.doppler_sl.value()
                        self.amp_val        =        self.amp_sl.value()
                        state_string = 'Amplitude Scaling and Doppler Shift'
                        change = True
            elif (self.time.isChecked()):
                self.state = 4
                self.time_val       =        self.time_sl.value()
                self.amp_val        =        self.amp_sl.value()
                state_string = 'Time Delay and Amplitude Scale'
                change = True
            else:    
                self.state = 3
                self.amp_val        =        self.amp_sl.value()
                state_string = 'Amplitude Scale'
                change = True
        if ((self.amp.isChecked() == 0) and (self.time.isChecked() == 0) and (self.doppler.isChecked() ==0) ):
            self.state = 0
            state_string = ''
            # change = True
        if (change):
            self.com_thread.updateState(self.state,[0,self.time_val,int(self.doppler_val * (2**32/100e6)),self.amp_val])
            self.statusBar().showMessage('Performing '+ state_string)
            change = False



       
   


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