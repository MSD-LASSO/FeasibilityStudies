// basic file operations
#include <iostream>
#include <fstream>
#include <string>
#include <regex>
#include <vector>
#include <cstdlib>

using namespace std;
int main () {


//RUNNING THE JAR

std::system("chmod +x OrekitAccessDopplerCalculator.jar"); //might need this line for permissions?

//command syntax:
//java -jar OrekitAccessDopplerCalculator.jar errorTimeForTLE=0.3 recordingRate=60 noradID=30776 channelFrequency=437.15 endTime=2020-02-12T17:08:34.584+00:00

std::system("java -jar OrekitAccessDopplerCalculator.jar noradID=30776 errorTimeForTLE=0.3");



//READING THE OUTPUT FILE

 string numStationsString;
 string baseFreqLine;
 string signalBandwidthLine;
 string recordTimeLine;
 string numEventsLine;


 ifstream myfile ("DopplerAccess30776.txt");
 getline (myfile,numStationsString);

 numStationsString= numStationsString.replace(0,12,""); //1st line: number of stations

int numStations=stoi(numStationsString);
string stations[numStations];
 for (int n=0; n<numStations;n++){    //next n lines: station names
	
	getline(myfile,stations[n]);
	
	cout <<stations[n]<< "\n";
}
 
 getline (myfile,numEventsLine);
 double numEvents=stod(numEventsLine.replace(0,10,""));
 cout <<numEvents<< '\n';

 std::vector<std::vector< std::string> > dateArray; 

 std::vector<std::vector< std::vector< std::string> > >frequencyArray; 
 //defining dimensions of this messed up freq array
 int numContainers=numStations*3;  // 3 is because there is nominal, low, and high freq containers.

 for (int l=0;l<numContainers;l++){
     
     frequencyArray.push_back(std::vector<std::vector< std::string> >()); //defining "numContainers" # of blank 2d arrays
     
     for (int m=0;m<numEvents;m++){
         frequencyArray[l].push_back(std::vector<string>()); //next, defining "numEvents" # of rows for the 2d arrays. 
     }
     
 }



 int b=-1;
 string nextLine;
 int magnitudeMultiplier=1000000; //from MHz to Hz
 regex reg("\\s+");
getline(myfile,nextLine);
while (b< (numEvents) && myfile.eof()==0){

  //cout <<nextLine.substr(0,23)<< '\n';

  if (nextLine.substr(0,6)=="Access"){
	cout <<"this is a header line"<< '\n';
	b++;
	dateArray.push_back(std::vector<string>());

   }
  else{
  dateArray[b].push_back(nextLine.substr(0,23));   //0 to 23 is the date part of the line
  nextLine=nextLine.substr(28,nextLine.size());    //28 is hard coded start of 1st frequency term
  sregex_token_iterator iter(nextLine.begin(),nextLine.end(), reg, -1);
  sregex_token_iterator end;
  vector<string> vec(iter,end); //the frequencies are now separated
  //int numOfEntries= vec.size();  =numContainers
 // for (int l=0; l<numContainers; l++){
      
    //  for(int m=0; m<numEvents;m++){
         
          for(int n=0; n<numContainers;n++){
	       vec[n]= to_string(    (int)(stod(vec[n])*magnitudeMultiplier));
              frequencyArray[n][b].push_back(vec[n]);
             // cout<<"printing to ["+to_string(n)+"]"+"["+to_string(b)+"]"+vec[n]<< '\n';
          }
            //   cout<<"event ended"<< '\n';          
   //    }

 // }  



//     for (int a=0;a<vec.size();a++){
//       cout<<vec[a]<<endl;
//       }
//	cout<<" "<< '\n';
   

  }  //the else terminator

  // cout<<myfile.eof()<< '\n';	
  getline(myfile,nextLine);
}

myfile.close();

//checking if dates were stored properly

for (int d=0; d<numEvents;d++){
    cout <<dateArray[d].size()<< '\n';
    for (int f=0; f<dateArray[d].size();f++){
    cout <<dateArray[d][f]<< '\n';
    }
    
 }

//checking if frequencies were stored properly
cout<<to_string(frequencyArray.size())<< '\n';
cout<<to_string(frequencyArray[0].size())<< '\n';
 for (int p=0; p<frequencyArray.size();p++){
     for (int q=0; q<frequencyArray[0].size();q++){
         for (int r=0; r<frequencyArray[0][q].size();r++){
          
              cout<<frequencyArray[p][q][r]<< ' ';
              
      // cout<<to_string(frequencyArray[p][q].size())<< ' ';
         }
 
      cout <<"\n event end"<< '\n'; 
     }
     cout <<"container end"<< '\n';

 }


// cout << "Hello World \n"; // prints Hello World
 
 return 0;

}
// add a numStations (to count # station string names)
// add a numAccesses (for 2D array of freq information?..)
// hardcode baseFreq signalBandwidth and recordTime vars.
// reading string loop
//- if string starts with Access Number, skip it.
//-make shit ton of 2d arrays. dates, station 0 upper lower nom, station 1 upper lower 
//nom, station 2 upper lower nom