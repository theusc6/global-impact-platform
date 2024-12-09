const { SchemaDirectiveVisitor } = require('graphql-tools');
const { defaultFieldResolver } = require('graphql');

class AuthDirective extends SchemaDirectiveVisitor {
  visitFieldDefinition(field) {
    const { resolve = defaultFieldResolver } = field;
    const { requires } = this.args;
    field.resolve = async function (...args) {
      const [, , context] = args;
      const user = context.user;
      if (!user || !user.roles.includes(requires)) {
        throw new Error('Unauthorized');
      }
      return resolve.apply(this, args);
    };
  }
}

module.exports = { AuthDirective };