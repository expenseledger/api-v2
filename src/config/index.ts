const config = {
    postgraphile: {
        SCHEMA: process.env.POSTGRESQL_SCHEMA,
        APP_CONN: process.env.POSTGRAPHILE_APP_CONN,
    },
    server: {
        PORT: process.env.PORT || 5000,
    },
    firebase: {
        SERVICE_ACCOUNT: process.env.FIREBASE_SERVICE_ACCOUNT || 'false',
        DATABASE_URL: process.env.FIREBASE_DATABASE_URL,
    },
}

export default config
