function Yemd=EmbedBlock(DCTpsd1ext,DCTpsd2ext,DCTall,fY,kr,kc,ik,wm,selidxs,Delta)
%{
    Embed watermark to block.
    Input: 
        DCTpsd1ext: PSAMVs of set 1
        DCTpsd2ext: PSAMVs of set 2
        DCTall:     DCT coefficients of all blocks
        fY:         The flag of face position 
        kr:         Block position kr(height) being executed
        kc:         Block position kc(weight) being executed
        ik:         Block position ik(channel) being executed
        wm:         Watermark bit
        selidxs:    Two sets of coefficients
        Delta:      Quantization step
    Output:
        Yemd:       watermarked block.
        
%}
    selidx1=selidxs(1:4);
    ww1=[1  -1  1  -1];
    selidx2=selidxs(5:8);
    ww2=[1  1  -1  -1];
    xidx=[0,1,0,1,0;1,0,1,0,1;0,1,0,1,0;1,0,1,0,1;0,1,0,1,0];%[0,1,0;1,0,1;0,1,0];%
    yidx=13;%5;%
    ext=2;
    kre=kr+2; kce=kc+2;
    ffY=fY(kre-ext:kre+ext,kce-ext:kce+ext);
        
    DCTtmp=DCTall(:,:,kr,kc,ik);
    if mod(kr+kc,2)==0
        Btmp=DCTpsd2ext(kre-ext:kre+ext,kce-ext:kce+ext,ik);
        IDs=selidx2;
        ww0=ww2;
    else
        Btmp=DCTpsd1ext(kre-ext:kre+ext,kce-ext:kce+ext,ik);
        IDs=selidx1;
        ww0=ww1;
    end
    Org=Btmp(yidx);      
    Est=median(Btmp(xidx&ffY));

    p = 1.5 * Delta;
    n = 2 * Delta;
    g = max(Delta/2,0.05*abs(Org));
    d=(Org-Est);

    if wm == 1
        o1 = min(Est + Delta, max(Org, Est +g));
    else
        o1 = max(Est - Delta, min(Org, Est -g));
    end
    if d>p
        if wm == 0
            o2 = Est + floor((d-n)/2/Delta+0.5)*2*Delta + n;
        else
            o2 = Est + floor((d-n)/2/Delta)*2*Delta + Delta + n;
        end
    elseif d<-p
        if wm == 1
            o2 = Est + floor((d+n)/2/Delta+0.5)*2*Delta - n; 
        else
            o2 = Est + floor((d+n)/2/Delta)*2*Delta + Delta - n; 
        end
    else
        if wm == 1
                o2=Est-n;
        else
                o2=Est+n;
        end
    end       
    if abs(Org-o1)<abs(Org-o2)
        tmpy=o1;
    else
        tmpy=o2;
    end
    tmpx=Org;       
    qseq=ones(size(IDs));
    DCTtmp(IDs)=DCTtmp(IDs)+(tmpy-tmpx).*ww0.*qseq/mean(qseq);

    Yemd=uint8(idct2(DCTtmp));
end
