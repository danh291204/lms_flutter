import { google } from 'googleapis';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';

// Khởi tạo dotenv để đọc file .env khi chạy ở local
dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// 1. Lấy cấu hình từ biến môi trường
const FOLDER_ID = process.env.DRIVE_FOLDER_ID;
const ENV_KEY = process.env.GOOGLE_SERVICE_ACCOUNT_JSON;

if (!FOLDER_ID) {
    console.error("❌ CẢNH BÁO: DRIVE_FOLDER_ID chưa được định nghĩa.");
}

// 2. Cấu hình xác thực thông minh
const authOptions = {
    scopes: ['https://www.googleapis.com/auth/drive'],
};

if (ENV_KEY) {
    // Ưu tiên sử dụng biến môi trường (Cho Render/Production)
    try {
        authOptions.credentials = JSON.parse(ENV_KEY);
        console.log("🚀 Google Drive Auth: Đang sử dụng Environment Variable.");
    } catch (parseErr) {
        console.error("❌ Lỗi Parse JSON từ GOOGLE_SERVICE_ACCOUNT_JSON:", parseErr.message);
    }
} else {
    // Sử dụng file vật lý nếu không có biến môi trường (Cho Local)
    const keyPath = path.join(__dirname, '../../google-key.json');
    if (fs.existsSync(keyPath)) {
        authOptions.keyFile = keyPath;
        console.log("💻 Google Drive Auth: Đang sử dụng file google-key.json.");
    } else {
        console.error("❌ Lỗi: Không tìm thấy cả biến môi trường lẫn file google-key.json");
    }
}

const auth = new google.auth.GoogleAuth(authOptions);
const drive = google.drive({ version: 'v3', auth });

/**
 * Hàm upload file lên Google Drive
 */
export const uploadToDrive = async (file) => {
    // Kiểm tra đầu vào
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
        // Thực hiện upload
        const response = await drive.files.create({
            requestBody: fileMetadata,
            media: media,
            fields: 'id',
        });

        const fileId = response.data.id;
        console.log(`✅ Upload thành công! File ID: ${fileId}`);

        // Chỉnh quyền xem công khai (Public) cho file vừa upload
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
        // QUAN TRỌNG: Luôn dọn dẹp file tạm để tránh tràn bộ nhớ Host
        if (fs.existsSync(file.path)) {
            try {
                fs.unlinkSync(file.path);
                console.log("🧹 Đã dọn dẹp file tạm trong thư mục uploads.");
            } catch (unlinkError) {
                console.error("Lỗi khi xóa file tạm:", unlinkError);
            }
        }
    }
};