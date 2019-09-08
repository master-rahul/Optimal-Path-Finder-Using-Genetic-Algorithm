function gch=selection(genes1,genes2,cp)

    
for cpc=1:cp
    if genes2(cpc)~=genes1(cpc) 
        ind=find(genes1==genes2(cpc));
        
        
        genes1(ind)=genes1(cpc); 
        genes1(cpc)=genes2(cpc);
    end
end
gch=genes1;