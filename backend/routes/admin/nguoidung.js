import express from 'express'
import { prisma } from '../../prisma/client.js'

const router = express.Router()


router.get('/', async (req, res) => {
  try {
    const users = await prisma.nguoidung.findMany()
    res.json(users)
  } catch (err) {
    res.status(500).json({ error: err.message })
  }
})

// ======================
// GET user by id
// ======================
router.get('/:id', async (req, res) => {
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

// ======================
// CREATE user
// ======================
router.post('/', async (req, res) => {
  try {
    const { hoTen, taiKhoan, matKhau, email, vaiTro } = req.body

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

// ======================
// UPDATE user
// ======================
router.put('/:id', async (req, res) => {
  try {
    const id = parseInt(req.params.id)
    const { hoTen, email, trangThai, vaiTro, matKhau } = req.body

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

// ======================
// DELETE user
// ======================
router.delete('/:id', async (req, res) => {
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