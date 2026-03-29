import express from 'express'
import { prisma } from '../../prisma/client.js'
import { checkAdmin } from '../middleware.js'

const router = express.Router()

router.get('/', checkAdmin, async (req, res) => {
  try {
    const users = await prisma.nguoidung.findMany()
    res.json(users)
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
})

router.get('/:id', checkAdmin, async (req, res) => {
  try {
    const id = parseInt(req.params.id)

    const user = await prisma.nguoidung.findUnique({
      where: { idNguoiDung: id }
    })

    if (!user) {
      return res.status(404).json({ message: 'Không tìm thấy user' })
    }

    res.json(user)
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
})

router.post('/', checkAdmin, async (req, res) => {
  try {
    let { hoTen, taiKhoan, matKhau, email, vaiTro } = req.body
    hoTen = hoTen ? hoTen.trim() : undefined
    taiKhoan = taiKhoan ? taiKhoan.trim() : undefined
    matKhau = matKhau ? matKhau.trim() : undefined
    email = email ? email.trim() : undefined
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

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

    const existing = await prisma.nguoidung.findUnique({
      where: { taiKhoan }
    })

    if (existing) {
      return res.status(409).json({
        success: false,
        message: "Tài khoản đã tồn tại"
      })
    }

    const newUser = await prisma.nguoidung.create({
      data: {
        hoTen,
        taiKhoan,
        matKhau,
        email,
        trangThai: true,
        vaiTro
      }
    })

    res.json(newUser)
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
})

router.put('/:id', checkAdmin, async (req, res) => {
  try {
    const id = parseInt(req.params.id)
    let { hoTen, email, trangThai, vaiTro, matKhau } = req.body
    hoTen = hoTen ? hoTen.trim() : undefined
    matKhau = matKhau ? matKhau.trim() : undefined
    email = email ? email.trim() : undefined
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

    if (!hoTen || !matKhau || !email) {
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

    const updatedUser = await prisma.nguoidung.update({
      where: { idNguoiDung: id },
      data: {
        hoTen,
        email,
        trangThai,
        vaiTro,
        matKhau
      }
    })

    res.json(updatedUser)
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
})

router.delete('/:id', checkAdmin, async (req, res) => {
  try {
    const id = parseInt(req.params.id)

    await prisma.nguoidung.delete({
      where: { idNguoiDung: id }
    })

    res.json({ message: 'Xóa thành công' })
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
})

export default router