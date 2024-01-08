function M=Arnoldplus(WM,times,crypt,key)     
%{
    Arnold transform scrambling algorithm (ATS): encrypt watermark(logo).
    Input: 
        WM:         Watermark (logo)
        times:      The Key (times) of Arnold transform scrambling algorithm (ATS)
        crypt:      encrypt = 0, decrypt = 1
        key:        The key value of Arnold transform scrambling algorithm (ATS)
    Output:
        M:          encrypt/decrypt watermark(logo)        
%}
    if ~exist('key','var'), key=0.93; end 
    Q=WM; if crypt==0, Q=STmap(WM,key); end
    M = Q ; 
    Size_Q   = size(Q);     
    isOK=1;
    if (length(Size_Q) == 2)  
       if Size_Q(1) ~= Size_Q(2)   
            isOK=0;
       end 
    else 
       isOK=0;  
    end 
     
    if isOK
       n = 0; 
       K = Size_Q(1); 
        
       M1_t = Q; 
       M2_t = Q; 
        
       if crypt==1   
           times=ArnoldPeriod( Size_Q(1) )-times; 
       end 
            
       for s = 1:times 
           n = n + 1; 
           if mod(n,2) == 0 
                for i = 1:K 
                   for j = 1:K 
                      c = M2_t(i,j); 
                      M1_t(mod(i+j-2,K)+1,mod(i+2*j-3,K)+1) = c; 
                   end 
                end 
           else 
                for i = 1:K 
                   for j = 1:K 
                       c = M1_t(i,j); 
                       M2_t(mod(i+j-2,K)+1,mod(i+2*j-3,K)+1) = c; 
                   end 
                end 
           end 
       end 
        
       if mod(times,2) == 0 
          M = M1_t; 
       else 
          M = M2_t; 
       end 
    end
    if crypt==1, M=STmap(M,key); end %modification
   
end   
function Period=ArnoldPeriod(N)  
%{
    Scrambling algorithm: encrypt watermark(logo).
    Input: 
        WM:         Watermark (logo)
        key:        The key value of the scrambling algorithm
    Output:
        WMb:        Scrambling/descrambling watermark(logo)        
%}
    if ( N<2 ) 
        Period=0; 
        return; 
    end 
     
    n=1; 
    x=1; 
    y=1; 
    while n~=0 
        xn=x+y; 
        yn=x+2*y; 
        if ( mod(xn,N)==1 && mod(yn,N)==1 ) 
            Period=n; 
            return; 
        end 
        x=mod(xn,N); 
        y=mod(yn,N); 
        n=n+1; 
    end
end
function WMb=STmap(WM,key)    
%{
    Scrambling algorithm: encrypt watermark(logo).
    Input: 
        WM:         Watermark (logo)
        key:        The key value of the scrambling algorithm
    Output:
        WMb:        Scrambling/descrambling watermark(logo)        
%}
    [kr,kc]=size(WM);kno=kr*kc;
    if ~exist('va','var'), va=0.66; end
    if ~exist('vb','var'), vb=0.5; end
    x(1)=key;
    for k=2:kno
        x(k)=skewtentmap(x(k-1),va);
    end
    Xskm=reshape(x>=vb,kr,kc);
    WMb= xor(WM,Xskm);
end

function y=skewtentmap(x,key) 
%{
    skew tent map: encrypt information.
    Input: 
        x:          information
        key:        The key value of the skew tent map algorithm
    Output:
        y:          encrypted information        
%}
    if ~exist('va','var'), key=0.66; end
    if x<key
        y=x/key;
    else
        y=(1-x)/(1-key);
    end
end
