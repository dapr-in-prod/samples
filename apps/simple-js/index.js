import express from 'express';

const app = express();
app.use(express.json());

app.get('/health', (req, res) => {
    res.status(200).send('Ok');
});

app.post('/orders', (req, res) => {
    console.log("Order received:", req.body);
    res.sendStatus(200);
});

app.listen(5001);