import socket

host = 'localhost' 
port = 2540
size = 4294967296 

fsm = ['00000000000000000000000001000000','00000000000000000100000000000000','00000000010000000000000000000000','01000000000000000000000000000000']

def Open(host, port):
	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	s.connect(( host,port))
	return s

def Write_LED(conn,b_val):
    size = 32
    # bStr_LEDValue = '01000000000000000000000000000000'#bin(intValue).split('0b')[1].zfill(size) #Convert from int to binary string
    conn.send(b_val + '\n') #Newline is required to flush the buffer on the Tcl server


conn = Open(host, port)
count = 0
index = 0
for val in range(0, 2**10):
	if count >10:
		Write_LED(conn, fsm[index])
		index = index +1
		count = 0;
		if(index ==len(fsm)):
			index =0
	else:
		Write_LED(conn, fsm[index])
	count= count +1

conn.close()


#00000000000000000000000001000000 delay
#00000000000000000100000000000000 doppler
#00000000010000000000000000000000 scale
#01000000000000000000000000000000 load


