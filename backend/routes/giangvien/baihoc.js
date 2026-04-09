import express from 'express';
import multer from 'multer';
import fs from 'fs';
import path from 'path';
import { prisma } from '../../prisma/client.js';
import { checkGiangVien } from '../middleware.js';
import { uploadToDrive } from './ggHelper.js';

const router = express.Router();

// 1. Cấu hình thư mục uploads tuyệt đối
const uploadDir = path.join(process.cwd(), 'uploads');
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

// 2. Khởi tạo Multer
const upload = multer({ dest: uploadDir });

// 3. THỨ TỰ QUAN TRỌNG: upload.single('file') phải đứng TRƯỚC checkGiangVien
// routes/giangvien/baihoc.js
router.post('/', checkGiangVien, async (req, res) => {
    try {
        const { idKhoaHoc, tenBaiHoc, thuTu } = req.body;
        
        const newBaiHoc = await prisma.baihoc.create({
            data: {
                idKhoaHoc: parseInt(idKhoaHoc),
                tenBaiHoc: tenBaiHoc,
                thuTu: thuTu ? parseInt(thuTu) : 1
                // Các trường URL để trống hoặc null
            }
        });

        res.status(201).json({ success: true, idBaiHoc: newBaiHoc.idBaiHoc });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

router.post('/upload-file/:idBaiHoc', checkGiangVien, upload.single('taiLieu'), async (req, res) => {
    try {
        
        const { idBaiHoc } = req.params;
        const file = req.file;

        if (!file) return res.status(400).json({ success: false, message: "Chưa chọn file" });

        // Upload lên Drive
        const driveFileId = await uploadToDrive(file);
        const driveUrl = `https://drive.google.com/file/d/${driveFileId}/view`;

        // Cập nhật URL vào Database
        const updateData = {};
        if (file.mimetype.startsWith('video/')) {
            updateData.videoUrl = driveUrl;
        } else {
            updateData.taiLieuUrl = driveUrl;
        }

        await prisma.baihoc.update({
            where: { idBaiHoc: parseInt(idBaiHoc) },
            data: updateData
        });

        res.json({ success: true, message: "Upload file thành công!", url: driveUrl });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

export default router;