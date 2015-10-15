// # Ghost Configuration
// Setup your Ghost install for various [environments](http://support.ghost.org/config/#about-environments).

// Ghost runs in `development` mode by default. Full documentation can be found at http://support.ghost.org/config/

var path = require('path'),
  config;

config = {


  // ### Production
  // When running Ghost in the wild, use the production environment.
  // Configure your URL and mail settings here
  production: {
    url: process.env.GHOST_URL,
    mail: {
      transport: 'SMTP',
      options: {
        host: process.env.SES_HOST,
        port: 465,
        service: 'SES',
        auth: {
          user: process.env.SES_KEY,
          pass: process.env.SES_SECRET
        }
      }
    },
    database: {
      client: 'postgres',
      connection: {
        host: process.env.PG_HOST,
        user: process.env.PG_USER,
        password: process.env.PG_PASSWORD,
        database: process.env.PG_DB,
        port: '5432'
      },
    },
    server: {
      host: '127.0.0.1',
      port: '2368'
    },
    storage: {
      active: 'ghost-s3',
      'ghost-s3': {
        accessKeyId: process.env.GHOST_KEY,
        secretAccessKey: process.env.GHOST_SECRET,
        bucket: process.env.GHOST_BUCKET,
        region: process.env.GHOST_REGION,
        assetHost: process.env.GHOST_ASSETHOST
      }
    }
  },

  // ### Development **(default)**
  development: {
    // The url to use when providing links to the site, E.g. in RSS and email.
    // Change this to your Ghost blogs published URL.
    url: 'http://localhost:2368',

    // Example mail config
    // Visit http://support.ghost.org/mail for instructions
    // ```
    //  mail: {
    //      transport: 'SMTP',
    //      options: {
    //          service: 'Mailgun',
    //          auth: {
    //              user: '', // mailgun username
    //              pass: ''  // mailgun password
    //          }
    //      }
    //  },
    // ```

    // #### Database
    // Ghost supports sqlite3 (default), MySQL & PostgreSQL
    database: {
      client: 'sqlite3',
      connection: {
        filename: path.join(__dirname, '/content/data/ghost-dev.db')
      },
      debug: false
    },
    // #### Server
    // Can be host & port (default), or socket
    server: {
      // Host to be passed to node's `net.Server#listen()`
      host: '127.0.0.1',
      // Port to be passed to node's `net.Server#listen()`, for iisnode set this to `process.env.PORT`
      port: '2368'
    },
    // #### Paths
    // Specify where your content directory lives
    paths: {
      contentPath: path.join(__dirname, '/content/')
    }
  },

  // **Developers only need to edit below here**

  // ### Testing
  // Used when developing Ghost to run tests and check the health of Ghost
  // Uses a different port number
  testing: {
    url: 'http://127.0.0.1:2369',
    database: {
      client: 'sqlite3',
      connection: {
        filename: path.join(__dirname, '/content/data/ghost-test.db')
      }
    },
    server: {
      host: '127.0.0.1',
      port: '2369'
    },
    logging: false
  },

  // ### Testing MySQL
  // Used by Travis - Automated testing run through GitHub
  'testing-mysql': {
    url: 'http://127.0.0.1:2369',
    database: {
      client: 'mysql',
      connection: {
        host: '127.0.0.1',
        user: 'root',
        password: '',
        database: 'ghost_testing',
        charset: 'utf8'
      }
    },
    server: {
      host: '127.0.0.1',
      port: '2369'
    },
    logging: false
  },

  // ### Testing pg
  // Used by Travis - Automated testing run through GitHub
  'testing-pg': {
    url: 'http://127.0.0.1:2369',
    database: {
      client: 'pg',
      connection: {
        host: '127.0.0.1',
        user: 'postgres',
        password: '',
        database: 'ghost_testing',
        charset: 'utf8'
      }
    },
    server: {
      host: '127.0.0.1',
      port: '2369'
    },
    logging: false
  }
};

module.exports = config;
