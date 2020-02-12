package com.LASSO;

import java.io.*;
import java.net.*;
import java.util.Date;
import java.nio.ByteBuffer; 

public class Server {

    public static void main(String[] args) {
	int port = 5010;

	int sizeInt = 4; // 4 bytes er int
	int sizeDouble = 8; // 4 bytes er int


//	double[] ref=new double[]{43.203,-76.03252,710,0.5,0.5,3}; //random reference
	double[] ref=new double[]{42.7002,-77.4086,701,0.5,0.5,9};
	double stationLatitudes[]= {42.7002, 42.70162,43.2138 };
	double stationLongitudes[]=  {-77.4086,-77.1380,-77.1905};
	double stationAltitudes[]=  {701,  284,  148 };
	double stationLatitudeserr[]= {0.0000526, 0.0000311,0.0000486 };
	double stationLongitudeserr[]=  {0.000031,0.000024,0.000027};
	double stationAltitudeserr[]=  {15,  2,  7 };
	double stationClkerr[]={1e-6,1.45e-6,0.95e-6};

//	derived using Sat at [az,el] [45,45], [125,30], [90,75],[345,15]
		double[][] TDdata={{-0.0531e-3,0.1171e-3,0.1702e-3},{-0.2026e-3,-0.0600e-3,0.1427e-3},{-0.6791e-4,0.0116e-4,0.6907e-4},{0.1559e-3,0.1607e-3,0.0048e-3}};
		double[][] TDerr={{0.0082,0.00743,0.0092},{0.0052,0.00355,0.0009},{0.0012,0.00055,0.00539},{0.0045,0.0101,0.0213}};


	int solverType = 1;
	int numStations = 3;
	int numDataPoints = 4;

	int numInts = 3;
	int numDoubles = 6+3*numStations+4*numStations+2*3*numDataPoints;


	//byte[] recvSizeBytes = new byte[4];
	byte[] sendMsgBytes;

	int recvSizeInt = 20;
	byte[] recv = new byte[recvSizeInt];
	
	int recvMsg;

        try (ServerSocket serverSocket = new ServerSocket(port)) {
 
            //while (true) {
                Socket socket = serverSocket.accept();

		InputStream input = socket.getInputStream();
		//BufferedReader reader = new BufferedReader(new InputStreamReader(input));
                OutputStream output = socket.getOutputStream();

		ByteBuffer bb = ByteBuffer.allocate(numInts*sizeInt+numDoubles*sizeDouble);

		bb.putInt(solverType);
		bb.putInt(numStations);
		bb.putInt(numDataPoints);
		//Reference
		for(double x : ref){
			bb.putDouble(x);
		}

		//Station Info
		for(int i=0;i<numStations;i++){
			bb.putDouble(stationLatitudes[i]);
			bb.putDouble(stationLongitudes[i]);
			bb.putDouble(stationAltitudes[i]);
		}
		for(int i=0;i<numStations;i++){
			bb.putDouble(stationLatitudeserr[i]);
			bb.putDouble(stationLongitudeserr[i]);
			bb.putDouble(stationAltitudeserr[i]);
			bb.putDouble(stationClkerr[i]);
		}

		//Time Diff info
		for(int col=0;col<numDataPoints;col++){
			for(int row=0;row<3;row++) {
				bb.putDouble(TDdata[col][row]);
				System.out.println(TDdata[col][row]);
			}
		}
		for(int col=0;col<numDataPoints;col++){
			for(int row=0;row<3;row++) {
				bb.putDouble(TDerr[col][row]);
			}
		}


//		bb.putDouble(refA);
//		bb.putDouble(refB);
//		bb.putDouble(dataC);


		sendMsgBytes = bb.array();
 	
		output.write(sendMsgBytes);
	
		input.read(recv, 0, recvSizeInt);
		recvMsg = ByteBuffer.wrap(recv).getInt();
		System.out.println(String.format("0x%08X", recvMsg));

		// use if reading string
		//String recv_str = new String(recv, "UTF-8");
		//System.out.println("CLIENT: " + recv_str);

		socket.close();
            //}
 
        } catch (IOException ex) {
            System.out.println("Server exception: " + ex.getMessage());
            ex.printStackTrace();
        }
    }
}
