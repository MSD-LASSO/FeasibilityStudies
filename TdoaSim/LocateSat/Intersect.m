function Solutions=Intersect(Surf,SymVars)
%This function calculates the real intersection between all specified
%surfaces and returns the equations (in symbolic form) that describe that
%intersection.
%This function uses the symbolic toolbox.
    %INPUTS: an array containing syms in the form
    %Surf=[Eqn1,Eqn2,...];
    %Each entry is an equation of symbols that is equal to 0.
    %SymVars is an array of variables to solve for.
    %SymVars=[x,y,z,t,...];
    %Plot=1 to plot results, Plot=0 or is empty to not see a plot.
    %
    %OUTPUTS: A cell array containing all real solutions. To access, do
    %SymbolicEqns{1} for all solutions corresponding to SymVars(i). 
    %Expect SymbolicEqns length to be the smaller of Eqns or the number of
    %SymVars. Two equations and three unknowns returns 
       
% 11/11/2019 This function now assumes the input is 2D. 
id='symbolic:solve:PossiblySpuriousSolutions';
warning('off',id)

SymbolicEqns=solve(Surf);
Solutions=struct2cell(SymbolicEqns); %easier to work with. 
%each entry in the cell array corresponds to the associated variable in
%SymVars.

% figure()
% fimplicit(Surf(1),'linewidth',3,'color','c')
% hold on
% fimplicit(Surf(2),'linewidth',3,'color','c')
% plot(double(vpa(SymbolicEqns.x)),double(vpa(SymbolicEqns.y)),'.','MarkerSize',20,'color','black')
% plot(double(vpa(Solutions{1})),double(vpa(Solutions{2})),'.','MarkerSize',20,'color','black')

%% for each solution, verify it satisfies the equations. Needed for 1 sided Hyperbolas. 
RemoveList=true(length(Solutions{1}),1);
for i=1:size(Solutions{1},1)
    Out=double(subs(Surf,SymVars,[Solutions{1}(i) Solutions{2}(i)]));
    if sum(abs(Out)<1e-10)<2
        RemoveList(i)=false;
    end
end

for i=1:2
    Solutions{i}=Solutions{i}(RemoveList);
end

%% plot feature, not implemented.
% if nargin==3
%     if Plot==1
%         %currently not implemented correctly.
%         %use fimplicit to plot Surf
%         %use plot(SymbolicEqns.x,SymbolicEqns.y,...) to plot the solution. 
%         PlotIntersect(Surf,SymbolicEqns)
%     end
% end

end