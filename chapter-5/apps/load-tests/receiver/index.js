import express from 'express';
import bodyParser from 'body-parser';

const app = express();
app.use(bodyParser.json({ type: 'application/*+json' }));

app.get('/health', (req, res) => {
    res.status(200).send('Ok');
});

app.get('/dapr/subscribe', (req, res) => {
    res.json([
        {
            pubsubname: "pubsub-loadtest",
            topic: "load",
            route: "receive"
        }
    ]);
})

app.post('/receive', (req, res) => {
    console.log(req.body.data);
    res.sendStatus(200);
});

app.listen(5002);