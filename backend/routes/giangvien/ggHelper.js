import { v2 as cloudinary } from 'cloudinary';
import fs from 'fs';
import dotenv from 'dotenv';

dotenv.config();

cloudinary.config({ 
  cloud_name: process.env.CLOUDINARY_NAME, 
  api_key: process.env.CLOUDINARY_API_KEY, 
  api_secret: process.env.CLOUDINARY_API_SECRET 
});

export const uploadToCloudinary = async (file) => {
    if (!file || !file.path) {
        throw new Error("Dữ liệu file không hợp lệ");
    }

    try {
        const result = await cloudinary.uploader.upload(file.path, {
            resource_type: "auto", // Tự động nhận diện video, rar, docx, pdf
            folder: "LMS_Project", 
        });

        console.log(`✅ Cloudinary Upload Success: ${result.secure_url}`);

        return result.secure_url; 

    } catch (error) {
        console.error("❌ Cloudinary Error:", error.message);
        throw error;
    } finally {
        // Xóa file tạm trong thư mục uploads/ sau khi upload xong
        if (fs.existsSync(file.path)) {
            try {
                fs.unlinkSync(file.path);
                console.log("Đã dọn dẹp file tạm.");
            } catch (err) {
                console.error("Lỗi xóa file tạm:", err);
            }
        }
    }
};