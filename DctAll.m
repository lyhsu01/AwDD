function [DCTpsd1ext,DCTpsd2ext,DCTall]=DctAll(Y,selidxs) 
%{
    DCT is performed on all 8*8 non-overlapping blocks, 
    and then its Partly sign-altered mean value (PSAMV) 
    is obtained through two sets of coefficients.
    Input: 
        Y:          Original image
        selidxs:    Two sets of coefficients
    Output:
        DCTpsd1ext: PSAMVs of set 1
        DCTpsd2ext: PSAMVs of set 2
        DCTall:     DCT coefficients of all blocks        
%}
    Y=double(Y);    
    clear DCTall;
    MBrn=8;MBcn=8;
    selidx1=selidxs(1:4);
    ww1=[1  -1  1  -1];
    selidx2=selidxs(5:8);
    ww2=[1  1  -1  -1];
    
    DCTall=zeros(8,8,size(Y,1)/8,size(Y,2)/8,3);
    for kk=1:size(Y,3)
        for kr=1:size(Y,1)/MBrn
            for kc=1:size(Y,2)/MBcn
                MBtmp=Y((kr-1)*MBrn+(1:MBrn),(kc-1)*MBcn+(1:MBcn),kk);
                DCTtmp=dct2(MBtmp);
                DCTall(:,:,kr,kc,kk)=DCTtmp;
                if sum(abs(DCTtmp(selidx1)))==0
                    DCTtmp(selidx1)=randn(size(DCTtmp(selidx1)))*eps;
                end
                DCTpsd1(kr,kc,kk)=mean(DCTtmp(selidx1).*ww1); 
                if sum(abs(DCTtmp(selidx2)))==0
                    DCTtmp(selidx2)=randn(size(DCTtmp(selidx2)))*eps;
                end
                DCTpsd2(kr,kc,kk)=mean(DCTtmp(selidx2).*ww2); 
            end
        end        
        DCTpsd1e=DCTpsd1(:,:,kk);
        DCTpsd1e=DCTpsd1e([3 2 1:end end-1 end-2],:); 
        DCTpsd1e=DCTpsd1e(:,[3 2 1:end end-1 end-2]);
        DCTpsd1ext(:,:,kk)=DCTpsd1e;
        DCTpsd2e=DCTpsd2(:,:,kk);
        DCTpsd2e=DCTpsd2e([3 2 1:end end-1 end-2],:); 
        DCTpsd2e=DCTpsd2e(:,[3 2 1:end end-1 end-2]);
        DCTpsd2ext(:,:,kk)=DCTpsd2e;
    end
end