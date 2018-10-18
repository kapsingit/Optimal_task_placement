%%  Task scheduling algorithm

% Enjoyement, time to complete in hr, due hour, hardness (assumes 5 working hr per
% day), final row for doing nothing
elements = [5 1 5 2;
    5 1 5 2;
    5 10 25 5;
    5 4 45 3;
    4 4 20 3;
    3 5 35 3;
    3 5 70 3;
    4 6 30 4;
    4 7 45 4;
    20 27 100 0];

total_hours = max(elements(1:end-1,3));
risk  = 0.5*elements(1:end-1,4)/max(elements(1:end-1,4))+0.4*elements(1:end-1,3)/max(elements(1:end-1,3))+0.1*elements(1:end-1,2)/max(elements(1:end-1,2));
risk = risk*5/max(risk);
risk(end+1) = 0;

%%
nhours = total_hours;
ntasks = total_hours;
get_mat = [];
get_mat2 = [];
get_mat3 = [];
for i = 1:length(elements)
    get_mat =[get_mat; risk(i)*ones(elements(i,2),1)];
    get_mat2 = [get_mat2; elements(i,1)*ones(elements(i,2),1)];
    get_mat3 = [get_mat3; elements(i,3)*ones(elements(i,2),1)];
end
%%
risk_matrix = repmat(get_mat,1,nhours);
enjoy_matrix = repmat(get_mat2,1,nhours);
task_schedule = optimproblem;
status = optimvar('status',ntasks,nhours,'Type','integer','LowerBound',0,'UpperBound',1);
task_schedule.Objective = 0.7*sum(sum(status.*risk_matrix))-0.3*sum(sum(status.*enjoy_matrix));

task_schedule.Constraints.duedate = optimconstr(length(elements)*total_hours-sum(elements(:,3)));
counter = 1;
for i = 1:ntasks
    for j = 1:nhours
             if j>=get_mat3(i)
                   task_schedule.Constraints.duedate(counter) = ...
                       status(i,j) ==0;
                   counter = counter+1;
             end
             
    end   
end
task_schedule.Constraints.mustdo = optimconstr(15);
for k =1:total_hours
    task_schedule.Constraints.mustdo(k) = ...
    sum(status(k,:))== 1;
end
task_schedule.Constraints.mustnotrepeat = optimconstr(15);
for k =1:total_hours
    task_schedule.Constraints.mustnotrepeat(k) = ...
    sum(status(:,k))== 1;
end
%%
options = optimoptions('intlinprog','MaxTime',1000);
% call the optimization solver to find the best solution
[sol,TotalCost,exitflag,output] = solve(task_schedule,options);
%%
list = [];
a = sol.status;
figure;
for i = 1:total_hours
    ab = a(:,i);
    list = [list find(ab,1)];
end
for k = 1:total_hours
    rectangle('Position',[k-1,list(k)-1,1,1],'FaceColor',[0 .5 .5],'EdgeColor','none');
    if k == 1
        hold on;
    end
end
for i =1:length(elements)
    plot([0,total_hours],[sum(elements(1:i,2)),sum(elements(1:i,2))],'--r')
end
for i =5:5:total_hours
    plot([i,i],[0,total_hours],'--g')
end
grid on;
xticks([0:5:total_hours]);