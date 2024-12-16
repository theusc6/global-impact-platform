const Joi = require('joi');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const { GraphQLScalarType, Kind } = require('graphql');

const Constraint = new GraphQLScalarType({
  name: 'Constraint',
  description: 'Custom scalar type for constraints',
  serialize(value) {
    // Implement your serialization logic
    return value;
  },
  parseValue(value) {
    // Implement your parsing and validation logic
    if (typeof value !== 'string') {
      throw new TypeError('Constraint must be a string');
    }
    // Add any additional validation logic here
    return value;
  },
  parseLiteral(ast) {
    if (ast.kind !== Kind.STRING) {
      throw new TypeError('Constraint must be a string');
    }
    // Add any additional validation logic here
    return ast.value;
  },
});

const resolvers = {
  Query: {
    me: async (parent, args, { user }) => {
      if (!user) throw new Error('Unauthorized');
      return prisma.user.findUnique({ where: { id: user.id } });
    },
    charity: async (parent, { id }) => {
      return prisma.charity.findUnique({ where: { id: parseInt(id) } });
    },
    charities: async () => {
      return prisma.charity.findMany();
    },
  },
  Mutation: {
    createDonation: async (parent, { input }, { user }) => {
      if (!user) throw new Error('Unauthorized');

      // Validate input
      const schema = Joi.object({
        amount: Joi.number().positive().required(),
        charityId: Joi.string().required(),
      });
      const { error } = schema.validate(input);
      if (error) throw new Error(error.message);

      return prisma.donation.create({
        data: {
          amount: input.amount,
          charityId: parseInt(input.charityId),
          userId: user.id,
        },
      });
    },
  },
  Constraint,
};

module.exports = resolvers;