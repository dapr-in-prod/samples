import express from 'express';
import bodyParser from 'body-parser';
import { DaprClient } from '@dapr/dapr';
import { faker } from '@faker-js/faker';

const DAPR_HOST = process.env.DAPR_HOST || "http://localhost";
const DAPR_HTTP_PORT = process.env.DAPR_HTTP_PORT || "3500";
const APP_PORT = process.env.APP_PORT || "5001";

const app = express();
app.use(bodyParser.json({ type: 'application/*+json' }));

app.get('/health', (req, res) => {
    res.status(200).send('Ok');
});

function createRandomOrder() {
    return {
        orderId: faker.datatype.uuid(),
        email: faker.internet.email(),
        name: faker.name.fullName(),
    };
}

app.get('/send', async (req, res) => {
    const client = new DaprClient(DAPR_HOST, DAPR_HTTP_PORT);

    const pubSubName = req.query.pubsubname || "pubsub-loadtest";
    const count = req.query.count || 1;

    for (var i = 0; i < count; i++) {
        const order = createRandomOrder();
        let response = await client.pubsub.publish(pubSubName, "load", order);
        console.log(`send order ${order.orderId} response ${true}`);
    }

    res.status(200).send(pubSubName);
});

console.log('Sender listening on port %d', APP_PORT);
app.listen(APP_PORT);
