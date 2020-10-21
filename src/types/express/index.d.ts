declare namespace Express {
    export type AuthRole = 'nologin' | 'authuser'
    export interface Request {
        auth?: {
            role: AuthRole
            firebaseUid?: string
        }
    }
}
