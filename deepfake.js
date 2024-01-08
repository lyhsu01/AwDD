const axios = require('axios');
const fs = require('fs');
const path = require('path');  // Import the 'path' module
const https = require('https');
const apiKey = process.argv[2];

async function uploadFile() {
  const fileName = 'watermarked.png';
  const fileContent = fs.readFileSync(fileName);

  const formData = new FormData();
  formData.append('files', new Blob([fileContent]), fileName);

  try {
    const response = await axios.post('https://ecepro.niu.edu.tw/tmp/index.php', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });

    console.log('Success:', response.data);
  } catch (error) {
    console.error('Fail:', error.message);
  }
}



async function makeApiRequest(apiKey) {
  const options = {
    method: 'POST',
    method: 'POST',
	url: 'https://faceswap-image-transformation-api.p.rapidapi.com/faceswap',
	headers: {
		'content-type': 'application/json',
		'X-RapidAPI-Key': 'bbffc6a2f5mshcc54233c84b3e32p17c771jsne743eb461112',
		'X-RapidAPI-Host': 'faceswap-image-transformation-api.p.rapidapi.com'
	},
    data: {
      TargetImageUrl: 'https://ecepro.niu.edu.tw/tmp/tmp/watermarked.png',
      SourceImageUrl: 'https://ecepro.niu.edu.tw/tmp/pic.jpg'
    }
  };

  // options.headers['X-RapidAPI-Key'] = apiKey;
  //console.log(options.headers['X-RapidAPI-Key']);
  try {
    const response = await axios.request(options);
	
	const fileUrl = response.data.ResultImageUrl;
	const downloadPath = 'deepfake.png';

	const fileStream = fs.createWriteStream(downloadPath);

	https.get(fileUrl, (response) => {
		response.pipe(fileStream);

		fileStream.on('finish', () => {
			fileStream.close(() => {
				console.log('File downloaded successfully!');
			});
		});
	}).on('error', (err) => {
		console.error(`Error downloading file: ${err.message}`);
	});
    //console.log(response.data);
  } catch (error) {
    console.error(error);
  }
}
async function main() {
  try {
    await uploadFile();
    const apiResponse = await makeApiRequest(apiKey);
    console.log(apiResponse);
  } catch (error) {
    console.error('Error in main:', error);
  }
}

main();
