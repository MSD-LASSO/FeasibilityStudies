function out=SUM
data=dlmread('C:\Users\Acer\Desktop\MSD\FeasibilityStudies\TdoaSim\Experimental\SimpleSumTest\data.txt','');
out=sum(data);
h1=fopen('C:\Users\Acer\Desktop\MSD\FeasibilityStudies\TdoaSim\Experimental\SimpleSumTest\out.txt','w');
fprintf(h1,'%13.5e',out);
fprintf('\n')
fprintf('fprintf cmd, ')
disp('disp cmd')
fclose(h1);

% if rand(1)<0.1
%     error('Random number less than 0.5')
% end

warning('this is a warning')

figure()
plot(rand(5,1),rand(5,1),'*','linewidth',3)

end