disp('#############################################################################################################################')
disp('#########################################    *OPTIMAL PATH FINDER USING GENETIC ALGORITHM*    ###############################')
disp('#############################################################################################################################')
disp('###################################')
disp('###################################')
disp('##Deveoped By:                   ##')
disp('##Rahul Verma                    ##')
disp('###################################')
city=input('Enter the city number: ');
pm=0.01;
pm2=0.02;
pmf=0.08;
area_of_graph=10;
population=input('Enter the population size: ');
generation=input('Enter the generation number: ');
coordinates=area_of_graph*rand(2,city); 
distance_matrix=zeros(city,city); 
for n1=1:city-1
    r1=coordinates(:,n1);
    for n2=n1+1:city
        r2=coordinates(:,n2);
        dr=r1-r2;
        dr2=dr'*dr;
        drl=sqrt(dr2);
        distance_matrix(n1,n2)=drl;
        distance_matrix(n2,n1)=drl;
    end
end
Gene=zeros(population,city); 
for populationc=1:population
    Gene(populationc,:)=randperm(city);
end
figure('units','normalized','position',[0.05 0.2 0.9 0.6]);
subplot(1,2,1);
hpb=plot(NaN,NaN,'r-');
ht=title(' ');
hold on;
for n=1:city
    text(coordinates(1,n),coordinates(2,n),num2str(n),'color',[0.1 0.1 0.1]);
end
plot(coordinates(1,:),coordinates(2,:),'k.');
axis equal;
xlim([-0.1*area_of_graph 1.1*area_of_graph]);
ylim([-0.1*area_of_graph 1.1*area_of_graph]);
subplot(1,2,2);
hi=imagesc(Gene);
title('color is city number');
colorbar;
xlabel('index in sequence of cities');
ylabel('path number');
path_length=zeros(population,1); 
p=zeros(population,1);
for gc=1:generation 
        for populationc=1:population
        Gt=Gene(populationc,:);
        pt=0;
        for nc=1:city-1
            pt=pt+distance_matrix(Gt(nc),Gt(nc+1));
        end
        pt=pt+distance_matrix(Gt(city),Gt(1));
        path_length(populationc)=pt;
    end
    inverse_path_length=1./path_length; 
    p=inverse_path_length/sum(inverse_path_length); 
    [mbp bp]=max(p); 
    best_gene=Gene(bp,:);  
   if mod(gc,5)==0
        set(hpb,'Xdata',[coordinates(1,best_gene) coordinates(1,best_gene(1))],'YData',[coordinates(2,best_gene) coordinates(2,best_gene(1))]);
        set(ht,'string',['generation: ' num2str(gc)  '  best path length: ' num2str(path_length(bp))]);
        set(hi,'CData',Gene);
        drawnow;
    end
     ii=roulette_wheeling(population,p);
   Gc=Gene(ii,:); 
    Gch=zeros(population,city);
    for prc=1:(population/2) 
        i1=1+2*(prc-1);
        i2=2+2*(prc-1);
        gene1=Gc(i1,:);
        gene2=Gc(i2,:); 
        cp=ceil((city-1)*rand); 
        gene1ch=selection(gene1,gene2,cp);
        gene2ch=selection(gene2,gene1,cp);
        Gch(i1,:)=gene1ch;
        Gch(i2,:)=gene2ch;
    end 
     
    for psc=1:population
        if rand<pm
            rnp=ceil(city*rand);
            rpnn=randperm(city);
            ctp=rpnn(1:rnp); 
            Gt=Gene(psc,ctp); 
            Gt=Gt(randperm(rnp)); 
            Gene(psc,ctp)=Gt; 
         end
    end
    for psc=1:population
        if rand<pm2
            cp=1+ceil((city-3)*rand); 
            Gene(psc,:)=[Gene(psc,cp+1:city) Gene(psc,1:cp)];
        end
    end
    
    for psc=1:population
        if rand<pmf
            n1=ceil(city*rand);
            n2=ceil(city*rand);
            Gene(psc,n1:n2)=fliplr(Gene(psc,n1:n2));
        end
    end  
      Gene(1,:)=best_gene;
end
disp('########################################################################################################################')
disp('########################################################################################################################')
disp('OUTPUT:')
disp('The matrix for coordintes of cities :')
coordinates
disp('The best chromosomes is  : ')
best_gene
disp('The distance between cities is given by distance matrix  :')
distance_matrix
disp('The optimized gene matrix  :')
Gene
disp('##########################################################################################################################')
disp('################################################                THANKS FOR USING                   #######################')
disp('##########################################################################################################################')
