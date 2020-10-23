import * as dotenv from 'dotenv'

dotenv.config()

import express from 'express'

import config from './config'
import postgraphile from './middleware/postgraphile'
import auth from "./middleware/auth";
import cors from "./middleware/cors";

const app = express()

app.use(cors)
app.use(auth)
app.use(postgraphile)

app.listen(+config.server.PORT, () => {
    console.log(`Server running at http://localhost:${config.server.PORT}`)
})
