import * as admin from 'firebase-admin'

import config from '../config'

admin.initializeApp({
    credential: admin.credential.cert(
        JSON.parse(config.firebase.SERVICE_ACCOUNT) /*|| serviceAccount*/
    ),
    databaseURL: config.firebase.DATABASE_URL,
})

export default admin
