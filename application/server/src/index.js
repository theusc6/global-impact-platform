// application/server/src/index.js

const express = require('express');
const { ApolloServer } = require('apollo-server-express');
const helmet = require('helmet');
const typeDefs = require('./schema/typeDefs');
const resolvers = require('./schema/resolvers');
const morgan = require('morgan');


async function startServer() {
  const app = express();
  
// Place morgan first to log all incoming requests
  app.use(morgan('combined')); // Logs requests in Apache format

  // Security middleware follows
  app.use((req, res, next) => {
    if (!req.secure) {
      return res.redirect(`https://${req.headers.host}${req.url}`);
    }
    next();
  });

  // Security Enhancements:
  app.use(helmet());  // Adds various HTTP headers for security
  
  const server = new ApolloServer({
    typeDefs,
    resolvers,
    context: ({ req }) => {
      // Security Enhancement: Will add auth context here
      return { req };
    },
    formatError: (error) => {
      // Security Enhancement: Error sanitization
      console.error('GraphQL Error:', error);
      return new Error('Internal server error');
    }
  });

  await server.start();
  
  // Security Enhancement: Configure CORS
  server.applyMiddleware({ 
    app,
    cors: {
      origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
      credentials: true
    }
  });

  const PORT = process.env.PORT || 4000;
  
  app.listen(PORT, () => {
    console.log(`🚀 Server running at http://localhost:${PORT}${server.graphqlPath}`);
  });
}

startServer().catch(console.error);