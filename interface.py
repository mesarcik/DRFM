import sys
import socket
from PyQt4 import QtGui, QtCore

#GLOBALS

host = 'localhost' 
port = 2540
size = 4294967296 

fsm = ['00000000000000000000000001000000','00000000000000000100000000000000','00000000010000000000000000000000','01000000000000000000000000000000']
#

class Window(QtGui.QMainWindow):
    
    def __init__(self):
        super(Window, self).__init__()

        #Atrributes
        self.display = QtGui.QWidget()
        self.layout = QtGui.QGridLayout()
        self.state =''
        self.conn = ''

        self.initUI()
        
    def initUI(self): 
    	
    	self.layout.setSpacing(20)
              
        # Start Doppler Stuff
        self.doppler    = QtGui.QRadioButton("Doppler Shift")

        self.doppler_sl = QtGui.QSlider(QtCore.Qt.Horizontal)
        self.doppler_sl.setMinimum(-64)
        self.doppler_sl.setMaximum(64)
        self.doppler_sl.setValue(0)
        self.doppler_sl.setTickPosition(QtGui.QSlider.TicksBelow)
        self.doppler_sl.setTickInterval(5)

        self.doppler_lbl = QtGui.QLabel(str(self.doppler_sl.value()) )

        self.layout.addWidget(self.doppler,0,0)
        self.layout.addWidget(self.doppler_sl,0,1)
        self.layout.addWidget(self.doppler_lbl,0,2)

        self.doppler.toggled.connect(self.DopplerShift)
        self.doppler_sl.valueChanged.connect(self.SliderChange)                        
        #

        # Start Time Stuff
        self.time    = QtGui.QRadioButton("Time Delay")

        self.time_sl = QtGui.QSlider(QtCore.Qt.Horizontal)
        self.time_sl.setMinimum(0)
        self.time_sl.setMaximum(128)
        self.time_sl.setValue(0)
        self.time_sl.setTickPosition(QtGui.QSlider.TicksBelow)
        self.time_sl.setTickInterval(5)

        self.time_lbl = QtGui.QLabel(str(self.time_sl.value()) )

        self.layout.addWidget(self.time,1,0)
        self.layout.addWidget(self.time_sl,1,1)
        self.layout.addWidget(self.time_lbl,1,2)

        self.time.toggled.connect(self.TimeDelay)
        self.time_sl.valueChanged.connect(self.SliderChange)    
        #     

        # Start Amplitude Stuff
        self.amp = QtGui.QRadioButton("Amplitude Scaling")

        self.amp_sl = QtGui.QSlider(QtCore.Qt.Horizontal)
        self.amp_sl.setMinimum(0)
        self.amp_sl.setMaximum(128)
        self.amp_sl.setValue(0)
        self.amp_sl.setTickPosition(QtGui.QSlider.TicksBelow)
        self.amp_sl.setTickInterval(5)

        self.amp_lbl = QtGui.QLabel(str(self.amp_sl.value()) )

        self.layout.addWidget(self.amp,2,0)
        self.layout.addWidget(self.amp_sl,2,1)
        self.layout.addWidget(self.amp_lbl,2,2)

        self.amp.toggled.connect(self.AmpScale)
        self.amp_sl.valueChanged.connect(self.SliderChange)    
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

       
        self.statusBar()
        self.display.setLayout(self.layout)
        self.setCentralWidget(self.display)

        self.setGeometry(300, 300, 290, 150)
        self.setWindowTitle('DRFM Interface')
        self.show()

    def SliderChange(self):
        self.doppler_lbl.setText(str(self.doppler_sl.value()))
        self.time_lbl.setText(str(self.time_sl.value()))
        self.amp_lbl.setText(str(self.amp_sl.value()))

    #@TODO Timer that send states etc. 

    def Connect(self):
        try:
            self.statusBar().showMessage('Connecting to DE-10 Lite')
            self.conn = self.Open(host, port)

        except Exception as e:
            print e
            msgBox = QtGui.QMessageBox()
            msgBox.setText('Connection Refused')
            # msgBox.setInformativeText('Ensure you have connected the DE-10 lite correctly.')
            msgBox.setWindowTitle("Connection Error")
            msgBox.setDefaultButton(QtGui.QMessageBox.Ok)
            ret = msgBox.exec_()

            if ret == QtGui.QMessageBox.Ok:
                pass

    def Upload(self):
         self.statusBar().showMessage('Uploading Data to DE-10 Lite')
         self.state = fsm[3]
         self.conn.send(self.state + '\n') 

    def Open(self,host, port):
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect(( host,port))
        return s

        
    def buttonClicked(self,int):
      
        sender = self.sender()
        self.statusBar().showMessage(sender.text() + ' was pressed')

    def DopplerShift(self):
        if (self.doppler.isChecked()):
            self.statusBar().showMessage('Performing Doppler Shift by...')
            self.state = fsm[1]
        else:
            self.statusBar().showMessage("")

    def TimeDelay(self):
        if(self.time.isChecked()):
            self.statusBar().showMessage('Performing Time Delay by...')
            self.state = fsm[0]

        else:
            self.statusBar().showMessage("")

    def AmpScale(self):
        if(self.amp.isChecked()):
            self.statusBar().showMessage('Performing Amplitude Scaling by...')
            self.state = fsm[2]
        else:
            self.statusBar().showMessage("")

        
def main():
    
    app = QtGui.QApplication(sys.argv)
    ex = Window()
    sys.exit(app.exec_())


if __name__ == '__main__':
    main()