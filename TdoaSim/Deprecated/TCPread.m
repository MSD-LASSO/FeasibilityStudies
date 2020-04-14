host='127.0.0.1';
port=5010;

sizeDouble=8;
numArgs = 3;

% thost = tcpip(host, port, 'NetworkRole', 'server');
% fopen(thost);
% fwrite(thost,4542.242353532);

% t = tcpclient('www.mathworks.com', 80)
t = tcpclient(host, port)
h1=read(t, sizeDouble*numArgs);

for doubleIdx = 1:numArgs
    dataBytes = h1(1+(doubleIdx-1)*sizeDouble : doubleIdx*sizeDouble);
    num = typecast(flip(dataBytes), 'double')
end

returnValue=56.0978754;
RV=typecast(returnValue,'uint8');
write(t, flip(RV))

% write(t,50)
% 
% read(t)