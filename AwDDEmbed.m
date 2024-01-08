function [Yb,WM]=AwDDEmbed(Y,WM,Key1,Key2,Delta,selidxs)
%{
    AwDD embed watermark WM to image Y.
    Input: 
        Y:          Original image
        WM:         Watermark (logo)
        Key1:       The Key (times) of Arnold transform scrambling algorithm (ATS)
        Key2:       The Key value of Arnold transform scrambling algorithm (ATS)
        Delta:      Quantization step
        selidxs:    Two sets of coefficients
    Output:
        Yb:         Watermarked image
        YM:         Resized watermak(logo)        
%}
    Y=ScaleExtremePixel(double(Y),6,2);
    [bboxes, scores, wboxes, landmarks] =  FaceDetect(Y);

    fY=ones(size(Y,1)/8,size(Y,2)/8,3);
    wmI=1;

    numFace=size(wboxes,1);
    if numFace==0
        L=1;
        Y = rgb2ycbcr(uint8(Y));
        WM=imresize(WM,size(Y,1,2)/8);
        [DCTpsd1ext,DCTpsd2ext,DCTall]=DctAll(Y(:,:,1),selidxs); 
        WM1=Arnoldplus(WM,Key2,0,Key1);
        wwm=WM1(:);
    else
        L=3;
        [DCTpsd1ext,DCTpsd2ext,DCTall]=DctAll(Y,selidxs); 
        ns=ceil(log2(max(size(Y,1)/8,size(Y,2)/8)))+2;
        nb=zeros(numFace,1);
        nbT=0;
        for k = 1:numFace
            iF13=min(wboxes(k,1)+wboxes(k,3),size(fY,2));
            iF24=min(wboxes(k,2)+wboxes(k,4),size(fY,1));
            for iy=wboxes(k,1):iF13+1
                for ix=wboxes(k,2):iF24+1
                    if fY(ix,iy,1) 
                        fY(ix,iy,:)=0;
                        nbT=nbT+1;
                    end
                end            
            end
            nb(k)=nbT-sum(nb);
        end
       
        nf=ceil(ns*4*3);      
        nm=numel(WM);

        nr=(numel(fY)-nm-nf-3*nbT);
        nd=floor(nr/8);    
        TDMV=[];
        ffY=zeros(size(Y));
        for k = 1:numFace
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
                    Ytmp=Y(bx+(ix-1)*nx:B4,by+(iy-1)*ny:B3,:);
                    Yemd=Ytmp(fff==0);
                    mmean=floor(mean(Yemd(:)));
                    if ~isnan(mmean)
                        TDMV=[TDMV,mmean];
                    end
                    ffY(bx+(ix-1)*nx:B4,by+(iy-1)*ny:B3,:)=1;
                end
            end
        end
        TDMVs=de2bi(TDMV,8,'left-msb')';         %%%
        facePos=zeros(1,12);
        facePos(1:numFace*4)=wboxes(:)';
        head = de2bi(facePos,ns,'left-msb');
        ehead = head(:);
        info=Arnoldplus([WM(:);TDMVs(:)],Key2,0,Key1);
        wwm=[ehead(:);info];
    end


    Yb=Y;    
    fYY=fY(:,:,1);
    fYY=fYY([3 2 1:end end-1 end-2],:); 
    fYY=fYY(:,[3 2 1:end end-1 end-2]);
    fC=zeros(size(fY));
    dir=1;ii=1;jj=0;ix=1;iy=1;ik=0; 
    while(wmI<=length(wwm))
        if ik==L 
            if (ix+ii>size(Y,1)/8 || iy+jj>size(Y,2)/8 || (ix+ii==0&&iy>1) || fC(ix+ii,iy+jj,1)==1)
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
            Yemd=EmbedBlock(DCTpsd1ext,DCTpsd2ext,DCTall,fYY,ix,iy,ik,wwm(wmI),selidxs,Delta);   
            fY(ix,iy,ik)=2;
            wmI=wmI+1;
            Yb((ix-1)*8+1:ix*8,(iy-1)*8+1:iy*8,ik)=Yemd;
        end
    end
    Yb=uint8(Yb);
    if numFace==0
        Yb = ycbcr2rgb(Yb);
    end
end

