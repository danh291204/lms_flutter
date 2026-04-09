import express from 'express'
import test from './test.js'
import nguoiDungRoutes from './routes/admin/nguoidung.js'
import authRoutes from './routes/auth.js'
import lopHocAdminRoutes from './routes/admin/lophoc.js'
import lopHocHocVienRoutes from './routes/hocvien/lophoc.js'
import lopHocGiangVienRoutes from './routes/giangvien/lophoc.js'
import baiHocGiangVienRoutes from './routes/giangvien/baihoc.js'
import cors from 'cors'

const app = express()
const PORT = process.env.PORT || 5000;

app.use(cors())

app.use(express.json()) 
app.use(express.urlencoded({ extended: true }));

app.use('/admin/nguoidung', nguoiDungRoutes)
app.use('/admin/lophoc', lopHocAdminRoutes)
app.use('/auth', authRoutes)
app.use('/hocvien/lophoc', lopHocHocVienRoutes)
app.use('/giangvien/lophoc', lopHocGiangVienRoutes)
app.use('/giangvien/baihoc',baiHocGiangVienRoutes)
app.use('/', test)

app.listen(PORT, () => {
  console.log('Server chạy ở' + PORT)
})