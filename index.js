import Fastify from "fastify";

const fastify = Fastify({
  logger: true,
});

fastify.get("/", async (_request, _reply) => {

  return { hello: "world" };
});

const start = async () => {
  try {
    const host = "0.0.0.0";

    const port = 3000;

    await fastify.listen({ port, host });
  } catch (err) {
    fastify.log.error(err);
    process.exit(1);
  }
};
start();
