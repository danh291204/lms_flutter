import express from 'express';
import multer from 'multer';
import fs from 'fs';
import path from 'path';
import { prisma } from '../../prisma/client.js';
import { checkGiangVien } from '../middleware.js';
import { uploadToCloudinary } from './ggHelper.js'; 

const router = express.Router();

const uploadDir = path.join(process.cwd(), 'uploads');
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

const upload = multer({ dest: uploadDir });

router.post('/', checkGiangVien, async (req, res) => {
    try {
        let { idKhoaHoc, tenBaiHoc, thuTu } = req.body;
        tenBaiHoc = tenBaiHoc ? tenBaiHoc.trim() : undefined;

        if (!tenBaiHoc) {
            return res.status(400).json({ success: false, message: "Thiếu tên bài học!" });
        }
        if (!idKhoaHoc) {
            return res.status(400).json({ success: false, message: "Thiếu ID khóa học!" });
        }

        const newBaiHoc = await prisma.baihoc.create({
            data: {
                idKhoaHoc: parseInt(idKhoaHoc),
                tenBaiHoc: tenBaiHoc,
                thuTu: thuTu ? parseInt(thuTu) : 1
            }
        });

        return res.status(201).json({ success: true, idBaiHoc: newBaiHoc.idBaiHoc });
    } catch (error) {
        return res.status(500).json({ success: false, error: error.message });
    }
});

router.post('/upload-file/:idBaiHoc', checkGiangVien, upload.single('taiLieu'), async (req, res) => {
    try {
        const { idBaiHoc } = req.params;
        const file = req.file;

        if (!file) {
            return res.status(400).json({ success: false, message: "Chưa chọn file" });
        }

        const secureUrl = await uploadToCloudinary(file);

        const updateData = {};
        if (file.mimetype.startsWith('video/')) {
            updateData.videoUrl = secureUrl;
        } else {
            // Các file .rar, .docx, .pdf sẽ vào đây
            updateData.taiLieuUrl = secureUrl;
        }

        await prisma.baihoc.update({
            where: { idBaiHoc: parseInt(idBaiHoc) },
            data: updateData
        });

        return res.json({ 
            success: true, 
            message: "Upload file thành công!", 
            url: secureUrl 
        });

    } catch (error) {
        console.error("Lỗi Upload:", error);
        return res.status(500).json({ success: false, error: error.message });
    }
});

router.get('/:idKhoaHoc', checkGiangVien, async (req, res) => {
    try {
        const idGiangVien = req.user.idNguoiDung;
        const idKhoaHoc = parseInt(req.params.idKhoaHoc);

        const khoaHoc = await prisma.khoahoc.findFirst({
            where: {
                idKhoaHoc: idKhoaHoc,
                idGiangVien: idGiangVien
            }
        });

        if (!khoaHoc) {
            return res.status(403).json({
                success: false,
                message: "Bạn không có quyền truy cập lớp này"
            });
        }

        const baiHocs = await prisma.baihoc.findMany({
            where: {
                idKhoaHoc: idKhoaHoc
            },
            select: {
                idBaiHoc: true,
                tenBaiHoc: true,
                videoUrl: true,
                taiLieuUrl: true,
                thuTu: true
            },
            orderBy: {
                thuTu: 'asc'
            }
        });
        const kq = baiHocs.map(b=>({
            ...b, loai: b.videoUrl ? 'video' : b.taiLieuUrl ? 'taiLieu' : 'none'
        }));

        res.status(200).json({
            success: true,
            data: kq
        });

    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

export default router;