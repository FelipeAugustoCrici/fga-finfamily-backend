import 'dotenv/config'
import { app } from './app'

const PORT = Number(process.env.PORT) || 3333

async function bootstrap() {
  await app.ready()

  console.log('--- ROTAS REGISTRADAS ---')
  console.log(app.printRoutes())
  console.log('-------------------------')

  await app.listen({ port: PORT, host: '0.0.0.0' })
  console.log(`Server running on http://localhost:${PORT}`)
}

bootstrap().catch((err) => {
  app.log.error(err)
  process.exit(1)
})
