import { Request } from 'express'
import { postgraphile } from 'postgraphile'
import PgSimplifyInflectorPlugin from '@graphile-contrib/pg-simplify-inflector'

import config from '../../config'

const pg = postgraphile(
    config.postgraphile.APP_CONN,
    config.postgraphile.SCHEMA,
    {
        appendPlugins: [PgSimplifyInflectorPlugin],
        graphiql: true,
        enhanceGraphiql: true,
        pgSettings: async (req: Request) => ({
            role: req.auth?.role,
            'jwt.claims.firebase_uid': `${req.auth?.firebaseUid}`,
        }),
        additionalGraphQLContextFromRequest: async (req, _) => ({
            userId: req.auth?.firebaseUid,
        }),
    }
)

export default pg
