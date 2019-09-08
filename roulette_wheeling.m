function ii=roulette_wheeling(m,prn)
cumulative_sum=cumsum(prn);

n=length(prn);


sz=size(cumulative_sum);
if sz(1)>sz(2)
    cumulative_sum1=cumulative_sum';
else
    cumulative_sum1=cumulative_sum;
end

i1=interp1([0 cumulative_sum1],1:(n+1),rand(1,m),'linear');
ii=floor(i1); 