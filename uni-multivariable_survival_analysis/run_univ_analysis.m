data=load('clinical_data.mat');

cd=data.clinical_data;

data79=cd(cell2mat(cd(:,16))==0,:);
data140=cd(cell2mat(cd(:,16))==1,:);


%% cleaning data %%

num=length(data79);
col=3;
ind=[];
for i=1:num
    if isempty(data79{i,col}) || strcmp(num2str(data79{i,col}),'0')
        ind=[ind; i];
    end    
end
data79(ind,:)=[];

data79(:,3)=strrep(data79(:,3),'a','A');
data79(:,3)=strrep(data79(:,3),'b','B');

%% univariable analysis%%
age=cell2mat(data79(:,2))>60;
sex=strcmp(data79(:,7),'Female');
stage=(strcmp(data79(:,3),'I') | strcmp(data79(:,3),'IA') | strcmp(data79(:,3),'IB'));
followup=cell2mat(data79(:,14));
cens=cell2mat(data79(:,15));

% age
X = [age];
[b,logl,H,stats] = coxphfit(X,followup,'censoring',cens);

i=1;
for i=1:1
    fprintf('p=%.8f,HR ratio(95CI)=%.2f(%.2f-%.2f)\n', stats.p(i),exp(stats.beta(i)),exp(stats.beta(i)-1.96*stats.se(i)),exp(stats.beta(i)+1.96*stats.se(i)));
end

% sex
X = [sex];
[b,logl,H,stats] = coxphfit(X,followup,'censoring',cens);

i=1;
for i=1:1
    fprintf('p=%.8f,HR ratio(95CI)=%.2f(%.2f-%.2f)\n', stats.p(i),exp(stats.beta(i)),exp(stats.beta(i)-1.96*stats.se(i)),exp(stats.beta(i)+1.96*stats.se(i)));
end

% stage

X = [stage];
[b,logl,H,stats] = coxphfit(X,followup,'censoring',cens);

i=1;
for i=1:1
    fprintf('p=%.8f,HR ratio(95CI)=%.2f(%.2f-%.2f)\n', stats.p(i),exp(stats.beta(i)),exp(stats.beta(i)-1.96*stats.se(i)),exp(stats.beta(i)+1.96*stats.se(i)));
end

%% getting automatic data %%

data=load('allvariable.mat');
imgNames=data.TestSetNames;

data79(:,1)=strrep(data79(:,1),'norm_','');
imgNames=strrep(imgNames,'.mat','');

vals=[];
num=length(data79);
labels=zeros(num,1);
for i=1: num
    val=find(strcmp(data79(i,1),imgNames));
    labels(i)=data.real_predlabels(val);
end


%% multivariable analysis %%

X = [age sex stage labels];
[b,logl,H,stats] = coxphfit(X,followup,'censoring',cens);

i=1;
for i=1:4
    fprintf('p=%.8f,HR ratio(95CI)=%.2f(%.2f-%.2f)\n', stats.p(i),exp(stats.beta(i)),exp(stats.beta(i)-1.96*stats.se(i)),exp(stats.beta(i)+1.96*stats.se(i)));
end
 



