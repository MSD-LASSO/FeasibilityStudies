import RPi.GPIO as GPIO
import config
import math
import time
import os

Temp = '0123456789ABCDEF*'
BUFFSIZE = 1100

class L76X(object):
    Lon = 0.0
    Lat = 0.0
    Lon_area = 'E'
    Lat_area = 'W'
    Date_M = 0
    Date_D = 0
    Date_Y = 0
    Time_H = 0
    Time_M = 0
    Time_S = 0
    Time = ""
    Date = ""
    Status = 0
    
    GPS_Lon = 0
    GPS_Lat = 0
    
    #Startup mode
    SET_HOT_START       = '$PMTK101'
    SET_WARM_START      = '$PMTK102'
    SET_COLD_START      = '$PMTK103'
    SET_FULL_COLD_START = '$PMTK104'

    #Standby mode -- Exit requires high level trigger
    SET_PERPETUAL_STANDBY_MODE      = '$PMTK161'

    SET_PERIODIC_MODE               = '$PMTK225'
    SET_NORMAL_MODE                 = '$PMTK225,0'
    SET_PERIODIC_BACKUP_MODE        = '$PMTK225,1,1000,2000'
    SET_PERIODIC_STANDBY_MODE       = '$PMTK225,2,1000,2000'
    SET_PERPETUAL_BACKUP_MODE       = '$PMTK225,4'
    SET_ALWAYSLOCATE_STANDBY_MODE   = '$PMTK225,8'
    SET_ALWAYSLOCATE_BACKUP_MODE    = '$PMTK225,9'

    #Set the message interval,100ms~10000ms
    SET_POS_FIX         = '$PMTK220'
    SET_POS_FIX_100MS   = '$PMTK220,100'
    SET_POS_FIX_200MS   = '$PMTK220,200'
    SET_POS_FIX_400MS   = '$PMTK220,400'
    SET_POS_FIX_800MS   = '$PMTK220,800'
    SET_POS_FIX_1S      = '$PMTK220,1000'
    SET_POS_FIX_2S      = '$PMTK220,2000'
    SET_POS_FIX_4S      = '$PMTK220,4000'
    SET_POS_FIX_8S      = '$PMTK220,8000'
    SET_POS_FIX_10S     = '$PMTK220,10000'

    #Switching time output
    SET_SYNC_PPS_NMEA_OFF   = '$PMTK255,0'
    SET_SYNC_PPS_NMEA_ON    = '$PMTK255,1'

    #To restore the system default setting
    SET_REDUCTION               = '$PMTK314,-1'

    #Set NMEA sentence output frequencies 
    SET_NMEA_OUTPUT = '$PMTK314,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,1,0'
    #Baud rate
    SET_NMEA_BAUDRATE          = '$PMTK251'
    SET_NMEA_BAUDRATE_115200   = '$PMTK251,115200'
    SET_NMEA_BAUDRATE_57600    = '$PMTK251,57600'
    SET_NMEA_BAUDRATE_38400    = '$PMTK251,38400'
    SET_NMEA_BAUDRATE_19200    = '$PMTK251,19200'
    SET_NMEA_BAUDRATE_14400    = '$PMTK251,14400'
    SET_NMEA_BAUDRATE_9600     = '$PMTK251,9600'
    SET_NMEA_BAUDRATE_4800     = '$PMTK251,4800'

    def __init__(self):
        self.config = config.config(9600)
    
    def L76X_Send_Command(self, data):
        Check = ord(data[1]) 
        for i in range(2, len(data)):
            Check = Check ^ ord(data[i]) 
        data = data + Temp[16]
        data = data + Temp[(Check/16)]
        data = data + Temp[(Check%16)]
        self.config.Uart_SendString(data)
        self.config.Uart_SendByte('\r')
        self.config.Uart_SendByte('\n')
        # print(data)
       
    def L76X_Get(self):
        data = self.config.Uart_ReceiveString(BUFFSIZE)

        string = ""

        for ch in data:
            string += ch

        newStr = string.split("\n")

        # Setting default value
        self.Alt = 0.0
        self.Lat = 0.0
        self.Lat_area = ''
        self.Lon = 0.0
        self.Lon_area = ''

        for line in newStr:
            split = line.split(',')
    
            # print(line)

            if(len(split) >=11):
                if(split[0] == "$GNGGA" or split[0] == "$GPGGA"):
                    if(split[6] == "1"):
                        self.Status = split[6]

                        self.Lat = float(split[2]) / 100.0
                        self.Lat = (self.Lat // 1) + ((self.Lat%1/.01)/60);
                    
                        self.Lon = float(split[4]) / 100.0
                        self.Lon = (self.Lon // 1) + ((self.Lon%1/.01)/60);
                
                        if(split[3] == 'S'):
                            self.Lat = self.Lat*-1
                    
                        if(split[5] == 'W'):
                            self.Lon = self.Lon*-1
                        
                        self.Alt = float(split[9])
                        
                if(split[0] == "$GNRMC" or split[0] == "$GPRMC"):
                    if(split[2] == "A"):
                        time = float(split[1])
                        self.Time_H = int(time//10000)
                        self.Time_M = int(time//100%100)
                        self.Time_S = round(time%100,3)
                        
                        self.Time = str(self.Time_H)+":"+str(self.Time_M)+":"+str(self.Time_S)
                        
                        date = float(split[9])
                        self.Date_M = int(date%10000//100)
                        self.Date_D = int(date//10000)
                        self.Date_Y = int(2000 + date%100)
                        
                        self.Date = str(self.Date_Y)+"-"+str(self.Date_M)+"-"+str(self.Date_D)
                        
                        #os.system('sudo timedatectl set-time \'' + self.Date + ' ' + self.Time+'\'')

    def L76X_Set_Baudrate(self, Baudrate):
        self.config.Uart_Set_Baudrate(Baudrate)

    def L76X_Exit_BackupMode(self):
        GPIO.setup(self.config.FORCE, GPIO.OUT)
        time.sleep(1)
        GPIO.output(self.config.FORCE, GPIO.HIGH)
        time.sleep(1)
        GPIO.output(self.config.FORCE, GPIO.LOW)
        time.sleep(1)
        GPIO.setup(self.config.FORCE, GPIO.IN)


    



