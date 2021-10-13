import * as dotenv from 'dotenv';
import express from 'express';
import config from './config';
import auth from './middleware/auth';
import cors from './middleware/cors';
import postgraphile from './middleware/postgraphile';

dotenv.config();

const app = express();

app.use(cors);
app.use(auth);
app.use(postgraphile);

app.listen(+config.server.PORT, () => {
    console.log(`Server running at http://localhost:${config.server.PORT}`);
});
