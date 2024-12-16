// application/server/src/schema/typeDefs/index.js
const { gql } = require('apollo-server-express');

const typeDefs = gql`
  scalar Constraint

  directive @auth(requires: Role = USER) on FIELD_DEFINITION

  enum Role {
    ADMIN
    USER
  }

  type Query {
    me: User @auth(requires: USER)
    charities: [Charity!]! @auth(requires: ADMIN)
  }

  # User type definition
  type User {
    id: ID!           # ! means required
    email: String!
    name: String
    donations: [Donation!]  # Array of donations
  }

  # Charity type definition
  type Charity {
    id: ID!
    name: String!
    description: String
    walletAddress: String!
    campaigns: [Campaign!]
  }

  # Define what queries are possible
  type Query {
    me: User                      # Get current user
    charity(id: ID!): Charity     # Get specific charity
    charities: [Charity!]!        # Get all charities
  }

  # Define what mutations (changes) are possible
  type Mutation {
    createDonation(input: DonationInput!): Donation!
  }

  # Input type for donations
  input DonationInput {
    amount: Float!
    charityId: ID!
  }
`;

module.exports = typeDefs;
