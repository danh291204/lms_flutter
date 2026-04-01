import express from 'express'
import { prisma } from '../prisma/client.js'

const router = express.Router()
router.post("/login", async (req, res) => {
    try {
        let { taiKhoan, matKhau } = req.body

        taiKhoan = taiKhoan ? taiKhoan.trim() : undefined
        matKhau = matKhau ? matKhau.trim() : undefined

        if (!taiKhoan || !matKhau) {
            return res.status(400).json({
                success: false,
                message: "Vui lòng nhập tài khoản và mật khẩu"
            })
        }

        const nguoiDung = await prisma.nguoidung.findUnique({
            where: { taiKhoan }
        })

        if (!nguoiDung) {
            return res.status(401).json({
                success: false,
                message: "Tài khoản không tồn tại"
            })
        }

        if (matKhau !== nguoiDung.matKhau) {
            return res.status(401).json({
                success: false,
                message: "Mật khẩu không chính xác"
            })
        }
        if (!nguoiDung.trangThai) {
            return res.status(403).json({
                success: false,
                message: "Tài khoản đã bị khóa"
            })
        }
        let duongDan = "/"
        switch (nguoiDung.vaiTro) {
            case "admin":
                duongDan = "/admin"
                break
            case "giangvien":
                duongDan = "/giangvien"
                break
            case "hocvien":
                duongDan = "/khoahoc"
                break
        }

        res.json({
            success: true,
            message: "Đăng nhập thành công",
            user: {
                id: nguoiDung.idNguoiDung,
                hoTen: nguoiDung.hoTen,
                taiKhoan: nguoiDung.taiKhoan,
                vaiTro: nguoiDung.vaiTro
            },
            redirectTo: duongDan
        })

    } catch (error) {
        res.status(500).json({ success: false, message: "Không thể đăng nhập" })
    }
})


router.post("/dangky", async (req, res) => {
    try {
        let { hoTen, taiKhoan, matKhau, email,vaiTro } = req.body
        hoTen = hoTen ? hoTen.trim().replace(/\s+/g, ' ') : undefined
        taiKhoan = taiKhoan ? taiKhoan.trim() : undefined
        matKhau = matKhau ? matKhau.trim() : undefined
        email = email ? email.trim() : undefined

        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
        const nameRegex = /^[a-zA-ZÀ-ỹ\s]+$/

        if (!hoTen || !taiKhoan || !matKhau || !email) {
            return res.status(400).json({
                success: false,
                message: "Vui lòng điền đầy đủ thông tin"
            })
        }

        if (!emailRegex.test(email)) {
            return res.status(400).json({
                success: false,
                message: "Email không hợp lệ"
            })
        }
        if (!nameRegex.test(hoTen)) {
            return res.status(400).json({
                success: false,
                message: "Họ tên chỉ được chứa chữ cái và khoảng trắng"
            })
        }

        const existing = await prisma.nguoidung.findUnique({
            where: { taiKhoan }
        })

        if (existing) {
            return res.status(409).json({
                success: false,
                message: "Tài khoản đã tồn tại"
            })
        }

        const nguoiDungMoi = await prisma.nguoidung.create({
            data: {
                hoTen,
                taiKhoan,
                matKhau,
                email,
                trangThai: true,
                vaiTro: ["giangvien", "hocvien"].includes(vaiTro)
                    ? vaiTro
                    : "hocvien"
            }
        })

        res.status(201).json({
            success: true,
            message: "Đăng ký thành công",
            user: nguoiDungMoi
        })

    } catch (error) {
        res.status(500).json({ success: false, message: "Không thể đăng ký" })
    }
})

export default router