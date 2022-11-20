import express from 'express';
import fetch from 'node-fetch';

const daprHost = "127.0.0.1";
const daprPortDefault = "3500";

const app = express();
app.use(express.json());

app.get('/health', (req, res) => {
    res.status(200).send('Ok');
});

app.get('/show-secret', async (req, res) => {
    let port = process.env.DAPR_HTTP_PORT ?? daprPortDefault;
    let url = `http://${daprHost}:${port}/v1.0/secrets/secretstore/simple-js-secret`;
    console.log(url);
    try {
        let secret_response = await fetch(url);
        let secret = await secret_response.json();
        return res.status(200).send(secret);
    } catch (error) {
        console.log(error);
    }    
});

app.listen(5001);