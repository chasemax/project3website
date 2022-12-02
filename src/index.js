// Need a few libraries. NPM install... ejs, express, knex, and mysql

var express = require('express');
var app = express();

app.set('view engine', 'ejs');

const knex = require('knex')({
    client: 'mysql',
    connection: {
        host: 'rds-is531-docker.ccme3kf5lctp.us-east-2.rds.amazonaws.com',
        port: 3306,
        user: 'is531admin',
        password: 'is531project3docker',
        database: 'BYUIS'
    }
});

app.use(express.static('public'));

app.get('/', function(req, res) {
    knex.select().from('mytable')
        .then((results) => {
            res.render('pages/index', {
                results: results
            });
        });
});

app.listen(8080);
console.log("Server on port 8080");