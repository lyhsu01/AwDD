function Ym=Deepfake(Yb,Key3)
%{
    Deepfake watermarked image Yb.
    Input: 
        Yb:         Watermarked image
    Output:
        Ym:         Deepfaked watermarked image        
%}

    [bboxes, scores, wboxes] =  FaceDetect(Yb);
    numFace=size(wboxes,1);
    bb=floor([scores,bboxes,wboxes]);
    Ym=Yb;
    if numFace>0
        system(['node deepfake.js ', Key3]);
        Yd=imread('deepfake.png');
        for k = 1:size(bb,1)
            
            s1=max(bb(k,2),1);
            s2=max(bb(k,3),1);
            s3=min(bb(k,2)+bb(k,4),size(Yb,2));
            s4=min(bb(k,3)+bb(k,5),size(Yb,1));
            MSE=sum(mse(Yb(s2:s4,s1:s3,:),Yd(s2:s4,s1:s3,:)));
            if MSE>15
                Ym(s2:s4,s1:s3,:) = pictureMerge(Yb(s2:s4,s1:s3,:),Yd(s2:s4,s1:s3,:),3);
            end
        end
    end
    imwrite(Ym,'deepfake.png');
end


function Y=pictureMerge(img1,img2,v)
    for k=1:4
        if (k==1)
            A=img1(1:v,:,:);
            B=img2(1:v,:,:);
        elseif (k==2)
            A=img1(:,1:v,:);
            B=img2(:,1:v,:);
        elseif (k==3)
            A=img1(end-v:end,:,:);
            B=img2(end-v:end,:,:);
        elseif (k==4)
            A=img1(:,end-v:end,:);
            B=img2(:,end-v:end,:);
        end
        [ma,na,ka]=size(A);
        I1=rgb2gray(A);
        I1=double(I1);
        v1=sum(I1(:));
        I2= rgb2gray(B);
        I2=double(I2);
        v2=sum(I2(:));
     
        K=v1/v2;
        for j=1:v
            d=1-(j)/v;
            if (k==1)
                img2(j,:,:)=img1(j,:,:)*d+(1-d)*img2(j,:,:)*K;
            elseif (k==2)
                img2(:,j,:)=img1(:,j,:)*d+(1-d)*img2(:,j,:)*K;
            elseif (k==3)
                img2(end-v-1+j,:,:)=img1(end-v-1+j,:,:)*d+(1-d)*img2(end-v-1+j,:,:)*K;
            elseif (k==4)
                img2(:,end-v-1+j,:)=img1(:,end-v-1+j,:)*d+(1-d)*img2(:,end-v-1+j,:)*K;
            end
        end
    end
    Y=uint8(img2);
end

