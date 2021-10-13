import cors from 'cors';

const allowed = cors({
    origin: [
        'http://localhost:3000',
        'https://expense-ledger-web.herokuapp.com',
    ],
});

export default allowed;
