function[zpos,convimg] = diagdetect(img,filter1,filter2,thresh,peak)

[r1, c1] = size(img);
testconv1 = conv2(img,filter1);
testconv2 = conv2(img,filter2);

[r2, c2] =size(testconv1);

testconv1 = testconv1(r2-r1+1:r1, c2-c1+1:c1);
testconv2 = testconv2(r2-r1+1:r1, c2-c1+1:c1);
testconv3 = testconv1 +testconv2;
testvalue = sort(unique(testconv3(:)),'descend');
testvalue = testvalue(peak);
convimg = testconv3;

if testvalue > thresh

[~, zpos] = find(testconv3 == testvalue);
    if length(zpos)>1
        zpos = zpos(1);
    end
else
    zpos = 0;
end
