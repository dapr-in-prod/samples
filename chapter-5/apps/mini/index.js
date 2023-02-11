import express from 'express';
import bodyParser from 'body-parser';

const APP_PORT = process.env.APP_PORT || "5001";

const app = express();
app.use(bodyParser.json({ type: 'application/*+json' }));

app.get('/health', (req, res) => {
    res.status(200).send('Ok');
});

console.log('Mini listening on port %d', APP_PORT);
app.listen(APP_PORT);
