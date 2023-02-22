import express from 'express';
import fetch from 'node-fetch';

import { DaprClient } from '@dapr/dapr';

const DAPR_HOST = process.env.DAPR_HOST || "http://localhost";
const DAPR_HTTP_PORT = process.env.DAPR_HTTP_PORT || "3500";

const app = express();
app.use(express.json());

app.get('/health', (req, res) => {
    res.status(200).send('Ok');
});

app.get('/send', (req, res) => {
    const client = new DaprClient(DAPR_HOST, DAPR_HTTP_PORT);    

    res.status(200).send('Ok');
});

app.listen(5001);