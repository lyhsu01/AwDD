function Y=ScaleExtremePixel(Y,extreme,range)
%{
    Scale extreme pixels in an image
    Input: 
        Y:          Image
        extreme:    New upper and lower extreme pixels
        range:      Affected pixel range
    Output:
        Y:          New image
        
%}

    f=Y<=extreme;
    ff=extreme-floor((extreme-Y)/range);
    Y(f)=ff(f);
    f=Y>(255-extreme);
    ff=(255-extreme)+floor((Y-255+extreme+1)/range);
    Y(Y>(255-extreme))=ff(f);
end