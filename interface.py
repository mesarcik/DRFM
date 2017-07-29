import sys
from PyQt4 import QtGui, QtCore


class Window(QtGui.QMainWindow):
    
    def __init__(self):
        super(Window, self).__init__()
        
        self.initUI()
        
    def initUI(self): 
    	display = QtGui.QWidget()
    	layout = QtGui.QGridLayout()
    	layout.setSpacing(100)
              

        button1 = QtGui.QPushButton("Button 1")
        layout.addWidget(button1,1,0)

        button2 = QtGui.QPushButton("Button 2")
        layout.addWidget(button2,1,1)
      
        button1.clicked.connect(self.buttonClicked)            
        button2.clicked.connect(self.buttonClicked)
        
        self.statusBar()
        display.setLayout(layout)
        self.setCentralWidget(display)

        self.setGeometry(300, 300, 290, 150)
        self.setWindowTitle('Event sender')
        self.show()

        
    def buttonClicked(self):
      
        sender = self.sender()
        self.statusBar().showMessage(sender.text() + ' was pressed')
        
def main():
    
    app = QtGui.QApplication(sys.argv)
    ex = Window()
    sys.exit(app.exec_())


if __name__ == '__main__':
    main()