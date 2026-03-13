import { register } from 'tsx/esm/api'
import { pathToFileURL } from 'url'
import { fileURLToPath } from 'url'
import { dirname, join } from 'path'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

register()

const handlerPath = pathToFileURL(join(__dirname, 'handler.ts')).href
const { default: handler } = await import(handlerPath)

export default handler
