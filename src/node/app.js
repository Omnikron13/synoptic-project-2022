// Port to serve the website on
const PORT = 8080;

// Import modules
import ejs from 'ejs';
import express from 'express';
import path from 'path';
import * as pg from 'pg';
import url from 'url';

// Initialise express
const app = express();

// Render with ejs
app.set('view engine', 'ejs');
app.set('views', 'templates');

// Serve anything found in the public dir statically by default
app.use(express.static(path.join(path.dirname(url.fileURLToPath(import.meta.url)), 'static')));

// Redirect root to the index via the primary route
app.get('/', (req, res) => res.redirect('/index.html'));

// Serve any HTML file that isn't static as an EJS template
app.get('/*.html', (req, res) => {
   // Name of the page (without extention)
   var page = req.params[0];

   // Render the template
   res.render('main.ejs', {
      page: page,
      scripts: [],
   });
});

// TODO: more specific routes, e.g. /api/table[/id] or similar


// Connect to the database
// TODO: this should perhaps be moved, and error checking should also be performed
const { Pool } = pg.default;
const db = new Pool();
await db.connect();

// TODO: the api will most likely have a better way to specify the schema
await db.query('SET search_path = flood_dist');

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

