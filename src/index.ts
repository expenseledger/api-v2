import * as dotenv from 'dotenv'

dotenv.config()

import express from 'express'

import config from './config'
import postgraphile from './middleware/postgraphile'

const app = express()

app.use(postgraphile)

app.listen(+config.server.PORT, () => {
    console.log(`Server running at http://localhost:${config.server.PORT}`)
})
