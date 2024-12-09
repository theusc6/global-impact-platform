const jwt = require('jsonwebtoken');

async function startServer() {
  const app = express();

  app.use(helmet());

  // Authentication middleware
  app.use((req, res, next) => {
    const token = req.headers.authorization?.split(' ')[1]; // Bearer token
    if (token) {
      try {
        req.user = jwt.verify(token, process.env.JWT_SECRET); // Ensure JWT_SECRET is set in .env
      } catch (err) {
        console.error('Invalid Token:', err.message);
      }
    }
    next();
  });

  const server = new ApolloServer({
    typeDefs,
    resolvers,
    context: ({ req }) => ({ user: req.user }), // Pass user info to context
    formatError: (error) => {
      console.error('GraphQL Error:', error.message);
      return new Error('Internal server error');
    }
  });

  await server.start();
  server.applyMiddleware({
    app,
    cors: {
      origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
      credentials: true,
    },
  });

  const PORT = process.env.PORT || 4000;
  app.listen(PORT, () => {
    console.log(`🚀 Server running at http://localhost:${PORT}${server.graphqlPath}`);
  });
}

startServer().catch(console.error);

const { gql } = require('apollo-server-express');

const typeDefs = gql`
  type User {
    id: ID!
    email: String!
    name: String
    walletAddress: String
    donations: [Donation!]
  }

  type Charity {
    id: ID!
    name: String!
    description: String
    walletAddress: String!
    campaigns: [Campaign!]
  }

  type Campaign {
    id: ID!
    title: String!
    description: String!
    targetAmount: Float!
    currentAmount: Float!
    charity: Charity!
    donations: [Donation!]
  }

  type Donation {
    id: ID!
    amount: Float!
    currency: String!
    status: DonationStatus!
    donor: User!
    charity: Charity!
    campaign: Campaign
    transactionHash: String
    createdAt: DateTime!
  }

  enum DonationStatus {
    PENDING
    PROCESSING
    COMPLETED
    FAILED
  }

  scalar DateTime

  type Query {
    me: User
    charity(id: ID!): Charity
    charities: [Charity!]!
    campaign(id: ID!): Campaign
    campaigns: [Campaign!]!
    myDonations: [Donation!]!
  }

  type Mutation {
    createDonation(input: DonationInput!): Donation!
    updateDonationStatus(id: ID!, status: DonationStatus!): Donation!
  }

  input DonationInput {
    amount: Float!
    currency: String!
    charityId: ID!
    campaignId: ID
  }
`;

module.exports = { typeDefs };