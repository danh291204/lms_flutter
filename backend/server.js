import express from 'express'
import nguoiDungRoutes from './routes/admin/nguoidung.js'
import cors from 'cors'

const app = express()

app.use(cors())

app.use(express.json())

app.use('/admin/nguoidung', nguoiDungRoutes)

app.listen(5000, () => {
  console.log('Server chạy ở port 5000')
})