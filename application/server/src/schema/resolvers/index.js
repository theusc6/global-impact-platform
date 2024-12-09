const Joi = require('joi');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

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
};

module.exports = resolvers;