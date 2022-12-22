import express from 'express';
import fetch from 'node-fetch';

const daprHost = "127.0.0.1";
const daprPortDefault = "3500";

function fibo(n) {
    if (n < 2)
        return 1;
    else return fibo(n - 2) + fibo(n - 1);
}

const app = express();
app.use(express.json());

app.get('/health', (req, res) => {
    res.status(200).send('Ok');
});

app.get('/calculate', async (req, res) => {
    const start = new Date();
    let result = fibo(40);
    const end = new Date();
    const duration = (end - start)/1000;
    res.status(200).send(`Result: ${result} Duration: ${duration} seconds\n`);
});

app.listen(5001);