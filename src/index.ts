import * as dotenv from 'dotenv'

dotenv.config()

import express from 'express'

import config from './config'

const app = express()

app.listen(+config.server.PORT, () => {
    console.log(`Server running at http://localhost:${config.server.PORT}`)
})