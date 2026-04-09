import { google } from 'googleapis';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv'; // Thêm dòng này

// Khởi tạo dotenv để đọc file .env
dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Kiểm tra xem Folder ID có tồn tại không để tránh lỗi im lặng
const FOLDER_ID = process.env.DRIVE_FOLDER_ID;
if (!FOLDER_ID) {
    console.error("CẢNH BÁO: DRIVE_FOLDER_ID chưa được định nghĩa trong .env");
}

const auth = new google.auth.GoogleAuth({
  // Nếu có biến môi trường (trên Host) thì dùng nó, 
  // nếu không (ở Local) thì đọc từ file json
  credentials: process.env.GOOGLE_KEYS 
    ? JSON.parse(process.env.GOOGLE_KEYS) 
    : undefined,
  keyFile: process.env.GOOGLE_KEYS 
    ? undefined 
    : path.join(__dirname, '../../google-key.json'),
  scopes: ['https://www.googleapis.com/auth/drive'],
});

const drive = google.drive({ version: 'v3', auth });

export const uploadToDrive = async (file) => {
  // 1. Kiểm tra đầu vào
  if (!file || !file.path) {
    throw new Error("Dữ liệu file không hợp lệ");
  }

  const fileMetadata = {
    name: file.originalname,
    parents: FOLDER_ID ? [FOLDER_ID] : [], 
  };

  const media = {
    mimeType: file.mimetype,
    body: fs.createReadStream(file.path),
  };

  try {
    // 2. Upload file
    const response = await drive.files.create({
      requestBody: fileMetadata,
      media: media,
      fields: 'id',
    });

    const fileId = response.data.id;
    console.log(`✅ Đã upload lên Drive: ${fileId}`);

    // 3. Chỉnh quyền công khai (Public)
    try {
      await drive.permissions.create({
        fileId: fileId,
        requestBody: {
          role: 'reader',
          type: 'anyone',
        },
      });
    } catch (permError) {
      console.warn("⚠️ Không thể set quyền công khai, nhưng file đã được upload.");
    }

    return fileId;

  } catch (error) {
    console.error("❌ Drive Upload Error:", error.message);
    throw error;
  } finally {
    // 4. LUÔN LUÔN xóa file tạm bất kể thành công hay thất bại
    if (fs.existsSync(file.path)) {
      try {
        fs.unlinkSync(file.path);
        console.log("🧹 Đã dọn dẹp file tạm.");
      } catch (unlinkError) {
        console.error("Lỗi khi xóa file tạm:", unlinkError);
      }
    }
  }
};