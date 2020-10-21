import { Request, Response, NextFunction } from 'express'

import admin from '../lib/firebase'

export default async function checkAuth(
    req: Request,
    res: Response,
    next: NextFunction
) {
    req.auth = { role: 'nologin' }

    const authString = req.headers.authorization
    if (!authString || !authString.startsWith('Bearer ')) {
        req.auth.role = 'nologin'
    } else {
        const token = authString.trim().split(' ')[1]
        try {
            const claims = await admin.auth().verifyIdToken(token)
            req.auth.role = 'authuser'
            req.auth.firebaseUid = claims.uid
        } catch (err) {
            res.status(403).send(JSON.stringify(err))
            return
        }
    }
    next()
}
