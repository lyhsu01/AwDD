function [Ym,WMb]=AwDDExtract(Yb,Key1,Key2,Delta,selidxs)
%{
    AwDD extract watermark WM from watermarked image Yb.
    Input: 
        Yb:         Watermarked image
        Key1:       The Key (times) of Arnold transform scrambling algorithm (ATS)
        Key2:       The Key value of Arnold transform scrambling algorithm (ATS)
        Delta:      Quantization step
        selidxs:    Two sets of coefficients
    Output:
        Ym:         Masked (deepfaked) watermarked image
        WMb:        Extracted watermark(logo)
        
%}

    Yb=uint8(Yb);
    [bboxes, scores, wboxes,landmarks] =  FaceDetect(Yb);

    ns=ceil(log2(max(size(Yb,1)/8,size(Yb,2)/8)))+2;
    numFace=size(wboxes,1);
    if numFace==0
        L=1;
        Ym=Yb;
        Yb = rgb2ycbcr(uint8(Yb));
        [DCTpsd1ext,DCTpsd2ext,DCTall]=DctAll(Yb(:,:,1),selidxs); 
        nf=size(Yb,1)/8*size(Yb,2)/8;
        isPic=1;
    else
        L=3;
        ws=max(size(Yb,1,2))/8;        
        nf=ceil(ns*4*3);        
        [DCTpsd1ext,DCTpsd2ext,DCTall]=DctAll(Yb,selidxs); 
        isPic=0;
    end

    wmI=1;
    wwm=[];
    fY=ones(size(Yb,1)/8,size(Yb,2)/8,3);
    fYY=fY(:,:,1);
    fYY=fYY([3 2 1:end end-1 end-2],:); 
    fYY=fYY(:,[3 2 1:end end-1 end-2]); 
    fC=zeros(size(fY));
    dir=1;ii=1;jj=0;ix=1;iy=1;ik=0;
    fc=1;
    while(fc<=numel(fY))
        if fc==nf+1 && numFace~=0
            head=reshape(wwm(1:nf),ns,[])';
            facePos = bi2de(head,'left-msb');
            if facePos(5)==0
                numFace=1;
            elseif facePos(9)==0
                numFace=2;
            else
                numFace=3;
            end

            wboxesE=double(reshape(facePos(1:numFace*4),numFace,4));
            if ~isempty(wboxes)
                if size(wboxes,1)==size(wboxes,1)
                    for k = 1:size(wboxes,1)
                        if sum(abs(wboxes(1,:)-wboxesE(1,:)))<4
                            wboxes(1,:)=wboxesE(1,:);
                        end
                    end
                end
            end
            
            nbT=0;
            nb=zeros(size(wboxes,1),1);
            for k = 1:size(wboxes,1)
                iF13=min(wboxes(k,1)+wboxes(k,3),size(fY,2));
                iF24=min(wboxes(k,2)+wboxes(k,4),size(fY,1));
                for iiy=wboxes(k,1):iF13+1
                    for iix=wboxes(k,2):iF24+1
                        if fY(iix,iiy,1)==1
                            nbT=nbT+1; 
                            fY(iix,iiy,:)=0;
                        end
                    end
                end
                nb(k)=nbT-sum(nb);
            end
            fYY=fY(:,:,1);
            fYY=fYY([3 2 1:end end-1 end-2],:); 
            fYY=fYY(:,[3 2 1:end end-1 end-2]);    
        end

        if ik==L
            if (ix+ii>size(Yb,1)/8 || iy+jj>size(Yb,2)/8 || (ix+ii==0&&iy>1) || fC(ix+ii,iy+jj,1)==1)
                dir=rem(dir,4)+1;
                if dir==1
                    ii=1;jj=0;
                elseif dir==2
                    ii=0;jj=1;
                elseif dir==3
                    ii=-1;jj=0;
                else
                    ii=0;jj=-1;
                end
            end
            ik=1;
            ix=ix+ii;
            iy=iy+jj;
        else
            ik=ik+1;
        end
        fC(ix,iy,ik)=1;
        if fY(ix,iy,ik)==1
            wwm(wmI)=ExtractBlock(DCTpsd1ext,DCTpsd2ext,DCTall,fYY,ix,iy,ik,Delta);
            fY(ix,iy,ik)=2;
            wmI=wmI+1;
        end
        fc=fc+1;
    end
    

    if isPic==1
        WMb = reshape(wwm,size(fY,1,2));
        WMb = uint8(Arnoldplus(WMb,Key2,1,Key1));   
    else
        nm=ws*ws;
        nr=(numel(fY)-nm-nf-3*nbT);
        nd=floor(nr/8);         
        nTDMV=0;
        for k = 1:size(wboxes,1)
            np=nb(k)/nbT*nd;
            nw=floor(sqrt(np*(wboxes(k,4))/(wboxes(k,3))));
            nh=floor(np/nw);
            nTDMV=nTDMV+nw*nh;
        end
        space=(nf+1:ws*ws+nf+nTDMV*8);
        wwm(space)=uint8(Arnoldplus(wwm(space)',Key2,1,Key1)'); 
        WMb = uint8(reshape(wwm(nf+1:ws*ws+nf),[],ws));
        wm1=wwm(ws*ws+nf+1:end);     
        ba=wm1(1:end-rem(length(wm1(:)),8));
        head=reshape(ba,8,[])';
        facePos = bi2de(head,'left-msb');
           
        ffY=zeros(size(Yb));
        cY=zeros(size(Yb));
        count=1;
        for k = 1:size(wboxes,1)
            iF13=min(wboxes(k,1)+wboxes(k,3),size(fY,2));
            iF24=min(wboxes(k,2)+wboxes(k,4),size(fY,1));
            np=nb(k)/nbT*nd;
            nw=floor(sqrt(np*(wboxes(k,4))/(wboxes(k,3))));
            nh=floor(np/nw);
            nx=floor((wboxes(k,4))*8/nw);
            ny=floor((wboxes(k,3))*8/nh);
            bx=(wboxes(k,2)-1)*8+1;
            by=(wboxes(k,1)-1)*8+1;
            for iy=1:nh                
                for ix=1:nw
                    if iy==nh
                        B3=8*(iF13);
                    else
                        B3=by+iy*ny-1;
                    end
                    if ix==nw
                        B4=8*(iF24);
                    else
                        B4=bx+ix*nx-1;
                    end
                    fff=ffY(bx+(ix-1)*nx:B4,by+(iy-1)*ny:B3,:);
                    Ytmp=Yb(bx+(ix-1)*nx:B4,by+(iy-1)*ny:B3,:);
                    Yemd=Ytmp(fff==0);
                    mmean=floor(mean(Yemd(:)));    
                    if ~isnan(mmean)            
                        ffY(bx+(ix-1)*nx:B4,by+(iy-1)*ny:B3,:)=1;
                        if count>length(facePos)
                            break;
                        end
                        if facePos(count)~=mmean
                            if facePos(count)-mmean>1
                                cY(bx+(ix-1)*nx:B4,by+(iy-1)*ny:B3,:)=1;
                            end
                        end
                        count=count+1;
                    end
                end
            end
        end
        color=ones(size(ffY));
        color(:,:,1)=64;
        color(:,:,2)=64;
        color(:,:,3)=64;
        Ym=uint8(double(Yb)+cY.*color);
    end
end

