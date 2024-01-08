function wm=ExtractBlock(DCTpsd1ext,DCTpsd2ext,DCTall,fY,kr,kc,ik,Delta)  
%{
    Extract watermark from block.
    Input: 
        DCTpsd1ext: PSAMVs of set 1
        DCTpsd2ext: PSAMVs of set 2
        DCTall:     DCT coefficients of all blocks
        fY:         The flag of face position 
        kr:         Block position kr(height) being executed
        kc:         Block position kc(weight) being executed
        ik:         Block position ik(channel) being executed
        selidxs:    Two sets of coefficients
        Delta:      Quantization step
    Output:
        wm:         Watermark bit        
%}
    xidx=[0,1,0,1,0;1,0,1,0,1;0,1,0,1,0;1,0,1,0,1;0,1,0,1,0];
    yidx=13;
    ext=2;
    kre=kr+2; kce=kc+2;
    ffY=fY(kre-ext:kre+ext,kce-ext:kce+ext);
    DCTtmp=DCTall(:,:,kr,kc,ik);
    if mod(kr+kc,2)==0
        Btmp=DCTpsd2ext(kre-ext:kre+ext,kce-ext:kce+ext,ik);
    else
        Btmp=DCTpsd1ext(kre-ext:kre+ext,kce-ext:kce+ext,ik);
    end
    Org=Btmp(yidx);      
    Est=median(Btmp(xidx&ffY));

    
    p = 1.5 * Delta;
    n = 2 * Delta;
    d=(Org-Est);
    if d>=p
        wm=mod(floor((d-n)/Delta+0.5),2);
    elseif d<=-p
        wm=mod(floor((d+n)/Delta-0.5),2);
    else
        wm=(d>0);
    end
end