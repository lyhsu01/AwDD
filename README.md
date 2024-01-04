# AI-assisted Deepfake Detection Using Adaptive Blind Image Watermarking

## Abstract
This paper proposes a new adaptive blind watermarking technology for deepfake detection, which can embed deepfake detection information into the image and verify the image's authenticity without requiring additional information. The proposed scheme utilizes mixed modulation combined with partly sign-altered mean value to embed a set of coefficients that enhance robustness against attacks while maintaining high image quality. Additionally, blind adaptive deepfake detection technology with the tamper detection mean value is employed to detect relative positions adaptively, even when face images are slightly modified or deepfaked. To further improve the performance of the proposed scheme, a gray wolf optimizer is introduced to optimize parameters, and a denoising autoencoder is employed to facilitate the identification of extracted watermarks. This technology will adaptively embed watermark information while preserving the original face image, thereby maintaining the authenticity of the face in the image and verifying the owner of the image.

## Installation
## Create a Matlab runtime environment
This project is built on Matlab 2013 with the MTCNN Face Detection toolbox. 
### Install the MTCNN Face Detection Toolbox from:
https://www.mathworks.com/matlabcentral/fileexchange/73947-mtcnn-face-detection/

## Create a Javascript runtime environment
The deepfake image is obtained from Javascript. 
### Install the Javascript runtime environment from:
https://nodejs.org/en
### Install the axios library:
Install the axios library in the same directory.
'''Javascript
npm install axios


