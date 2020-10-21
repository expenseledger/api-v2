import cors from 'cors'

const allowed = cors({
    origin: [
        'http://localhost:3000',
        // 'https://the-prince-98130.web.app',
        // 'https://the-prince-98130.firebaseapp.com',
    ],
})

export default allowed
