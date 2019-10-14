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
    
SymbolicEqns=solve(Surf,'Real',true);
Solutions=struct2cell(SymbolicEqns); %easier to work with. 
%each entry in the cell array corresponds to the associated variable in
%SymVars.


%for each solution, verify it satisfies the first equation.
RemoveList=true(length(Solutions{1}),1);
for i=1:length(Solutions{1})
    Eqn=Surf(1);
    
    %make sure soln corresponds with SymVars shape. 
    if size(SymVars,1)>size(SymVars,2)
        %N rows, 1 column
        soln=sym(zeros(length(Solutions),1));
    else
        %1 row, N columns
        soln=sym(zeros(1,length(Solutions)));
    end

    %get the ith solution    
    for k=1:length(Solutions)
        soln(k)=Solutions{k}(i);
    end
    
    %verify the ith solution is identically 0. 
    out=simplify(subs(Eqn,SymVars(1:length(Solutions)),soln));
    if ~logical(out==0)
       %if the answer does not equal to 0. Its not on the hyperbola!
       RemoveList(i)=false;
    end
end

%Remove false solutions
for k=1:length(Solutions)
    Solutions{k}=Solutions{k}(RemoveList);
end


% if nargin==3
%     if Plot==1
%         %currently not implemented correctly.
%         %use fimplicit to plot Surf
%         %use plot(SymbolicEqns.x,SymbolicEqns.y,...) to plot the solution. 
%         PlotIntersect(Surf,SymbolicEqns)
%     end
% end

end