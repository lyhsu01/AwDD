function [bboxes, scores, wboxes, landmarks] =  FaceDetect(Y)
%{
    Detect faces, change the pixel values ​​of the detected 
    faces to block values ​​(8*8) and arrange the detected 
    faces according to their confidence values.
    Input: 
        Y:          Image
    Output:
        bboxes:     Face information(pixel) (left, right, width, height)  
        bboxes:     Confidence values. 
        wboxes:     Face information(block) (left, right, width, height) 
        landmarks:  five position (x,y) for each face        
%}

    prob=0.8;
    Y=uint8(Y);
    [bboxes, scores, landmarks] = mtcnn.detectFaces(Y,'ConfidenceThresholds',[0.6, 0.7, 0.8],'UseDagNet',true,'UseDagNet',true);
    
    bboxes = sortrows([bboxes,scores]);
    wboxes=[];
    delA=[];
    for iFace = 1:size(bboxes,1)
        if bboxes(iFace,5)<prob, delA=[delA,iFace];continue; end
        xx=max(1,ceil(bboxes(iFace,1)/8));
        yy=max(1,ceil(bboxes(iFace,2)/8));
        ww=floor((bboxes(iFace,1)+bboxes(iFace,3))/8)-xx;
        hh=floor((bboxes(iFace,2)+bboxes(iFace,4))/8)-yy;
        wboxes=[wboxes;[xx,yy,ww,hh]];
    end
    if ~isempty(bboxes)
        bboxes(delA,:)=[];
        scores=bboxes(:,5);
        bboxes=bboxes(:,1:4);
    end
end