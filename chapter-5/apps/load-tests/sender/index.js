import express from 'express';
import bodyParser from 'body-parser';
import { DaprClient } from '@dapr/dapr';

const DAPR_HOST = process.env.DAPR_HOST || "http://localhost";
const DAPR_HTTP_PORT = process.env.DAPR_HTTP_PORT || "3500";
const APP_PORT = process.env.APP_PORT || "5001";

const app = express();
app.use(bodyParser.json({ type: 'application/*+json' }));

app.get('/health', (req, res) => {
    res.status(200).send('Ok');
});

app.get('/send', async (req, res) => {
    const client = new DaprClient(DAPR_HOST, DAPR_HTTP_PORT);

    const order = {
        orderId: 1
    };

    let response = await client.pubsub.publish("pubsub-loadtest", "load", order);

    res.status(200).send('Ok');
});

app.listen(APP_PORT);