// Port to serve the website on
const PORT = 8080;

// Import modules
import express from 'express';
import path from 'path';
import url from 'url';

// Initialise express
const app = express();

// Serve anything found in the public dir statically by default
app.use(express.static(path.join(path.dirname(url.fileURLToPath(import.meta.url)), 'static')));

// Redirect root to the index via the primary route
app.get('/', (req, res) => res.redirect('/index.html'));

// TODO: more specific routes

// Start the server
app.listen(PORT, (error) => {
    // Log any errors
    if(error) {
        console.error("Failed to start listening on port " + PORT);
        console.error(error);
        return;
    }

    // Log successful startup
    console.log("Listening on port " + PORT);
});

