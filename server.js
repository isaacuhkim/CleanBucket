// server.js
const express = require('express');
const multer = require('multer');
const path = require('path');
const cors = require('cors');
const spawn = require('child_process').spawn;
const bodyParser = require('body-parser');

const app = express();
const PORT = 5001;

// Middleware
app.use(cors()); // Allow cross-origin requests
app.use(express.static('uploads')); // Serve static files from the 'uploads' folder
app.use(bodyParser.json({ limit: "10mb" }));

// Set up Multer storage configuration
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname)); // Unique file name
  },
  limits: { fileSize: 10485760 }
}); 

const upload = multer({ storage: storage });

// Create 'uploads' folder if it doesn't exist
const fs = require('fs');
const uploadsDir = './uploads';
if (!fs.existsSync(uploadsDir)){
  fs.mkdirSync(uploadsDir);
}
const ai = spawn('/root/bucketbackend/.venv/bin/python', ['img-ai.py']);
// const ai2 = spawn('/root/bucketbackend/.venv/bin/python', ['the-architect.py']);   - the architect has been replaced
const ai3 = spawn('/root/bucketbackend/.venv/bin/python', ['gen-ratings.py']);

const poke = spawn('/root/bucketbackend/.venv/bin/python', ['fetch-agents/pokingAgent.py']);

const send = spawn('/root/bucketbackend/.venv/bin/python', ['fetch-agents/senderAgent.py']);

const recv = spawn('/root/bucketbackend/.venv/bin/python', ['fetch-agents/receiverAgent.py']);



// API Endpoint to upload video file
app.post('/api/upload', upload.single('video'), (req, res) => {
  const py = spawn('/root/bucketbackend/.venv/bin/python', ['vid-recv.py', req.file.filename]);
  console.log('File uploaded successfully ' + req.file.filename);
  if (!req.file) {
    return res.status(400).json({ message: 'No file uploaded' });
  }
  res.json({ message: 'File uploaded successfully', fileName: req.file.filename });
});

// API Endpoint to get the list of uploaded video files
app.get('/api/videos', (req, res) => {
  const py = spawn('/root/bucketbackend/.venv/bin/python', ['top-vids.py']);
  let output;
    py.stdout.on("data", (data) => {
          output += data.toString();
    });
    py.on("close", () => {
        console.log(output);
    });
  console.log('videos requested');
  fs.readdir(uploadsDir, (err, files) => {
    if (err) {
      return res.status(500).json({ message: 'Error reading files' });
    }
    res.json(files);
  });
});

function getMimeType(fileExtension) {
  const mimeTypes = {
    '.mp4': 'video/mp4',
    '.mov': 'video/quicktime',
    '.webm': 'video/webm',
    '.avi': 'video/x-msvideo',
    '.qt' : 'video/quicktime',
  };

  return mimeTypes[fileExtension] || 'application/octet-stream'; // Default MIME type
}

app.get('/api/videos/:fileName', (req, res) => {
  const { fileName } = req.params;
  const filePath = path.join(__dirname, 'uploads', fileName);
  const fileExtension = path.extname(fileName);

  // Get MIME type based on file extension
  const mimeType = getMimeType(fileExtension);

  console.log(`Sending video: ${fileName} with MIME type: ${mimeType}`);

  res.setHeader('Content-Type', mimeType);
  res.sendFile(filePath, (err) => {
    if (err) {
      console.error('Error sending file:', err);
      res.status(500).send('Error sending video file');
    }
  });
});

app.get('/api/topvid', (req, res) => {
  const py = spawn('/root/bucketbackend/.venv/bin/python', ['top-vids.py']);
  let output;
    py.stdout.on("data", (data) => {
          output += data.toString();
    });
    py.on("close", () => {
      const filePath = path.join(__dirname, 'ranks.json');
    
      // Read the file and send it as a JSON response
      fs.readFile(filePath, 'utf8', (err, data) => {
          if (err) {
              return res.status(500).json({ error: 'Error reading file' });
          }
          try {
              const jsonData = JSON.parse(data);
              res.json(jsonData);
          } catch (parseError) {
              res.status(500).json({ error: 'Error parsing JSON data' });
          }
      });
    });
});

app.listen(5001, () => {
  console.log(`Server running on http://localhost:${5001}`);
});
